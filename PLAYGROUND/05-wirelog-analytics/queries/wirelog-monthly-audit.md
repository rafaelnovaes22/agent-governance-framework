# Queries WireLog — Auditoria Mensal

> Referência de queries para o relatório mensal quando `analytics_provider=wirelog`.
> Executar no dashboard WireLog ou via API read-only.
> Período padrão: últimos 30 dias (`last 30d`).

---

## 1. Funil de outcome (métrica principal)

```
funnel forge_outcome_created -> forge_outcome_delivered -> forge_outcome_billed
  | filter project_id = 'acme-corp-saas'
  | last 30d
```

**Interpretação**:
- Conversão `created → delivered` < 90% → investigar erros de agente
- Conversão `delivered → billed` < 95% → investigar falha de billing

---

## 2. Outcomes entregues por dia (volume / drift)

```
forge_outcome_delivered
  | filter project_id = 'acme-corp-saas'
  | last 30d
  | count by day
```

**Interpretação**:
- Volume cai > 30% vs mês anterior → WARN de drift de volume

---

## 3. Gates falhos por tipo

```
forge_gate_failed
  | filter project_id = 'acme-corp-saas'
  | last 30d
  | count by event_properties.gate_id
```

**Interpretação**:
- `gate_4` (eval_suite_passing) com > 3 falhas → prompt em drift, rodar `/acme:eval`
- `gate_2` (unit_economics) com falhas → recalcular economics

---

## 4. Erros de agente por código

```
forge_agent_error
  | filter project_id = 'acme-corp-saas'
  | last 30d
  | count by error_code
```

---

## 5. Promoções bloqueadas (últimos 90 dias)

```
forge_promotion_blocked
  | filter project_id = 'acme-corp-saas'
  | last 90d
  | show eventType, toMode, errorCode, timestamp
```

---

## 6. Desvio DB ↔ WireLog (check C6.analytics.1)

Para calcular o desvio:

1. Query no DB: `SELECT COUNT(*) FROM outcomes WHERE status='DELIVERED' AND created_at > NOW() - INTERVAL '30 days'`
2. Query WireLog: `forge_outcome_delivered | filter project_id='acme-corp-saas' | last 30d | count`
3. Calcular: `|db_count - wirelog_count| / db_count * 100`
4. Threshold: ≤ 1% PASS / ≤ 5% WARN / > 5% FAIL

---

## 7. Check de PII (amostra)

Query para verificar ausência de PII crua (executar no WireLog dashboard):

```
forge_outcome_delivered
  | filter project_id = 'acme-corp-saas'
  | last 7d
  | limit 20
  | show all_fields
```

Verificar manualmente que NENHUM evento contém:
- `email` / `cpf` / `cnpj` / `telefone`
- `tenant_id` em claro (deve estar como `tenant_id_hash`)
- `nome` / `name` / `full_name`

---

## 8. Custo médio por outcome (C3 cross-check)

```
forge_outcome_delivered
  | filter project_id = 'acme-corp-saas'
  | last 30d
  | avg cost_cents
```

Cruzar com LangSmith:
- LangSmith mostra custo de token por trace
- WireLog mostra `cost_cents` como calculado pelo sistema de billing
- Desvio > 10% entre os dois → investigar cálculo de cost_cents no código
