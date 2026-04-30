# Acme Forge

> Framework Claude Code-nativo para engenharia de SKUs verticais **SaaS²** seguindo a metodologia Acme.

[![Version](https://img.shields.io/badge/version-0.1.0-blue)](./CHANGELOG.md)
[![Phase](https://img.shields.io/badge/phase-Forge--0-orange)](./docs/forge/roadmap.md)
[![Reviewer](https://img.shields.io/badge/reviewer-DeepAgents%20%2F%20GPT--5.5-purple)](./docs/forge/reviewer-contract.md)

---

## O que é

Acme Forge transforma a **metodologia Acme SaaS²** em rails operacionais executáveis pelo Claude Code. Cada SKU vertical novo herda automaticamente:

- **Diagnóstico estruturado** (Fase 0)
- **Spec contratual de outcome cobrável** (D1+D2)
- **Gate de unit economics ≤ 25% do preço** (D5)
- **Threshold de SLA pré-contratual** (D6)
- **Promoção SHADOW → ASSISTED → AUTONOMOUS** com gates verificáveis
- **Eval suite obrigatória** antes de billing variável
- **Camadas Sincra L0 / L1 / L2** com herança de contexto

> **Tese**: a metodologia Acme já está formalizada em prosa. O Forge **operacionaliza** essa metodologia como artefatos executáveis pelo Claude Code — slash commands, subagents, skills, hooks — para que cada novo SKU/cliente reuse os mesmos rails sem recriar processo.

---

## O que NÃO é

- ❌ Não é starter kit genérico Claude Code
- ❌ Não é metodologia de processo (a metodologia já existe nos docs do projeto consumidor)
- ❌ Não é SDK de agentes (LangGraph cumpre esse papel)
- ❌ Não é uma plataforma — é um conjunto de **conventions + automations** sobre Claude Code

Detalhes em [`docs/forge/out-of-scope.md`](./docs/forge/out-of-scope.md).

---

## Status atual

| Onda | Status | Entregue |
|---|---|---|
| **Forge-0** Fundação | ✅ Concluída | Constitution, settings, manifest, 4 templates, CLAUDE.md template |
| Forge-1 Skills L0/L1/L2 | ⏳ Próxima | 13 skills Sincra |
| Forge-2 Slash commands | 🔜 Pendente | 11 commands do pipeline |
| Forge-3 Subagents Guardian | 🔜 Pendente | 10 guardians + reviewer DeepAgents |
| Forge-4 Hooks runtime | 🔜 Pendente | Governance hooks |
| Forge-5 Playbooks verticais | 🔜 Pendente | Pós primeiro cliente em AUTONOMOUS |

Roadmap completo em [`docs/forge/roadmap.md`](./docs/forge/roadmap.md).

---

## Os 8 princípios (Constitution)

Versionados em [`.claude/CONSTITUTION.md`](./.claude/CONSTITUTION.md):

1. **C1** — Diagnose-before-design
2. **C2** — Outcome-first, never tech-first
3. **C3** — Custo ≤ 25% do preço
4. **C4** — SHADOW antes de cobrar
5. **C5** — Three-tier context (Sincra L0/L1/L2)
6. **C6** — Telemetry-by-default (Langfuse)
7. **C7** — Portability over lock-in
8. **C8** — Anti-customização heroica

---

## Como usar em um projeto

Veja [`INSTALL.md`](./INSTALL.md) — instalação manual ou via script (a chegar em Forge-2).

Em resumo:

```bash
# A partir do diretório do projeto consumidor
cp -r /path/to/agent-governance-framework/.claude/* ./.claude/
cp -r /path/to/agent-governance-framework/templates ./
cp -r /path/to/agent-governance-framework/docs/forge ./docs/
cp /path/to/agent-governance-framework/CLAUDE.md.template ./CLAUDE.md
# Adaptar CLAUDE.md ao contexto do projeto
```

> ⚠️ **Não sobrescreva** `.claude/settings.local.json` do projeto consumidor — ele contém overrides do dev.

---

## Reviewer externo: DeepAgents / GPT-5.5

Toda implementação que adota o Forge é auditada mensalmente por um Deep Agent externo (GPT-5.5) que:

- Valida os 8 princípios da Constitution
- Confere coerência entre `manifest.json` e estado real do repositório
- Amostra 5–10% dos outcomes de produção e reclassifica
- Detecta drift (degradação de qualidade ao longo do tempo)
- Emite relatório `docs/forge/audits/{YYYY-MM-DD}.md`

Contrato em [`docs/forge/reviewer-contract.md`](./docs/forge/reviewer-contract.md).

---

## Documentação

| Arquivo | Para quem |
|---|---|
| [`README.md`](./README.md) (este) | Visão geral / onboarding |
| [`INSTALL.md`](./INSTALL.md) | Como instalar em um projeto consumidor |
| [`CHANGELOG.md`](./CHANGELOG.md) | Histórico de versões |
| [`.claude/CONSTITUTION.md`](./.claude/CONSTITUTION.md) | Princípios versionados |
| [`docs/forge/README.md`](./docs/forge/README.md) | Overview interno do framework |
| [`docs/forge/decisions.md`](./docs/forge/decisions.md) | Decisões F1-F12 |
| [`docs/forge/roadmap.md`](./docs/forge/roadmap.md) | Roadmap das 5 ondas |
| [`docs/forge/reviewer-contract.md`](./docs/forge/reviewer-contract.md) | Contrato com reviewer externo |
| [`docs/forge/manifest.json`](./docs/forge/manifest.json) | Inventory machine-readable |
| [`docs/forge/out-of-scope.md`](./docs/forge/out-of-scope.md) | O que NÃO entra |
| [`templates/`](./templates/) | Templates fundamentais (sku-spec, adr, eval-case, unit-economics) |

---

## Versionamento

SemVer estrito:

- **MAJOR** — quebra de Constitution (princípio removido/reformulado)
- **MINOR** — onda Forge concluída (nova capability)
- **PATCH** — correção de template/doc/hook sem mudar contrato

A versão atual está em `docs/forge/manifest.json` → `framework.version` e em [`CHANGELOG.md`](./CHANGELOG.md).

---

## Contribuição

Forge é **fechado e versionado**. Mudanças entram via:

1. Issue descrevendo motivação
2. Branch `forge/{onda}-{slug}`
3. PR com referência aos princípios afetados
4. Review humano + (após Forge-3) review do DeepAgents
5. Bump de versão em `manifest.json` + entrada em `CHANGELOG.md`

---

## Licença e propriedade

Repositório privado. Propriedade da **Acme / Novais Digital**.

---

## Frase-resumo

> O **Acme Forge** transforma a metodologia Acme SaaS² em rails Claude Code-nativos: cada SKU vertical novo herda automaticamente diagnóstico estruturado, spec contratual de outcome, gate de unit economics, threshold de SLA e promoção SHADOW→AUTONOMOUS — com auditoria externa mensal por DeepAgents/GPT-5.5.
