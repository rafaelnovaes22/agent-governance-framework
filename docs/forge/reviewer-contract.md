# Acme Forge — Contrato com Reviewer Externo (DeepAgents / GPT-5.5)

> **Status**: ⏳ Especificação inicial (Forge-0). Implementação técnica em Forge-3. Atualizado em Forge-9 (delivery-type agnostic) e Forge-21 (analytics_provider WireLog).
> **Versão**: 0.3.0
> **Data**: 2026-05-26

---

## 1. Por que existe um reviewer externo

A metodologia Acme SaaS² exige **independência de modelo** na auditoria mensal (D6.3.1: *"LLM-as-judge independente do modelo de produção"*) e **observabilidade total** (princípio Constitution #6). O reviewer externo:

- Valida que o framework Forge segue a Constitution
- Revisa amostras de outcomes em produção (5–10% conforme D6)
- Audita coerência entre artefatos (`spec.md` vs código vs eval cases)
- Sinaliza drift (degradação de qualidade ao longo do tempo)
- Gera relatório mensal consumível por CEO + Tech Lead

Critério principal: o reviewer **não pode ser Claude** (independência) e precisa **ler tudo** (não apenas amostragem cega).

---

## 2. Identidade do reviewer

| Campo | Valor |
|---|---|
| **Tipo** | Deep Agent (filesystem virtual + planejamento + tools + subagentes) |
| **Modelo** | GPT-5.5 (provedor: OpenAI) |
| **Stack candidata** | Python `deepagents` (Scoras Academy / `Deep_Agents/`) **ou** Node/TS `@langchain/langgraph` (já no projeto) — decisão final em ADR-002 (Forge-3) |
| **Local de execução** | A definir (CI? script local mensal? worker BullMQ?) |
| **Frequência** | Mensal por padrão, eventos críticos podem disparar (a definir em F11) |
| **Custo estimado** | < US$ 30/mês na fase de 1–3 SKUs |

---

## 3. Inputs que o reviewer ingere (contratualmente)

O reviewer **deve** receber acesso a:

### 3.1. Manifest auditável
- **Arquivo**: `docs/forge/manifest.json`
- **Formato**: JSON estruturado com array de artefatos
- **Garantia**: atualizado automaticamente via hook `manifest-sync` (Forge-4)
- **Conteúdo**: para cada artefato — `path`, `type`, `version`, `sha256`, `description`, `owner`, `linked_principles[]`

### 3.2. Project config (NOVO em v0.2.0 — Forge-9; atualizado em v0.3.0 — Forge-21)
- **Arquivo**: `docs/forge/project.json` (no consumidor)
- **Template**: [`templates/project.template.json`](../../templates/project.template.json)
- **Conteúdo crítico**:
  - `project.type` ∈ {`agentic_saas`, `platform`, `automation`, `hybrid`}
  - `project.ai_enabled` (boolean)
  - `economics.model` ∈ {`cost_per_outcome`, `platform_margin`, `hybrid`}
  - `telemetry.llm_trace_provider` — traces LLM (LangSmith/helicone/phoenix/custom/null)
  - `telemetry.analytics_provider` — eventos de negócio/outcomes (wirelog/posthog/segment/custom/null) **[NOVO Forge-21]**
  - `telemetry.{audit_log_provider | structured_logging_provider | metrics_provider | error_tracking_provider}`
  - `modules[]` com overrides per-module (essencial em `hybrid`)
- **Quando ausente**: reviewer aplica defaults retroativos (`agentic_saas` + `ai_enabled=true`) e registra em `audit_metadata.limitations_encountered`
- **Nota sobre analytics_provider**: `null` é valor válido — não bloqueia nenhum projeto. Quando `wirelog`, reviewer aplica checks `C6.analytics.*` conforme `validation-rules.json` v0.4.0.

### 3.3. Constitution
- **Arquivo**: `.claude/CONSTITUTION.md` (versão ≥ 0.3.0 para usar a matriz por `project_type`)
- **Versão referenciada no manifest** garante que reviewer audita contra a constituição vigente

### 3.4. Especificações
- **Arquivos**: `docs/specs/{artifact_id}.md`, `src/skus/*/spec.md`, `src/modules/*/spec.md`, `docs/onda-N/*`
- Reviewer correlaciona spec com implementação. Tipo de spec varia por `project_type`:
  - `agentic_saas` → `templates/platform-sku-spec` ou `templates/product-spec`
  - `platform` → `templates/platform-module-spec`
  - `automation` → `templates/platform-module-spec` (subset)
  - `diagnostic` → `templates/diagnostic-spec` (todos os tipos)

### 3.5. Eval suites OU testes funcionais (conforme ai_enabled)
- **Quando `ai_enabled=true`**: `evals/{artifact_id}/cases/*.json`, `evals/{artifact_id}/runs/*.md`
- **Quando `ai_enabled=false`**: `tests/e2e/reports/{module}-*.json`, `docs/specs/{module}.acceptance-report.md`

### 3.6. Outcomes / Audited actions de produção (amostra)
- **Quando `ai_enabled=true`**: tabela `Outcome` do PostgreSQL (read-only) + traces no `llm_trace_provider`
- **Quando `ai_enabled=false`**: audit log entries do `audit_log_provider` + cross-check com mutações em tabelas de negócio
- **Janela**: 30 dias rolling
- **Amostragem**: 5–10% aleatório por categoria (regra D6)

### 3.7. Traces / Audit logs
- **Quando `ai_enabled=true`**: API do `llm_trace_provider` (`langsmith` / `helicone` / `phoenix` / custom) com chave read-only
- **Quando `ai_enabled=false`**: API do `audit_log_provider` com permissão read-only
- Reviewer correlaciona outcome/ação com trace/audit entry para validar custo, latência, decisão

### 3.8. Documentação Forge
- Tudo em `docs/forge/`

### 3.9. Analytics provider — eventos de negócio (NOVO em v0.3.0 — Forge-21)
- **Quando**: `project.telemetry.analytics_provider == 'wirelog'` (opcional; null desabilita)
- **Acesso necessário**: API WireLog read-only para queries de eventos dos últimos 30 dias
- **O que o reviewer cruza**:
  - `outcomes_delivered_db` ↔ eventos `forge_outcome_delivered` no WireLog: desvio ≤ 1% PASS / ≤ 5% WARN / > 5% FAIL
  - `outcomes_billed_db` ↔ eventos `forge_outcome_billed`: mesma regra
  - Verificação de ausência de PII crua em sample de 20 eventos
  - Eventos `forge_gate_failed` contêm `gate_id`, `artifact_id`, `lifecycle_stage`
- **Separação**: WireLog **não substitui** LangSmith — os dois providers são cruzados no relatório
- **Schema de referência**: [`templates/telemetry/wirelog-event-schema.template.md`](../../templates/telemetry/wirelog-event-schema.template.md)

---

## 4. O que o reviewer valida (checks formais)

Cada check produz **PASS / FAIL / WARN** com evidência citada do manifest.

### 4.1. Checks da Constitution (princípios 1–8)

> A interpretação de cada princípio depende de `project.type` e `module.ai_enabled` (resolvidos a partir de `docs/forge/project.json`). A tabela abaixo lista a versão **agentic** (default histórico). Para a versão **platform/automation** ver detalhe completo em [`reviewer/prompt.template.md`](../../reviewer/prompt.template.md) §"Princípios em detalhe" e em [`reviewer/validation-rules.json`](../../reviewer/validation-rules.json) (seções `common` + `agentic_saas` + `platform` + `automation`).

| # | Check (agentic_saas) | Equivalente platform/automation |
|---|---|---|
| C1 | Diagnose-before-build — cada SKU/produto em produção tem `diagnostic.md` referenciado | Cada módulo CANONICAL ou PILOT crítico tem `diagnostic.md` |
| C2 | Outcome-first — `Cláusula de outcome` com 3+3 exemplos + categorias com threshold | `Cláusula de outcome` com critério de aceite operacional + payload de evento + audit log entry |
| C3 | Cost-per-outcome ≤ 25% (cross-check via LLM trace provider) | Platform margin: (infra + suporte + manutenção) / receita ≤ 25% (`delivery-economics.md`) |
| C4 | SHADOW → ASSISTED → AUTONOMOUS com gates pass + janela ≥ 14 dias em SHADOW | DRAFT → STAGING → PILOT → CANONICAL com testes E2E, aceite humano, audit log e janela ≥ 14d (críticos) ou ≥ 3d (simples) em PILOT |
| C5 | Three-tier — toda skill declara `tier`; herança respeitada | Toda spec de módulo declara `tier_scope`; herança respeitada |
| C6 | Telemetry — toda chamada LLM tem trace; desvio outcomes↔traces ≤ 1% | Auditability — toda mutação crítica tem `auditLog.write`; desvio mutações↔audit_log ≤ 1%; structured_logging + error_tracking configurados |
| C7 | Portability — SDKs LLM apenas em `src/llm/**` ou `src/infra/llm-*.ts` | Portability — SDKs de integração/infra/pagamento apenas em `src/integrations/**` ou `src/infra/**` |
| C8 | Anti-customização — sem `if (tenantId === ...)` ou `clients/{nome}/` | Mesma regra (vale para todos os tipos) — especialmente vigilante em `platform` |

### 4.2. Checks de coerência

| Check | Validação |
|---|---|
| Spec ↔ código | Cada artefato em produção tem spec correspondente em `docs/specs/` |
| Spec ↔ eval / teste | `agentic`: categorias da spec batem com `evals/{id}/cases/`. `platform`: categorias da spec batem com casos de teste E2E |
| Spec ↔ acceptance-report | `platform` apenas: módulos CANONICAL têm `acceptance-report.md` assinado |
| ADR ↔ implementação | ADRs assinadas refletem o stack real |
| Outcome / Action ↔ trace / audit | `agentic`: `Outcome.id` tem `trace_id`. `platform`: cada mutação crítica tem entrada no audit log |

### 4.3. Checks de qualidade

| Check | Validação (`ai_enabled=true`) | Validação (`ai_enabled=false`) |
|---|---|---|
| SLA mensal | Acurácia auditada ≥ threshold | Pass rate de aceite humano ≥ threshold |
| Drift detection — qualidade | Acurácia mês N vs N-1: queda >5pp = WARN | Pass rate de aceite mês N vs N-1: queda >5pp = WARN |
| Drift — custo | Custo médio outcome mês N / N-1 > 1.15 = WARN | Platform cost-to-revenue ratio mês N / N-1 > 1.15 = WARN |
| Eval / teste freshness | `evals/{id}/cases/` atualizado ≤ 90 dias | `tests/e2e/reports/{module}-latest.json` ≤ 7 dias; `acceptance-report.md` ≤ 90 dias |

---

## 5. Output esperado do reviewer

### 5.1. Relatório mensal

**Arquivo**: `docs/forge/audits/{YYYY-MM-DD}-monthly.md`

**Estrutura**:

```markdown
# Auditoria Mensal Forge — {YYYY-MM-DD}

## Resumo executivo
- ✅ Constitution: 7/8 PASS, 1 WARN (C3 marginal)
- ✅ SLA mensal: 87% (threshold 85%) — PASS
- ⚠️ Drift: queda 6pp em SKU triagem-comercial — investigar
- ❌ Coerência: spec X não bate com código — abrir issue

## Detalhamento por check
[uma seção por check com evidência citada do manifest]

## Anomalias amostradas (5 outcomes auditados)
[outcomes com decisão agente vs gabarito humano lado a lado]

## Recomendações
[ações priorizadas]

## Próxima auditoria: {YYYY-MM-DD}
```

### 5.2. Output machine-readable

**Arquivo**: `docs/forge/audits/{YYYY-MM-DD}-monthly.json`

```json
{
  "audit_date": "2026-05-31",
  "reviewer": "deepagents-gpt-5.5",
  "constitution_version": "0.1.0",
  "manifest_version": "0.3.2",
  "checks": [
    {"id": "C1", "status": "PASS", "evidence": "..."},
    {"id": "C3", "status": "WARN", "evidence": "razão custo/preço = 24.8% (limiar 25%)"}
  ],
  "drift_detected": false,
  "skus_audited": ["example-triagem-whatsapp"],
  "outcomes_sampled": 47,
  "issues_opened": []
}
```

### 5.3. Issues acionáveis

Quando encontrar FAIL, reviewer **abre issue** (GitHub ou tabela DB) com:
- Título conciso
- Check violado (referência Constitution)
- Evidência (path + linha do artefato problemático)
- Severidade (P0/P1/P2)
- Owner sugerido (PO Guardian, SKU Architect, etc.)

---

## 6. Garantias do framework para o reviewer

Para o reviewer funcionar de forma confiável, o Forge **garante**:

1. **Manifest sempre fresh**: hook `manifest-sync` atualiza em todo commit que toca `.claude/`, `docs/forge/`, `src/skus/`, `evals/`
2. **Versionamento explícito**: cada artefato no manifest tem `version` e `sha256`
3. **Read-only access**: reviewer **nunca** edita arquivos do projeto — só lê e gera novos arquivos em `docs/forge/audits/`
4. **Idempotência**: rodar o reviewer 2x no mesmo dia produz output idêntico (a menos que dados de produção mudem)
5. **Bypass auditado**: se algum dev usar `ACME_FORGE_BYPASS=incident`, fica registrado em `docs/forge/bypass-log/` que o reviewer **lê e cita** no próximo relatório

---

## 7. O que o reviewer NÃO faz (out-of-scope)

- ❌ Não bloqueia merges (isso é trabalho dos hooks Claude Code)
- ❌ Não substitui code review humano de PRs
- ❌ Não toma decisões automáticas (não promove subscription, não muda pricing)
- ❌ Não acessa dados sensíveis de tenants além do necessário para sample auditing
- ❌ Não executa código (só lê estado e logs)

---

## 8. Sequência de execução padrão (mensal)

```
1. Hook ou cron dispara reviewer no último dia útil do mês
2. Reviewer faz fetch:
   - manifest.json
   - constitution
   - últimos 30d de outcomes (DB query read-only)
   - traces LangSmith correspondentes
   - eval reports
3. Reviewer gera plano de auditoria (Deep Agent planning step)
4. Reviewer roda os checks (4.1, 4.2, 4.3) em ordem
5. Reviewer amostra 5–10% dos outcomes e re-classifica
6. Reviewer compara classificação humana (gabarito) vs agente vs reviewer
7. Reviewer gera relatório markdown + JSON
8. Reviewer commita relatório em docs/forge/audits/ via PR (não direto na main)
9. Reviewer notifica CEO + Tech Lead (canal a definir)
```

---

## 9. Versionamento deste contrato

Mudanças neste contrato exigem:
- Nova ADR (ADR-003+ na sequência)
- Atualização da `version` do reviewer no manifest
- Comunicação ao reviewer (via update do prompt do Deep Agent)

---

## 10. Estado atual (2026-04-30)

- ✅ Contrato especificado (este documento)
- ⏳ Implementação técnica: Forge-3 (ADR-002)
- ⏳ Primeira auditoria de teste: após Forge-3 concluído
- ⏳ Primeira auditoria real: 1 mês após primeiro SKU em SHADOW
