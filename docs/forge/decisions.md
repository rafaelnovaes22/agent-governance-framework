# Acme Forge — Decisões F1–F16

> **Status**: ✅ Defaults aprovados em 2026-04-30 (v0.1.0) e refinados em 2026-04-30 (v0.2.0)
> **Versão atual**: 0.2.0

Decisões fundacionais do framework Acme Forge. Mudança em qualquer uma destas exige nova ADR.

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

**Status**: Pendente — decisão em ADR-002 do projeto consumidor (Forge-3)

**Opções**:
- (a) Python `deepagents` (LangChain) — alinhado ao curso Scoras estudado
- (b) Node/TS `@langchain/langgraph` — alinhado ao stack do `acme-governanca-ia`

**Default sugerido**: (a) Python `deepagents` — foco em planejamento e filesystem virtual.

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

## Histórico de mudanças

| Versão | Data | Mudança | Razão |
|---|---|---|---|
| 0.1.0 | 2026-04-30 | Aprovação dos 8 defaults iniciais | Plano inicial aprovado |
| 0.1.0 | 2026-04-30 | F4 override: Gemini → DeepAgents/GPT-5.5 | Diretiva direta |
| 0.2.0 | 2026-04-30 | F2 atualizado para repo standalone | Reposicionamento como produto distribuível |
| 0.2.0 | 2026-04-30 | F13-F16 adicionadas | Generalização da Constitution + estrutura examples/ + versionamento + distribuição |
