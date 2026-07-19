# Walkthrough — PLAYGROUND/04-automation

> Pipeline completo para criar um job RPA determinístico sob o Foundry, do diagnose ao CANONICAL.
> **Duração estimada**: ~20 min de leitura + execução em consumer real.
> **Pré-requisitos**: Foundry v0.13.0+ instalado, `docs/foundry/project.json` declarando `project_type=automation`.

---

## Cenário

Cliente operacional precisa sincronizar pedidos do ERP legado (sem webhooks, sem fila) para o Data Warehouse a cada 6 horas. Sem IA, sem decisão automática — apenas movimentação de dados auditável.

---

## Passo 1 — Diagnóstico (`/novais-digital:diagnose`)

```bash
claude
> /novais-digital:diagnose --project_type=automation --ai_enabled=false
```

Output esperado em `docs/clients/{client_id}/diagnostic.md`:

```yaml
client_id: cliente-erp-sync
project_type: automation
ai_enabled: false
problem_statement: "Pedidos do ERP demoram 24h para refletir no BI; analistas perdem 2h/dia conferindo planilhas."
baseline:
  current_method: "Export manual de CSV + import no warehouse"
  frequency: "1x/dia"
  effort_hours_per_run: 2.0
  cost_per_run_brl: 80.00
  error_rate: "~5% (cancelamentos não refletidos)"
proposed_outcome:
  unit: "synced_record"
  sla: "fresh_within_6h, dedup_rate=100%, audit_completeness=100%"
icp_fit: "high (cliente já paga R$ 2400/mês em horas-homem manual)"
```

**Gate**: po-guardian valida que outcome é `execution_event` verificável (não vago) e ICP fit ≥ medium.

---

## Passo 2 — Spec (`/novais-digital:spec --type=automation-job`)

```bash
> /novais-digital:spec --type=automation-job --client_id=cliente-erp-sync
```

Output em `docs/specs/erp-to-warehouse-sync.md` (gerado a partir de `templates/platform-module-spec.template.md` com adaptações `automation`):

```yaml
artifact_id: erp-to-warehouse-sync
type: automation_job
ai_enabled: false
criticality: B
schedule: "cron:0 */6 * * *"
idempotency_key: "sync_window_start"
payload_schema:
  source: "ERP REST /api/orders?since={timestamp}"
  fields_required: [id, customer_id, total_brl, status, created_at, updated_at]
  fields_pii: [customer_id]
  retention_policy: "warehouse mantém 7 anos; ERP 1 ano"
sink_schema:
  table: synced_orders
  unique_key: dedup_key
log_location: "audit_log table + CloudWatch /automation/erp-sync"
max_retries: 3
retry_backoff: "exponential, base=2s, cap=60s"
dead_letter: "automation_failures table"
acceptance_criteria:
  - "Re-execução produz 0 duplicatas (idempotência)"
  - "Audit log 100% das runs com exit_code, rows_processed, errors[]"
  - "Diff ERP vs warehouse ≤ 5 registros 7d janela"
```

**Gate**: artifact-architect valida que C5 (three-tier) é respeitado — o job é uma só camada de processo, mas separação `src/integrations/erp/`, `src/integrations/warehouse/`, `src/jobs/erp-to-warehouse-sync.ts` é exigida (C7).

---

## Passo 3 — Plan (`/novais-digital:plan`)

```bash
> /novais-digital:plan
```

Plano em `docs/specs/erp-to-warehouse-sync.plan.md` — variante platform (sem seções LLM, sem prompts, sem LANGSMITH):

```markdown
## 1. Arquitetura

src/jobs/erp-to-warehouse-sync.ts       # entrypoint
src/integrations/erp/client.ts          # cliente HTTP autenticado
src/integrations/warehouse/adapter.ts   # SQL adapter (driver-agnostic)
src/infra/audit-log/writer.ts           # audit trail
tests/erp-to-warehouse-sync/unit/       # idempotência, parsing
tests/erp-to-warehouse-sync/integration/ # ERP mock + DB real ephemeral

## 4P. Audit Log (C6.platform)

- Toda função pública grava entry em audit_log:
  - start (run_id, started_at, source_window)
  - per-record-error (run_id, record_id, error_class, retry_count)
  - end (run_id, completed_at, exit_code, rows_processed, errors_summary)
- Retention: 7 anos (LGPD se PII; CVM se financeiro)

## 6P. Cronograma PILOT

- Day 1-3: SHADOW (DRAFT) — job roda em ambiente staging com ERP real read-only
- Day 4-17: PILOT (≥14 dias, criticality B) — produção com gate humano diário
- Day 18+: CANONICAL após audit completo + idempotência verificada

## Riscos

- ERP API rate limit (mitigação: respeitar 429 + retry)
- Janela duplicada se cron disparado manualmente (mitigação: idempotency_key absoluto)
- Schema drift no ERP (mitigação: validação payload_schema no entrypoint, fail-fast)
```

---

## Passo 4 — Tasks (`/novais-digital:tasks`)

DAG platform (Waves 1P-4P + 6P, T6.2P foundry-tests):

```
Wave 1P (scaffolding): src/jobs/ + tests/{module}/unit/ vazios
Wave 2P (service build): erp client + warehouse adapter + job orchestrator
Wave 3P (E2E): tests/{module}/integration/ + tests/{module}/e2e/ (com fixtures)
Wave 4P (PILOT prep): audit_log schema + monitoring dashboard + alerting
Wave 6P (CI/CD):
  T6.1P: foundry-validate.yml ativo
  T6.2P: foundry-test.yml com unit + integration (Postgres ephemeral)
  T6.3P: branch protection
  T6.4P: audit cron mensal
  T6.5P: cicd-checklist.template.md gate_6_status: pass
```

---

## Passo 5 — Implement (`/novais-digital:implement`)

Gera scaffolding com idempotência embutida. Boilerplate de exemplo (`src/jobs/erp-to-warehouse-sync.ts`):

```typescript
import { logger, auditLog } from '@/infra/audit-log/writer'
import { erpClient } from '@/integrations/erp/client'
import { warehouseAdapter } from '@/integrations/warehouse/adapter'

export async function run(syncWindowStart: Date) {
  const runId = crypto.randomUUID()
  const startedAt = new Date()
  await auditLog({ event: 'run.start', run_id: runId, started_at: startedAt, source_window: { start: syncWindowStart } })

  let rowsProcessed = 0
  const errors: any[] = []

  try {
    const records = await erpClient.fetchOrdersSince(syncWindowStart)
    for (const r of records) {
      try {
        // TODO: idempotency key generation derivada de spec
        const dedupKey = `${syncWindowStart.toISOString()}_${r.id}`
        await warehouseAdapter.upsertOrder(dedupKey, r)
        rowsProcessed++
      } catch (e) {
        errors.push({ record_id: r.id, error_class: e.name })
        // TODO: dead-letter se retry esgotar
      }
    }
  } catch (e) {
    errors.push({ scope: 'global', error_class: e.name })
  }

  const exitCode = errors.length === 0 ? 0 : 1
  await auditLog({
    event: 'run.end',
    run_id: runId,
    completed_at: new Date(),
    exit_code: exitCode,
    rows_processed: rowsProcessed,
    errors_count: errors.length
  })
  return exitCode
}
```

**Verificação humana obrigatória** (gate em `/novais-digital:implement`): operador revisa scaffolding, preenche `TODO`s com lógica de domínio antes de marcar Wave 2P completa.

---

## Passo 6 — Tests TDD (`test_agent --mode red`)

Antes do build da Wave 2P:

```bash
> python aios/orchestrator.py test --module erp-to-warehouse-sync --mode red
```

Materializa em `tests/erp-to-warehouse-sync/unit/idempotency.test.ts`:

```typescript
describe('erp-to-warehouse-sync idempotência', () => {
  it('re-executar com mesma sync_window não duplica registros', async () => {
    const window = new Date('2026-05-13T00:00:00Z')
    await run(window)
    const count1 = await warehouseAdapter.countOrders()
    await run(window)
    const count2 = await warehouseAdapter.countOrders()
    expect(count2).toBe(count1) // ZERO duplicatas
  })

  it('audit log contém run.start e run.end para toda execução', async () => {
    const window = new Date('2026-05-13T06:00:00Z')
    await run(window)
    const entries = await auditLog.fetchByWindow(window)
    expect(entries.find(e => e.event === 'run.start')).toBeDefined()
    expect(entries.find(e => e.event === 'run.end')).toBeDefined()
  })
})
```

Operador roda localmente, **confirma que falham (RED)**, depois implementa, depois roda `test --mode verify` e confirma GREEN.

---

## Passo 7 — PILOT (`/novais-digital:promote --to=pilot`)

```bash
> /novais-digital:promote --to=pilot --artifact=erp-to-warehouse-sync
```

6 gates verificados:

1. **G1 spec** — payload_schema declarado, idempotency_key presente
2. **G2 acceptance criteria** — 3 critérios mensuráveis listados
3. **G3 audit log schema** — tabela criada no warehouse
4. **G4 foundry-doctor consumer** — 0 FAIL
5. **G5 eval** — `foundry-test.yml` ativo no PR, idempotência testada (RED→GREEN)
6. **G6 CI/CD checklist** — `gate_6_status: pass`

Aprovação cruzada: artifact-architect + promotion-officer assinam.

---

## Passo 8 — Operação PILOT (14 dias)

Daily checks:

- Audit log completeness: SQL `SELECT count(*) FROM audit_log WHERE event='run.end' AND completed_at > NOW() - INTERVAL '24h'` ≥ 4 (cron 6h)
- Zero duplicatas: `SELECT count(*) FROM synced_orders GROUP BY dedup_key HAVING count(*) > 1` = 0
- Lag aceitável: `SELECT MAX(NOW() - synced_at) FROM synced_orders` ≤ 6h
- Errors taxa: `SELECT SUM(errors_count) / SUM(rows_processed)` < 0.5%

Reviewer DeepAgent mensal compara essas métricas com SLA contratado e gera relatório em `docs/foundry/audits/2026-06.md`.

---

## Passo 9 — Promote to CANONICAL

Após 14 dias com gates verdes:

```bash
> /novais-digital:promote --to=canonical --artifact=erp-to-warehouse-sync
```

Promotion-officer + security-privacy-guardian assinam (PII em customer_id → LGPD review).

**A partir daqui**: job entra em produção operacional. Reviewer mensal monitora drift. Mudanças exigem novo ciclo PILOT.

---

## O que aprendemos com este exemplo

1. **`automation` é subset operacional de `platform`** — todo workflow é similar, mas critério de aceite e gates diferem (idempotência > acceptance UX)
2. **Idempotência é mecanicamente verificável** — TDD RED phase exige teste que falha sem dedup_key absoluto
3. **Audit log substitui telemetry LLM** — toda C6.platform requer entry por run, com retention conforme regulação
4. **CI/CD continua obrigatório** — Gate 6 não é opcional para CANONICAL, mesmo sem IA
5. **Reviewer mensal lê audit log, não outcomes classificados** — métricas são success_rate + idempotência + audit_completeness
6. **Foundry sabe lidar com isso sem IA** — F26 (Foundry-9) formalizou interpretação ramificada de C1-C8

---

## Próximo passo

Voltar ao [`PLAYGROUND/README.md`](../README.md) e escolher próximo exemplo, ou aplicar este pipeline ao seu consumer real seguindo [`INSTALL.md`](../../INSTALL.md).
