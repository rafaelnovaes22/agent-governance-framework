---
schema_type: wirelog-event-schema
version: "1.0.0"
linked_principles: [C6, C7, C8]
provider: wirelog
foundry_version_required: ">=0.22.0"
---

# WireLog Event Schema — Novais Digital Foundry

> Schema canônico de eventos de negócio/outcomes enviados ao `analytics_provider` (WireLog).
>
> **Papel no Foundry**: WireLog é o `analytics_provider` — rastreia eventos de negócio, funis de lifecycle, gates e auditoria operacional.
> LangSmith é o `llm_trace_provider` — rastreia chamadas LLM, prompts, custo e evals.
> Os dois coexistem e se complementam; nunca um substitui o outro.

---

## Objetivo do schema

Padronizar os eventos enviados ao WireLog de modo que:

1. O reviewer DeepAgent pode fazer queries agregadas sem conhecer detalhes de implementação de cada projeto consumidor.
2. Funis de outcome são comparáveis entre projetos.
3. Gates e promoções são rastreáveis com `trace_id` cruzado com LangSmith.
4. PII/LGPD é bloqueada na origem — adapter recusa eventos com campos proibidos.

---

## Regras de PII / LGPD

### Campos PROIBIDOS em qualquer evento WireLog

| Campo | Por quê é proibido |
|---|---|
| `email` cru | LGPD art. 5º — dado pessoal identificável |
| `cpf` / `cnpj` cru | LGPD art. 5º — dado pessoal sensível |
| `telefone` cru | Dado pessoal identificável |
| Nome completo de cliente | Dado pessoal identificável |
| Payload bruto do usuário | Pode conter qualquer PII |
| API keys / tokens / secrets | Dado sensível de segurança |
| `tenant_id` em claro | Use `tenant_id_hash` (sha256 do tenant_id real) |

### Campos PERMITIDOS

- `tenant_id_hash` — sha256 hexadecimal do `tenant_id` real (primeiros 16 hex aceitáveis)
- `actor_id_hash` — sha256 do ID do usuário/operador
- IDs opacos de outcome, artifact, subscription, run
- Métricas numéricas (custo em centavos, latência em ms, contagens)
- Strings de enum (lifecycle_stage, status, error_code, project_type)
- Timestamps ISO 8601

---

## Eventos mínimos — 14 tipos canônicos

### Categoria: Outcome lifecycle

| Evento | Quando emitir |
|---|---|
| `foundry_outcome_created` | Outcome criado no DB, antes de processamento |
| `foundry_outcome_delivered` | Outcome entregue ao cliente (`status: DELIVERED`) |
| `foundry_outcome_billed` | Outcome faturado / cobrança confirmada |

### Categoria: Eval

| Evento | Quando emitir |
|---|---|
| `foundry_eval_started` | Início de `/novais-digital:eval` |
| `foundry_eval_completed` | Conclusão de `/novais-digital:eval` com `pass_rate` |

### Categoria: Gate / Promotion

| Evento | Quando emitir |
|---|---|
| `foundry_gate_failed` | Gate (1–6) falhou durante `/novais-digital:promote` |
| `foundry_promotion_requested` | Operador inicia `/novais-digital:promote` |
| `foundry_promotion_approved` | Todos os gates passaram, transição registrada |
| `foundry_promotion_blocked` | Promoção bloqueada (gates ou regra de negócio) |

### Categoria: Reviewer / Auditoria

| Evento | Quando emitir |
|---|---|
| `foundry_reviewer_audit_started` | Início de auditoria mensal |
| `foundry_reviewer_audit_completed` | Conclusão de auditoria com overall_status |

### Categoria: Economia / Qualidade

| Evento | Quando emitir |
|---|---|
| `foundry_unit_economics_recalculated` | `/novais-digital:unit-economics` recalculado |

### Categoria: Erros / Feedback

| Evento | Quando emitir |
|---|---|
| `foundry_agent_error` | Erro em execução de agente / skill (não de LLM — esses vão para LangSmith) |
| `foundry_user_feedback` | Feedback humano registrado (aprovação/rejeição em ASSISTED) |

---

## Campos obrigatórios por evento

Todos os eventos **devem** incluir estes campos:

```typescript
{
  eventType: string;           // um dos 14 tipos acima
  projectId: string;           // ID do projeto consumidor
  foundryVersion: string;        // ex: "0.22.0"
  timestamp: string;           // ISO 8601 UTC
}
```

## Campos condicionais recomendados

```typescript
{
  artifactId?: string;         // slug do SKU/módulo/produto
  projectType?: string;        // "agentic_saas" | "platform" | "automation" | "hybrid"
  aiEnabled?: boolean;
  tenantIdHash?: string;       // sha256(tenant_id) — NUNCA tenant_id cru
  actorIdHash?: string;        // sha256(user_id) — NUNCA user_id cru
  lifecycleStage?: string;     // "SHADOW" | "ASSISTED" | "AUTONOMOUS" | "DRAFT" | etc.
  outcomeId?: string;          // ID opaco do outcome no DB
  traceId?: string;            // trace_id do LangSmith correspondente (cruzamento)
  runId?: string;              // ID da run LangSmith
  costCents?: number;          // custo em centavos (inteiro)
  latencyMs?: number;          // latência em milissegundos
  status?: string;             // "ok" | "fail" | "warn" | "pass" | "blocked"
  errorCode?: string;          // enum de erro (snake_case)
  gateId?: string;             // para gate_failed: "gate_1" | "gate_2" | ... | "gate_6"
  fromMode?: string;           // para promotion events
  toMode?: string;             // para promotion events
  passRate?: number;           // 0.0–1.0, para eval events
  overallStatus?: string;      // para audit events: "pass" | "warn" | "fail"
  properties?: Record<string, unknown>;  // extensões não-PII
}
```

---

## Exemplos JSON de eventos canônicos

### Exemplo 1 — `foundry_outcome_delivered`

```json
{
  "eventType": "foundry_outcome_delivered",
  "projectId": "novais-digital",
  "artifactId": "triagem-comercial",
  "projectType": "agentic_saas",
  "aiEnabled": true,
  "tenantIdHash": "a3f9c2e14b8d7f01",
  "lifecycleStage": "AUTONOMOUS",
  "outcomeId": "outcome_0001",
  "traceId": "ls-trace-abc123",
  "runId": "run-xyz789",
  "costCents": 12,
  "latencyMs": 2340,
  "status": "ok",
  "foundryVersion": "0.22.0",
  "timestamp": "2026-05-26T14:32:00Z"
}
```

### Exemplo 2 — `foundry_gate_failed`

```json
{
  "eventType": "foundry_gate_failed",
  "projectId": "novais-digital",
  "artifactId": "triagem-comercial",
  "projectType": "agentic_saas",
  "aiEnabled": true,
  "tenantIdHash": "a3f9c2e14b8d7f01",
  "lifecycleStage": "SHADOW",
  "fromMode": "SHADOW",
  "toMode": "ASSISTED",
  "gateId": "gate_4",
  "status": "fail",
  "errorCode": "eval_too_old",
  "foundryVersion": "0.22.0",
  "timestamp": "2026-05-26T10:15:00Z",
  "properties": {
    "gate_name": "eval_suite_passing",
    "last_eval_age_days": 9
  }
}
```

### Exemplo 3 — `foundry_reviewer_audit_completed`

```json
{
  "eventType": "foundry_reviewer_audit_completed",
  "projectId": "novais-digital",
  "projectType": "agentic_saas",
  "aiEnabled": true,
  "overallStatus": "warn",
  "status": "ok",
  "foundryVersion": "0.22.0",
  "timestamp": "2026-05-31T23:59:00Z",
  "properties": {
    "audit_period": "2026-05",
    "constitution_checks_pass": 7,
    "constitution_checks_warn": 1,
    "constitution_checks_fail": 0,
    "outcomes_sampled": 47,
    "sla_breaches": 0
  }
}
```

---

## Queries de auditoria mensal (WireLog / SQL-like)

Usar estas queries no relatório mensal quando `analytics_provider=wirelog`:

```
-- Funil de outcome (últimos 30 dias)
funnel foundry_outcome_created -> foundry_outcome_delivered -> foundry_outcome_billed
  | filter project_id = '{project_id}'
  | last 30d

-- Outcomes entregues por dia
foundry_outcome_delivered
  | filter project_id = '{project_id}'
  | last 30d
  | count by day

-- Gates falhos por tipo
foundry_gate_failed
  | filter project_id = '{project_id}'
  | last 30d
  | count by properties.gate_id

-- Erros de agente por código
foundry_agent_error
  | filter project_id = '{project_id}'
  | last 30d
  | count by error_code

-- Promoções bloqueadas (investigar causas)
foundry_promotion_blocked
  | filter project_id = '{project_id}'
  | last 90d
  | show eventType, toMode, errorCode, timestamp
```

---

## Regra de desvio (cruzamento DB ↔ WireLog)

O reviewer aplica esta regra mensalmente:

| Métrica | Threshold | Status |
|---|---|---|
| `outcomes_delivered_db` vs `foundry_outcome_delivered` no WireLog | desvio ≤ 1% | PASS |
| `outcomes_delivered_db` vs `foundry_outcome_delivered` no WireLog | desvio ≤ 5% | WARN |
| `outcomes_delivered_db` vs `foundry_outcome_delivered` no WireLog | desvio > 5% | FAIL |

Mesma regra aplica-se para `foundry_outcome_billed` vs entradas de billing no DB.
