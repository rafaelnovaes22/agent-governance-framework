# Acme Forge — Decisões F1–F29

> **Status**: ✅ Defaults aprovados em 2026-04-30 (v0.1.0) e refinados em ondas subsequentes até v0.12.0 (Forge-12 Fase 2)
> **Versão atual**: 0.12.0

Decisões fundacionais do framework Acme Forge. Mudança em qualquer uma destas exige nova ADR.

---

## F26 (NOVO 2026-05-08) — Forge delivery-type agnostic (Forge-9)

**Decisão**: ✅ **O Forge passa a suportar formalmente quatro `project_type` (`agentic_saas`, `platform`, `automation`, `hybrid`) e o booleano `ai_enabled`, com matriz de interpretação por princípio**.

**Motivação**: o framework foi forjado a partir do caso Acme SaaS² e até a v0.7.0 pressupunha que todo projeto consumidor entregava agentes de IA com governança de outcome cobrável. Em 2026-05-08 entrou em pauta o caso `school-platform` (sucessor de CAPSYSTEM): plataforma SaaS/operacional com módulos CRUD/CRM/financeiro/Tele-Pesquisa/Jovens — sem prompts, sem Langfuse, sem custo de inferência. Aplicar regras LLM-centric a esse projeto produziria FAILs falsos no reviewer e pediria artefatos inexistentes. A escolha foi: **(a)** criar um framework irmão "Forge-Platform", duplicando manutenção; ou **(b)** generalizar o Forge para reconhecer múltiplos tipos de entrega. Optamos por (b) — preserva 8 princípios canônicos, evita fork, e ainda permite projetos `hybrid` (plataforma com 1-2 módulos agênticos).

**Implicações arquiteturais**:

1. **Constitution v0.3.0** — cada princípio C1-C8 ganhou seção "Como validar — por `project_type`":
   - C1 renomeado para "Diagnose-before-build" (de "Diagnose-before-design" — agora também para módulos/jobs).
   - C3 generalizado: modelo `cost_per_outcome` (IA) OU `platform_margin` (infra+suporte+manutenção / receita).
   - C4 ganha vocabulário paralelo: `SHADOW/ASSISTED/AUTONOMOUS` para IA, `DRAFT/STAGING/PILOT/CANONICAL/DEPRECATED` para platform.
   - C6 ganha audit-log como provedor obrigatório quando `ai_enabled=false`.
   - C7 ampliado: cobre integrações, pagamentos, infra (não só LLM SDKs).
   - C2/C5/C8 mantêm letra; só ampliam escopo.

2. **`docs/forge/project.json`** (NOVO arquivo no consumidor, template em `templates/project.template.json`) — fonte de verdade para `project.type`, `ai_enabled`, `economics.model`, `telemetry.*`, `modules[]` (overrides per-module em hybrid). Lido por reviewer + commands antes de qualquer check.

3. **validation-rules v0.3.0** — estruturado em `common` (sempre aplica) + `agentic_saas` + `platform` + `automation` + `hybrid` (composite). Cada check declara `applies_when` para o reviewer ramificar.

4. **Reviewer prompt v0.3.0** — passo obrigatório de carregar `project.json` antes de qualquer check; ramo de validação por tipo; **NÃO marca FAIL por ausência de LLM/Langfuse/prompts em `ai_enabled=false`**.

5. **4 templates novos**: `platform-module-spec.template.md`, `platform-pilot-state.template.md`, `platform-acceptance-report.template.md`, `delivery-economics.template.md`. Templates agentic existentes mantidos (`platform-sku-spec`, `product-spec`, `unit-economics`).

6. **Commands ramificados**:
   - `/acme:diagnose` aceita `--project_type` e `--ai_enabled`; bloco 5 do roteiro adapta-se.
   - `/acme:spec` aceita `--type ∈ {platform-sku, product, diagnostic, platform-module, automation-job}` com matriz de compatibilidade por project_type.
   - `/acme:promote` aceita transições agentic (start_shadow/...) **OU** platform (to_staging/to_pilot/to_canonical/to_deprecated). 6 gates reinterpretados quando `ai_enabled=false`.
   - `/acme:audit-monthly` audita `outcomes` (agentic) ou `audited_actions` (platform); aceita `--module_filter`.

7. **Backwards compatibility**: projeto consumidor sem `project.json` → defaults retroativos (`agentic_saas` + `ai_enabled=true`). Comportamento ≤ v0.7.0 preservado. Nenhum SKU/produto agentic existente quebra.

**SemVer**:
- Constitution: MINOR (0.2.0 → 0.3.0) — interpretação ampliada, IDs preservados.
- Manifest framework: MINOR (0.7.0 → 0.8.0) — Forge-9.
- validation-rules: MINOR (0.2.0 → 0.3.0).
- Reviewer prompt: MINOR (0.2.0 → 0.3.0).
- reviewer-contract: MINOR (0.1.0 → 0.2.0).
- 4 commands com bumps próprios (versão por command).

**Pendências**:
- Hooks (`unit-economics-recalc`, `langfuse-trace-check`) ainda assumem `ai_enabled=true`. Refator condicional fica para Forge-9.1 ou primeira auditoria real do `school-platform`. Hoje: o hook simplesmente não dispara em projeto platform pois os paths/patterns que ele monitora (prompts/LLM calls) não existem nesses projetos.
- Reviewer-contract.md atualizado parcialmente; revisão completa quando primeiro projeto platform for auditado.
- Skills DeepAgent (`reviewer/deepagents/skills/`) seguem cobrindo agentic_saas; conversão de skills para platform é Forge-9.2 (não bloqueia adoção pelo `school-platform`).

---

## F1 — Nome do framework

**Decisão**: ✅ **Acme Forge**

**Justificativa**: "Forge" carrega a ideia de *forjar/moldar* — o framework forja agentes de IA com governança a partir de princípios. Curto, pronunciável em PT/EN, sem conflito com produtos existentes.

---

## F2 — Onde instalar

**Decisão original** (v0.1.0): Projeto-only em `acme-governanca-ia/.claude/`

**Decisão atualizada** (v0.2.0): ✅ **Repositório standalone consumível por N projetos**

**Justificativa do upgrade**: a v0.2.0 reposicionou Forge como **produto distribuível**, não framework embarcado. Origem canônica em `github.com/rafaelnovaes22/agent-governance-framework` (privado). Projetos consumidores fazem `cp -r` dos artefatos canônicos e adaptam só o que é local (CLAUDE.md, ADRs específicas).

**Implicação prática**:
- Forge é versionado independentemente
- Mudanças entram via PR no repo do Forge + bump SemVer
- Consumidores atualizam por sync periódico
- Múltiplos projetos podem usar Forge simultaneamente

---

## F3 — Repositório `lc-spec-driven`

**Decisão**: ✅ **Pular até confirmar nome correto**

Pesquisa via Agent não encontrou repo público com esse nome. Quando o nome correto for confirmado, abrir ADR específica para reavaliar absorção.

---

## F4 — Cross-LLM Reviewer

**Decisão**: ✅ **DeepAgent (GPT-5.5)** via OpenAI SDK

**Implicações arquiteturais**:

1. **Stack do reviewer**: Python `deepagents` (LangChain) OU Node/TS `@langchain/langgraph` — decisão técnica em ADR-002 do projeto consumidor (Forge-3)
2. **Manifest auditável obrigatório**: reviewer ingere `docs/forge/manifest.json` primeiro, todos os artefatos listados com path/hash/versão
3. **Contrato formal**: [`docs/forge/reviewer-contract.md`](./reviewer-contract.md) + assets em [`reviewer/`](../../reviewer/)
4. **Custo controlado**: roda mensalmente em amostra 5–10% dos outcomes (~US$ 1-3/mês na fase inicial)
5. **Independência**: GPT-5.5 é independente de Claude (modelo de produção)

---

## F5 — Plugin marketplace

**Decisão**: ✅ **Não na Forge-0** — reavaliar após Forge-3

Forge é **fechado e versionado** no repo standalone. Publicar como plugin Claude Code (estilo `anthropics/skills`) só faz sentido após Forge-3 quando reviewer estiver maduro.

---

## F6 — BMAD helper pattern

**Decisão**: ✅ **Sim, mas só em Tier 1** (vocabulário Sincra: L0)

Helper pattern do BMAD reduz tokens em 70-85% via referências a seções reutilizáveis. Ganho mais alto em **Tier 1** (DNA, ICP, ofertas) — informação repetida em todo prompt. Aplicar em Tier 2/3 adiciona complexidade sem ganho proporcional.

**Implementação**:
- Tier 1 vive em seção marcada com `<!-- l0:cacheable -->`
- Skills Tier 2/3 referenciam `{{l0.dna}}`, `{{l0.icp}}` em vez de duplicar
- Cache via Anthropic prompt cache (`cache_control: ephemeral`)

---

## F7 — Smart model routing

**Decisão**: ✅ **Default**:

| Tarefa | Modelo |
|---|---|
| Unit Economist, PO Guardian (raciocínio crítico) | **Opus** |
| QA, Security, Code Review | **Sonnet** |
| Lint, format, classificação simples | **Haiku** |

Reavaliar com base em telemetria Langfuse após Forge-3.

---

## F8 — Sunset da pasta `legacy-pmo/` (Acme específico)

**Decisão**: ✅ **Usar como L0 temporário** até Onda 5 da Acme (no projeto consumidor)

Aplicação local da Acme. Outros projetos consumidores podem ignorar.

---

## F9 — Stack técnica do reviewer DeepAgent

**Status**: ✅ **Decidida em 2026-05-01** (substitui F17/F18 — ver abaixo)

**Decisão**: **Python `deepagents` (LangChain)** + **Deep Agents CLI v0.0.34+** + **Anderson Amaral converter** para tradução Claude Code → Deep Agents.

Histórico: opção (b) Node/TS `@langchain/langgraph` foi descartada porque o Deep Agents CLI é Python-first; alinhamento com o stack TS do `acme-governanca-ia` é feito via boundary HTTP/CLI (reviewer roda como processo separado, não como dependência do consumidor).

---

## F10 — Provedor do reviewer

**Status**: Pendente — Forge-3

**Opções**:
- (a) OpenAI direto (cliente `openai` SDK)
- (b) OpenRouter (acesso multi-modelo)
- (c) Vertex AI (gerenciado Google)

**Default sugerido**: (a) OpenAI direto — mais simples; troca depois se precisar.

---

## F11 — Frequência de auditoria

**Status**: Pendente — Forge-3

**Default**: **Mensal** (último dia útil do mês)

**Eventos críticos** que podem disparar auditoria adicional:
- Mudança de prompt em SKU em produção
- Drift detectado em métrica de custo > 15%
- Promoção de modo (SHADOW→ASSISTED→AUTONOMOUS)

A definir se eventos críticos disparam **automaticamente** ou apenas marcam item para revisão na próxima auditoria mensal.

---

## F12 — Adoção do Forge em outros projetos do workspace

**Status**: Pendente — pós Forge-5

**Projetos candidatos** (workspace Rafael):
- CarInsight (precisa avaliação)
- FacilIAuto (precisa avaliação)
- novais-digital (provavelmente não — landing page, não SaaS² agêntico)

Reavaliar quando Forge-5 estiver concluída.

---

## F13 (NOVO v0.2.0) — Constitution genérica vs Acme-específica

**Decisão**: ✅ **Constitution principal genérica** (C1-C8); extensões específicas em `examples/{dominio}/constitution-extension.md`

**Justificativa**: Forge é replicável. Constitution não pode ter `metodologia_acme.md` hardcoded. C9, C10, C11 (lifecycle, two-track economics, portfolio em 3 categorias) são **específicos da Acme** e vivem em `examples/acme/constitution-extension.md`.

**Implicação**: outros projetos consumidores podem definir suas próprias extensões (`examples/{nome}/constitution-extension.md`) sem quebrar a Constitution base.

---

## F14 (NOVO v0.2.0) — Estrutura `examples/`

**Decisão**: ✅ **`examples/acme/` é caso real, não conteúdo prescritivo**

**Conteúdo**:
- `methodology/` — 3 docs de metodologia Acme
- `portfolio.md` — 3 categorias Acme
- `constitution-extension.md` — C9-C11
- `clickup-blueprint.md` — ClickUp interno Acme
- `products/acme-fin.md` — produto em Beta
- `products/acme-educacional.md` — produto em Discovery

**Como outros projetos usam**:
- Como gabarito (estrutura de referência)
- Não como template literal (cada domínio tem sua realidade)
- Cada novo projeto pode contribuir seu próprio `examples/{nome}/`

---

## F15 (NOVO v0.2.0) — Versionamento do Forge

**Decisão**: ✅ **SemVer estrito**

| Mudança | Bump |
|---|---|
| Adicionar template/skill/command novo | **PATCH** |
| Modificar template público (mantém compatibilidade) | **PATCH** |
| Adicionar princípio à Constitution | **MINOR** |
| Concluir Onda Forge (Forge-1, Forge-2, ...) | **MINOR** |
| Modificar regra de princípio existente | **MAJOR** |
| Remover princípio | **MAJOR** |

**Tags git**: `vX.Y.Z` no commit que bumpa a versão. Detalhe em [`CONTRIBUTING.md`](../../CONTRIBUTING.md).

---

## F16 (NOVO v0.2.0) — Distribuição e adoção

**Decisão**: ✅ **Repo privado por enquanto**

Mantenedor (Acme / Novais Digital) controla quem pode adotar. Adoção por terceiros mediante autorização explícita.

**Quando avaliar abrir**:
- Após Forge-5 concluída
- Após pelo menos 3 projetos de domínios diferentes adotarem com sucesso
- Após reviewer DeepAgent estar implementado e testado

---

## F17 (NOVO 2026-05-01) — Stack do reviewer: Deep Agents CLI

**Decisão**: ✅ **`deepagents` CLI (Python, LangChain) v0.0.34+**

**Justificativa**:
- Filesystem virtual e tools tipados (`write_file`, `execute`, `read_file`, `task`) batem com a auditoria que precisamos: ler artefatos do consumidor, rodar lints, paralelizar checks por princípio
- Suporte nativo a sub-agents via `task` permite paralelizar audit C1, C2, C3, ..., C8
- Modelo agnóstico — pode usar Claude (Sonnet/Opus), GPT (4.x/5.5), Gemini conforme custo/qualidade
- Maturidade do framework + comunidade ativa (LangChain)

**Local de execução**:
- Reviewer roda como **processo Python separado** no projeto consumidor (ou CI), não como dependência embarcada do framework Forge
- Acesso aos artefatos via filesystem (consumidor monta o repo no working directory do agent)
- Output gravado em `docs/forge/audits/{YYYY-MM}.md` (consumido posteriormente pelo `/acme:audit-monthly` do Forge ou disparado por ele)

**Provedor de modelo**: ainda **F10** (default OpenAI direto). Reviewer respeita variável de ambiente `DEEPAGENTS_MODEL` para flexibilidade.

**Implicação para Forge**:
- Skills do Forge (`.claude/skills/`) ficam em formato Claude Code (uso pelo dev em sessão)
- Para o reviewer ler/executar essas skills, precisamos **versão paralela** em `reviewer/deepagents/skills/` no formato Deep Agents
- Conversão é feita via F18 abaixo

---

## F18 (NOVO 2026-05-01) — Tradução Claude Code → Deep Agents

**Decisão**: ✅ **Adotar `andersonamaral2/Claude-Code-to-Deep-Agents-Skills-Converter` como ferramenta de tradução**

**Repositório**: https://github.com/andersonamaral2/Claude-Code-to-Deep-Agents-Skills-Converter (MIT, ativo)

**Por que**:
- Skill que vive no Deep Agents CLI; instalação via one-liner ou `curl | bash`
- Aplica **8 transformações estruturadas (T1-T8)** + tabela de semantic replacements (CLAUDE.md → AGENTS.md, `.claude/` → `.deepagents/`, implicit bash → `execute`, etc)
- Suporta batch conversion e dry-run; pode ser auditado em CI

**Como aplicamos**:
- Manter skills do Forge no formato Claude Code (`.claude/skills/`) como **fonte canônica**
- Versão Deep Agents fica em `reviewer/deepagents/skills/{tier}/{name}/SKILL.md` — gerada por conversão
- Toda mudança numa skill canônica dispara re-conversão (Forge-4 hook futuro)
- **Zero divergência manual**: a versão Deep Agents nunca é editada à mão; sempre vem do converter

**Não abraçamos como dependência hard**: se o converter sair de manutenção, podemos manter a versão Deep Agents à mão temporariamente — formato é estável (frontmatter + 8 seções).

**Output esperado** (estrutura por skill):

```
reviewer/deepagents/skills/L0/company-dna/
  └── SKILL.md         ← gerado, com frontmatter Deep Agents + T1-T8

reviewer/deepagents/skills/reviewer/forge-auditor/
  └── SKILL.md         ← skill orquestradora, escrita direto em formato Deep Agents
```

**Conversion log**: cada execução do converter registra em `reviewer/deepagents/conversion-log.md` (origem, hash da skill original, data, versão do converter, transformações aplicadas).

---

## F19 (NOVO 2026-05-01) — Estratégia de playbooks verticais

**Decisão**: ✅ **Playbooks como artefatos de primeira classe no Forge**

**Formato**: `docs/playbooks/{vertical}/playbook.md` no projeto consumidor, gerado via `/acme:playbook-extract` após o primeiro SKU do vertical atingir `AUTONOMOUS`.

**Critério de sucesso do playbook**: cliente 2 do mesmo vertical consome **≤ 30% do esforço do cliente 1**. Se não atingir, o playbook deve registrar os blocos que falharam em reutilização e atualizar estimativas.

**O que entra no playbook**:
1. Blocos com **alta confiança de reutilização** (sem hardcode, sem persona cliente-específica)
2. Padrão de TenantContext do vertical
3. Seed de eval categorizado (≥ 30 casos)
4. Métricas reais de esforço do cliente 1

**O que NÃO entra**:
- Dados do cliente (PII, nomes, volumes comerciais) — anonimizar antes de incluir
- Seções da Constitution — são compartilhadas via Forge, não por playbook
- Prompts com tenant hardcoded — se existe, é bug C8, não bloco

---

## F20 (NOVO 2026-05-01) — Reavaliação F5.5: Deploy global em `~/.claude/`

**Status**: ✅ **Avaliado em 2026-05-01 (Forge-5) — manter projeto-scoped por ora**

**Contexto**: F2 decidiu repo standalone com `cp -r` para projetos consumidores. F5.5 questiona se faz sentido promover para `~/.claude/` global do desenvolvedor.

**Avaliação**:

| Critério | Global `~/.claude/` | Projeto-scoped (atual) |
|---|---|---|
| Versão por projeto | ❌ todos na mesma versão | ✅ cada projeto na versão que adotou |
| Atualizações | ❌ riscos de breaking change silencioso | ✅ sync explícito e controlado |
| Múltiplos projetos paralelos | ⚠️ mesmas skills para projetos diferentes | ✅ isolamento natural |
| Onboarding novo dev | ⚠️ precisa instalar globalmente | ✅ vem com o repo |

**Decisão**: **Manter projeto-scoped**. Criar `forge-global-install.sh` como opt-in experimental para devs que preferem global — mas o padrão e o caso de uso primário é projeto-scoped.

**Reavaliar**: quando ≥ 5 projetos diferentes adotarem o mesmo Forge e a manutenção de `cp -r` por projeto for demonstravelmente onerosa.

---

## F21 (NOVO 2026-05-01) — Reavaliação F5.6: Publicação como plugin

**Status**: ✅ **Avaliado em 2026-05-01 (Forge-5) — não publicar ainda**

**Contexto**: F5 decidiu "não na Forge-0, reavaliar após Forge-3". Forge-5 é o momento de avaliar.

**Critérios para publicar**:
1. ≥ 3 projetos de **domínios diferentes** adotando com sucesso
2. Reviewer DeepAgent executando ≥ 3 auditorias mensais com resultados validados
3. Constitution estável (nenhum MAJOR bump) por ≥ 6 meses
4. Nenhum dado proprietário da Acme nos artefatos canônicos

**Status atual**:
- Projetos: 1 (Acme apenas) — abaixo do mínimo ❌
- Auditorias reais: 0 — abaixo do mínimo ❌
- Constitution: estável desde 0.2.0 (< 6 meses) ⚠️

**Decisão**: **Não publicar**. Reavaliar após cliente 2 de vertical diferente em AUTONOMOUS.

---

## F22 (NOVO 2026-05-04) — Sincronização de metadados (v0.4.1)

**Status**: ✅ **Aplicado em 2026-05-04**

**Contexto**: auditoria interna (pré-CI) identificou 6 divergências de versão/status acumuladas desde Forge-4:
1. `README.md` badges e tabela de status travadas em Forge-0/v0.2.0
2. `settings.json._forge_version` = `0.3.0` (framework em 0.4.0)
3. `settings.json._constitution_version` = `0.1.0` enquanto `CONSTITUTION.md` declara `0.2.0`
4. `decisions.md` título e header em "F1-F16 / v0.2.0"
5. `manifest.json` sem política explícita de sha256 (`sha256: null` ambíguo)
6. `reviewer/README.md` inexistente (README root linka `reviewer/` como entrypoint)

**Decisões tomadas**:
- **sha256_policy = "post-install"**: hashes ficam `null` no repo; consumidor/reviewer recomputa na auditoria. Fonte canônica: `_meta.sha256_policy` no manifest.
- `settings.json._constitution_version` era a fonte errada — `CONSTITUTION.md` é canônico. settings.json reflete o valor, não o define.
- `reviewer/README.md` criado como índice do diretório (entrypoint para humanos e deep-agents).

**Implicação**: qualquer divergência futura entre `settings.json._forge_version`, `manifest.framework.version`, badge do README e topo do CHANGELOG é tratada como bug — detectada por `scripts/forge-doctor.sh` (Fase 5 planejada).

---

---

## F23 (NOVO 2026-05-06) — AIOS Server como camada de implementação multiagente (Forge-6)

**Status**: ✅ **Formalizado em 2026-05-06 — Forge-6 infraestrutura entregue**

**Contexto**: projeto consumidor SchoolPlatform/EDIX adotou **AIOS Server** (arXiv 2403.16971, `agiresearch/AIOS` v0.2.2) como kernel LLM OS para orquestrar 6 agentes especializados com contexto isolado em paralelo. Esta decisão foi formalizada como **Forge-6** e precisou de suporte nativo nos artefatos do framework.

**O que é AIOS**: kernel LLM OS com scheduler, gerenciador de contexto e memória isolada por agente. Em vez de implementação módulo a módulo, 6 agentes (spec, schema, backend, frontend, test, review) executam o pipeline com contexto estritamente isolado.

**Mapeamento com a Constitution (não muda princípios, apenas aplica)**:

| Princípio | Como AIOS aplica |
|---|---|
| C5 (Three-tier) | Tier A = L2 (autônomo), Tier B = L1 (iteração humana), Tier C = L0 (dev dirige) |
| C6 (Telemetry) | `send_request()` de cada agente deve ter trace Langfuse — ver `docs/forge/aios-telemetry-pattern.md` |
| C7 (Portability) | SYSTEM_PROMPTs funcionam standalone sem o kernel; kernel offline ≠ agente inutilizável |
| C8 (Anti-heroic) | `tenantId` vai em `task_input`, nunca hardcoded em SYSTEM_PROMPT |

**Decisão de versionamento**: AIOS é camada de implementação do consumidor, não princípio novo da Constitution. Não exige MAJOR bump. Forge-6 é MINOR (0.4.x → 0.5.0).

**Artefatos Forge-6 entregues**:
- F6.1/F6.2: no projeto consumidor (orchestrator.py, setup guide, ADR-003) — F6.1/F6.2 entregues lá
- F6.3: `/acme:plan` (seção 9 condicional), `/acme:tasks` (Wave 2-AIOS), `/acme:implement` (`--via aios`)
- F6.4: `/acme:aios-init`, `/acme:aios-run`, `/acme:aios-status`
- F6.5: `docs/forge/aios-telemetry-pattern.md` — padrão Langfuse + mock + campos obrigatórios
- F6.6: `templates/platform-sku-spec.template.md` com `aios_tier` + `aios_context_boundaries` no frontmatter

---

## F24 (NOVO 2026-05-07) — AIOS agentes portáveis em templates/aios/ (Forge-7)

**Status**: ✅ **Formalizado em 2026-05-07 — Forge-7 entregue**

**Contexto**: Forge-6 (v0.5.0) entregou os slash commands AIOS (`/acme:aios-init`, `/acme:aios-run`, `/acme:aios-status`) e o padrão de telemetria, mas o **boilerplate dos agentes ficou inline no `aios-init.md`** e cobria apenas 3 dos 6 agentes (spec/backend/frontend). Cada projeto consumidor que adotasse AIOS tinha que gerar seus agentes do zero ou copiar do SchoolPlatform — onde o código está cravado em "EDIX" (viola C7/C8).

**Problema concreto**: o usuário pediu "que cada novo projeto cliente criado possa utilizá-los" e a forma só-comando-inline não escala — qualquer evolução nos agentes teria que ser duplicada manualmente em cada consumidor.

**Decisão**: extrair os 6 agentes (`spec`, `backend`, `frontend`, `schema`, `test`, `review`) como **templates físicos canônicos** em `templates/aios/`, com placeholders bem definidos e SYSTEM_PROMPTs neutros (sem hardcode de cliente/stack/framework).

**Diferença-chave vs. SchoolPlatform**:
- `schema_agent` é **stack-agnostic**: lê `aios/config.yaml → stack.database` e gera schema na stack declarada; se vazia, propõe 1-3 stacks com tradeoffs e pede decisão humana antes do schema definitivo
- `backend_agent`, `frontend_agent`, `test_agent` leem `stack.{backend,frontend,tests}` da config — não cravam Next.js/Prisma/Vitest
- `orchestrator.py` lê `modules:` da config (em vez de lista hardcoded de 15 módulos do SchoolPlatform)
- Todos têm bloco Langfuse + `_MockTrace` obrigatório (C6)
- `tenantId` sempre via `task_input["tenant_id"]` (C8)

**Mapeamento com a Constitution**:

| Princípio | Como Forge-7 aplica |
|---|---|
| C5 (Three-tier) | `tier: A | B | C` no `config.json` de cada agente especializado; agentes compartilhados marcados `tier: shared` |
| C6 (Telemetry) | Bloco Langfuse + `_MockTrace` no boilerplate de cada `entry.py.template` (não opcional) |
| C7 (Portability) | SYSTEM_PROMPT funciona standalone em Claude Code (declarado no comentário-cabeçalho); kernel offline ≠ agente inutilizável |
| C8 (Anti-heroic) | Stack lida de `aios/config.yaml`, nunca cravada; `tenantId` em `task_input`; nenhum nome de cliente em código |

**Decisão de versionamento**: Forge-7 é nova onda → MINOR bump (v0.5.0 → v0.6.0). Não viola Constitution.

**Artefatos Forge-7 entregues**:
- F7.1 — `templates/aios/README.md` (documentação dos placeholders, tabela de diferenças vs. SchoolPlatform)
- F7.2 — `templates/aios/orchestrator.py.template` + `templates/aios/config.yaml.template`
- F7.3 — 6 agentes em `templates/aios/agents/{spec,backend,frontend,schema,test,review}_agent/{entry.py.template, config.json.template}`
- F7.4 — `/acme:aios-init` v0.2.0 (copia de templates físicos; cobre 6 agentes; cria orchestrator/config quando ausentes)
- F7.5 — `manifest.json` v0.6.0 com novo bloco `templates_aios.files[]` (9 entradas)
- F7.6 — `roadmap.md` Forge-7 section
- F7.7 — F24 em decisions.md

**Trade-off aceito**: centralizar os agentes impõe evolução coordenada — qualquer mudança no padrão atualiza 6 arquivos. Em troca, todos os projetos consumidores recebem a mesma evolução via `cp -r` ou via re-run do `/acme:aios-init` na próxima vez (idempotente para agentes compartilhados, regenera os especializados).

---

## F25 (NOVO 2026-05-07) — CI/CD como pré-requisito de produção (Forge-8)

**Status**: ✅ **Formalizado em 2026-05-07 — Forge-8 entregue**

**Contexto**: Forge-0 a Forge-7 construíram toda a governança de IA — Constitution, skills, commands, hooks, agentes AIOS — mas **não impunham CI/CD como pré-requisito mecânico para produção**. O resultado prático era que projetos podiam promover SKUs para AUTONOMOUS sem nenhuma automação de validação: regressões de prompt passavam despercebidas, auditorias mensais eram manuais e inconsistentes, e branch protection não era verificada.

**Problema concreto**: o Gate 5 (aprovação cruzada humana) pode ser executado mesmo sem CI/CD, criando um falso senso de segurança. Um SKU em AUTONOMOUS sem pipeline de eval automático pode ter `prompt_hash` em produção diferente do `prompt_hash` validado — exatamente o drift que `/acme:eval` e o hook `langfuse-trace-check` tentam prevenir no desenvolvimento local.

**Decisão**: tornar CI/CD um **Gate obrigatório (Gate 6)** no `/acme:promote`, especificamente para a transição `assisted_to_autonomous`. Para transições anteriores (start_shadow, shadow_to_assisted), CI/CD é fortemente recomendado mas não bloqueia.

**O que o Forge provê (Forge-8)**:

1. **`templates/cicd/github-actions-validate.template.yml`** — workflow de validação para todo PR:
   - `forge-doctor.sh` (7 checks estruturais)
   - `skill-security-scan.sh` (5 checks de segurança)
   - Pre-merge G1-G5 (C7 imports, C8 anti-hardcode, C6 observe(), manifest sync, eval freshness)

2. **`templates/cicd/github-actions-eval.template.yml`** — eval automático em mudanças de `prompts/`:
   - Detecta artifact_id modificado
   - Roda eval por categoria; falha PR se `pass_rate < agreement_rate_min`
   - Trace Langfuse obrigatório em CI (C6)
   - Comentário automático no PR com resumo

3. **`templates/cicd/github-actions-audit.template.yml`** — auditoria mensal via cron:
   - Cron: 1ª segunda-feira do mês, 06:00 UTC
   - Invoca reviewer DeepAgent (`forge-auditor`)
   - Commit automático de `docs/forge/audits/{YYYY-MM}.md`
   - Cria Issue se SLA breach detectado

4. **`templates/cicd/cicd-checklist.template.md`** — checklist platform-agnostic:
   - 27 itens em 7 seções (validação, pre-merge, eval, auditoria, branch protection, secrets, rastreabilidade)
   - 18 itens 🔴 obrigatórios para Gate 6; 9 itens 🟡 recomendados
   - Campo `gate_6_status: pass | fail | pending` lido pelo `promotion-officer`

**Gate 6 (mecânico no `/acme:promote`)**:

| Evidência exigida | Como verificar |
|---|---|
| `docs/cicd-checklist-{artifact_id}.md` com `gate_6_status: pass` | Ler arquivo; verificar campo YAML |
| Todos os 18 itens 🔴 marcados | Contar checkboxes marcados |
| `ci_pipeline_url` preenchido e acessível | Verificar URL não-nula |
| `last_ci_run_status: passing` | Ler campo; opcionalmente verificar via GitHub API |
| Workflows presentes: `forge-validate`, `forge-eval`, `forge-audit` | `find .github/workflows/ -name "forge-*.yml"` |

**Mapeamento com a Constitution**:

| Princípio | Como Forge-8 aplica |
|---|---|
| C1 (Audit trail) | Auditoria mensal automatizada; relatório commitado; Issue criada em SLA breach |
| C4 (SHADOW antes de cobrar) | Gate 6 garante que eval automático está ativo antes de AUTONOMOUS — o dado de produção é monitorado |
| C6 (Telemetria) | Eval em CI tem trace Langfuse obrigatório (campo `LANGFUSE_PUBLIC_KEY` em secrets) |
| C7 (Portabilidade) | Templates de CI são agnósticos de projeto — placeholders `{PROJECT_NAME}`, `{ARTIFACT_ID}` |

**Decisão de versionamento**: Forge-8 adiciona Gate 6 (novo constraint) mas não muda nenhum princípio da Constitution. É MINOR bump (v0.6.0 → v0.7.0). Não exige ADR de Constitution.

**Trade-off aceito**: Gate 6 aumenta o custo de entrada para AUTONOMOUS (Wave 6 do tasks tem 5 tasks adicionais). Em troca, qualquer SKU em AUTONOMOUS tem garantia mecânica de que regressões são detectadas automaticamente.

---

## F26 (NOVO 2026-05-12) — AIOS pipeline TDD-first (Forge-10)

**Status**: ✅ **Formalizado em 2026-05-12 — Forge-10 entregue**

**Contexto**: Forge-6/7 entregou os 6 agentes AIOS portáveis, mas o pipeline canônico era `spec → build → test → review`. O `test_agent` lia o output do backend antes de gerar testes e produzia apenas um markdown em `docs/specs/_tests_{module}.md` — sem arquivos físicos executáveis e sem coverage gate. Em paralelo, o CI/CD entregue em Forge-8 (`forge-validate`, `forge-eval`, `forge-audit`) **não rodava `npm test` / `pytest` / Playwright** do projeto consumidor — só lint estrutural, eval LLM e auditoria mensal.

**Problema concreto**:
1. **"Test-after" disfarçado de TDD** — o `test_agent` via o código antes de escrever os testes, então os testes inevitavelmente refletiam o que o código já fazia, não o que a spec exigia. Regressão de regra de negócio passava porque o teste foi escrito para passar.
2. **Sem cobertura mecânica** — não havia threshold de coverage por tier, nem enforcement em CI. Tier C (financeiro) podia ir para produção com 30% de cobertura.
3. **Frontend e e2e ausentes do contrato** — o `test_agent` mencionava genericamente "testes de integração reais" mas não exigia camadas separadas (unit/integration/e2e).
4. **CI/CD não fechava o ciclo** — nenhum workflow rodava os testes funcionais do projeto cliente. Branch protection podia ser configurado com check `unit-tests` mas o check não existia.

**Decisão**: refatorar o pipeline AIOS para **TDD-first** e entregar um workflow de testes funcionais que enforce o ciclo no CI.

**Mudanças (templates/aios/)**:

1. **`test_agent` ganha 2 modos** (v0.2.0):
   - `mode=red` (default, antes do build) — lê **apenas** a spec; gera arquivos físicos em `tests/{module}/{unit,integration,e2e}/`; produz matriz "requisito da spec → teste"; isolamento C5 reforçado (não pode ler `_backend_*.md`).
   - `mode=verify` (após o build) — revisa cobertura vs. requisitos; aponta gaps; veredicto parseável (`VEREDICTO: TESTES SUFICIENTES | ADICIONAR TESTES`).
   - Coverage targets por tier no SYSTEM_PROMPT, lidos de `aios/config.yaml → coverage_targets` (defaults: A=70%, B=85%, C=95% line; critical_path 100%).

2. **Orchestrator** (v0.2.0) — pipeline reordenado para:
   ```
   spec → schema → test(red) → build(back+front) → test(verify) → review
   ```
   Com **3 gates humanos C4 explícitos**: após spec, após test(red) — operador roda os testes e confirma que falham, após build — operador confirma que viraram GREEN.

3. **`review_agent`** (v0.2.0) — checklist ganha bloco TDD: existe plano RED, existem arquivos físicos por camada, `VEREDICTO: TESTES SUFICIENTES`, cobertura ≥ tier-target. Se qualquer item desmarcado → `APROVADO PARA MERGE: Não`. Inventário automático de `tests/{module}/{unit,integration,e2e}/` no contexto enviado ao LLM.

4. **`config.yaml.template`** (v0.2.0) — novos blocos:
   - `stack.tests_unit`, `stack.tests_integration`, `stack.tests_e2e`
   - `coverage_targets: {A, B, C}: {line, branch, critical_path}`
   - `test_commands: {install, lint, typecheck, unit, integration, e2e, coverage_report_path}` — comandos lidos pelo CI sem hardcode de npm/pytest.

**Mudanças (templates/cicd/)**:

5. **Novo `github-actions-test.template.yml`** — workflow com 6 jobs:
   - `resolve-config` (lê `aios/config.yaml` para extrair matriz, comandos e targets)
   - `lint-typecheck` (falha rápido)
   - `unit-tests` em matrix por módulo + **coverage gate** comparando line/branch com `coverage_targets[tier]`
   - `integration-tests` em matrix com **Postgres ephemeral via service container** — Tier C bloqueia se ausente
   - `e2e-tests` apenas para módulos com `has_ui: true` — Tier C com UI bloqueia se ausente
   - `summary` com comentário no PR e fail consolidado

6. **`github-actions-validate.template.yml`** — novo job `tdd-red-phase-check` (Gate G6): para cada caminho `src/{modules,features,domains}/{nome}/*` modificado no PR, exige que `tests/{nome}/unit/` exista e tenha ≥ 1 arquivo. Impede que o build chegue ao merge sem ter passado pela fase RED.

7. **`cicd-checklist.template.md`** — nova seção 3 "Testes funcionais do projeto cliente" com 11 itens 🔴 (workflow ativo, coverage gate, integration sem mocks de regra, e2e para módulos com UI, Tier C bloqueante). Total: 39 itens (29 🔴, 10 🟡).

**Gates novos (consolidando v0.9.0)**:

| Gate | Onde | O que valida |
|---|---|---|
| C4-TDD-RED (humano) | orchestrator pipeline | Operador roda testes localmente após `test(red)` e confirma falha |
| C4-TDD-GREEN (humano) | orchestrator pipeline | Operador confirma que testes viraram GREEN após build |
| G6 (mecânico) | `forge-validate.yml` | Todo módulo modificado em `src/{modules,features,domains}/` tem `tests/{module}/unit/` |
| Coverage Gate (mecânico) | `forge-test.yml` job `unit-tests` | line/branch ≥ `coverage_targets[tier]` do módulo |
| Tier C Integration Gate (mecânico) | `forge-test.yml` job `integration-tests` | Tier C sem `tests/{module}/integration/` → fail |
| Tier C E2E Gate (mecânico) | `forge-test.yml` job `e2e-tests` | Tier C com UI sem `tests/{module}/e2e/` → fail |

**Mapeamento com a Constitution**:

| Princípio | Como Forge-10 aplica |
|---|---|
| C4 (SHADOW antes de cobrar) | Testes RED são a especificação executável — failure inicial obrigatório; coverage por tier enforça evidência mecânica antes de qualquer promoção |
| C5 (three-tier) | `test_agent` em modo RED não pode ler outros módulos nem o backend que ainda não existe — isolamento absoluto |
| C6 (telemetry) | Cada execução do `test_agent` é um trace Langfuse separado, com `mode` e `tdd_phase` em metadata |
| C7 (portability) | Comandos de teste lidos de `aios/config.yaml → test_commands` (sem hardcode npm/pytest); workflows usam matrix lida de `modules:` |
| C8 (anti-heroic) | `tests/{module}/` por convenção, não por cliente; coverage_targets configuráveis sem hardcode |

**Decisão de versionamento**: MINOR bump (v0.8.1 → v0.9.0). Novo gate G6 + reordenação do pipeline AIOS são adições, não quebras — projetos consumidores em Forge ≤ 0.8.x continuam funcionando porque `stack.tests` (singular) é mantido como fallback no `test_agent`. Não exige ADR de Constitution.

**Trade-off aceito**: Forge-10 aumenta o custo de entrada do projeto consumidor (precisa configurar `test_commands` + ter runner de teste + service container). Em troca, regressão de regra de negócio em Tier C **não passa silenciosamente** — a CI bloqueia mecanicamente PRs que reduzam cobertura abaixo de 95% line em código financeiro.

---

## F27 (NOVO 2026-05-13) — Master prompt universal para projetos consumidores (Forge-11)

**Status**: ✅ **Formalizado em 2026-05-13 — Forge-11 entregue**

**Contexto**: Após Forge-9 (delivery-type agnostic) e Forge-10 (AIOS TDD-first), o framework passou a suportar 4 `project_type` (`agentic_saas`, `platform`, `automation`, `hybrid`) com interpretação local de C1-C8 via `docs/forge/project.json`. Porém, cada projeto consumidor (Acme SaaS², Aicfo, SchoolPlatform, Acme Social) precisava manter manualmente seu próprio `CLAUDE.md` instruindo o Claude Code sobre qual pipeline usar, qual Guardian invocar, qual lifecycle aplicar. Isso gerou três problemas concretos:

1. **Inconsistência entre consumidores** — cada projeto descrevia o pipeline `/acme:*` à sua maneira; alguns esqueciam de mencionar `po-guardian`, outros não documentavam interpretação local de C3.
2. **Drift do framework** — quando Forge-10 adicionou gates TDD, projetos consumidores antigos não atualizaram seus CLAUDE.md, e o Claude Code operava como se ainda fosse Forge-8 nesses repos.
3. **Onboarding lento** — abrir um projeto consumidor novo exigia replicar instruções manuais (cerca de 200 linhas no CLAUDE.md médio) que o autor precisava memorizar do framework.

**Problema concreto**: sem um ponto de entrada canônico distribuível, o Forge não escalava para múltiplos consumidores. Cada novo projeto reinventava convenções; cada upgrade do framework virava migração manual.

**Decisão**: criar um **master prompt universal** versionado em `templates/master-prompt.md` que substitui as instruções operacionais dos `CLAUDE.md` dos consumidores. O master-prompt:

1. **Detecta** `project_type` + `ai_enabled` ao ler `docs/forge/manifest.json` (ou `project.json`) do consumidor — não exige instrução manual.
2. **Adapta** interpretação de C1-C8 conforme matriz já estabelecida em F26 (Forge-9):
   - `agentic_saas`: C3 audita tokens, C4 exige eval-suite LLM, C6 Langfuse obrigatório, lifecycle SHADOW→ASSISTED→AUTONOMOUS
   - `platform` (ai_enabled=false): C3 audita infra/operação, C4 usa acceptance gate, C6 condiciona Langfuse, lifecycle draft→staging→pilot→canonical
   - `hybrid`: per-module decision via ADR; Forge-10 TDD-first aplicado nos módulos com IA
3. **Roteia** slash commands `/acme:*` por tipo:
   - `/acme:spec --type=platform-sku` para agentic_saas; `--type=platform-module` para platform
   - `/acme:sla-threshold` apenas para agentic; `/acme:pre-merge-check` apenas para platform
   - AIOS pipeline (Forge-6/7/10) aplicado em ambos, com TDD-first uniforme
4. **Invoca** os 10 Guardians corretos: po-guardian (C2), unit-economist (C3, branch agentic/platform), artifact-architect (C5/C7), eval-engineer (apenas se ai_enabled=true), promotion-officer (gate final), etc.
5. **Padroniza output** em 5 seções (Diagnóstico, Rota proposta, Riscos, Próximo passo, Outputs esperados) — facilita revisão humana e telemetria.
6. **Sinaliza escalação** quando ambiguidade (conflito entre Guardians, Constitution sem interpretação local, custo extrapola baseline >30%).

**Mudanças (templates/)**:

1. **Novo `templates/master-prompt.md` v1.0.0** (~17.5 KB, 12 seções):
   - Detecção automática de tipo (matriz `project_type × ai_enabled`)
   - Interpretação adaptativa C1-C8
   - Roteamento de comandos com regras por palavra-chave do input
   - Catálogo dos 10 Guardians com modo (ATIVO/PASSIVO) e ordem de invocação
   - Skills L0-L1-L2 com sintaxe `@skill:nome`
   - Mapa dos 9 hooks runtime e o que cada um bloqueia
   - 3 fluxos completos (Criar agente IA, Criar módulo platform, Adicionar feature IA em platform)
   - Guardrails universais (NUNCA/SEMPRE)
   - Output format padronizado
   - Critérios de escalação
   - Regras de auto-evolução

**Mudanças (CLAUDE.md do framework)**:

2. Nova seção **"Master Prompt para projetos consumidores"** com:
   - Tabela dos 3 tipos suportados
   - Como projetos consumidores instalam (cópia ou referência)
   - Quando evoluir o master-prompt (regras de versionamento)

**Mudanças (manifest.json)**:

3. Nova entrada em `templates[]` com id `template-master-prompt`, `applies_to_project_types: [agentic_saas, platform, automation, hybrid]`, vinculada a TODOS os 8 princípios (C1-C8) — único template com escopo universal.

**Gates novos (consolidando v0.10.0)**:

| Gate | Onde | O que valida |
|---|---|---|
| Manifest-driven detection | Master prompt | Antes de propor qualquer pipeline, lê `manifest.json` do consumidor e sinaliza `project_type + ai_enabled` detectados |
| Adaptive C1-C8 interpretation | Master prompt | Aplica `principle_interpretation_local` quando declarado; usa defaults canônicos quando ausente |
| Output 5-seções | Master prompt | Toda resposta operacional segue Diagnóstico→Rota→Riscos→Próximo passo→Outputs |
| Escalation triggers | Master prompt | Bloqueia decisão autônoma em conflito entre Guardians, custo >30% baseline, cliente externo envolvido |

**Mapeamento com a Constitution**:

| Princípio | Como Forge-11 aplica |
|---|---|
| C1 (Diagnose-before-build) | Master prompt obriga `/acme:diagnose` antes de qualquer capability nova, independente de tipo |
| C2 (Outcome contratual) | Master prompt invoca po-guardian em toda spec; valida outcome positivo + negativo |
| C3 (Unit economics) | Master prompt roteia para unit-economist com branch correto (tokens vs infra) conforme `ai_enabled` |
| C4 (SHADOW antes de cobrar) | Master prompt aplica lifecycle SHADOW→AUTONOMOUS (agentic) OU draft→canonical (platform) sem confundir vocabulários |
| C5 (ADR) | Master prompt obriga ADR para toda decisão arquitetural e referencia decisions.md do consumidor |
| C6 (Telemetria) | Master prompt condiciona Langfuse a `ai_enabled=true`; logs estruturados em todos os tipos |
| C7 (Portability) | Master prompt proíbe acoplar SDK no domain layer; orienta abstração via interfaces |
| C8 (Anti-heroic) | Master prompt usa templates como fonte; não permite criação ad-hoc fora do framework |

**Decisão de versionamento**: MINOR bump (v0.9.0 → v0.10.0). Adiciona capability nova (template universal de orquestração) sem mudar Constitution ou quebrar APIs existentes. Projetos consumidores em Forge ≤ 0.9.x continuam funcionando porque o master-prompt é **opcional** — ele substitui instruções manuais nos CLAUDE.md dos consumidores quando adotado.

**Trade-off aceito**: Forge-11 cria **superfície adicional** que precisa ser versionada junto com Constitution + Guardians + commands. Toda mudança em qualquer um destes pode exigir atualização do master-prompt. Em troca, projetos consumidores ganham um único ponto de entrada canônico, atualizável via `cp` ou referência relativa, e o Forge passa a ter narrativa coerente para 4 tipos de delivery sem que cada consumidor reinvente convenções.

**Próxima evolução prevista (Forge-11.x)**: implementar `forge-router` subagent que lê input em linguagem natural ("crie um post sobre X") e dispara automaticamente o pipeline correto, eliminando necessidade do operador conhecer os slash commands específicos. Atualmente o master-prompt ainda exige que o operador acione `/acme:*` manualmente; com o router, isso vira chamada implícita.

---

## F28 (NOVO 2026-05-13) — Camada de usabilidade adaptativa por persona (Forge-12 Fase 1)

**Status**: ✅ **Fase 1 formalizada em 2026-05-13 — Forge-12 Fase 1 entregue**

**Contexto**: Após Forge-11 (master prompt universal), o framework passou a ter um ponto de entrada técnico canônico para projetos consumidores. Porém, esse ponto de entrada **assume um operador familiar com conceitos do Forge** (slash commands `/acme:*`, Guardians, Constitution C1-C8, ADRs). Duas personas reais não atendidas ficaram explicitamente identificadas:

1. **CEO / founder vibecodando** — usa Claude Code interativo, não usa terminal nem git, não conhece nem precisa conhecer conceitos como Constitution ou ADR. Digita pedidos em linguagem natural ("crie um carrossel sobre IA") e espera resultado. Hoje o Forge era invisível para esta persona, e os erros eram intraduzíveis (mensagens como "C3 violation: cost_per_outcome > 0.25" são incompreensíveis).
2. **Dev novo no time** — entende git/terminal/JSON/Markdown, mas não conhece os ~100KB de documentação do Forge. Tempo até primeira contribuição útil: 2-3 dias só lendo. A documentação otimiza para **referência completa**, não para **onboarding rápido**.

**Problema concreto**: o Forge resolvia governança (correção) mas não usabilidade (acesso). Sem camada de superfície, o framework efetivamente excluía dois públicos importantes — o decisor de negócio (que paga) e o dev recém-contratado (que vai construir).

**Decisão**: criar uma **camada de usabilidade adaptativa** sobre o Forge existente, **sem mudar a base técnica**. A camada se organiza em 3 níveis:

```
SURFACE (o que o usuário vê)   → HELLO.md + QUICKSTART_VIBE/DEV + scripts/forge
       ↓
TRANSLATOR (intenção ↔ Forge)  → master-prompt.md (já em Forge-11) + modo persona
       ↓
CORE (governança, não muda)    → Constitution + Guardians + Hooks + Templates
```

**Princípio fundador da camada Surface**: **traduzir, não esconder**. A Constitution permanece visível e canônica para quem quer aprofundar. A camada de superfície apenas adapta a linguagem ao público.

**Mudanças (Fase 1 — entregues em v0.11.0)**:

1. **`HELLO.md` (raiz)** — landing adaptativo. Pergunta "quem é você?" e direciona para 1 de 4 caminhos: vibe (CEO), dev (programador), agent (IA), wizard interativo (não sei). Substitui a "porta da frente" técnica do README como entrada para humanos.

2. **`QUICKSTART_VIBE.md` (raiz)** — guia para CEO em linguagem natural. 5 min de leitura. Sem jargão. Inclui:
   - 3 exemplos do mundo real (criar post, criar agente, entender erro)
   - Glossário leigo (Forge = "regras invisíveis", Outcome = "o que o cliente paga", etc.)
   - 5 receitas práticas (templates de pedido natural)
   - Sinais de "tá tudo bem" vs "para aí"
   - O que fazer quando der errado (frases mágicas)
   - Como pedir bem (3 elementos obrigatórios: O que / Para quem / Em qual canal)

3. **`QUICKSTART_DEV.md` (raiz)** — cheatsheet técnico de 1 página. 15 min de leitura. Otimizado para **scanning**:
   - Estrutura do repo em 30 segundos
   - Setup em 3 minutos
   - Tabela dos 15 slash commands + scripts bash
   - "Como adicionar X" (skill, command, Guardian, hook, template)
   - Tabela dos 10 Guardians com modo (ATIVO/CONSULTOR/PASSIVO)
   - Tabela dos 9 hooks + o que cada um bloqueia
   - Top 10 erros + como resolver
   - Loop de desenvolvimento (do diff ao push)
   - Princípios mentais

4. **`scripts/forge` (executável bash)** — CLI wrapper unificado com 5 verbos:
   - `start` — wizard interativo, detecta persona, salva preferência em `.forge-mode` (gitignored)
   - `doctor` — alias para `scripts/forge-doctor.sh`
   - `version` — versão + fase Forge + modo local
   - `mode <vibe|dev|agent>` — define modo de operação
   - `help [verbo]` — ajuda contextual
   
   Compatível com bash 4+ (git bash no Windows). Não substitui slash commands `/acme:*` (esses continuam sendo invocados dentro do Claude Code). Manifesta-se também na detecção de path absoluto Unix↔Windows (uso de `cd` para path relativo evita problemas no Node).

**Mudanças (manifest.json)**:

5. Nova entrada `script-forge-cli` em `artifacts.scripts[]`, com `linked_principles: [C7]` (portability — o wrapper é portável bash sem dependências externas além de jq/node opcionais com fallback grep).

**Gates novos (consolidando v0.11.0)**:

| Gate | Onde | O que valida |
|---|---|---|
| Persona-aware entry | HELLO.md | Usuário escolhe persona antes de continuar; previne onboarding desalinhado |
| Vibe Mode glossary | QUICKSTART_VIBE.md | Termos técnicos têm tradução leiga obrigatória |
| Dev cheatsheet scannability | QUICKSTART_DEV.md | Tudo cabe em 1 página A4 quando renderizado |
| CLI verb whitelist | scripts/forge | Apenas 5 verbos canônicos; verbos desconhecidos retornam erro com sugestão |

**Mapeamento com a Constitution**:

| Princípio | Como Forge-12 Fase 1 aplica |
|---|---|
| C1 (Diagnose-before-build) | QUICKSTART_VIBE.md ensina CEO a sempre confirmar antes do agente executar |
| C2 (Outcome contratual) | QUICKSTART_VIBE.md inclui receita "como pedir bem" (3 elementos obrigatórios — força outcome implícito) |
| C3 (Unit economics) | QUICKSTART_VIBE.md mostra exemplo "custo estimado: R$ 2,40" antes de executar — transparência de C3 para não-técnico |
| C4 (Verifiable evaluation) | scripts/forge doctor é primeira porta de entrada para validação |
| C5 (ADR) | QUICKSTART_DEV.md tem section "Como adicionar X" referenciando ADR para mudanças arquiteturais |
| C6 (Telemetry) | Glossário leigo traduz "Langfuse" como "registro do que aconteceu" para CEO |
| C7 (Portability) | scripts/forge é o exemplo canônico de portabilidade: bash puro, fallback graceful, detecção de jq/node opcionais |
| C8 (Anti-heroic) | HELLO.md elimina dependência de "alguém que já conhece o Forge" — qualquer um se onboarda sozinho |

**Decisão de versionamento**: MINOR bump (v0.10.0 → v0.11.0). Adiciona capability nova (camada de surface) sem mudar Constitution ou quebrar APIs. Projetos consumidores em Forge ≤ 0.10.x continuam funcionando — toda a Fase 1 é **opcional** e **adicional**. A camada Surface não substitui nada existente, apenas adiciona caminhos alternativos.

**Trade-off aceito**: Forge-12 Fase 1 cria **superfície de manutenção adicional** — sempre que adicionarmos verb/command/hook novo, os 3 quickstarts podem precisar atualizar. Em troca, o framework passa a ter portas de entrada distintas para 3 personas reais, reduzindo TTV (time-to-value) de ~3 dias (dev) e impossível (CEO) para ~30min/5min respectivamente.

**Próximas evoluções previstas (Forge-12 Fases 2-3)**:

- **Fase 2** (próxima): `PLAYGROUND/` com 3 exemplos executáveis para dev; `COMMON_ERRORS.md` com top 10 erros e soluções; hook `friendly-errors` que traduz erros C1-C8 para humano.
- **Fase 3** (depois de Fase 2 validada): `GLOSSARY_PLAIN.md` standalone (hoje embutido no VIBE); `forge-router` subagent (referenciado em F27.x — automação de linguagem natural → slash commands); modo persona detectado automaticamente baseado em comportamento.

---

## F29 (NOVO 2026-05-13) — Aprendizado por exemplos + tradução de erros (Forge-12 Fase 2)

**Status**: ✅ **Fase 2 formalizada em 2026-05-13 — Forge-12 Fase 2 entregue**

**Contexto**: F28 (Fase 1) entregou a "porta de entrada" para 3 personas via HELLO.md + quickstarts + CLI wrapper. Porém, ficaram 2 lacunas práticas evidentes ao testar mentalmente o onboarding:

1. **Leitura sem execução não fixa** — devs lendo QUICKSTART_DEV.md entendem **o que existe**, mas não **como aplicar concretamente** o pipeline em um caso real. Faltava material onde a pessoa pudesse ver `project.json` real, spec real, walkthrough do pipeline aplicado, e comparar com seu projeto.

2. **Mensagens de erro permanecem hostis para vibe mode** — mesmo com glossário leigo no QUICKSTART_VIBE, quando o Claude Code retorna uma mensagem como "C3 violation: cost_per_outcome > 0.25", a CEO continua sem entender. O glossário precisa ser **interceptado e aplicado automaticamente**, não consultado manualmente.

**Problema concreto**: Fase 1 trouxe o usuário até a porta. Fase 2 precisa convidá-lo a entrar e mostrar como caminhar dentro.

**Decisão**: três entregas complementares:

1. **`PLAYGROUND/`** — 3 exemplos executáveis end-to-end, cada um cobrindo um `project_type` diferente. Cada exemplo tem:
   - `README.md` — o que vamos construir e por quê (~3 min de leitura)
   - `walkthrough.md` — passo a passo do pipeline Forge aplicado com comandos reais, artefatos gerados em cada etapa (~15-25 min)
   - `docs/forge/project.json` — manifest do consumidor real (não placeholder)
   - Estrutura espelhando exatamente o que um projeto consumidor real teria

   Exemplos cobertos:
   - **01-agentic-saas-agent** — Carrossel Agent (inspirado Acme Social): pipeline SHADOW→ASSISTED→AUTONOMOUS, eval-suite LLM-as-judge, unit-economics em tokens, lifecycle 3 estágios.
   - **02-platform-module** — Módulo Faturamento (inspirado SchoolPlatform): pipeline draft→staging→pilot→canonical, acceptance gate operacional (sem LLM), delivery-economics (infra+suporte), TDD-first Tier C.
   - **03-hybrid** — Plataforma com Módulo IA (inspirado Aicfo): mistura platform core + agentic_sku, interpretação C1-C8 por módulo, ADR obrigatório para adicionar módulo IA.

2. **`COMMON_ERRORS.md`** — top 10 erros consolidados em formato copy-paste:
   - Mensagem literal que o usuário vê
   - Causa-raiz explicada
   - Comando de diagnóstico
   - Solução passo a passo
   - Prevenção para o futuro
   
   Cobertura: forge-doctor failures (C2/C3/C6), hooks bloqueando (outcome-clause-guard, adr-approval-gate, secret-scan), Guardians rejeitando (po-guardian, unit-economist), TDD red phase missing (Gate G6 Forge-10), hash mismatch.

3. **Hook `friendly-errors.sh` (PostToolUse)** — intercepta output de tools/comandos Claude Code, detecta padrões de violação C1-C8 (regex sobre strings como "C3 violation", "po-guardian reject", "secret-scan blocked", etc.) e anexa mensagem traduzida conforme `.forge-mode`:
   - **vibe** — tradução leiga ("Esse SKU está caro demais — você precisa cobrar mais ou cortar custos")
   - **dev** — tradução + detalhes técnicos + referência a COMMON_ERRORS.md
   - **agent** — passa direto sem traduzir (output original para downstream automation)

   Não bloqueia execução. Apenas anexa contexto humano. Modo padrão é `dev` se `.forge-mode` não existir.

**Mudanças (estrutura do repo)**:

- Nova pasta `PLAYGROUND/` na raiz com 3 sub-pastas, ~7 arquivos novos.
- Novo `COMMON_ERRORS.md` na raiz (~600 linhas, 10 erros).
- Novo `hooks/post-tool-use/friendly-errors.sh` (~270 linhas, 9 padrões de violação detectados).

**Mudanças (settings.json)**:

- Hook `friendly-errors` adicionado ao array `PostToolUse[].hooks[]` com matcher `Edit|Write` e timeout 3000ms.
- `_ids` atualizado para incluir `friendly-errors`.

**Mudanças (manifest.json)**:

- Nova entrada `hook-friendly-errors` em `hooks.post_tool_use[]` v1.0.0 com `linked_principles: [C7]` (portability — funciona em qualquer projeto consumidor, lê apenas `.forge-mode` que é gitignored).

**Gates novos (consolidando v0.12.0)**:

| Gate | Onde | O que valida |
|---|---|---|
| Playground completeness | PLAYGROUND/ | Cada exemplo tem README + walkthrough + project.json válido |
| Common errors coverage | COMMON_ERRORS.md | Top 10 erros incluem causa-raiz + diagnóstico + solução copy-paste |
| Friendly errors fallback | friendly-errors.sh | Detecta padrão C1-C8 OU não bloqueia (sempre exit 0) |
| Mode-aware translation | friendly-errors.sh + .forge-mode | Tradução vibe/dev/agent respeitando preferência local |

**Mapeamento com a Constitution**:

| Princípio | Como Forge-12 Fase 2 aplica |
|---|---|
| C1 (Diagnose-first) | PLAYGROUND/01 mostra `diagnostic.md` real antes de qualquer código |
| C2 (Outcome contratual) | PLAYGROUND/01 e 02 mostram outcomes verificáveis em formatos diferentes (LLM vs operacional) |
| C3 (Unit economics) | PLAYGROUND/01 mostra C3 em tokens; 02 em infra+suporte; 03 em mix; COMMON_ERRORS #8 ensina recuperação |
| C4 (Verifiable evaluation) | PLAYGROUND/01 mostra eval-suite; 02 mostra acceptance-report; ambos no walkthrough |
| C5 (ADR) | PLAYGROUND/01 mostra ADR-001 reduzindo slides; COMMON_ERRORS #5 ensina resposta a hook adr-approval-gate |
| C6 (Telemetry) | PLAYGROUND/02 mostra logs+audit ao invés de Langfuse; friendly-errors traduz "telemetry" amigavelmente |
| C7 (Portability) | friendly-errors.sh é o melhor exemplo: lê `.forge-mode` simples (texto), fallback graceful, não acopla nada |
| C8 (Tenant context) | PLAYGROUND/02 e 03 mostram tenant_id, RLS PostgreSQL, audit trail particionado |

**Decisão de versionamento**: MINOR bump (v0.11.0 → v0.12.0). Adiciona capability nova (Surface layer Fase 2) sem mudar Constitution ou quebrar APIs. Tudo é **opcional** (PLAYGROUND não interfere; COMMON_ERRORS é documentação; hook tem fallback graceful). Projetos consumidores em Forge ≤ 0.11.x continuam funcionando.

**Trade-off aceito**: Forge-12 Fase 2 cria **surface de manutenção significativa** — PLAYGROUND precisa atualizar quando pipeline muda, COMMON_ERRORS precisa expandir quando novos erros aparecem, friendly-errors regex pode quebrar com mudança de mensagens upstream. Em troca:
- TTV (time-to-value) cai mais ~30% para devs novos (eles agora têm onde **ver fazendo**)
- Vibe mode passa a entender erros sem ler glossário manualmente
- COMMON_ERRORS vira fonte única de verdade para top 10 problemas — reduz suporte ad-hoc

**Próxima evolução prevista (Forge-12 Fase 3)**:

- `GLOSSARY_PLAIN.md` standalone (hoje embutido no QUICKSTART_VIBE)
- `forge-router` subagent que lê input em linguagem natural ("crie um post sobre X") e dispara `/acme:*` automaticamente — elimina necessidade do operador conhecer slash commands
- Modo persona auto-detectado baseado em comportamento (sem precisar `forge mode`)
- PLAYGROUND adicionar exemplo 04 (automation/RPA)

---

## Histórico de mudanças

| Versão | Data | Mudança | Razão |
|---|---|---|---|
| 0.1.0 | 2026-04-30 | Aprovação dos 8 defaults iniciais | Plano inicial aprovado |
| 0.1.0 | 2026-04-30 | F4 override: Gemini → DeepAgents/GPT-5.5 | Diretiva direta |
| 0.2.0 | 2026-04-30 | F2 atualizado para repo standalone | Reposicionamento como produto distribuível |
| 0.2.0 | 2026-04-30 | F13-F16 adicionadas | Generalização da Constitution + estrutura examples/ + versionamento + distribuição |
| 0.4.0 | 2026-05-01 | F19-F21 adicionadas | Forge-5: estratégia de playbooks + reavaliação de deploy global e plugin |
| 0.4.1 | 2026-05-04 | F22 adicionada; sincronização de metadados | Auditoria interna pré-CI detectou 6 divergências acumuladas |
| 0.5.0 | 2026-05-06 | F23 adicionada; Forge-6 AIOS infraestrutura entregue | Adoção de AIOS Server pelo projeto consumidor SchoolPlatform/EDIX |
| 0.6.0 | 2026-05-07 | F24 adicionada; Forge-7 AIOS templates portáveis entregues | 6 agentes canônicos em templates/aios/ para serem reusados por todos os projetos consumidores; schema_agent stack-agnostic |
| 0.7.0 | 2026-05-07 | F25 adicionada; Forge-8 CI/CD esteira completa entregue | Gate 6 obrigatório para AUTONOMOUS; 4 templates CI/CD; Wave 6 no tasks; promotion-officer atualizado |
| 0.9.0 | 2026-05-12 | F26 adicionada; Forge-10 AIOS TDD-first entregue | test_agent com modos red/verify + arquivos físicos; orchestrator reordenado para TDD; novo workflow forge-test (unit/integration/e2e + coverage gate); gate G6 no validate; cicd-checklist com seção 3 (testes funcionais) |
| 0.10.0 | 2026-05-13 | F27 adicionada; Forge-11 master prompt universal entregue | `templates/master-prompt.md` v1.0.0 com detecção automática de project_type + ai_enabled, interpretação adaptativa de C1-C8, roteamento de /acme:* por tipo, invocação correta dos 10 Guardians, output padronizado em 5 seções; substitui instruções manuais nos CLAUDE.md de projetos consumidores; aplica-se a TODOS os project_types (agentic_saas, platform, automation, hybrid) |
| 0.11.0 | 2026-05-13 | F28 adicionada; Forge-12 Fase 1 camada de usabilidade entregue | HELLO.md (landing adaptativo), QUICKSTART_VIBE.md (CEO sem jargão), QUICKSTART_DEV.md (cheatsheet técnico), scripts/forge (CLI wrapper unificado com verbos start/doctor/version/mode/help); reduz TTV de ~3 dias (dev) e ~impossível (CEO) para 30min/5min |
| 0.12.0 | 2026-05-13 | F29 adicionada; Forge-12 Fase 2 aprendizado por exemplos + tradução de erros entregue | PLAYGROUND/ com 3 exemplos executáveis (agentic_saas / platform / hybrid) cada um com README + walkthrough + project.json; COMMON_ERRORS.md (top 10 erros copy-paste); hook friendly-errors.sh que traduz violações C1-C8 conforme .forge-mode (vibe/dev/agent); fixa lacuna de "leitura sem execução não fixa" e "mensagens hostis no modo vibe" |
