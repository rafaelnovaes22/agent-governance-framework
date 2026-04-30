# Acme Forge — Decisões F1–F8

> **Status**: ✅ Defaults aprovados pelo CEO em 2026-04-30
> **Override pós-aprovação**: F4 alterado para DeepAgents/GPT-5.5 (em vez de Gemini)

Decisões fundacionais do framework Acme Forge. Mudança em qualquer uma destas exige nova ADR.

---

## F1 — Nome do framework

**Decisão**: ✅ **Acme Forge**

**Justificativa**: "Forge" carrega a ideia de *forjar/moldar* — o framework forja SKUs SaaS² a partir da metodologia Acme. Curto, pronunciável em PT/EN, sem conflito com produtos existentes.

**Alternativas descartadas**: Acme Rails (associação ferroviária / Ruby), Acme Agentic SDK (genérico, redundante com LangGraph).

---

## F2 — Onde instalar

**Decisão**: ✅ **Projeto-only primeiro** (`PMO_Acme/acme-governanca-ia/.claude/`)

**Justificativa**: Forge é específico do contexto SaaS² da Acme. Promover ao `~/.claude/` global só faz sentido se o framework provar maturidade e for útil em **outros projetos** Claude Code do Rafael (CarInsight, FacilIAuto, novais-digital). Reavaliar após Forge-3 concluído.

**Implicação prática**:
- Forge é **versionado junto com o repositório** `acme-governanca-ia`
- Mudanças no Forge entram via PR + ADR
- O `.claude/settings.local.json` (overrides do dev) **continua intocado**

---

## F3 — Repositório `lc-spec-driven`

**Decisão**: ✅ **Pular até confirmar nome correto**

**Justificativa**: Pesquisa via Agent não encontrou repo público com esse nome. Candidatos prováveis (`Fission-AI/OpenSpec`, `mahidalhan/skilled-spec`, `gotalab/cc-sdd`, `Pimzino/claude-code-spec-workflow`) não foram absorvidos no Forge-0. Quando o nome correto for confirmado, abrir ADR específica para reavaliar absorção.

**Risco aceito**: pode haver pattern interessante que estamos perdendo. Mitigação: revisitar em Forge-3 com base em consulta direta ao Rafael.

---

## F4 — Cross-LLM Reviewer ⚠️ OVERRIDE

**Decisão original sugerida**: Gemini Pro
**Decisão final**: ✅ **DeepAgents (GPT-5.5)**

**Justificativa do override**: o Rafael especificou DeepAgents como reviewer externo. Implicações arquiteturais:

1. **Stack do reviewer**: pode usar a biblioteca `deepagents` (Python/LangGraph) já estudada na pasta `Deep_Agents/` do workspace, **OU** ser implementado como Deep Agent Node/TS usando `@langchain/langgraph` já presente no `package.json` do projeto. Decisão técnica adiada para Forge-3 (ADR específica).

2. **Manifest auditável obrigatório**: o reviewer precisa de **observabilidade total** — todo artefato do Forge deve estar listado em [`manifest.json`](./manifest.json) com path, hash, versão e descrição. O reviewer ingere o manifest primeiro e navega a partir dali.

3. **Contrato formal**: o que o reviewer valida, com que frequência, qual o output esperado, está em [`reviewer-contract.md`](./reviewer-contract.md).

4. **Custo controlado**: reviewer roda na **auditoria mensal** (5–10% sample dos outcomes — D6.3.1), não em todo PR. Custo estimado: poucos USD/mês.

5. **Independência**: GPT-5.5 é independente de Claude (modelo de produção). Atende requisito metodológico de "modelo independente do que gerou o output".

**Stack adicional necessária** (a configurar em Forge-3):
- `OPENAI_API_KEY` no `.env`
- Possivelmente `openai` SDK ou usar OpenAI via `@langchain/openai`

---

## F5 — Plugin marketplace

**Decisão**: ✅ **Não na Forge-0** — reavaliar após Forge-3

**Justificativa**: publicar como plugin Claude Code (estilo `anthropics/skills`) só faz sentido se:
- Framework provar valor em pelo menos 1 SKU em AUTONOMOUS
- Houver intenção de share público (decisão de produto/marketing)
- Alguma generalização (não específico Acme) tiver sido extraída

Por enquanto, Forge é **fechado e versionado** no repo da Acme.

---

## F6 — BMAD helper pattern

**Decisão**: ✅ **Sim, mas só em L0** (TenantContext)

**Justificativa**: o helper pattern do BMAD reduz tokens em 70-85% via referências a seções reutilizáveis. O ganho mais alto está em **L0** (Company DNA, ICP, ofertas) — informação repetida em todo prompt de todo SKU. Aplicar em L1/L2 adiciona complexidade sem ganho proporcional.

**Implementação**:
- L0 vive em uma seção marcada com `<!-- L0:cacheable -->`
- Skills L1/L2 referenciam `{{l0.dna}}`, `{{l0.icp}}` etc. em vez de duplicar
- Cache via Anthropic prompt cache (ephemeral) — já mencionado em `demo_saas2.md`

---

## F7 — Smart model routing

**Decisão**: ✅ **Aceitar default da tabela §4.2 do plano**, ajustar com dados de uso

**Tabela atual**:

| Tarefa | Modelo |
|---|---|
| Unit Economist, PO Guardian (raciocínio crítico) | **Opus** |
| QA, Security, Code Review | **Sonnet** |
| Lint, format, classificação simples | **Haiku** |

**Reavaliar**: após Forge-3, com base em telemetria Langfuse (latência + custo + qualidade).

---

## F8 — Sunset da pasta `legacy-pmo/`

**Decisão**: ✅ **Usar como L0 temporário** até Onda 5 da Acme

**Justificativa**: `src/legacy-pmo/` ainda contém TenantContext, DNA, ICP, ofertas dos clientes PMO (Cenário A). Deletar agora quebra os dados de exemplo do `seed:example`. Manter como L0 transitório:

- Skills L0 do Forge leem de `legacy-pmo/tenants/*` quando o tenant atual existir lá
- Em paralelo, novos tenants SaaS² têm sua própria estrutura em `src/skus/{sku}/tenants/` ou tabela `TenantContext`
- Onda 5 (limpeza) move dados úteis para o novo schema e remove `legacy-pmo/`
- Forge ganha hook que avisa quando uma skill está lendo de `legacy-pmo/` (debt log)

---

## Decisões pendentes (a abrir)

| ID | Tema | Quando decidir |
|---|---|---|
| F9 | Stack técnica do reviewer DeepAgents (Python `deepagents` vs Node/TS LangGraph) | Forge-3 |
| F10 | Provedor do reviewer: OpenAI direto vs OpenRouter vs Vertex AI | Forge-3 |
| F11 | Frequência de auditoria reviewer (mensal default, mas eventos críticos podem disparar?) | Forge-3 |
| F12 | Adoção do Forge em outros projetos do workspace (CarInsight, FacilIAuto) | Pós Forge-5 |

---

## Histórico de mudanças

| Data | Mudança | Razão |
|---|---|---|
| 2026-04-30 | Aprovação dos 8 defaults | Plano inicial aprovado pelo CEO |
| 2026-04-30 | F4 override: Gemini → DeepAgents/GPT-5.5 | Diretiva direta do CEO |
