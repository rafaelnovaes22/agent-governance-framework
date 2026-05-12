# Acme Forge — Documentação interna

> **Versão**: 0.9.0 (Forge-10 entregue)
> **Data**: 2026-05-12
> **Status**: ✅ Framework consistente via `scripts/forge-doctor.sh`
> **Reviewer externo**: DeepAgent — auditoria mensal sobre `manifest.json` + `validation-rules.json`

---

## O que é o Acme Forge

Framework de governança Claude Code-nativo para projetos que entregam **outcome cobrável**: agentes de IA, plataformas SaaS/operacionais, automações ou híbridos. O Forge transforma princípios, templates, commands, skills, agents, hooks e reviewer externo em rails operacionais auditáveis.

---

## Princípios canônicos

Formalmente versionados em [`.claude/CONSTITUTION.md`](../../.claude/CONSTITUTION.md):

1. **C1 — Diagnose-before-build**
2. **C2 — Outcome-first, never tech-first**
3. **C3 — Cost ≤ 25% of price**
4. **C4 — SHADOW before charge / staged promotion**
5. **C5 — Three-tier context**
6. **C6 — Telemetry-by-default**
7. **C7 — Portability over lock-in**
8. **C8 — Configuration over heroic customization**

---

## Documentos do Forge

| Arquivo | Conteúdo |
|---|---|
| [`README.md`](./README.md) | Este arquivo — overview interno |
| [`decisions.md`](./decisions.md) | Decisões F1-F26 |
| [`roadmap.md`](./roadmap.md) | Roadmap das ondas Forge |
| [`reviewer-contract.md`](./reviewer-contract.md) | Contrato com reviewer externo |
| [`manifest.json`](./manifest.json) | Inventory machine-readable do framework |
| [`out-of-scope.md`](./out-of-scope.md) | O que explicitamente não entra no Forge |
| [`helper-pattern.md`](./helper-pattern.md) | Helper pattern BMAD para redução de contexto |
| [`aios-telemetry-pattern.md`](./aios-telemetry-pattern.md) | Padrão de telemetria AIOS |

---

## Inventário atual

| Categoria | Quantidade | Path |
|---|---:|---|
| Slash commands | 15 | `.claude/commands/acme/` |
| Guardian/cross agents | 10 | `.claude/agents/` |
| Skills Forge | 9 | `.claude/skills/L0..L2/` |
| Hooks/scripts runtime | 10 | `hooks/` |
| Templates | 37 | `templates/` |
| Reviewer DeepAgent skills | 10 | `reviewer/deepagents/skills/` |

---

## Como validar

```bash
bash scripts/forge-doctor.sh
```

Critérios cobertos: JSON parse, paths do manifest, coerência de versão, Constitution, sintaxe bash dos hooks, artefatos órfãos, permissions sanity e templates AIOS TDD-ready.

---

## Como ler estes documentos

- **CEO / não-técnico**: comece por este README + [`decisions.md`](./decisions.md)
- **Tech Lead / dev**: leia `CLAUDE.md` raiz, Constitution, [`manifest.json`](./manifest.json) e [`roadmap.md`](./roadmap.md)
- **Reviewer externo**: ingerir [`manifest.json`](./manifest.json), depois [`reviewer-contract.md`](./reviewer-contract.md) e `reviewer/validation-rules.json`
- **Mantenedor**: seguir `CLAUDE.md` raiz e atualizar manifest/changelog/decisions a cada mudança de contrato

---

## Frase-resumo

> O Forge oferece rails auditáveis para transformar intenção de negócio em outcome verificável, com governança de custo, promoção, telemetria, portabilidade e anti-customização heroica.
