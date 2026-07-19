# PLAYGROUND/04-automation — Job RPA determinístico (sync ERP → Warehouse)

> Exemplo didático do Foundry para `project_type: automation`, `ai_enabled: false`.
> Inspirado em casos reais de integração operacional (CAPSYSTEM/SchoolPlatform operacional, sem IA).

---

## Outcome contratual

**O job sincroniza pedidos novos do ERP para o Data Warehouse a cada 6 horas, com idempotência forte e audit log completo.**

- **Outcome unit**: `synced_record` (1 registro = 1 pedido do ERP gravado/atualizado no warehouse)
- **Critério de aceite operacional**: ao final de cada execução, `audit_log` registra `rows_processed`, `errors[]` e `exit_code`. Zero erros + diff entre ERP e warehouse ≤ 5 registros (lag aceitável) = sucesso.
- **Pricing**: R$ 0,05 por registro sincronizado (custo de infra + monitoramento + suporte ≤ 25% conforme C3.platform)

---

## Por que `automation` e não `platform`?

| Aspecto | `platform` | `automation` (este caso) |
|---|---|---|
| Apresentação | UI/API consumida por usuário final | Job/worker sem UI |
| Trigger | Síncrono (request) | Síncrono ou agendado (cron) |
| Outcome | `operational_action` (ação visível) | `execution_event` (evento auditável) |
| Lifecycle | DRAFT → STAGING → PILOT → CANONICAL | mesmo, mas testes de pilot focados em **idempotência sob retry**, não UX |
| Métrica chave | latency p95 + acceptance gate | success_rate + dedup + audit_completeness |

**Critério de decisão**: se o entregável é **um evento auditável** consumido por sistema downstream (ERP, BI, fila), use `automation`. Se é **uma ação operacional** consumida por humano (tela, API, dado em CRM), use `platform`.

---

## Stack referência (não-prescritivo)

| Camada | Tecnologia |
|---|---|
| Runtime | Node.js 20 (TypeScript) ou Python 3.12 |
| Scheduler | GitHub Actions cron, AWS EventBridge, ou cron nativo |
| Source (ERP) | API REST autenticada (OAuth2 ou API Key em vault) |
| Sink (Warehouse) | PostgreSQL (`COPY` ou `INSERT ... ON CONFLICT`) ou BigQuery |
| Audit log | Pino → ELK ou CloudWatch + tabela `automation_runs` no warehouse |
| Idempotência | `sync_window_start` timestamp como dedup key |
| Retries | Exponential backoff, max 3 tentativas, dead-letter no log |
| Observabilidade | Sentry para erros + métricas Prometheus (`automation_runs_total`, `automation_rows_processed`) |

**C7 (portabilidade)**: nenhum SDK acoplado. ERP via cliente HTTP genérico (`fetch` ou `requests`); warehouse via driver SQL padrão. Trocar Postgres por BigQuery exige apenas reescrita do adapter em `src/integrations/warehouse/`.

---

## Conceitos-chave (`automation`)

### Idempotência (não-negociável)

Job pode ser **re-executado a qualquer momento** sem duplicar registros. Implementação:

```typescript
// Dedup por window + record_id
const dedup_key = `${sync_window_start}_${erp_record.id}`
await warehouse.query(`
  INSERT INTO synced_orders (dedup_key, payload, synced_at)
  VALUES ($1, $2, NOW())
  ON CONFLICT (dedup_key) DO NOTHING
`, [dedup_key, JSON.stringify(erp_record)])
```

Reviewer DeepAgent **bloqueia** promoção para CANONICAL se idempotência não for verificável (audit log mostra duplicatas em retry).

### Audit log obrigatório (C6.platform)

Toda execução grava:

```json
{
  "run_id": "uuid",
  "module_id": "erp-to-warehouse-sync",
  "started_at": "2026-05-13T06:00:00Z",
  "completed_at": "2026-05-13T06:02:34Z",
  "exit_code": 0,
  "rows_processed": 1247,
  "errors": [],
  "source_window": {
    "start": "2026-05-13T00:00:00Z",
    "end": "2026-05-13T06:00:00Z"
  },
  "warehouse_lag_seconds": 18
}
```

Retention 7 anos (LGPD/CVM se houver dados regulados). Nunca registra payload completo dos pedidos no log — só metadata + IDs.

### Critério de aceite para `current_stage: pilot`

- Mínimo **14 dias** de execuções consecutivas (≥ 56 ciclos de 6h)
- ≥ 99.5% das execuções com `exit_code: 0`
- Zero divergência entre ERP e warehouse no fim de cada janela (verificação automática semanal)
- Audit log 100% completo (nenhum run sem entrada correspondente)

Se qualquer um falhar, `/novais-digital:promote --to=canonical` é bloqueado.

---

## Pipeline canônico para este exemplo

```
1. /novais-digital:diagnose --project_type=automation --ai_enabled=false
   ↓
2. /novais-digital:spec --type=automation-job
   ↓ (gera docs/specs/erp-to-warehouse-sync.md com payload_schema + log_location)
3. /novais-digital:plan (variante platform — sem prompts, sem LANGSMITH)
   ↓
4. /novais-digital:tasks (Waves 1P-4P + 6P; T6.2P foundry-tests para idempotência)
   ↓
5. /novais-digital:implement (scaffolding worker + audit log + retry)
   ↓
6. PILOT por 14 dias (gates humanos diários + verificação automática)
   ↓
7. /novais-digital:promote --to=canonical
```

---

## Diferenças críticas vs PLAYGROUND/01 (agentic) e /02 (platform UI)

| Aspecto | 01-agentic-saas-agent | 02-platform-module | **04-automation (este)** |
|---|---|---|---|
| `ai_enabled` | true | false | false |
| Outcome | classified_outcome (LLM) | operational_action (UI/API) | execution_event (job log) |
| C3 audita | tokens vs preço | infra+suporte vs receita | infra+suporte+monitoramento vs receita |
| C4 lifecycle | SHADOW→ASSISTED→AUTONOMOUS | DRAFT→PILOT→CANONICAL | DRAFT→PILOT→CANONICAL (idempotência-focused) |
| C6 telemetria | LANGSMITH trace | structured logs + audit | audit log com retenção 7 anos |
| Critério promoção | Eval LLM ≥ 90% | Acceptance report assinado | 14d runs + idempotência + audit completo |
| Hook crítico | `langfuse-trace-check` | `audit-trail-check` (futuro) | `idempotency-check` (futuro) |

---

## Próximo passo

Veja [`walkthrough.md`](./walkthrough.md) para o pipeline completo passo-a-passo (~20 min).

---

## Bibliografia interna

- F26 (Foundry-9) — delivery-type agnostic
- `templates/project.template.json` — schema declarativo
- `templates/platform-module-spec.template.md` — adaptável a `automation-job` via `type_compatibility_matrix`
- `docs/foundry/manifest.json → framework.supported_project_types[automation]`
