# 🛠️ QuickStart Dev — Cheatsheet de 1 Página
**Leitura: 15 minutos** | **Pré-requisito: git, terminal, Markdown, JSON**

> Tudo o que você precisa para contribuir no Forge ou em projetos que consomem o Forge. Otimizado para **scanning**, não para narrativa.

---

## 1. 🗺️ Estrutura do Repo (30 segundos)

```
agent-governance-framework/
├── .claude/
│   ├── CONSTITUTION.md          ← 8 princípios canônicos (NÃO edite)
│   ├── settings.json            ← Permissões + hooks ativos
│   ├── agents/                  ← 10 Guardian subagents
│   ├── commands/acme/         ← 15 slash commands
│   └── skills/                  ← Skills L0/L1/L2
├── docs/forge/
│   ├── manifest.json            ← Inventário versionado (fonte de verdade)
│   ├── decisions.md             ← ADRs F1-F27
│   ├── roadmap.md               ← 11 ondas Forge
│   └── reviewer-contract.md     ← Contrato DeepAgent
├── hooks/
│   ├── pre-tool-use/            ← 4 hooks (bloqueiam edits inválidos)
│   ├── post-tool-use/           ← 3 hooks (auditam outputs)
│   └── stop/                    ← 2 hooks (sumários de sessão)
├── templates/                   ← 19 templates reusáveis
│   ├── master-prompt.md         ← Orquestrador universal (NOVO v0.10.0)
│   └── aios/                    ← 6 agentes AIOS portáveis
├── reviewer/                    ← Enablement DeepAgent (GPT-5.5)
├── scripts/
│   ├── forge                    ← CLI wrapper unificado
│   └── forge-doctor.sh          ← Validação completa
└── examples/acme/             ← Caso real (Acme Fin beta)
```

---

## 2. 🚀 Setup em 3 minutos

```bash
# Clonar
git clone https://github.com/acme-startup/agent-governance-framework.git
cd agent-governance-framework

# Validar instalação
bash scripts/forge-doctor.sh
# Esperado: ✅ 25 OK / 0 WARN / 0 FAIL

# Ver versão
bash scripts/forge version
# Esperado: Forge v0.10.0 (Forge-11)

# Ajuda contextual
bash scripts/forge help
```

---

## 3. ⌨️ Comandos mais usados

### Slash commands do Claude Code (15 disponíveis)

```bash
# Pipeline principal (use nessa ordem)
/acme:diagnose <id>              # 1. Diagnostica nova capability
/acme:spec --type=<tipo>         # 2. Cria spec contratual
/acme:plan <id>                  # 3. Plano técnico
/acme:tasks <id>                 # 4. Decomposição em tasks
/acme:implement <id>             # 5. Execução TDD-first
/acme:eval <id>                  # 6. Eval suite
/acme:promote <id> <stage>       # 7. Promover lifecycle

# Validação
/acme:pre-merge-check            # Antes de merge
/acme:sla-threshold              # Definir SLA contratual
/acme:unit-economics             # Recalcular custo C3

# Auditoria
/acme:audit-monthly              # Audit DeepAgent
/acme:playbook-extract           # Extrair padrões

# AIOS pipeline (Forge-10 TDD-first)
/acme:aios-init                  # Setup AIOS no projeto
/acme:aios-run                   # Pipeline spec→schema→test(red)→build→test(verify)→review
/acme:aios-status                # Estado atual
```

### Scripts bash

```bash
bash scripts/forge-doctor.sh       # Validação completa (25 checks)
bash scripts/forge start           # Wizard interativo
bash scripts/forge doctor          # Alias para forge-doctor.sh
bash scripts/forge mode <vibe|dev> # Definir modo de operação
bash scripts/forge version         # Versão atual
```

---

## 4. 🧱 Como ADICIONAR coisas

### Nova skill (`.claude/skills/L{0|1|2}/`)

```bash
# 1. Criar arquivo com frontmatter
.claude/skills/L1/nova-skill.md

# 2. Adicionar entrada em manifest.json
docs/forge/manifest.json → artifacts.skills.L1[]

# 3. Bump PATCH + CHANGELOG
```

### Novo slash command (`.claude/commands/acme/`)

```bash
# 1. Criar arquivo com frontmatter (description, allowed-tools)
.claude/commands/acme/novo-verbo.md

# 2. Verification gate explícito + output structured

# 3. Adicionar entrada em manifest.json → artifacts.commands

# 4. Bump PATCH + CHANGELOG
```

### Novo Guardian subagent (`.claude/agents/`)

```bash
# 1. Criar arquivo com frontmatter (model: opus|sonnet|haiku, tools)
.claude/agents/novo-guardian.md

# 2. Smart routing declarado

# 3. Adicionar em manifest.json → artifacts.agents

# 4. Bump PATCH + CHANGELOG
```

### Novo hook runtime (`hooks/`)

```bash
# 1. Editar .claude/settings.json → hooks.{PreToolUse|PostToolUse|Stop}

# 2. Implementação:
hooks/pre-tool-use/novo-hook.sh  # ou .ps1 para Windows-only

# 3. Adicionar em manifest.json → artifacts.hooks

# 4. Testar bash -n e bash <hook>.sh

# 5. Bump PATCH + CHANGELOG
```

### Novo template (`templates/`)

```bash
# 1. Criar templates/nome.template.md ou nome.md

# 2. Adicionar em manifest.json → artifacts.templates[]
#    com sha256: $(sha256sum templates/nome.md | cut -c1-16)

# 3. Bump PATCH + CHANGELOG
```

---

## 5. 🛡️ Guardians (10) — quando invocar

| Guardian | Quando | Modo |
|----------|--------|:----:|
| `po-guardian` | Toda spec nova (valida outcome C2 + ICP) | 🔴 ATIVO |
| `unit-economist` | Spec com cobrança (audita C3) | 🔴 ATIVO |
| `artifact-architect` | Em `/acme:plan` (valida abstração) | 🟡 CONSULTOR |
| `eval-engineer` | Em `/acme:eval` (eval-cases) | 🟡 CONSULTOR |
| `promotion-officer` | Em `/acme:promote` (gate final) | 🔴 ATIVO |
| `observability-guardian` | Pre-merge se ai_enabled=true | ⚪ PASSIVO |
| `security-privacy-guardian` | Em `/acme:pre-merge-check` | ⚪ PASSIVO |
| `code-reviewer-claude` | PRs Claude-generated | ⚪ PASSIVO |
| `code-reviewer-cross` | PRs antes de merge | ⚪ PASSIVO |
| `tenant-context-curator` | Multi-tenant declarado | ⚪ PASSIVO |

**Sintaxe:** `@po-guardian valide outcome da spec X`

---

## 6. 🔒 Hooks Runtime (9) — o que bloqueia o quê

### PreToolUse (4)
| Hook | Bloqueia |
|------|----------|
| `outcome-clause-guard` | Spec sem outcome contratual |
| `adr-approval-gate` | Decisão arquitetural sem ADR |
| `secret-scan` | Commit com `.env`, tokens, chaves |
| `any-type-guard` | `any` em TypeScript |

### PostToolUse (3)
| Hook | Verifica |
|------|----------|
| `llm-trace-check` (`langfuse-trace-check` legado) | Trace LangSmith gerado se `ai_enabled=true` |
| `unit-economics-recalc` | Recalcula C3 após edits |
| `manifest-sync` | Sincroniza manifest após edits |

### Stop (2)
| Hook | Quando |
|------|--------|
| `5-gates-summary` | Fim de sessão |
| `eval-suite-fresh` | Valida eval recente |

**Bypass:** auditado em `bypass-log/`. **Evitar** — resolva a causa.

---

## 7. 📐 Constitution C1-C8 (não-negociáveis)

| ID | Princípio | Como aplica |
|----|-----------|-------------|
| **C1** | Diagnose-before-build | `/acme:diagnose` antes de qualquer capability |
| **C2** | Outcome contratual | Toda spec: 3 exemplos positivos + 3 negativos |
| **C3** | Unit economics | Custo ≤ 25% do preço (tokens em agentic; infra em platform) |
| **C4** | Verifiable evaluation | Eval-suite (agentic) ou acceptance gate (platform) |
| **C5** | ADR | Toda decisão arquitetural em `docs/forge/decisions.md` |
| **C6** | Observability | LangSmith (`ai_enabled=true`) ou logs estruturados |
| **C7** | Portability | Isolamento da camada LLM/framework |
| **C8** | Tenant context | Multi-tenant respeitado se declarado |

**Mudança em C1-C8** = MAJOR bump + ADR justificando + atualizar prompt reviewer.

---

## 8. 🎯 Versionamento (SemVer)

```
MAJOR  →  quebra Constitution (raríssimo)
MINOR  →  onda Forge concluída (nova capability)
PATCH  →  correção sem mudar contrato
```

**Fontes que precisam ficar coerentes:**
- `docs/forge/manifest.json` → `framework.version` + `manifest_version`
- `.claude/settings.json` → `_forge_version`
- `README.md` → badge `version-X.Y.Z`
- `CHANGELOG.md` → última entrada `[X.Y.Z]`
- `docs/forge/decisions.md` → header

**Forge-doctor valida coerência em 4 fontes (check C3).**

---

## 9. 🐛 Top 10 Erros (e como resolver)

| # | Erro | Causa | Solução |
|---|------|-------|---------|
| 1 | `forge-doctor` falha em C2 (path missing) | Arquivo referenciado em manifest mas não existe | Criar arquivo OU remover entrada do manifest |
| 2 | `forge-doctor` falha em C3 (version mismatch) | Versão divergente entre 4 fontes | Sincronizar: manifest, settings, README, CHANGELOG |
| 3 | `forge-doctor` warning C6 (artefato órfão) | Arquivo existe mas não está no manifest | Adicionar entrada com `sha256`, `path`, `type` |
| 4 | `outcome-clause-guard` bloqueia spec | Spec sem outcome contratual definido | Adicionar bloco "## Outcome" com 3 exemplos +/- |
| 5 | `adr-approval-gate` bloqueia edit | Mudança arquitetural sem ADR | Criar ADR em `docs/forge/decisions.md` (Fxx) |
| 6 | `secret-scan` bloqueia commit | Detectou padrão de secret | Mover para `.env` (gitignored) + revisar regex |
| 7 | `po-guardian` rejeita spec | Outcome vago ou ICP fit incorreto | Reescrever outcome em 1 frase verificável |
| 8 | `unit-economist` falha C3 | Custo > 25% do preço | Reduzir custo OU aumentar preço OU justificar com ADR |
| 9 | Hash sha256 incorreto no manifest | CRLF vs LF | `sha256sum arquivo \| cut -c1-16` (LF preferido) |
| 10 | TDD red phase missing | Módulo modificado sem testes em `tests/{module}/unit/` | Criar testes RED antes do build (`/acme:aios-run`) |

---

## 10. 📦 Estrutura simétrica com consumidores

Repo segue **estrutura espelhada** aos projetos consumidores:

```
agent-governance-framework/                    projeto-consumidor/
├── .claude/                     ├── .claude/        (cópia canônica)
│   ├── CONSTITUTION.md          │   ├── CONSTITUTION.md
│   └── settings.json            │   ├── settings.json
│                                │   └── settings.local.json (gitignored)
├── templates/                   ├── templates/      (cópia canônica)
├── docs/forge/                  ├── docs/forge/     (cópia canônica)
└── CLAUDE.md.template           └── CLAUDE.md       (adaptado)
```

**Sync entre forge e consumidor:** `cp -r` ou symlink.

---

## 11. 🧪 Loop de desenvolvimento

```bash
# Antes de mudar
bash scripts/forge-doctor.sh                  # baseline limpo

# Fazer mudança (skill / command / hook / template)
# ...

# Validar
bash scripts/forge-doctor.sh                  # deve continuar 25 OK

# Validar JSON específico
node -e "JSON.parse(require('fs').readFileSync('docs/forge/manifest.json','utf8'))"

# Recalcular hash
sha256sum templates/novo.md | cut -c1-16

# Commit
git add <arquivos específicos>                # NUNCA git add .
git commit -m "feat(forge-N): descrição — Fxx vY.Z.W"

# Push
git push origin master
```

---

## 12. 🔗 Documentos para escanear (quando precisar)

| Doc | Quando ler |
|-----|------------|
| [`README.md`](./README.md) | Onboarding inicial |
| [`HELLO.md`](./HELLO.md) | Landing adaptativo (você está aqui via essa porta) |
| [`ARCHITECTURE.md`](./ARCHITECTURE.md) | Decisões arquiteturais |
| [`CONTRIBUTING.md`](./CONTRIBUTING.md) | Workflow de PR |
| [`docs/forge/decisions.md`](./docs/forge/decisions.md) | ADRs F1-F27 |
| [`docs/forge/roadmap.md`](./docs/forge/roadmap.md) | Próximas ondas |
| [`CHANGELOG.md`](./CHANGELOG.md) | Histórico de versões |
| [`GLOSSARY.md`](./GLOSSARY.md) | Termos técnicos |
| [`templates/master-prompt.md`](./templates/master-prompt.md) | Orquestrador universal (referência operacional completa) |

---

## 13. 🤝 Antes de abrir PR

```bash
# Checklist mecânico
[ ] bash scripts/forge-doctor.sh → 0 FAIL, ideal 0 WARN
[ ] git diff --stat → mudanças contidas
[ ] manifest.json válido: node -e "JSON.parse(...)"
[ ] CHANGELOG.md tem entrada da versão
[ ] ADR criado (se mudou contrato): F<próximo>
[ ] Versão bumped coerente em 4 fontes
[ ] PR pequeno (≤ 5 arquivos por mudança lógica)
```

---

## 14. 💡 Princípios mentais

- **Manifest é fonte de verdade.** Se está no filesystem mas não no manifest → órfão → erro.
- **Constitution é canônica.** Não copie, referencie.
- **Templates são reusáveis.** Não crie do zero.
- **Hooks são guard-rails, não punições.** Se bloqueou, há razão.
- **Guardians são subagents.** Invoque via `@nome-guardian`.
- **Slash commands têm verification gates.** Não pule.

---

**Está perdido? Rode:** `bash scripts/forge start` (wizard interativo)
**Confuso com termo?** [`GLOSSARY.md`](./GLOSSARY.md)
**Falando com agente IA neste repo?** referencie [`templates/master-prompt.md`](./templates/master-prompt.md)
