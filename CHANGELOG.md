# Changelog — Acme Forge

Todas as mudanças notáveis neste framework são documentadas aqui.

Formato segue [Keep a Changelog](https://keepachangelog.com/) e versionamento [SemVer](https://semver.org/):
- **MAJOR** — quebra de Constitution (princípio removido/reformulado)
- **MINOR** — onda Forge concluída (nova capability)
- **PATCH** — correção de template/doc/hook sem mudar contrato

---

## [0.6.0] — 2026-05-07

### Added (Forge-7 — AIOS agentes portáveis em templates físicos canônicos)

**6 agentes AIOS extraídos como templates canônicos versionados na Forge — qualquer novo projeto consumidor recebe os agentes prontos via `/acme:aios-init` (sem hardcode de cliente, sem dependência da implementação de referência SchoolPlatform/EDIX):**

**Novo diretório `templates/aios/`:**

- `templates/aios/README.md` — documentação dos placeholders (`{PROJECT_NAME}`, `{MODULE}`, `{TIER}`, `{STACK_*}`), estrutura física e tabela de diferenças vs. SchoolPlatform/EDIX
- `templates/aios/orchestrator.py.template` — pipeline multiagente que lê `aios/config.yaml → modules:` (sem hardcode de lista de módulos), com gates humanos C4 obrigatórios em pipeline completo
- `templates/aios/config.yaml.template` — config canônica AIOS com novos blocos `project.*` (name, tenant_field) e `stack.*` (backend, frontend, database, tests) + `modules:` array

**6 agentes em `templates/aios/agents/`:**

- `spec_agent/` (**especializado** por módulo) — converte descrição em spec executável; tier configurável A/B/C
- `backend_agent/` (**especializado**) — implementa API/service layer; **stack lida de `aios/config.yaml → stack.backend`** (sem cravamento de Next.js/FastAPI/Rails)
- `frontend_agent/` (**especializado**) — implementa UI/telas; **stack lida de `stack.frontend`**
- `schema_agent/` (**compartilhado, stack-agnostic**) — gera schema na stack declarada em `stack.database`; se vazia, propõe 1-3 stacks com tradeoffs e pede decisão humana antes do schema definitivo
- `test_agent/` (**compartilhado**) — gera testes priorizando edge cases financeiros; stack via `stack.tests`
- `review_agent/` (**compartilhado**) — revisa output contra spec + checklist Constitution C5-C8; output parseável (linha "APROVADO PARA MERGE: Sim/Não")

Cada `entry.py.template` inclui obrigatoriamente:
- Bloco `langfuse.trace() → generation.end()` envolvendo `send_request()` (C6)
- `_MockTrace` fallback para dev local sem Langfuse (não substitui — apenas evita crash em dev)
- Comentário-cabeçalho declarando que o SYSTEM_PROMPT funciona standalone em Claude Code sem o kernel AIOS (C7)
- `tenantId` lido de `task_input["tenant_id"]`, nunca hardcoded (C8)
- Carregamento de `aios/config.yaml` para `_PROJECT_NAME` e `_STACK_*` em runtime (zero hardcode de cliente)

**`/acme:aios-init` bumped para v0.2.0:**

- Passa a **copiar dos templates físicos** em `templates/aios/` em vez de gerar boilerplate inline
- Cobre os 6 agentes (Forge-6 cobria só 3): especializados são regenerados a cada chamada; compartilhados (schema/test/review) são **idempotentes** — só criados se ausentes
- Cria `aios/orchestrator.py` e `aios/config.yaml` quando ausentes, copiando dos templates
- Atualiza `aios/config.yaml → modules:` automaticamente com o novo módulo
- Validation gate aumentado de 4 para 7 checks (adiciona: forge_root, pyyaml, langfuse-warning)
- Resolução de `${FORGE_ROOT}` em ordem: `ACME_FORGE_ROOT` env → `./forge/` → `./.claude/forge/`

**Decisão registrada (F24):**

- `docs/forge/decisions.md` — F24 documenta a extração dos agentes como templates canônicos, mapeamento com Constitution e trade-off (evolução coordenada via 6 arquivos centralizados em troca de garantia C7/C8 e propagação automática para todos os consumidores)

### Changed

- `manifest.json` versão `0.5.0 → 0.6.0`; novo bloco `artifacts.templates_aios.files[]` com 9 entradas (README + orchestrator + config + 6 agent dirs); `command-aios-init` bumped para v0.2.0; `_status` de `commands.aios` atualizado para "Forge-2+5+6+7"; `version_bumps.0.5.0_to_0.6.0` adicionado
- `docs/forge/roadmap.md` — header status atualizado para v0.6.0; tabela de visão geral expandida para **7 ondas**; nova seção **"Forge-7 — AIOS agentes portáveis"** completa com tasks F7.1-F7.6 e critério de pronto (todas marcadas `[x]`)
- `docs/forge/decisions.md` — F24 adicionada; histórico expandido com linha v0.6.0

### Constitution

8 princípios C1–C8 **inalterados**. Forge-7 é evolução de empacotamento da Forge-6 (camada de implementação no consumidor), não princípio novo — não exige MAJOR bump.

---

## [0.5.0] — 2026-05-06

### Added (Forge-6 — AIOS Server camada de implementação multiagente)

**Suporte nativo no framework para projetos consumidores que adotam AIOS Server (`agiresearch/AIOS` v0.2.2, arXiv 2403.16971) como kernel LLM OS:**

**3 novos slash commands em `.claude/commands/acme/`:**

- `/acme:aios-init` — scaffolda estrutura `aios/agents/{module}/` (spec_agent + backend_agent + frontend_agent) com 4 checks pré-criação (spec existe, aios/config.yaml existe, Python 3.10+, ANTHROPIC_API_KEY)
- `/acme:aios-run` — wrapper para `python aios/orchestrator.py pipeline` com health check do kernel + **gates humanos C4 obrigatórios** após cada step (spec/build/test/review). Não re-executa automaticamente após gate rejeitado
- `/acme:aios-status` — comando read-only que exibe tabela de status de todos os módulos (spec/backend/frontend/testes/review/kernel) com detecção de BLOCKERs em review e fallback filesystem sem kernel

**3 commands existentes atualizados (mudanças condicionais — comportamento original preservado quando `aios_tier` ausente):**

- `/acme:plan` — seção 9 condicional "Classificação AIOS" com tabela de módulos, aviso C7 portabilidade (SYSTEM_PROMPTs standalone), próximos passos por tier
- `/acme:tasks` — Wave 2-AIOS com 4 tasks (T2-AIOS-1 init → T2-AIOS-2 build → T2-AIOS-3 test+review → T2-AIOS-4 mover para src/) emitida quando `spec.aios_tier` presente
- `/acme:implement` — bloco "Modo de implementação" no topo com detecção de `--via aios` ou `spec.aios_tier`, health check do kernel, redirecionamento para `/acme:aios-run`. Argumento opcional `via_aios` adicionado ao frontmatter

**Padrão de telemetria oficial:**

- `docs/forge/aios-telemetry-pattern.md` — Langfuse `trace.generation()` → `generation.end()` em cada `send_request()`, campos obrigatórios (`name`, `agent`, `module`, `tier`, `aios_version`, `trace_id`), mock fallback `_MockTrace` para dev local sem `LANGFUSE_PUBLIC_KEY`, integração com hook existente `langfuse-trace-check.sh`, mapeamento explícito C6/C7/C8

**Template atualizado:**

- `templates/platform-sku-spec.template.md` — campos `aios_tier` (A=autônomo, B=iterativo, C=Rafael-dirige) e `aios_context_boundaries` (spec_agent/backend_agent/frontend_agent) adicionados ao frontmatter após `owners:`. Defaults vazios — opt-in apenas se projeto consumidor usa AIOS

**Decisão registrada (F23):**

- `docs/forge/decisions.md` — F23 documenta adoção de AIOS pelo projeto consumidor SchoolPlatform/EDIX e o **mapeamento com a Constitution sem alterar princípios**: Tier A/B/C ↔ C5; `send_request()` + Langfuse ↔ C6; SYSTEM_PROMPTs standalone ↔ C7; `tenantId` em `task_input` ↔ C8

### Changed

- `manifest.json` versão `0.4.1 → 0.5.0`; nova seção `artifacts.commands.aios[]` com 3 entradas; `forge-aios-telemetry-pattern` adicionado em `forge_docs[]`; `_status` de commands atualizado para "Forge-2+5+6 — 15 commands"; `version_bumps.0.4.1_to_0.5.0` adicionado
- `docs/forge/roadmap.md` — header status atualizado para v0.5.0; tabela de visão geral expandida com Forge-6; nova seção **"Forge-6 — AIOS Server"** completa com tasks F6.1–F6.6 e critério de pronto (todas marcadas `[x]`)
- `docs/forge/decisions.md` — histórico expandido com linha v0.5.0 / F23

### Constitution

8 princípios C1–C8 **inalterados**. Forge-6 é camada de implementação no consumidor, não princípio novo — não exige MAJOR bump.

---

## [0.4.1] — 2026-05-04

### Fixed (sincronização de metadados — F22)

**6 divergências de versão/status corrigidas após auditoria interna pré-CI:**

- `README.md` — badges atualizados (`version-0.2.0` → `0.4.1`, `phase-Forge-0` → `Forge-5`); tabela "Status atual" corrigida para refletir Forge-1..5 concluídas; seção "Forge resolve com" expandida (items 5-8 adicionados: hooks, commands, agents, skills); "Estrutura do repositório" expandida com `.claude/{skills,agents,commands}/`, `hooks/`, `docs/playbooks/`, `docs/retrospectives/`, 3 templates novos e `reviewer/deepagents/`
- `.claude/settings.json` — `_forge_version: "0.3.0"` → `"0.4.1"`; `_constitution_version: "0.1.0"` → `"0.2.0"` (Constitution é fonte canônica — settings espelha)
- `docs/forge/decisions.md` — título e header atualizados para "F1–F22 / v0.4.1"; F22 adicionada documentando a sincronização e a política sha256
- `docs/forge/roadmap.md` — header de status atualizado para v0.4.1
- `docs/forge/manifest.json` — `manifest_version` e `framework.version` bumped para `0.4.1`; versões individuais de readme, changelog, forge-decisions, forge-roadmap, forge-manifest, claude-settings atualizadas; `sha256_policy: "post-install"` adicionado em `_meta`; `path_kind: "directory"` adicionado em `examples/acme/`; `version_bumps.0.4.0_to_0.4.1` adicionado

### Added

- `reviewer/README.md` — índice do diretório `reviewer/`, ordem de leitura para deep-agent e dev humano, tabela de assets, ponteiro para `deepagents/README.md` e `reviewer-contract.md`
- `docs/forge/manifest.json` — entry `reviewer-readme` em `artifacts.reviewer_assets`

---

## [0.4.0] — 2026-05-01

### Added (Forge-5 — Playbooks verticais)

**Infraestrutura para reutilização vertical (meta: cliente 2 ≤ 30% esforço do cliente 1):**

- `templates/playbook.template.md` — template de playbook vertical com blocos reutilizáveis por tier (confiança alta/média/baixa), padrão de TenantContext, métricas de esforço cliente 1 vs. cliente 2
- `templates/retrospective.template.md` — retrospectiva por SKU com compliance C1-C8, gate failures, métricas reais (C3 custo/preço, C4 SHADOW, C6 trace coverage), lições aprendidas
- `/acme:playbook-extract` — slash command que guia extração de playbook a partir de SKU em AUTONOMOUS; gera `docs/playbooks/{vertical}/playbook.md` + `docs/retrospectives/{sku}/`
- `docs/playbooks/README.md` + `docs/retrospectives/` — estrutura de diretórios no framework

**Decisões adicionadas:**
- **F19** — Estratégia de playbooks: blocos classificados por tier e confiança; PII fora do playbook; critério ≤30% obrigatório
- **F20** — Reavaliação F5.5 (deploy global `~/.claude/`): manter projeto-scoped; reavaliar com ≥5 projetos
- **F21** — Reavaliação F5.6 (plugin publication): não publicar ainda; critérios definidos (≥3 projetos AUTONOMOUS, ≥3 auditorias reais, Constitution estável ≥6 meses)

### Changed

- `manifest.json` versão `0.3.0 → 0.4.0` (12 commands: +playbook-extract; 12 templates: +playbook + retrospective)
- `docs/forge/decisions.md` — F19, F20, F21 adicionadas; histórico atualizado

---

## [0.3.0] — 2026-05-01

### Added (Forge-4 — Hooks runtime)

**9 hooks ativos em `.claude/settings.json`:**

| Hook | Tipo | Exit | Propósito |
|---|---|---|---|
| `outcome-clause-guard` | PreToolUse | 2 (block) | Bloqueia edição de outcome clauses aprovadas |
| `adr-approval-gate` | PreToolUse | 2 (block) | Bloqueia edição de ADRs assinadas |
| `secret-scan` | PreToolUse | 2 (block) | Detecta API keys / connection strings |
| `any-type-guard` | PreToolUse | 2 (block) | Bloqueia `any` TypeScript em src/skus + src/agents |
| `langfuse-trace-check` | PostToolUse | 1 (warn) | LLM calls sem trace Langfuse (C6) |
| `unit-economics-recalc` | PostToolUse | 1 (warn) | Prompts mudaram — recalc C3 necessário |
| `manifest-sync` | PostToolUse | 0 (info) | Artefatos Forge mudaram sem update de manifest |
| `5-gates-summary` | Stop | 0/1 | Relatório dos 5 gates ao fim de sessão |
| `eval-suite-fresh` | Stop | 0/1 | Eval suites < 30 casos (C4) ao fim de sessão |

**Bypass auditado:** `ACME_FORGE_BYPASS=<motivo>` em env ou `settings.local.json` (gitignored). Todos os bypasses registrados em `docs/forge/bypass-log/YYYY-MM-DD.md`.

**Skill security scan standalone:** `hooks/scripts/skill-security-scan.sh` — 5 checks (S1-S5: secrets, URLs, destrutivos, bypass, frontmatter) — para uso em CI/PR.

**Relatórios de sessão:** `docs/forge/session-gate-reports/` — persistidos pelo `5-gates-summary` hook.

### Changed

- `settings.json` `_forge_version` bumped `0.1.0 → 0.3.0`
- `settings.json` `_planned_features` → `_forge_features` (hooks_path adicionado)
- `manifest.json` versão `0.2.0 → 0.3.0`

---

## [0.2.0] — 2026-04-30

### Repositioning

**Forge agora é repositório standalone consumível por N projetos** (devs com Claude Code + DeepAgents + outros agentes autônomos), não mais framework embarcado em `acme-governanca-ia`.

### Added (multi-consumer enablement)

- **README.md** reescrito para 3 audiências (dev humano, deep-agent, framework-maintainer)
- **QUICKSTART.md** — instalar Forge em projeto novo em <5 minutos
- **ARCHITECTURE.md** — visão estrutural, fluxos, camadas de governança (1-6)
- **DEEPAGENT_GUIDE.md** — como agente autônomo navega o Forge para auditoria mensal
- **GLOSSARY.md** — vocabulário compartilhado entre humanos e agentes
- **CONTRIBUTING.md** — processo de evolução do framework

### Added (templates novos — 5)

- `templates/product-spec.template.md` — produtos self-serve (cliente loga; mensalidade fixa)
- `templates/diagnostic-spec.template.md` — Diagnóstico/Fase 0 cobrável
- `templates/lifecycle-stage.template.md` — declaração de stage (Discovery → Sunset) com critérios
- `templates/monthly-audit.template.md` — output do reviewer DeepAgent
- `templates/clickup-blueprint.template.md` — estrutura ClickUp aplicando Three-tier (opcional)

### Added (reviewer enablement — pasta `reviewer/`)

- `reviewer/prompt.template.md` — system prompt completo do DeepAgent reviewer
- `reviewer/output-schema.json` — JSON schema da auditoria mensal (validação machine-readable)
- `reviewer/validation-rules.json` — checks formais para cada princípio C1-C8
- `reviewer/example-audit.md` — exemplo sintético de relatório bem-feito (gabarito)

### Added (caso real como exemplo — pasta `examples/acme/`)

- `examples/acme/README.md` — overview do caso Acme
- `examples/acme/portfolio.md` — 3 categorias formais (Diagnóstico/Plataforma/Produtos)
- `examples/acme/constitution-extension.md` — princípios C9, C10, C11 específicos Acme (lifecycle, two-track economics, portfolio)
- `examples/acme/clickup-blueprint.md` — estrutura ClickUp interno Acme
- `examples/acme/methodology/` — 3 metodologias originais (clássica, SaaS², Sincra)
- `examples/acme/products/acme-fin.md` — Acme Fin (Beta em produção)
- `examples/acme/products/acme-educacional.md` — Acme Educacional (Discovery)

### Changed

- **Constitution v0.1.0 → v0.2.0**: princípios C1-C8 desacoplados de Acme específico; vocabulário multi-domínio (Tier 1/2/3 ou L0/L1/L2 ou Strategic/Tactical/Operational); refs Acme hardcoded movidas para `examples/acme/constitution-extension.md`
- **Manifest enriquecido**: `consumer_types[]`, `principle_extensions_path`, `reviewer.artifacts{}`, `templates[]` expandido para 9, `reviewer_assets[]`, `examples[]`
- **Decisions F2** atualizado: instalação como projeto-only → repositório standalone consumível externamente
- **`templates/sku-spec.template.md` → `templates/platform-sku-spec.template.md`**: renomeado para clareza (existem agora 3 tipos de spec: platform-sku, product, diagnostic)

### New decisions registered

- **F13** — Constitution genérica vs Acme-específica (extensões em `examples/`)
- **F14** — `examples/` como caso real, não conteúdo prescritivo
- **F15** — SemVer estrito com regras de bump claras
- **F16** — Distribuição privada por enquanto; reavaliar pós Forge-5

### Constitution principles status

8 princípios genéricos (inalterados em essência, refinados em vocabulário):

- C1 — Diagnose-before-design
- C2 — Outcome-first, never tech-first
- C3 — Cost ≤ 25% of price
- C4 — SHADOW antes de cobrar
- C5 — Three-tier context
- C6 — Telemetry-by-default
- C7 — Portability over lock-in
- C8 — Anti-customização heroica

Extensões Acme (em `examples/acme/constitution-extension.md`):

- C9 — Lifecycle declarado por produto/SKU
- C10 — Two-track economics
- C11 — Portfolio em 3 categorias

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

## [Unreleased] — Forge-3 em execução

### Added (2026-05-01) — 10 subagents Claude Code (`.claude/agents/`)

- **4 Guardians Opus** (decisão estratégica):
  - `po-guardian` — Product Owner; valida cláusula de outcome (C2), ICP fit, catalog fit; cross-approver mandatório do `/acme:promote` Gate 5
  - `artifact-architect` — **renomeado de `sku-architect`** (alinhamento v0.2.0 — multi-type artifact); plan 8 seções, `agent_readiness_score`, abstração C5/C7/C8; `target_model` advisory apenas
  - `unit-economist` — economic firewall; valida `c3_check`, baseline-cost, força recalc quando `prompt_hash` muda; bloqueia `/acme:sla-threshold` se unviable
  - `promotion-officer` — autoridade de transição de modo; Gate 5 do `/acme:promote`; cross-approval com `po-guardian`; refuta self-approval; gate adicional para `assisted_to_autonomous`
- **4 Guardians Sonnet** (validação técnica):
  - `eval-engineer` — eval suite quality; coverage por outcome_category, source_mode breakdown (real/synthetic/edge/adversarial), ground-truth justified, regressão por `prompt_hash`
  - `tenant-context-curator` — anti-customização (C8); lint regex de `tenantId === '...'`, `switch(tenantName)`, pastas `clients/{nome}/`; valida TenantContext schema
  - `observability-guardian` — telemetry-by-default (C6); Section 8 dos prompts, `observe()` wrapper, trace_coverage ≥99%, `prompt_hash` drift detection
  - `security-privacy-guardian` — PII/LGPD/secrets; lint em eval-cases, prompts, traces sample; **assinatura terceira mandatória** para `assisted_to_autonomous`
- **2 cross-LLM reviewers**:
  - `code-reviewer-claude` (Sonnet) — code review nativo Claude para PRs (focado em src/, prompts/, evals/)
  - `code-reviewer-cross` (Haiku, delegator) — **bridge** para o DeepAgent externo (`forge-auditor` via deepagents CLI); não revisa diretamente; orquestra invocação + traduz output

### Added — Template ADR-002

- `templates/adr-reviewer-runtime.template.md` — template para projeto consumidor adaptar como `docs/adr/002-reviewer-runtime.md`. Cobre 7 decisões (D1-D7): local de execução, modelo do DeepAgent, provedor de telemetria, cadência, output, auto-rollback, credenciais

### Smart routing

| Tier de decisão | Modelo | Quantidade |
|---|---|---|
| Estratégico (outcome, arquitetura, economics, promotion) | Opus | 4 |
| Validação técnica (eval, tenant, telemetry, security) | Sonnet | 4 |
| Code review nativo | Sonnet | 1 |
| Delegator para DeepAgent externo | Haiku | 1 |

### Renaming registrado

- `sku-architect` → `artifact-architect` (v0.2.0 já abriu caminho com `templates/{platform-sku,product,diagnostic}-spec.template.md`; agora consistente também nos guardians). Histórico em `naming_history` no frontmatter.

### Manifest

- `artifacts.agents{}` populado com 3 grupos (`guardians_opus`, `guardians_sonnet`, `cross_llm_reviewers`) — total 10 entradas
- `artifacts.templates[]` cresce de 9 para 10 (adiciona `template-adr-reviewer-runtime`)
- `framework.phase` indica "Forge-3 in progress — 10 SKILL.md + 8 Guardians + 2 cross-LLM reviewers delivered"

### Pendente em Forge-3 (responsabilidade do consumer)

- ADR-002 efetiva no projeto consumidor (template entregue)
- Primeira auditoria mensal de teste com `forge-auditor` rodando contra repo real

---

## [Pré-Forge-3 agents] — Reviewer DeepAgent infraestrutura

### Added (2026-05-01) — Reviewer DeepAgent (F17 + F18)

- **Decisões F17/F18 registradas** em `docs/forge/decisions.md`:
  - F17: stack do reviewer = **`deepagents` CLI (Python, LangChain) v0.0.34+**; processo separado, modelo configurável via `DEEPAGENTS_MODEL`
  - F18: tradução Claude Code → Deep Agents via `andersonamaral2/Claude-Code-to-Deep-Agents-Skills-Converter` (MIT); skills do Forge ficam canônicas em `.claude/skills/`, versão Deep Agents em `reviewer/deepagents/skills/` é **gerada** (nunca editada à mão)

- **Estrutura `reviewer/deepagents/`** criada:
  - `README.md` — guia de instalação (Deep Agents CLI + converter + 10 skills) e uso
  - `conversion-log.md` — histórico de conversões com hash da origem para detectar drift
  - `skills/L0/{company-dna,icp-loader,offerings-loader}/SKILL.md` — 3 skills Tier 1 convertidas
  - `skills/L1/{baseline-cost-builder,diagnostic-runner,process-mapper}/SKILL.md` — 3 skills Tier 2 convertidas
  - `skills/L2/{artifact-prompt-builder,eval-case-author,shadow-mode-runner}/SKILL.md` — 3 skills Tier 3 convertidas
  - `skills/reviewer/forge-auditor/SKILL.md` — **skill nativa Deep Agents** (não convertida) que orquestra a auditoria mensal C1-C8 via 9 sub-agents `task` paralelos

- **8 transformações T1-T8** aplicadas em cada conversão:
  - T1 Execution Context (tabela de tools `read_file/write_file/execute/task`)
  - T2 Execution Plan (`write_todos` checklist)
  - T3 Prerequisites (verificação tools/env via `execute`)
  - T4 Explicit `write_file`
  - T5 Inline tests via `execute`
  - T6 Sub-agents via `task` (quando aplicável)
  - T7 Usage guide (3 modos: interactive, one-shot, CI/CD)
  - T8 Troubleshooting

- **Manifest** atualizado: `framework.reviewer.stack` declarado, `implementation_status` mudado de `specified-not-implemented` para `infrastructure-complete`, lista completa dos 10 SKILL.md em `deepagents_skills[]`

- **Output do reviewer**: `forge-auditor` produz `docs/forge/audits/{YYYY-MM}.md` validado contra `reviewer/output-schema.json`. Auditoria roda 9 checks em paralelo (C1-C8 + structural drift) via `task`.

### Pendente em Forge-3

- 8 Subagent Guardians (`po-guardian`, `sku-architect`, `unit-economist`, `eval-engineer`, `tenant-context-curator`, `observability-guardian`, `promotion-officer`, `security-privacy-guardian`)
- 2 Cross-LLM reviewers (`code-reviewer-claude`, `code-reviewer-cross`)
- ADR-002 do projeto consumidor (decisão de runtime do reviewer no consumer)
- Primeira auditoria mensal de teste

---

## [Pré-Forge-3] — Forge-1 em execução

### Added (Forge-1 — Tier 1 entregue, 2026-04-30)

- **3 skills L0 (Tier 1 estratégico)** em `.claude/skills/L0/` com helper pattern BMAD:
  - `company-dna.md` — carrega DNA da organização (purpose, mission, values, north-star) em YAML compacto cacheável
  - `icp-loader.md` — carrega Ideal Customer Profile com sinais de qualificação e **anti-ICP** mandatório
  - `offerings-loader.md` — carrega catálogo de ofertas com `lifecycle_stage` e `pricing_model` declarados
- **`docs/forge/helper-pattern.md`** — documenta padrão BMAD (cache `ephemeral-strong`, namespace `__forge_cache.<key>`, regras hard R1-R4) com meta de ≥70% redução de tokens
- **Manifest** atualizado: `artifacts.skills.L0[]` populado com 3 entradas; `framework.phase` mudada para `Forge-1 in progress`

### Padrão das skills L0 (canonical reference)

Cada skill segue estrutura:
- Frontmatter Anthropic (`name`, `description`) + extensões Forge (`tier`, `linked_principles`, `helper_pattern`, `cache_strategy`, `reads_from_tier`, `must_not_read`, `activation.{paths,keywords,explicit_invocation}`)
- Tabela anti-rationalization (Addy Osmani) — 5 tentações comuns × resposta correta
- Verification gate com checklist
- C5 hard rule (Tier 1 **não** lê Tier 2/3)
- Saída de erro estruturada com enum

### Scope decision

Forge-1 escopo enxuto: apenas **9 skills genéricas** no Forge. As 4 skills Acme-específicas (`tenant-onboarding`, `outcome-classifier`, `billing-calculator`, `flywheel-collector`) ficam em `examples/acme/skills/` (consumidas por `acme-governanca-ia`), respeitando F13/F14.

### Added (Forge-2 — validation entregue, 2026-04-30) — **Forge-2 completa: 11/11 commands**

- **4 slash commands** em `.claude/commands/acme/` fechando o pipeline:
  - `/acme:eval` — executa eval suite com **pass rate por outcome_category** + **source_mode breakdown** (real/synthetic/edge/adversarial) + detecção de **regressão** vs último run com mesmo `prompt_hash`. Sub-trace por case (100%, sem amostragem)
  - `/acme:promote` — **único caminho legítimo** para mudar `subscription.mode`; valida **5 gates** obrigatórios (C2 outcome clause hash match, C3 viable + recalc clean, C4 SLA pré-contratada com signature, eval recente verde, aprovação cruzada PO × Promotion Officer). Append-only log em `subscriptions/{id}/promotions.md`
  - `/acme:audit-monthly` — sample 5-10% de runs ASSISTED/AUTONOMOUS, audit estrutural C1-C8 (lint regex C7/C8 + correspondência prompt ↔ baseline-cost), drift detection, formato consumível pelo reviewer DeepAgent (`reviewer/output-schema.json`). Suporta `auto_rollback_on_breach: false` (default — bypass exige flag explícita)
  - `/acme:pre-merge-check` — **read-only**, < 30s, **5 gates** mecânicos (G1 C7 imports, G2 C8 hardcode, G3 C6 observe, G4 manifest sync, G5 eval green). Exit code 0/1/2 para CI/pre-commit; integração com hook `pre-merge-check` virá em Forge-4

- **Pipeline completo end-to-end** agora encadeado nos 11 commands:
  ```
  /diagnose → /spec → /unit-economics → /sla-threshold
            → /plan → /tasks → /implement
            → /eval → /promote --to_mode=start_shadow
            → (14+ dias) → /eval → /promote --to_mode=shadow_to_assisted
            → (30+ dias) → /promote --to_mode=assisted_to_autonomous
            → /audit-monthly (mensal)
  /pre-merge-check em todo PR
  ```

- **Bloqueio mecânico de promoção**: nenhuma skill ou command (exceto `/acme:promote`) pode mudar `subscription.mode`. `@shadow-mode-runner.start` checked twice (pre-condição em command + skill).

### Pendente em Forge-2

- Nenhum item — onda concluída.

- **3 slash commands** em `.claude/commands/acme/` para a fase de implementação:
  - `/acme:plan` — gera plano técnico em **8 seções canônicas** (escopo derivado da spec, camadas C5/C7, fluxo input→output, pontos de instrumentação C6, TenantContext schema C8, cronograma com faixas, riscos enumerados, critérios de pronto). `target_model_advisory` apenas — escolha de modelo concreto fica para ADR-002 ou config (C7)
  - `/acme:tasks` — quebra plan em **DAG validado** (sem ciclos) distribuído em 5 ondas: (1) scaffolding C5/C6/C7/C8, (2) prompt build via `@artifact-prompt-builder`, (3) eval seed via `@eval-case-author` em loop até `c4_threshold_met: true` por categoria, (4) SHADOW prep (sem iniciar), (5) métricas e alertas. Cada task tem gate de pronto verificável (lint, test, hash)
  - `/acme:implement` — executa as 5 ondas em ordem topológica do DAG, gera **stubs boilerplate** (`src/llm/adapters/`, `src/observability/trace.ts`, `src/tenants/context.ts`, `src/skus/{id}/index.ts`, `src/skus/{id}/prompt.ts`), enforce mecânico de C6/C7/C8 (lint regex), pausa em gates subjetivos. **Nunca inicia SHADOW** — bloqueio enforced via `error: shadow_start_attempted`

- **Princípio de design**: implement gera estrutura mínima viável com `TODO` explícito; conhecimento de domínio fica com o dev. Provider e modelo concretos são decisão do consumidor, não do framework

### Pendente em Forge-2

- F2.3 validação: `/acme:eval`, `/acme:promote`, `/acme:audit-monthly`, `/acme:pre-merge-check` (4 commands)

---

### Added (Forge-2 — spec/economics entregue, 2026-04-30) — 4/11 commands

- **4 slash commands** em `.claude/commands/acme/` orquestrando as skills do Forge-1:
  - `/acme:diagnose` — Fase 0 cobrável; orquestra `@diagnostic-runner` + helpers L0; persiste `docs/clients/{client_id}/diagnostic.md`
  - `/acme:spec` — **renomeada de `/acme:spec-sku`**; aceita `--type=platform-sku|product|diagnostic` resolvendo o template correto pós-v0.2.0; cláusula de outcome copiada literalmente do diagnostic com hash registrado
  - `/acme:unit-economics` — invoca `@baseline-cost-builder`; **bloqueia** `/acme:sla-threshold` se `c3_check.status == unviable`; cross-valida volume diagnostic vs process-map (±20%)
  - `/acme:sla-threshold` — pré-contrata `c4_thresholds` com **aprovação humana explícita + signature_hash**, hard floor `min_window_days >= 14`, validação de consistência com C3, bloqueio de self-approval (checks-and-balances comercial × engenharia)

- **Padrão de slash command** estabelecido (canonical para F2.2/F2.3):
  - Frontmatter: `description`, `allowed-tools`, `arguments.{required,optional}`, `linked_principles`, `invokes_skills`, `output_artifact`, `trace_required`, opcional `human_approval_required`
  - Pre-conditions explícitas (estado do repo necessário antes de iniciar)
  - Sequência de execução numerada (start trace → helpers → tier 2 reads → core skill → persist → end trace)
  - Output structured (YAML) com `next_step` apontando próximo command
  - Verification gate com checklist
  - Tabela anti-rationalization
  - Saída de erro estruturada com enum
  - Trace Langfuse mesmo em uso manual (C6)

- **Decisão de naming**: `/acme:spec-sku` → `/acme:spec` para alinhar ao reposicionamento v0.2.0 (3 templates de spec disponíveis). Mudança documentada no histórico do command.


---

### Added (Forge-1 — Tier 3 entregue, 2026-04-30) — todas as skills genéricas concluídas (9/9)

- **3 skills L2 (Tier 3 operacional)** em `.claude/skills/L2/` fechando a cadeia operacional:
  - `artifact-prompt-builder.md` — constrói system prompt versionado em **9 seções canônicas** (identidade, contexto Tier 1 cacheado, cláusula de outcome literal, schema de input/output, processo do mapper, guard-rails C3, instrumentação C6 obrigatória, anti-hardcode C8). Persiste em `prompts/{artifact}/v{version}/system.md` com `prompt_hash` (sha256:16) e flag `recalc_unit_economics_required: true` em todo build
  - `eval-case-author.md` — gera eval cases em 4 source modes (`real | synthetic | edge | adversarial`), enforça sanitização PII pré-persistência, exige justificativa do gabarito, persiste em `evals/{artifact}/cases/`. Cap default ≤ 40% sintético; alvo ≥ 60% real após 90 dias
  - `shadow-mode-runner.md` — coordena SHADOW em 3 ações (`start | tick | report`), enforça mecanicamente C4 (≥ 14 dias, `delivered: false` em todo trace, `prompt_hash` imutável durante janela), produz `report-{artifact}-{date}.md` com recomendação **mas não auto-promove** (assinatura humana mandatória)
- **Padrão Tier 3** estabelecido: `reads_from_tier: [1, 2, 3]`, `must_not_read: []`, output em paths versionados ou cliente-específicos, hash sha256:16 para imutabilidade auditável

---

### Added (Forge-1 — Tier 2 entregue, 2026-04-30)

- **3 skills L1 (Tier 2 tático)** em `.claude/skills/L1/` com handoffs declarados entre si:
  - `baseline-cost-builder.md` — calcula custo humano (volume × tempo × custo-hora) e deriva `min_price_per_outcome` para satisfazer C3 (custo ≤ 25%); persiste em `docs/clients/{client}/baseline-cost-{process}.md`
  - `diagnostic-runner.md` — roteiro estruturado de **10 blocos** (problema, custo do não-resolvido, baseline, tentativas, outcome candidato, métrica, tolerância, ICP fit, catálogo fit, próximos passos) com handoff para `baseline-cost-builder` e `process-mapper`; persiste `diagnostic.md`
  - `process-mapper.md` — mapeia processo as-is em formato agent-ready (trigger, atores, steps tabulares, decision points, métricas) + `agent_readiness_score` heurístico; persiste `process-{name}.md`
- **Padrão Tier 2** (canonical para Tier 3): `helper_pattern: none` (consome cache L0, não cacheia), `reads_from_tier: [1, 2]`, `must_not_read: [3]`, `requires_helper:` declara dependências L0, parâmetros obrigatórios incluem `client_id`/`process_id`, output persistido em arquivo (não in-memory)
- **Manifest** atualizado: `artifacts.skills.L1[]` populado; `framework.phase` → `Tier 1 + Tier 2 generic skills delivered: 6/9`

### Pendente em Forge-1

- 4 skills Acme-específicas em `examples/acme/skills/` (F1.6 — escopo opcional)
- Validação empírica do `≥70% redução de tokens` (medível só em Forge-3 com Langfuse)

---

## [Próximas ondas]

### Forge-1 (resíduo) — Acme examples

- 4 skills em `examples/acme/skills/` (`tenant-onboarding`, `outcome-classifier`, `billing-calculator`, `flywheel-collector`)

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
