# Acme Forge

> Framework de governança para projetos que constroem **agentes de IA com outcome cobrável**.
> Replicável por **devs (Claude Code)**, **DeepAgents (GPT-5.5)** e outros agentes autônomos.

[![Version](https://img.shields.io/badge/version-0.6.0-blue)](./CHANGELOG.md)
[![Phase](https://img.shields.io/badge/phase-Forge--7-orange)](./docs/forge/roadmap.md)
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
5. **9 hooks runtime ativos** com bypass auditado (PreToolUse x4, PostToolUse x3, Stop x2) — [`hooks/`](./hooks/)
6. **12 slash commands** do pipeline diagnose → promote → audit — [`.claude/commands/`](./.claude/commands/)
7. **10 subagents Guardian** (4 Opus + 4 Sonnet + 2 cross-LLM) — [`.claude/agents/`](./.claude/agents/)
8. **9 skills** em 3 tiers (L0/L1/L2) com helper pattern BMAD — [`.claude/skills/`](./.claude/skills/)

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
| **Forge-0** Fundação | ✅ Concluída | Constitution, settings, manifest, 12 templates, multi-consumer docs, reviewer enablement, examples/acme |
| **Forge-1** Skills L0/L1/L2 | ✅ Concluída | 9 skills genéricas (3 L0 + 3 L1 + 3 L2) com helper pattern BMAD documentado |
| **Forge-2** Slash commands | ✅ Concluída | 12 commands do pipeline diagnose → promote → audit → playbook-extract |
| **Forge-3** Subagents Guardian + Reviewer | ✅ Concluída | 10 agents (8 Guardians + 2 cross-LLM) + infraestrutura DeepAgent reviewer |
| **Forge-4** Hooks runtime | ✅ Concluída (v0.3.0) | 9 hooks ativos, bypass auditado, skill-security-scan standalone |
| **Forge-5** Playbooks verticais (infraestrutura) | ✅ Entregue (v0.4.0) | Templates playbook + retrospectiva, /acme:playbook-extract; conteúdo real aguarda AUTONOMOUS |

**Pendências do consumidor:** ADR-002 do reviewer, primeira auditoria mensal de teste, primeiro SKU em AUTONOMOUS para gerar playbook real.

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
│   ├── settings.json                ← permissões + hooks (Forge layer)
│   ├── skills/                      ← 9 skills genéricas em 3 tiers
│   │   ├── L0/  (company-dna, icp-loader, offerings-loader)
│   │   ├── L1/  (baseline-cost-builder, diagnostic-runner, process-mapper)
│   │   └── L2/  (artifact-prompt-builder, eval-case-author, shadow-mode-runner)
│   ├── agents/                      ← 10 subagents Guardian + cross-LLM
│   │   ├── po-guardian.md, artifact-architect.md, unit-economist.md
│   │   ├── promotion-officer.md, eval-engineer.md, tenant-context-curator.md
│   │   ├── observability-guardian.md, security-privacy-guardian.md
│   │   └── code-reviewer-claude.md, code-reviewer-cross.md
│   └── commands/acme/             ← 12 slash commands do pipeline
│       ├── diagnose.md, spec.md, unit-economics.md, sla-threshold.md
│       ├── plan.md, tasks.md, implement.md
│       ├── eval.md, promote.md, audit-monthly.md
│       ├── pre-merge-check.md, playbook-extract.md
│
├── hooks/                           ← 9 hooks runtime + script CI
│   ├── pre-tool-use/   (outcome-clause-guard, adr-approval-gate, secret-scan, any-type-guard)
│   ├── post-tool-use/  (langfuse-trace-check, unit-economics-recalc, manifest-sync)
│   ├── stop/           (5-gates-summary, eval-suite-fresh)
│   └── scripts/        (skill-security-scan.sh — standalone CI)
│
├── docs/forge/                      ← documentação interna do framework
│   ├── README.md                    ← overview
│   ├── decisions.md                 ← F1-F21 + extensões
│   ├── roadmap.md                   ← 5 ondas
│   ├── reviewer-contract.md         ← contrato com reviewer
│   ├── manifest.json                ← inventory machine-readable
│   ├── out-of-scope.md              ← o que NÃO entra
│   ├── helper-pattern.md            ← helper pattern BMAD (L0, cache)
│   ├── bypass-log/                  ← registro de bypasses de hooks
│   └── session-gate-reports/        ← relatórios automáticos ao fim de sessão
│
├── templates/                       ← 12 templates fundamentais (genéricos)
│   ├── adr.template.md
│   ├── adr-reviewer-runtime.template.md  ← ADR-002 para consumidor
│   ├── platform-sku-spec.template.md
│   ├── product-spec.template.md
│   ├── diagnostic-spec.template.md
│   ├── eval-case.template.md
│   ├── unit-economics.template.md
│   ├── lifecycle-stage.template.md
│   ├── monthly-audit.template.md
│   ├── clickup-blueprint.template.md
│   ├── playbook.template.md         ← blocos verticais reutilizáveis (Forge-5)
│   └── retrospective.template.md    ← retrospectiva por SKU pós-AUTONOMOUS
│
├── reviewer/                        ← enablement do DeepAgent reviewer
│   ├── README.md                    ← índice e ordem de leitura
│   ├── prompt.template.md           ← system prompt
│   ├── output-schema.json           ← JSON schema do relatório
│   ├── validation-rules.json        ← checks machine-readable
│   ├── example-audit.md             ← exemplo de relatório
│   └── deepagents/                  ← 10 SKILL.md convertidos para DeepAgents CLI
│       ├── README.md
│       ├── conversion-log.md
│       └── skills/
│
├── docs/playbooks/                  ← playbooks verticais (pós cliente 1 AUTONOMOUS)
├── docs/retrospectives/             ← retrospectivas por SKU
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

# Após instalar, valide a consistência do framework:
bash scripts/forge-doctor.sh
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
