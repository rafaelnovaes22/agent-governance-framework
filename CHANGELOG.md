# Changelog — Acme Forge

Todas as mudanças notáveis neste framework são documentadas aqui.

Formato segue [Keep a Changelog](https://keepachangelog.com/) e versionamento [SemVer](https://semver.org/):
- **MAJOR** — quebra de Constitution (princípio removido/reformulado)
- **MINOR** — onda Forge concluída (nova capability)
- **PATCH** — correção de template/doc/hook sem mudar contrato

---

## [0.1.0] — 2026-04-30

### Added (Forge-0 — Fundação)

- **Constitution v0.1.0** com 8 princípios versionados (`.claude/CONSTITUTION.md`)
  - C1 Diagnose-before-design
  - C2 Outcome-first, never tech-first
  - C3 Custo ≤ 25% do preço
  - C4 SHADOW antes de cobrar
  - C5 Three-tier context (Sincra L0/L1/L2)
  - C6 Telemetry-by-default
  - C7 Portability over lock-in
  - C8 Anti-customização heroica
- **`.claude/settings.json`** com:
  - Allow list de comandos seguros (npm, prisma, git read-only, docker compose)
  - Deny list de comandos destrutivos (`rm -rf`, `npm publish`, `prisma migrate reset --force`, `git push --force`, `docker volume rm`)
  - Hooks placeholders documentando intent (Forge-4 implementa)
- **4 templates fundamentais** (`templates/`):
  - `sku-spec.template.md` — consolida D1 + D2 da Onda 0 Acme com cláusula contratual de outcome
  - `adr.template.md` — Architecture Decision Record padrão
  - `eval-case.template.md` — caso de eval suite por SKU com gabarito justificado
  - `unit-economics.template.md` — consolida D5 com gate C3 (custo ≤ 25%)
- **6 documentos do framework** (`docs/forge/`):
  - `README.md` — overview interno e ponteiros
  - `decisions.md` — F1-F8 com defaults aprovados pelo CEO + override F4 (DeepAgents/GPT-5.5)
  - `roadmap.md` — 5 ondas Forge-0 a Forge-5 com tasks e critérios de pronto
  - `reviewer-contract.md` — contrato formal com reviewer externo DeepAgents/GPT-5.5
  - `out-of-scope.md` — o que explicitamente NÃO entra no Forge
  - `manifest.json` — inventory machine-readable consumido pelo reviewer
- **`CLAUDE.md.template`** — template para projeto consumidor adaptar como CLAUDE.md raiz
- **`README.md` raiz** + **`INSTALL.md`** — onboarding e instalação manual

### Decisões registradas

- **F1** Nome: Acme Forge ✅
- **F2** Instalação: projeto-only primeiro (cross-project será reavaliado pós Forge-3) ✅
- **F3** `lc-spec-driven`: pular até confirmar nome correto (não encontrado no GitHub) ✅
- **F4** Reviewer: **DeepAgents/GPT-5.5** ⚠️ (override de Gemini Pro inicialmente sugerido)
- **F5** Plugin marketplace: não na Forge-0 ✅
- **F6** BMAD helper pattern: sim, apenas em L0 ✅
- **F7** Smart model routing: aceitar default (Opus / Sonnet / Haiku) ✅
- **F8** `legacy-pmo/`: usar como L0 temporário até Onda 5 da Acme ✅

### Repos absorvidos (origem dos componentes)

- `github/spec-kit` → Constitution pattern + pipeline `/diagnose → /promote`
- `vbomfim/sdlc-guardian-agents` → spec template + 5 quality gates + Guardian roles
- `addyosmani/agent-skills` → anti-rationalization tables + verification gates
- `aj-geddes/claude-code-bmad-skills` → helper pattern (token reduction in L0)
- `carlrannaberg/claudekit` → file-guard hook + secret scan + bash deny list
- `peterkrueck/Claude-Code-Development-Kit` → estrutura documental + cross-LLM review
- `VoltAgent/awesome-claude-code-subagents` → smart model routing
- `anthropics/skills` → skill format reference (frontmatter)
- `giuseppe-trisciuoglio/developer-kit` → path-scoped auto-activation
- `alirezarezvani/claude-skills` → skill security auditor pattern

### Excluído explicitamente

- `rohitg00/awesome-claude-code-toolkit` (meta-list redundante)
- Multi-provider de `feiskyer` (ADR 001 fixa Claude primário)
- Skills marketing/C-suite de `alirezarezvani` (fora do escopo eng)
- BMAD personas completas (sobreposição com Guardians)
- ClickUp interface (proibido pela ADR 001)

### Pendências para próximas ondas

- F9: Stack do reviewer (Python `deepagents` vs Node/TS LangGraph) — Forge-3
- F10: Provedor (OpenAI direto vs OpenRouter vs Vertex) — Forge-3
- F11: Cadência da auditoria (mensal default; eventos críticos disparam?) — Forge-3
- F12: Adoção em outros projetos do workspace (CarInsight, FacilIAuto) — pós Forge-5

---

## [Unreleased] — Próximas ondas

### Forge-1 (próxima) — Skills L0/L1/L2

- 13 skills Sincra com path-scoped auto-activation
- Helper pattern BMAD em L0 (cache de DNA/ICP)
- `/acme:diagnose` produz relatório Fase 0 estruturado em <10 min

### Forge-2 — Slash commands

- 11 commands do pipeline `/diagnose → /spec → /unit-economics → /sla → /plan → /tasks → /implement → /eval → /promote → /audit-monthly → /pre-merge-check`

### Forge-3 — Subagents Guardian + Reviewer

- 8 Guardians + 2 Cross-LLM reviewers
- ADR-002: stack do reviewer DeepAgents/GPT-5.5
- Primeira auditoria mensal de teste

### Forge-4 — Hooks runtime

- Hooks PreToolUse, PostToolUse, Stop ativos
- `manifest-sync` automatizado
- Bypass auditado (`ACME_FORGE_BYPASS=incident`)

### Forge-5 — Playbooks verticais (contínuo)

- Extração de playbooks pós primeiro cliente em AUTONOMOUS
- Reavaliação F2 (promoção a `~/.claude/` global) e F5 (plugin marketplace)

---

## Convenções deste arquivo

- Datas em formato ISO `YYYY-MM-DD`
- Toda mudança de Constitution exige nova ADR no projeto consumidor
- Bump MAJOR exige comunicação ao reviewer DeepAgents (atualizar prompt)
