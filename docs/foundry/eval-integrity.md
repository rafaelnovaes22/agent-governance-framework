# Eval Integrity — split público/privado + defesas anti reward hacking

> **Versão**: 0.1.0 · **Princípio**: C4 (SHADOW antes de cobrar) · **Origem**: issue [#1](https://github.com/rafaelnovaes22/agent-governance-framework/issues/1)
> **Checks**: `C4.eval.1` a `C4.eval.5` em `reviewer/validation-rules.json` (v0.5.0)

---

## Problema

Quando um agente (ou o dev iterando nele) enxerga a métrica que decide sua promoção, a métrica vira alvo e deixa de medir qualidade (lei de Goodhart). Em agentes LLM isso aparece como reward hacking: output copiado do gabarito, métrica impressa sem execução real, casos de eval decorados via contexto.

A Weco documentou isso quantitativamente no [AIDE²](https://www.weco.ai/blog/first-evidence-of-recursive-self-improvement): sem defesas, 63% das soluções do agente eram fraudulentas em KernelBench; com as defesas abaixo, caíram para 34%, abaixo do baseline do agente ajustado manualmente por humanos (42%). Os mecanismos são portáveis para governança de qualquer agente e é isso que este doc especifica.

---

## Mecanismo 1: split público/privado de métricas

Todo eval case declara `visibility` no frontmatter (`templates/eval-case.template.md`):

| Visibilidade | Quem vê o resultado | Papel |
|---|---|---|
| `public` | Agente e dev, durante iteração | Feedback de desenvolvimento |
| `private` | Somente o reviewer e o promotion gate | Hold-out; **única métrica que conta para promoção** |

Regras:

1. Mínimo **20% da suite** com `visibility: private` (`C4.eval.1`).
2. Gate SHADOW → ASSISTED → AUTONOMOUS registra `private_metric` e `private_case_count` no `gate_results` do log de promoção (`C4.eval.2`).
3. Resultado de caso private **nunca** entra em prompt, contexto ou feedback loop de agente (`C4.eval.3`). Vazou, o caso migra para `public` e um novo caso private o substitui.
4. Casos private são rotacionados/renovados após cada promoção (recomendação, não check).

## Mecanismo 2: defesa em três camadas contra reward hacking

Camadas em ordem de custo, todas complementares (nenhuma basta sozinha):

### Camada 1 — Instrutiva (prompt)

Regras anti-gaming explícitas no prompt do agente ("não otimize a métrica diretamente", "não reproduza gabaritos"). Barata e fraca isolada; serve de base para auditar intenção nos traces.

### Camada 2 — Hardcoded (validators determinísticos)

O runner de eval rejeita, **antes de pontuar**, padrões conhecidos de exploit (`C4.eval.4`):

- Output idêntico ou quase idêntico ao gabarito (`reject_verbatim`).
- Métrica reportada sem evidência de execução correspondente (`execution_evidence_check`).
- Artefato de saída ausente ou vazio com score positivo.

### Camada 3 — Estatística (plausibilidade)

Salto de score acima de 3 desvios-padrão contra o histórico de runs (mínimo 5 runs) bloqueia promoção automática e exige entrada de revisão humana no log (`C4.eval.5`). Melhores resultados legítimos existem; a camada não os proíbe, só exige que um humano assine.

---

## Severidades

| Check | SHADOW/ASSISTED | AUTONOMOUS |
|---|---|---|
| C4.eval.1 (split >= 20%) | WARN | FAIL |
| C4.eval.2 (gate usa private) | FAIL | FAIL |
| C4.eval.3 (vazamento de hold-out) | FAIL | FAIL |
| C4.eval.4 (validators no runner) | WARN | WARN |
| C4.eval.5 (plausibilidade de score) | WARN | FAIL |

---

## Trabalho futuro

~~Storage de histórico de runs + journal em árvore~~ → **entregue**: ver `docs/foundry/iteration-journal.md` (schema em `reviewer/iteration-journal-schema.json`, check `C4.eval.6`). O journal é o storage de histórico que destrava a automação do `C4.eval.5`.

## Referências

- Weco, [AIDE²: First Evidence of Recursive Self-Improvement](https://www.weco.ai/blog/first-evidence-of-recursive-self-improvement) (números de reward hacking e desenho do split público/privado).
- [WecoAI/aideml](https://github.com/WecoAI/aideml) — agente base open source (`aide/agent.py`, `aide/journal.py`).
