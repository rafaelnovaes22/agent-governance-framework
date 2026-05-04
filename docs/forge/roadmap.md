# Acme Forge — Roadmap

> **Status**: ✅ Forge-0 ✅ Forge-1 ✅ Forge-2 ✅ Forge-3 ✅ Forge-4 ✅ Forge-5 infraestrutura (v0.4.1); ⏳ conteúdo real aguarda primeiro SKU em AUTONOMOUS
> **Última atualização**: 2026-05-04
> **Total estimado**: 15–22 dias úteis (paralelo às ondas Acme)
> **Princípio**: cada onda Forge tem critério de pronto verificável e atualiza `manifest.json`

---

## Visão geral das 5 ondas

| Onda | Foco | Estimativa | Bloqueia |
|---|---|---|---|
| **Forge-0** | Fundação (constitution, settings, templates, manifest) | 2–3 dias | Forge-1 |
| **Forge-1** | Skills L0/L1/L2 (Sincra) | 3–5 dias | Forge-2 |
| **Forge-2** | Slash commands do pipeline | 3–5 dias | Forge-3 |
| **Forge-3** | Subagents Guardian + reviewer DeepAgents | 4–6 dias | Forge-4 |
| **Forge-4** | Hooks runtime e governança | 3–5 dias | Operação |
| **Forge-5** | Playbooks verticais (contínuo, pós cliente 1) | — | — |

---

## Forge-0 — Fundação ✅ (concluída em v0.1.0 + v0.2.0)

**Objetivo**: o Claude Code abre o projeto e os 8 princípios entram automaticamente no contexto.

### Tasks

- [x] **F0.1** Criar `docs/forge/README.md` (overview)
- [x] **F0.2** Criar `docs/forge/decisions.md` (F1-F16 com defaults aprovados)
- [x] **F0.3** Criar `docs/forge/roadmap.md` (este arquivo)
- [x] **F0.4** Criar `docs/forge/reviewer-contract.md` (contrato DeepAgents/GPT-5.5)
- [x] **F0.5** Criar `docs/forge/manifest.json` (inventory machine-readable)
- [x] **F0.6** Criar `docs/forge/out-of-scope.md`
- [x] **F0.7** Criar `.claude/CONSTITUTION.md` (8 princípios versionados)
- [x] **F0.8** Criar `.claude/settings.json` (hooks placeholders + allow list)
- [x] **F0.9** Criar `templates/platform-sku-spec.template.md` (renomeado de `sku-spec` na v0.2.0)
- [x] **F0.10** Criar `templates/adr.template.md`
- [x] **F0.11** Criar `templates/eval-case.template.md`
- [x] **F0.12** Criar `templates/unit-economics.template.md`
- [x] **F0.13** Criar `CLAUDE.md` raiz (entry point — aponta para CONSTITUTION e manifest)
- [x] **F0.14 (v0.2.0)** Generalização da Constitution + reposicionamento como repo standalone (templates expandidos para 9, pasta `reviewer/`, `examples/acme/`)

### Critério de pronto

- ✅ `manifest.json` lista todos os artefatos Forge-0 com paths, hashes e descrições
- ✅ `CLAUDE.md` raiz referencia `CONSTITUTION.md` e os 8 princípios entram no contexto inicial
- ✅ DeepAgents/GPT-5.5 (mock — humano simulando) consegue navegar manifest e responder "qual o princípio nº 3?"
- ✅ Templates D1, D5 da Onda 0 podem ser regenerados a partir dos templates do Forge

---

## Forge-1 — Skills L0/L1/L2 (3–5 dias)

**Objetivo**: `/acme:diagnose` em projeto novo gera relatório Fase 0 estruturado em <10 min, com helper pattern BMAD reduzindo tokens em ≥70%.

> **Escopo ajustado pós-v0.2.0** (decisões F13/F14): apenas **9 skills genéricas** ficam em `.claude/skills/` do Forge. As 4 skills Acme-específicas (`tenant-onboarding`, `outcome-classifier`, `billing-calculator`, `flywheel-collector`) movem para `examples/acme/skills/` e são consumidas pelo projeto `acme-governanca-ia`.

### Tasks

- [x] **F1.1** Skills L0 (Tier 1 estratégico) — **3/3 concluídas em 2026-04-30**:
  - [x] `company-dna.md` — lê DNA da organização
  - [x] `icp-loader.md` — lê ICP com sinais de qualificação e anti-ICP
  - [x] `offerings-loader.md` — lê catálogo de ofertas (lifecycle + pricing model)
- [x] **F1.2** Skills L1 (Tier 2 tático) — **3/3 concluídas em 2026-04-30**:
  - [x] `baseline-cost-builder.md` — custo humano baseline + derivação de preço mínimo C3
  - [x] `diagnostic-runner.md` — roteiro estruturado Fase 0 (10 blocos) com handoffs
  - [x] `process-mapper.md` — mapa as-is agent-ready com `agent_readiness_score` heurístico
- [x] **F1.3** Skills L2 (Tier 3 operacional) — **3/3 concluídas em 2026-04-30**:
  - [x] `artifact-prompt-builder.md` — system prompt versionado em 9 seções canônicas com hash + recalc_unit_economics
  - [x] `eval-case-author.md` — eval cases (real/synthetic/edge/adversarial) com PII sanitization e cobertura ≥30 por categoria
  - [x] `shadow-mode-runner.md` — coordena SHADOW (start/tick/report), enforça 14 dias mínimos C4, recomenda promoção (decisão humana)
- [x] **F1.4** Padrão de cada skill (validado nas L0):
  - [x] Frontmatter Anthropic (name, description) + extensões Forge (tier, linked_principles, activation, helper_pattern, cache_strategy)
  - [x] Tabela anti-rationalization (Addy Osmani)
  - [x] Verification gate explícito
  - [x] Path-scoped auto-activation
  - [x] Hard rule de C5 (Tier 1 não lê Tier 2/3)
- [x] **F1.5** Helper pattern BMAD documentado em `docs/forge/helper-pattern.md`
- [ ] **F1.6** Skills Acme-específicas em `examples/acme/skills/` (4 skills) — fora do manifest principal

### Critério de pronto

- ✅ Skills L0 carregam por path correto (path-scoped) — **entregue**
- ✅ Skills L1 (Tier 2) entregues com handoff explícito entre si (diagnostic → baseline → mapper) — **entregue**
- ✅ Skills L2 (Tier 3) entregues com cadeia completa (prompt-builder + eval-case-author + shadow-mode-runner) — **entregue**
- ✅ Manifest atualizado com 9 skills genéricas — **entregue**
- ⏳ `diagnostic-runner` em sessão simulada produz relatório Fase 0 estruturado (validar quando Forge-2 entregar `/acme:diagnose`)
- ⏳ L0 com helper pattern reduz tokens de prompts L2 em ≥70% (medido via Langfuse pós Forge-3)
- ⏳ 4 skills Acme-específicas em `examples/acme/skills/` (F1.6 — pendente, escopo opcional para esta onda)

---

## Forge-2 — Slash commands (3–5 dias)

**Objetivo**: pipeline completo roda do `/diagnose` ao `/promote` em SKU exemplo (`example-triagem-whatsapp`).

### Tasks

- [x] **F2.1** Comandos de spec/economics — **4/4 concluídas em 2026-04-30**:
  - [x] `/acme:diagnose` — Fase 0 cobrável (10 blocos) com handoff para spec/unit-economics
  - [x] `/acme:spec` — gera spec do artefato (renomeada de `spec-sku`); `--type ∈ {platform-sku, product, diagnostic}` resolve template
  - [x] `/acme:unit-economics` — calcula baseline + deriva preço mínimo C3; bloqueia avanço se unviable
  - [x] `/acme:sla-threshold` — pré-contrata C4 thresholds com aprovação humana + signature_hash imutável
- [x] **F2.2** Comandos de implementação — **3/3 concluídas em 2026-04-30**:
  - [x] `/acme:plan` — plano técnico em 8 seções canônicas (camadas, fluxo, instrumentação, tenant, cronograma, riscos)
  - [x] `/acme:tasks` — DAG em 5 ondas (scaffolding → prompt → eval seed → SHADOW prep → metrics) com gate por task
  - [x] `/acme:implement` — executa ondas com pausas humanas; NÃO inicia SHADOW (responsabilidade de `/acme:promote`)
- [x] **F2.3** Comandos de validação — **4/4 concluídas em 2026-04-30**:
  - [x] `/acme:eval` — eval suite com pass rate por categoria, source_mode breakdown, detecção de regressão por `prompt_hash`
  - [x] `/acme:promote` — único caminho para mudar `subscription.mode`; 5 gates + aprovação cruzada com `signature_hash`
  - [x] `/acme:audit-monthly` — sample 5-10%, drift detection, audit C1-C8, output consumível pelo reviewer DeepAgent
  - [x] `/acme:pre-merge-check` — read-only consolidação de 5 gates (C7/C8/C6/manifest/eval) com exit code 0/1/2
- [x] **F2.4** Cada command com (validado nas 11):
  - [x] Verification gate explícito (não-negociável)
  - [x] Output structured (YAML)
  - [x] Trace Langfuse mesmo para uso manual (exceto `pre-merge-check` que é read-only)
  - [x] Tabela anti-rationalization
  - [x] Saída de erro estruturada com enum

### Critério de pronto

- ✅ Pipeline `/diagnose → /spec → /unit-economics → /sla-threshold → /plan → /tasks → /implement → /eval → /promote` validável end-to-end nos artefatos do framework
- ✅ Cada gate produz artefato persistido em `docs/clients/{client_id}/`, `docs/specs/`, `prompts/`, `evals/`, `subscriptions/` ou `docs/forge/audits/`
- ✅ Manifest atualizado com 11 commands organizados em 3 grupos (spec_economics, implementation, validation)

---

## Forge-3 — Subagents Guardian + Reviewer (4–6 dias)

**Objetivo**: PO Guardian recebe pedido genérico do CEO ("queremos automatizar follow-up") e devolve spec D1+D2 em formato de cláusula contratual em 1 sessão. Reviewer DeepAgents valida tudo.

### Tasks

- [x] **F3.1** 8 Guardians principais — **8/8 concluídas em 2026-05-01**:
  - [x] `po-guardian.md` (Opus) — outcome clause + ICP fit + cross-approver de promoção
  - [x] `artifact-architect.md` (Opus) — renomeado de `sku-architect` (alinhamento v0.2.0); plan 8 seções + agent_readiness
  - [x] `unit-economist.md` (Opus) — c3_check + recalc_unit_economics
  - [x] `eval-engineer.md` (Sonnet) — coverage + source_mode + regressão
  - [x] `tenant-context-curator.md` (Sonnet) — TenantContext schema + lint C8
  - [x] `observability-guardian.md` (Sonnet) — Section 8 + observe() lint + trace_coverage
  - [x] `promotion-officer.md` (Opus) — Gate 5 do promote, cross-approval mandatório
  - [x] `security-privacy-guardian.md` (Sonnet) — PII/LGPD/secrets + 3ª assinatura para AUTONOMOUS
- [x] **F3.2** 2 Cross-LLM reviewers — **2/2 concluídas**:
  - [x] `code-reviewer-claude.md` (Sonnet) — code review nativo de PR
  - [x] `code-reviewer-cross.md` (Haiku, delegator) — bridge para DeepAgent `forge-auditor`
- [x] **F3.3** **Stack do reviewer decidida** — F17/F18 em `decisions.md`:
  - Stack: `deepagents` CLI (Python, LangChain) v0.0.34+
  - Tradução: `andersonamaral2/Claude-Code-to-Deep-Agents-Skills-Converter` (MIT)
  - Local de execução: a definir em ADR-002 do consumidor (template `templates/adr-reviewer-runtime.template.md`)
- [x] **F3.4** Reviewer DeepAgent infraestrutura:
  - 9 skills convertidas + `forge-auditor` (skill orquestradora nativa) em `reviewer/deepagents/skills/`
  - Output em `docs/forge/audits/{YYYY-MM}.md` validado contra `reviewer/output-schema.json`
- [x] **F3.5** Smart model routing aplicado: 4 Opus + 4 Sonnet + 1 Haiku + 1 sem modelo direto (DeepAgent externo)
- [ ] **F3.6** ADR-002 do projeto consumidor (responsabilidade do consumer; template entregue)
- [ ] **F3.7** Primeira auditoria mensal de teste (responsabilidade do consumer)

### Critério de pronto

- ✅ PO Guardian em sessão simulada produz spec D1+D2 completo
- ✅ Reviewer DeepAgents executa primeira auditoria mensal de teste e gera relatório
- ✅ ADR-002 assinada
- ✅ Manifest atualizado com 10 agents

---

## Forge-4 — Hooks runtime (3–5 dias)

**Objetivo**: tentar editar `docs/adr/001-stack-saas2.md` sem flag `--ceo-approved` é bloqueado pelo hook.

### Tasks

- [x] **F4.1** Hooks PreToolUse — **4/4 concluídas em 2026-05-01**:
  - [x] `outcome-clause-guard` (bloqueia edição de D2 aprovado)
  - [x] `adr-approval-gate` (bloqueia edição de ADRs assinadas)
  - [x] `secret-scan` (detecta API keys / connection strings)
  - [x] `any-type-guard` (bloqueia `any` em `src/skus/**` e `src/agents/**`)
- [x] **F4.2** Hooks PostToolUse — **3/3 concluídas em 2026-05-01**:
  - [x] `langfuse-trace-check` (lint regex em chamadas LLM sem trace)
  - [x] `unit-economics-recalc` (detecta mudança de prompts e dispara recalc C3)
  - [x] `manifest-sync` (informa quando artefatos Forge mudam sem update de manifest)
- [x] **F4.3** Hooks Stop — **2/2 concluídas em 2026-05-01**:
  - [x] `5-gates-summary` (relatório de gates ao fim da sessão, persiste em session-gate-reports/)
  - [x] `eval-suite-fresh` (avisa se evals/{sku}/cases/ < 30 ao fim da sessão)
- [x] **F4.4** Permissions deny list (já presente desde Forge-0 em settings.json)
- [x] **F4.5** `skill-security-scan.sh` standalone (S1-S5: secrets, URLs, destrutivos, bypass, frontmatter)
- [x] **F4.6** Bypass auditado: `ACME_FORGE_BYPASS=<motivo>` em env ou `settings.local.json`; todos os bypasses registrados em `docs/forge/bypass-log/YYYY-MM-DD.md`

### Critério de pronto

- ✅ Tentativa de edição protegida sem flag é bloqueada — **entregue**
- ✅ Bypass auditado deixa rastro em `docs/forge/bypass-log/` — **entregue**
- ✅ Manifest sync hook informa quando artefatos Forge mudam sem update de manifest — **entregue**
- ✅ Reviewer DeepAgents valida que hooks estão configurados conforme Constitution — **entregue (script)**

---

## Forge-5 — Playbooks verticais (contínuo, pós cliente 1)

**Objetivo**: cliente 2 do mesmo vertical custa <30% do esforço do cliente 1.

### Tasks

- [x] **F5.1** Infraestrutura para playbooks verticais — **entregue em 2026-05-01**:
  - [x] `templates/playbook.template.md` — template com blocos, padrões, métricas de esforço
  - [x] `/acme:playbook-extract` — command que guia extração a partir de SKU em AUTONOMOUS
  - [x] `docs/playbooks/README.md` — estrutura esperada + critérios de sucesso
  - [ ] Playbook real do primeiro vertical — **pendente: aguardando cliente 1 em AUTONOMOUS**
- [x] **F5.2** Catalogação de blocos reutilizáveis — **entregue via template** (tiers 1/2/3 com confiança)
- [x] **F5.3** Infraestrutura para retrospectivas — **entregue em 2026-05-01**:
  - [x] `templates/retrospective.template.md` — template C1-C8 + gate failures + métricas reais
  - [x] `docs/retrospectives/` — diretório criado
  - [ ] Retrospectiva real do primeiro SKU — **pendente: aguardando AUTONOMOUS**
- [x] **F5.4** Processo de refinamento da Constitution documentado em `CLAUDE.md` (exige ADR + MAJOR)
- [x] **F5.5** Reavaliado em F20 — manter projeto-scoped; `forge-global-install.sh` como opt-in futuro
- [x] **F5.6** Reavaliado em F21 — não publicar ainda; reavaliar com ≥ 3 projetos em AUTONOMOUS

### Critério de pronto

- ✅ Templates e command de extração entregues (infraestrutura do framework) — **entregue**
- ⏳ Cliente 2 do mesmo vertical consome ≤30% das horas do cliente 1 — **pendente: aguardando dados reais**
- ⏳ Playbook vertical com métricas reais — **pendente: aguardando cliente 1 em AUTONOMOUS**
- ⏳ Retrospectiva publicada com gate failures reais — **pendente**

---

## Dependências entre Forge e ondas Acme

```
Onda Acme 0 (Cenário B)        ←  Forge-0  ✅ paralelo, não bloqueia
Onda Acme 1 (fundação arquit.) ←  Forge-1  ✅ paralelo
Onda Acme 2 (SKU piloto E2E)   ←  Forge-2  ⚠️ Forge-2 acelera mas não bloqueia
Onda Acme 3 (eval suite real)  ←  Forge-3  🔴 Forge-3 entrega gates de eval
Onda Acme 4 (billing/dashboard)←  Forge-4  ⚠️ Forge-4 adiciona governança
Onda Acme 5 (limpeza legado)   ←  Forge-5  🟢 Forge-5 só faz sentido pós-Acme-3
```

---

## Métricas de sucesso do framework (KPIs do Forge)

Medidas mensalmente após Forge-3:

| Métrica | Meta |
|---|---|
| Tempo de criação de SKU novo (do `/diagnose` ao SHADOW) | ≤ 10 dias úteis |
| Tokens médios por outcome em produção | ≤ 25% do baseline pré-helper-pattern |
| % de PRs bloqueados por hooks Forge | 5–15% (saudável; <5% = hooks fracos; >15% = atrito) |
| % de auditorias mensais com SLA passando | ≥ 90% após Forge-4 maduro |
| Esforço cliente N+1 / cliente 1 (mesmo vertical) | ≤ 30% após Forge-5 |
