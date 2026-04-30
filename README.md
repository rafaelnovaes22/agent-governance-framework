# Acme Forge

> Framework de governança para projetos que constroem **agentes de IA com outcome cobrável**.
> Replicável por **devs (Claude Code)**, **DeepAgents (GPT-5.5)** e outros agentes autônomos.

[![Version](https://img.shields.io/badge/version-0.2.0-blue)](./CHANGELOG.md)
[![Phase](https://img.shields.io/badge/phase-Forge--0-orange)](./docs/forge/roadmap.md)
[![Reviewer](https://img.shields.io/badge/reviewer-DeepAgent%20%2F%20GPT--5.5-purple)](./reviewer/)

---

## O que o Forge resolve

Construir agentes de IA que **entregam outcome cobrável** (lead qualificado, ticket resolvido, análise gerada, etc.) tem armadilhas que matam projetos silenciosamente:

- Spec sem cláusula contratual → disputa eterna sobre "o que conta"
- Custo de inferência > preço do outcome → margem negativa em volume
- Promoção de "demo" pra "produção" sem eval → drift de qualidade não detectado
- Customização heroica por cliente → não escala, vira agência
- Sem telemetria → impossível auditar

Forge resolve isso com:

1. **Constitution versionada** (8 princípios, [`.claude/CONSTITUTION.md`](./.claude/CONSTITUTION.md))
2. **Templates fundamentais** (spec, ADR, eval-case, unit-economics, lifecycle, audit) — [`templates/`](./templates/)
3. **Manifest auditável** machine-readable — [`docs/forge/manifest.json`](./docs/forge/manifest.json)
4. **Reviewer externo independente** (DeepAgent / GPT-5.5) com contrato formal — [`reviewer/`](./reviewer/)
5. **Hooks de runtime** (em construção, Forge-4)

---

## Audiência: 3 tipos de consumidor

Forge é projetado para 3 tipos de usuário, cada um com seu próprio guia:

| Consumidor | Entry point | O que faz |
|---|---|---|
| 👤 **Dev humano** com Claude Code | [`QUICKSTART.md`](./QUICKSTART.md) → [`INSTALL.md`](./INSTALL.md) | Instala em projeto novo ou existente; usa skills/commands no editor |
| 🤖 **DeepAgent / GPT-5.5** (reviewer autônomo) | [`DEEPAGENT_GUIDE.md`](./DEEPAGENT_GUIDE.md) → [`reviewer/prompt.template.md`](./reviewer/prompt.template.md) | Lê manifest, valida princípios, emite relatório mensal |
| 🛠️ **Mantenedor do Forge** (evoluir o framework) | [`CONTRIBUTING.md`](./CONTRIBUTING.md) → [`CLAUDE.md`](./CLAUDE.md) | Adiciona skills/commands/templates ao framework |

---

## O que NÃO é

- ❌ Não é starter kit genérico Claude Code (existem dezenas)
- ❌ Não é metodologia de processo (a metodologia vive em quem opera o Forge — ver `examples/acme/`)
- ❌ Não é SDK de agentes (LangGraph, CrewAI, AutoGen cumprem esse papel)
- ❌ Não é plataforma — é um conjunto de **conventions + automations** sobre Claude Code

Detalhes em [`docs/forge/out-of-scope.md`](./docs/forge/out-of-scope.md).

---

## Os 8 princípios da Constitution

Versionados em [`.claude/CONSTITUTION.md`](./.claude/CONSTITUTION.md):

1. **C1** — Diagnose-before-design
2. **C2** — Outcome-first, never tech-first
3. **C3** — Cost ≤ 25% of price
4. **C4** — SHADOW antes de cobrar
5. **C5** — Three-tier context (Strategic / Tactical / Operational)
6. **C6** — Telemetry-by-default
7. **C7** — Portability over lock-in
8. **C8** — Anti-customização heroica

Princípios genéricos. Extensões específicas por domínio vivem em `examples/{domínio}/constitution-extension.md`.

---

## Status atual

| Onda | Status | Entregue |
|---|---|---|
| **Forge-0** Fundação | ✅ Concluída | Constitution, settings, manifest, 9 templates, multi-consumer docs, reviewer enablement, examples/acme |
| Forge-1 Skills L0/L1/L2 | 🔜 Próxima | 13 skills com path-scoped activation |
| Forge-2 Slash commands | 🔜 Pendente | 11 commands do pipeline |
| Forge-3 Subagents Guardian + Reviewer Implementation | 🔜 Pendente | 10 guardians + DeepAgent reviewer rodando |
| Forge-4 Hooks runtime | 🔜 Pendente | Governance hooks |
| Forge-5 Playbooks verticais | 🔜 Pendente | Pós primeiro caso real em produção |

Roadmap completo em [`docs/forge/roadmap.md`](./docs/forge/roadmap.md).

---

## Estrutura do repositório

```
agent-governance-framework/
├── README.md                        ← este arquivo
├── QUICKSTART.md                    ← instalar em 5 min
├── ARCHITECTURE.md                  ← visão da estrutura e fluxos
├── INSTALL.md                       ← instalação manual detalhada
├── CONTRIBUTING.md                  ← como evoluir o framework
├── DEEPAGENT_GUIDE.md               ← como agent autônomo navega o Forge
├── GLOSSARY.md                      ← vocabulário compartilhado
├── CLAUDE.md                        ← meta-doc para devs do framework
├── CLAUDE.md.template               ← template para projeto consumidor
├── CHANGELOG.md                     ← histórico de versões
│
├── .claude/
│   ├── CONSTITUTION.md              ← 8 princípios (genéricos)
│   └── settings.json                ← permissões + hooks (Forge layer)
│
├── docs/forge/                      ← documentação interna do framework
│   ├── README.md                    ← overview
│   ├── decisions.md                 ← F1-F12 + extensões
│   ├── roadmap.md                   ← 5 ondas
│   ├── reviewer-contract.md         ← contrato com reviewer
│   ├── manifest.json                ← inventory machine-readable
│   └── out-of-scope.md              ← o que NÃO entra
│
├── templates/                       ← templates fundamentais (genéricos)
│   ├── adr.template.md
│   ├── platform-sku-spec.template.md
│   ├── product-spec.template.md
│   ├── diagnostic-spec.template.md
│   ├── eval-case.template.md
│   ├── unit-economics.template.md
│   ├── lifecycle-stage.template.md
│   ├── monthly-audit.template.md
│   └── clickup-blueprint.template.md
│
├── reviewer/                        ← enablement do DeepAgent reviewer
│   ├── prompt.template.md           ← system prompt
│   ├── output-schema.json           ← JSON schema do relatório
│   ├── validation-rules.json        ← checks machine-readable
│   └── example-audit.md             ← exemplo de relatório
│
└── examples/                        ← casos de uso reais como referência
    └── acme/                      ← caso Acme (criadora do Forge)
        ├── README.md
        ├── methodology/
        ├── portfolio.md
        ├── constitution-extension.md
        ├── clickup-blueprint.md
        └── products/
            ├── acme-fin.md
            └── acme-educacional.md
```

---

## Como começar

### Sou dev. Quero usar Forge num projeto novo.

```bash
git clone https://github.com/rafaelnovaes22/agent-governance-framework.git
cd /caminho/do/seu/projeto
# segue passos em INSTALL.md
```

Consulta também [`QUICKSTART.md`](./QUICKSTART.md) e [`ARCHITECTURE.md`](./ARCHITECTURE.md).

### Sou DeepAgent. Quero auditar um projeto que usa Forge.

1. Lê [`reviewer/prompt.template.md`](./reviewer/prompt.template.md) e carrega como system prompt
2. Recebe `manifest.json` do projeto consumidor como input
3. Roda os checks definidos em [`reviewer/validation-rules.json`](./reviewer/validation-rules.json)
4. Emite relatório seguindo [`reviewer/output-schema.json`](./reviewer/output-schema.json)
5. Detalhe completo em [`DEEPAGENT_GUIDE.md`](./DEEPAGENT_GUIDE.md)

### Sou mantenedor. Quero evoluir o Forge.

[`CONTRIBUTING.md`](./CONTRIBUTING.md) descreve o processo (issue → branch → PR → versionamento).

---

## Versionamento

SemVer estrito:

- **MAJOR** — quebra de Constitution (princípio removido/reformulado)
- **MINOR** — onda Forge concluída (nova capability)
- **PATCH** — correção de template/doc/hook sem mudar contrato

Versão atual em [`docs/forge/manifest.json`](./docs/forge/manifest.json) → `framework.version`.

---

## Filosofia em uma frase

> Cada agente de IA novo em produção herda automaticamente diagnóstico estruturado, spec contratual de outcome, gate de unit economics, threshold de SLA e promoção SHADOW→AUTONOMOUS — com auditoria externa independente por DeepAgent.

---

## Licença

Repositório privado. Propriedade da **Acme / Novais Digital**. Pode ser replicado em projetos terceiros mediante autorização do mantenedor.
