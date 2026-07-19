# Playground 05 — WireLog Analytics

> **Nível**: Intermediário (requer familiaridade com Foundry-21 e C6 bifurcado)
> **Tempo estimado**: 15–20 minutos
> **Foundry version**: ≥ 0.22.0

---

## O que este playground demonstra

1. Como `analytics_provider` (WireLog) e `llm_trace_provider` (LangSmith) **coexistem sem conflito**
2. Os 14 tipos de evento canônicos e quando cada um é emitido
3. Como interpretar o desvio DB ↔ WireLog no relatório mensal (C6.analytics.1)
4. Como a PII guard do adapter impede envio acidental de dados sensíveis
5. Queries de auditoria mensal WireLog

---

## Contexto arquitetural

```
Agente de IA executa
       │
       ├─► LangSmith (llm_trace_provider)
       │     └─ trace completo: prompt, resposta, tokens, custo, latência
       │        → para debugging, custo de inferência, evals
       │
       └─► WireLog (analytics_provider)
             └─ evento de negócio: foundry_outcome_delivered
                → para funis de produto, auditoria de billing, desvio DB↔WireLog
```

**Regra de ouro**: WireLog NÃO vê prompts nem payloads de LLM. LangSmith NÃO agrega funis de outcome nem faz queries de business analytics. Os dois providers são complementares.

---

## Separação de responsabilidades completa

| Provider | Vê | NÃO vê | Usado para |
|---|---|---|---|
| `llm_trace_provider` (LangSmith) | Prompts, respostas, tokens, latência, custo de inferência | Dados de outcome/billing, funis de produto | Debugging, evals, custo por token, detecção de drift de prompt |
| `analytics_provider` (WireLog) | Eventos de negócio (IDs opacos, métricas, enums) | Prompts, payloads de LLM, PII | Funis de outcome, gates, promoções, auditoria mensal, queries agregadas |
| `audit_log_provider` (Postgres) | Mutações críticas (INSERT/UPDATE/DELETE) | Nada extra | Evidência transacional, compliance |
| `structured_logging_provider` (Pino) | Logs operacionais técnicos | Nada extra | Debugging de infra, diagnóstico |

---

## Configuração do projeto (docs/foundry/project.json)

Ver [`docs/foundry/project.json`](./docs/foundry/project.json).

Campos chave:
```json
{
  "telemetry": {
    "llm_trace_provider": "langsmith",
    "analytics_provider": "wirelog"
  }
}
```

---

## Eventos de exemplo

Ver [`events/sample-wirelog-events.jsonl`](./events/sample-wirelog-events.jsonl).

O arquivo contém 10 eventos reais do ciclo de vida de um projeto `agentic_saas`:

1. `foundry_outcome_created` — outcome entra no pipeline
2. `foundry_outcome_delivered` — outcome entregue (com `trace_id` do LangSmith para cruzamento)
3. `foundry_outcome_billed` — billing confirmado
4. `foundry_eval_started` / `foundry_eval_completed` — ciclo de eval
5. `foundry_promotion_requested` / `foundry_promotion_approved` — transição SHADOW→ASSISTED
6. `foundry_gate_failed` — gate 4 (eval_suite_passing) falhou ao tentar ASSISTED→AUTONOMOUS
7. `foundry_reviewer_audit_started` / `foundry_reviewer_audit_completed` — auditoria mensal

**Nota importante**: Todos os eventos usam `tenantIdHash` (sha256 do tenant_id real), nunca `tenantId` cru. O adapter bloqueia automaticamente campos proibidos (PII guard).

---

## Como o cruzamento LangSmith ↔ WireLog funciona

O campo `traceId` em eventos WireLog aponta para um trace no LangSmith:

```json
{
  "eventType": "foundry_outcome_delivered",
  "outcomeId": "outcome_0001",
  "traceId": "ls-trace-001abc"   ← mesmo ID que aparece no LangSmith
}
```

O reviewer DeepAgent usa esse vínculo para:
1. Confirmar que o outcome cobrado tem trace LangSmith (evidência de execução)
2. Cruzar custo de token (LangSmith) com `cost_cents` (WireLog billing)
3. Detectar outcomes sem trace (C6 FAIL)

---

## Queries de auditoria mensal

Ver [`queries/wirelog-monthly-audit.md`](./queries/wirelog-monthly-audit.md).

As queries cobrem:
- Funil completo (created → delivered → billed)
- Gates falhos por tipo
- Desvio DB ↔ WireLog (check C6.analytics.1)
- Verificação de ausência de PII

---

## Exercício prático

1. **Leia** `events/sample-wirelog-events.jsonl` e identifique o evento `foundry_gate_failed`
   - Qual gate falhou? (`gate_4`)
   - Qual o error_code? (`eval_too_old`)
   - O que deve ser feito? (rodar `/novais-digital:eval` com data recente)

2. **Calcule** o desvio hipotético:
   - DB: 47 outcomes delivered no mês
   - WireLog: 46 eventos `foundry_outcome_delivered`
   - Desvio: `|47-46|/47 * 100 = 2.1%` → WARN (≤ 5%)

3. **Verifique** que `sample-wirelog-events.jsonl` não contém campos proibidos:
   - Procure por `email`, `cpf`, `cnpj`, `tenant_id` (sem `_hash`)
   - Todos devem estar ausentes — o adapter bloqueia antes do envio

---

## Diferença WireLog vs LangSmith resumida

```
Pergunta: "Qual o custo de token da última chamada ao Claude?"
→ LangSmith (traces LLM)

Pergunta: "Quantos outcomes foram entregues hoje?"
→ WireLog (analytics_provider)

Pergunta: "O custo de inferência está dentro do limite de 25%?"
→ LangSmith (custo de token) + DB outcomes (volume) + WireLog (billing confirmado)

Pergunta: "Algum gate falhou nas últimas promoções?"
→ WireLog (foundry_gate_failed events)

Pergunta: "O prompt drift causou regressão na eval?"
→ LangSmith (trace das evals) + evals/{id}/runs/ (relatório)
```
