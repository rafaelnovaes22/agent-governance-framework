---
description: Promove modo de uma subscription (start_shadow | shadow_to_assisted | assisted_to_autonomous | rollback). Valida 5 gates obrigatórios (C2 pass, C3 viable, SLA pré-contratada, eval suite passing, aprovação cruzada PO + Promotion Officer). Invoca @shadow-mode-runner conforme transição. Persiste em subscriptions/{id}/promotions.md com signature_hash.
allowed-tools: [Read, Write, Glob, Grep]
arguments:
  required:
    - subscription_id
    - to_mode
  optional:
    - artifact_id
    - approver_po
    - approver_promotion_officer
    - rollback_reason
forge_command_version: 0.1.0
linked_principles: [C1, C2, C3, C4, C6]
invokes_skills:
  - "@offerings-loader"
  - "@shadow-mode-runner"
output_artifact: subscriptions/{subscription_id}/promotions.md
trace_required: true
human_approval_required: true
gate_count: 5
---

# /acme:promote — Transição de modo (C4 enforcement)

## Propósito

Único caminho legítimo para mudar `subscription.mode`. Implementa o gate completo de **C4 (SHADOW antes de cobrar)** com 5 validações e **aprovação cruzada humana** mandatória. Esta é a command que pode iniciar SHADOW (a única — nem `/acme:implement` nem qualquer skill faz isso).

Transições suportadas:

| Transição (`to_mode`) | De | Validações específicas |
|---|---|---|
| `start_shadow` | `none` | Todas as 6 precondições de `@shadow-mode-runner.start` |
| `shadow_to_assisted` | `shadow` | Janela ≥ window_days E agreement >= threshold E eval pass |
| `assisted_to_autonomous` | `assisted` | Tempo mínimo ASSISTED + auditoria de aprovação humana ≥ X% |
| `rollback` | qualquer | Reason obrigatória; rebaixa um nível |

## Pre-conditions

1. `subscriptions/{subscription_id}/` existe com estado atual conhecido
2. `docs/specs/{artifact_id}.md` (resolvido via subscription) com `c2_validation: pass` e `c4_thresholds`
3. `docs/clients/{client_id}/baseline-cost-*.md` com `c3_check.status` ∈ {viable, tight}
4. `evals/{artifact_id}/runs/` com run recente (≤ 7 dias) e `status: pass`
5. `--approver_po` e `--approver_promotion_officer` declarados (roles distintos)
6. Tracing configurado

## Inputs

```yaml
subscription_id: <slug>
to_mode: start_shadow | shadow_to_assisted | assisted_to_autonomous | rollback
# opcionais
artifact_id: <slug>                  # auto-resolve via subscription
approver_po: <nome|role>             # PO Guardian (Forge-3)
approver_promotion_officer: <nome|role> # Promotion Officer (Forge-3)
rollback_reason: <enum + texto>      # obrigatório se to_mode=rollback
```

## Os 5 gates

A command **não** executa transição se qualquer gate falhar:

### Gate 1 — C2 (cláusula de outcome)
- `spec.c2_validation: pass`
- `spec.outcome_clause` presente com 3+3 exemplos + `trigger_event`
- `prompt.outcome_clause_hash == spec.outcome_clause_hash` (rastreabilidade)

### Gate 2 — C3 (unit economics viável)
- `baseline-cost.c3_check.status` ∈ {viable, tight}
- `prompts/{id}/v{ver}/system.md` mais recente: `recalc_unit_economics_required: false`
- (se mudou prompt sem recalc → falha gate)

### Gate 3 — SLA pré-contratada (C4 estrutural)
- `spec.c4_thresholds` presente com `signature_hash` (output de `/acme:sla-threshold`)
- `c4_thresholds.min_window_days >= 14`
- `c4_thresholds.cost_per_outcome_max <= human_cost_per_unit`

### Gate 4 — Eval suite passing
- Run de `/acme:eval` em ≤ 7 dias com `status: pass`
- `prompt_hash` do eval == `prompt_hash` em produção (sem drift de prompt entre eval e deploy)
- `pass_rate >= c4_thresholds.agreement_rate_min` em **todas** as categorias

### Gate 5 — Aprovação cruzada humana
- `approver_po != approver_promotion_officer` (sem self-approval)
- `signature_hash` do PO + `signature_hash` do Promotion Officer registrados
- Para `assisted_to_autonomous`: + assinatura do `security-privacy-guardian` (Forge-3)

## Execução

```
1. Trace start

2. Helpers:
   - @offerings-loader (validar artifact_id, lifecycle_stage compatível com to_mode)

3. Carregar estado atual:
   - subscriptions/{subscription_id}/state.{md|json} → mode, started_at, history
   - artifact_id (resolvido)
   - spec, baseline-cost, eval recente

4. Validar transição é legal:
   - none → shadow (start_shadow)
   - shadow → assisted (shadow_to_assisted)
   - assisted → autonomous (assisted_to_autonomous)
   - * → (uma camada abaixo) (rollback)
   Se ilegal → error: illegal_transition

5. Rodar os 5 gates:
   - Cada gate retorna { passed: bool, reason: string, evidence: { ... } }
   - Se algum falhar → status: gates_failed; report list de gates failed; SEM transição

6. Se to_mode=start_shadow:
   - Invocar @shadow-mode-runner.start (precondições já checadas; skill faz check próprio)
   - Sucesso → mode: shadow; persistir window dates

   Se to_mode=shadow_to_assisted:
   - Invocar @shadow-mode-runner.report (já não pode ter bug de window incompleta)
   - Validar recommendation: promote_to_assisted
   - Sucesso → mode: assisted

   Se to_mode=assisted_to_autonomous:
   - Validar audit_trail dos últimos N runs em ASSISTED com aprovação humana ≥ 90%
   - Sucesso → mode: autonomous

   Se to_mode=rollback:
   - rebaixar um nível; registrar rollback_reason
   - Disparar incident notification

7. Persistir subscriptions/{subscription_id}/promotions.md (append-only log)
   + atualizar subscription state

8. Trace end + output structured
```

## Estrutura canônica do promotions.md (append-only)

```markdown
---
subscription_id: <>
artifact_id: <>
log_format: append-only
total_transitions: 3
---

## Transition 3 — 2026-05-12 — shadow → assisted

- prompt_hash: a3f9...c2e1
- gates:
  - c2_outcome_clause: { passed: true, evidence: spec_v0.1.1, hash_match: true }
  - c3_unit_economics: { passed: true, status: viable, recalc_required: false }
  - c4_sla_pre_contracted: { passed: true, signature_hash: 8b2c... }
  - eval_suite_passing: { passed: true, run: 2026-05-10-eval-a3f9.md, pass_rate: 0.91 }
  - human_approval: { passed: true, po: rafael (8b...), promo_officer: ana (4e...) }
- shadow_report: runs/<>/shadow/report-<>-2026-05-12.md
- recommendation: promote_to_assisted
- approved_at: 2026-05-12T14:33

## Transition 2 — 2026-04-30 — none → shadow
...
```

## Output structured

```yaml
command: /acme:promote
status: ok | gates_failed | illegal_transition | error
subscription_id: <>
artifact_id: <>
from_mode: shadow
to_mode: assisted
gates_status:
  c2_outcome_clause: pass
  c3_unit_economics: pass
  c4_sla_pre_contracted: pass
  eval_suite_passing: pass
  human_approval: pass
gates_passed: 5
gates_failed: 0
gate_failures: []
shadow_runner_outcome: { ... }   # se start_shadow ou shadow_to_assisted
human_approvals:
  po: { name, signature_hash, approved_at }
  promotion_officer: { name, signature_hash, approved_at }
promotions_log_path: subscriptions/<>/promotions.md
trace_id: <>
generated_at: 2026-04-30T...
next_step: "monitorar dashboards e rodar /acme:audit-monthly"
```

## Verification gate

- [x] Transição legal verificada
- [x] **5 gates** rodados; output declara cada um com evidence
- [x] Sem self-approval (`approver_po != approver_promotion_officer`)
- [x] `signature_hash` registrado para cada aprovador
- [x] `prompt_hash` em produção == `prompt_hash` do eval recente
- [x] Append-only log atualizado (não sobrescrita)
- [x] Subscription state atualizado **APÓS** persistência do log
- [x] Trace_id não-nulo
- [x] Para `rollback`: `rollback_reason` ∈ enum válido

## Tabela anti-rationalization

| Tentação | Por que é errado | Resposta correta |
|---|---|---|
| "Cliente urgente, pulo aprovação cruzada" | C4 estrutural; checks-and-balances comercial × engenharia | Bloquear; bypass exige `ACME_FORGE_BYPASS=incident` (Forge-4) com log auditado |
| "Eval do mês passado vale" | Drift de prompt/dados entre eval e deploy é causa #1 de regressão | `<= 7 dias` hard rule; novo `/acme:eval` mandatório |
| "Aprovo eu mesmo nas duas roles" | Anula checks-and-balances | Lint detecta `approver_po == approver_promotion_officer`; bloqueia |
| "Pular gate 3 (SLA) — cliente já aceitou verbal" | SLA verbal sem `signature_hash` é frágil legal/comercialmente | Exigir output formal de `/acme:sla-threshold` com hash |
| "ASSISTED → AUTONOMOUS sem ASSISTED extenso" | Pula validação humana por amostra que confirma SHADOW | `assisted_to_autonomous` exige ≥ 30 dias em ASSISTED + ≥ 90% aprovação humana |
| "Promover sem rodar shadow_runner.report — já estou olhando dashboards" | Skill calcula recomendação com regras consistentes; visual ≠ rigor | `shadow_to_assisted` invoca `@shadow-mode-runner.report` mandatoriamente |
| "Rollback sem reason — está óbvio" | Audit trail sem reason vira black box | `rollback_reason` ∈ enum: `sla_breach | incident | data_quality | regulatory | client_request` + texto |
| "Auto-promover quando gates passam por X dias" | Promoção automática quebra C4 (aprovação humana explícita) | Skill produz **status: ok com recommendation**; humano dispara o command com flags `--approver_*` |

## Saída de erro estruturada

```yaml
command: /acme:promote
status: error | gates_failed
error: <enum>
gate_failures: [...]   # lista detalhada
hint: <ação>
trace_id: <>
```

`error` ∈ `pre_conditions_failed` | `illegal_transition` | `gates_failed` | `eval_too_old` (>7 dias) | `prompt_hash_drift_eval_vs_prod` | `self_approval_attempted` | `recalc_unit_economics_pending` | `subscription_state_inconsistent` | `subscription_unwritable`.

## Histórico

| Versão | Data | Mudança |
|---|---|---|
| 0.1.0 | 2026-04-30 | Versão inicial — Forge-2 onda 3 (validation) |
