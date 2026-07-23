# Eval Integrity: anti reward hacking em 3 camadas

> **Versão**: 0.1.0 (Foundry, v0.23.0)
> **Princípios**: C4 (lifecycle/promoção), C6 (auditabilidade)
> **Origem**: issue [#1](https://github.com/rafaelnovaes22/agent-governance-framework/issues/1), padrões extraídos do [AIDE² (Weco)](https://www.weco.ai/blog/first-evidence-of-recursive-self-improvement) e do agente open source [WecoAI/aideml](https://github.com/WecoAI/aideml).

---

## Problema

Agentes otimizados contra uma eval suite tendem a aprender a passar na suite, não a resolver a tarefa (reward hacking). No experimento do AIDE², 63% das soluções do agente base eram fraudulentas sob pressão de otimização. Com as defesas abaixo, o número caiu para 34%, abaixo inclusive do baseline ajustado por humanos (42%).

No Foundry, o risco concreto é: um SKU passa no gate `C4.ai.3` porque o time (ou o próprio agente, em fluxos AIOS) iterou contra os mesmos casos que decidem a promoção.

## As 3 camadas

### Camada 1: instrutiva (prompts)

Regras anti-gaming explícitas nos prompts de agents e skills (ex.: "nunca hardcode o output esperado de um eval case"). Barata e fraca sozinha. Não é validável pelo reviewer; vive nos templates de agents (`templates/aios/`, `.claude/agents/`).

### Camada 2: determinística (checks `C4.integrity.*`)

Validators hardcoded em `reviewer/validation-rules.json`:

1. `C4.integrity.1`: todo eval case declara `visibility: public|private` no frontmatter; a suite mantém no mínimo 30% de casos private.
2. `C4.integrity.2`: casos private são hold-out real. O `case_id` não pode aparecer em prompts, skills ou código de produção.
3. `C4.integrity.3`: código de produção não hardcoda gabarito (output esperado, `case_id`, bypass de scorer).

### Camada 3: estatística (drift positivo)

`drift_thresholds.quality.max_positive_delta_pp` (default 10 pp): salto de acurácia mês a mês acima do limite, sem mudança declarada no CHANGELOG do consumidor, é implausível e gera WARN com revisão humana obrigatória antes de qualquer promoção no período. É o espelho do `max_negative_delta_pp` que já existia: queda indica regressão, salto indica gaming ou vazamento de gabarito.

## Split público/privado

| | `visibility: public` | `visibility: private` |
|---|---|---|
| Agente/time vê o resultado | Sim, feedback de iteração | Só o agregado (pass/fail da suite) |
| Pode aparecer em prompt/contexto | Sim | Nunca (`C4.integrity.2`) |
| Conta para gate de promoção | Não | Sim, exclusivamente (`C4.ai.3`) |

Regra de curadoria: casos private devem ser mantidos pelo PO Guardian ou Eval Engineer, renovados quando um caso vaza (foi discutido em issue/PR/prompt, passou a ser público por definição).

## Trilha de auditoria (journal)

O `promotions.md` append-only (`C4.ai.1`) registra o gate. Recomendação de evolução (não obrigatória nesta versão): registrar também o caminho de iterações que levou à versão promovida, no padrão do `Journal`/`Node` do aideml (nós draft/debug/improve com métrica e flag de bug), tornando a promoção replayável: "mostre o caminho, incluindo branches rejeitados".

## Enforcement

- **Reviewer mensal** (DeepAgents): aplica `C4.integrity.*` como parte da seção `agentic_saas`.
- **`/novais-digital:promote`**: gate passa a exigir métrica private (`C4.ai.3`) e ausência de WARN estatístico aberto.
- **Guardians**: `promotion-officer` (gate), `eval-engineer` (curadoria do split e do ratio private).

## Fora de escopo desta versão

- Detecção estatística intra-mês (exige histórico de runs por caso; hoje só há agregado mensal).
- Journal em árvore como artefato obrigatório (proposto acima como recomendação).
