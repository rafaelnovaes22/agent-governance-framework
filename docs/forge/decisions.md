# Acme Forge — Decisões F1–F22

> **Status**: ✅ Defaults aprovados em 2026-04-30 (v0.1.0) e refinados em ondas subsequentes até v0.4.1
> **Versão atual**: 0.4.1

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

## Histórico de mudanças

| Versão | Data | Mudança | Razão |
|---|---|---|---|
| 0.1.0 | 2026-04-30 | Aprovação dos 8 defaults iniciais | Plano inicial aprovado |
| 0.1.0 | 2026-04-30 | F4 override: Gemini → DeepAgents/GPT-5.5 | Diretiva direta |
| 0.2.0 | 2026-04-30 | F2 atualizado para repo standalone | Reposicionamento como produto distribuível |
| 0.2.0 | 2026-04-30 | F13-F16 adicionadas | Generalização da Constitution + estrutura examples/ + versionamento + distribuição |
| 0.4.0 | 2026-05-01 | F19-F21 adicionadas | Forge-5: estratégia de playbooks + reavaliação de deploy global e plugin |
| 0.4.1 | 2026-05-04 | F22 adicionada; sincronização de metadados | Auditoria interna pré-CI detectou 6 divergências acumuladas |
