# Iteration Journal — audit trail replayável de iterações de agente

> **Versão**: 0.1.0 · **Princípios**: C4 (promoção auditável) + C6 (telemetry/auditability)
> **Schema**: `reviewer/iteration-journal-schema.json` · **Check**: `C4.eval.6` em `reviewer/validation-rules.json` (v0.6.0)
> **Origem**: trabalho futuro de `docs/foundry/eval-integrity.md`; padrão portado de [WecoAI/aideml](https://github.com/WecoAI/aideml) (`aide/journal.py`, `aide/agent.py`).

---

## Problema

Hoje o log de promoção (`subscriptions/{id}/promotions.md`) registra o **resultado** do gate, mas não o **caminho** que levou até a versão promovida. Sem o caminho, três perguntas de auditoria ficam sem resposta:

1. Quais alternativas foram tentadas e rejeitadas antes desta versão?
2. A métrica final veio de melhoria real ou de um único run sortudo?
3. Algum node do caminho disparou flag de integridade (anti-gaming) que foi ignorada?

## Solução: árvore de nodes append-only

Cada sessão de iteração sobre um agente grava um journal JSON (schema v1.0). A estrutura é a do aideml:

- **Node** = uma mudança atômica com `plan` (o que se tentou), `change_ref` (commit/diff auditável), resultado de execução, métricas e `is_buggy`.
- **`parent_id`** forma a árvore. `stage` deriva do parent: sem parent = `draft`; parent buggy = `debug`; parent ok = `improve`.
- **`best_node_id`** = node não-buggy de maior métrica **private**. O caminho root → best é o "best path": a narrativa replayável da promoção, incluindo os branches rejeitados que ficam visíveis na árvore.

### Convenção de path

```
subscriptions/{id}/journal/{run_id}.json
```

### Integração com o gate de promoção

`gate_results` no log de promoção passa a incluir:

```yaml
journal_ref: "subscriptions/{id}/journal/{run_id}.json"
best_node_id: "{node id}"
```

Check `C4.eval.6`: `journal_ref` presente, arquivo existe, valida contra o schema e `best_node_id` referencia node existente, não-buggy e sem `integrity_flags` pendentes (WARN; FAIL em AUTONOMOUS).

## Bônus: destrava o C4.eval.5

O check estatístico (salto de score > 3σ exige assinatura humana) dependia de "storage de histórico de runs padronizado". O journal **é** esse storage: a série `nodes[].metrics.private.value` dos journals anteriores do mesmo SKU fornece o histórico para calcular o z-score. `C4.eval.5` deixa de ser aplicado manualmente quando o consumidor adota o journal.

## Interação com eval integrity

| Mecanismo | Onde aparece no journal |
|---|---|
| Split público/privado (`C4.eval.1-3`) | `metrics.public` / `metrics.private` por node; private nunca ecoa em contexto de agente |
| Validators anti-gaming (`C4.eval.4`) | `integrity_flags` no node; node flagueado é inelegível a `best_node_id` sem revisão humana |
| Plausibilidade estatística (`C4.eval.5`) | histórico = `metrics.private.value` dos journals anteriores do SKU |

## Regras de integridade do journal

1. **Append-only**: node gravado nunca é editado nem removido; correção = novo node `debug`.
2. **`ctime` monotônico** por `step` (detecta reescrita retroativa).
3. **Sem artefato embutido**: `change_ref` aponta para commit/diff; o journal não carrega código nem gabarito (evita virar canal de vazamento do hold-out).
4. Journal de sessão fechada acompanha o SKU até o descarte da versão promovida (mesma retenção do log de promoção).

## Trabalho futuro

- Runner de referência (adapter TS/Python em `templates/observability/`) que grava o journal automaticamente a cada iteração de eval.
- Automação do z-score do `C4.eval.5` lendo journals anteriores no CI de promoção.

## Referências

- [WecoAI/aideml](https://github.com/WecoAI/aideml) — `aide/journal.py` (estrutura Journal/Node), `aide/agent.py` (`search_policy()`: greedy no melhor node + desvio probabilístico para debug).
- Weco, [AIDE²](https://www.weco.ai/blog/first-evidence-of-recursive-self-improvement) — uso do journal como base do loop de auto-melhoria auditável.
- `docs/foundry/eval-integrity.md` — mecanismos C4.eval.1-5.
