# Acme Forge — Constitution

> **Versão**: 0.1.0
> **Data de aprovação**: 2026-04-30
> **Aprovação**: ✅ CEO + Tech Lead
> **Mudanças**: exigem nova ADR + bump de versão + comunicação ao reviewer DeepAgents

---

## Como esta Constitution é usada

Este arquivo é **carregado automaticamente** pelo Claude Code via referência em `CLAUDE.md` raiz. Os 8 princípios abaixo entram no contexto inicial de toda sessão e devem orientar **toda decisão de design, implementação e revisão** do projeto `acme-governanca-ia`.

O reviewer externo **DeepAgents/GPT-5.5** valida cada princípio mensalmente conforme [`docs/forge/reviewer-contract.md`](../docs/forge/reviewer-contract.md), §4.1.

---

## Os 8 princípios

### C1 — Diagnose-before-design

**Regra**: Nenhuma feature, SKU ou mudança de escopo começa sem **Diagnóstico Fase 0** (D7) aprovado e arquivado em `docs/onda-0/diagnostico_fase0.md` (ou `docs/diagnostics/{cliente}.md` para Diagnósticos por cliente).

**Por quê**: A metodologia Acme SaaS² (`docs/metodologia_acme.md`, §Fase 0) trata o Diagnóstico como **porta de entrada paga**, não pré-venda gratuita. Cliente que não topa pagar Diagnóstico não vira cliente. Sem Diagnóstico, processos automatizados em cima de caos viram caos automatizado.

**Como validar**: para cada SKU em produção, verificar:
- Existe `docs/onda-0/sku_piloto.md` aprovado (D1.5)
- Existe `Diagnostic` registrado (no DB ou em `docs/diagnostics/`)

**Exceções**: nenhuma. Mesmo cliente piloto interno (D7.6) precisa do roteiro D7.5 executado.

---

### C2 — Outcome-first, never tech-first

**Regra**: Toda spec começa pela **cláusula contratual de outcome cobrável** (D2.1 a D2.5 preenchidos). Stack, modelos e integrações vêm depois.

**Por quê**: Sem outcome definido como cláusula contratual, há disputa eterna ("isso conta?", "aquilo deveria contar"). A metodologia (`metodologia_acme.md`, §Risco R1) cita definição vaga de outcome como armadilha que mata empresas SaaS² nascentes.

**Como validar**: toda PR que adiciona ou modifica SKU deve:
- Atualizar `src/skus/{sku}/spec.md` com seção "Cláusula contratual de outcome" preenchida
- Linkar `docs/onda-0/sku_piloto.md` correspondente
- Ter 3 exemplos positivos + 3 negativos (D2.2, D2.3)

**Exceções**: SKUs `example-*` (showcase de engenharia) podem ter cláusula simplificada, mas devem declarar `is_example: true` no frontmatter do spec.

---

### C3 — Custo ≤ 25% do preço

**Regra**: O custo de inferência por outcome **não pode** exceder 25% do preço cobrado por outcome. Hard gate de unit economics.

**Por quê**: Regra prática da metodologia (`metodologia_acme.md`, §Risco R2). Margem comprimida por LLM mata SaaS² silenciosamente — o custo aparece só com volume, quando contrato já está assinado.

**Como validar**:
- `templates/unit-economics.template.md` preenchido por SKU em `docs/onda-N/unit_economics.md`
- D5.4 do template marca PASS
- Cross-check com Langfuse (custo real vs projetado) últimos 30 dias
- Hook `unit-economics-recalc` (Forge-4) dispara recalc se prompts mudarem

**Exceções**: durante SHADOW (não há cobrança variável), a regra não bloqueia. Mas precisa estar passando **antes** de ASSISTED.

---

### C4 — SHADOW antes de cobrar

**Regra**: Nenhum SKU vai a billing variável (cobrança por outcome) sem:
- N outcomes mínimos em modo SHADOW (definido em D6.4)
- Eval suite passando o threshold do D6.2
- Concordância humano-vs-agente acima do threshold D6.4

**Por quê**: A metodologia exige modo SHADOW → ASSISTED → AUTONOMOUS (`metodologia_acme.md`, §Fase 2). Cobrança em SHADOW é receita garantida de atrito comercial — agente pode estar errado e cliente paga mesmo assim.

**Como validar**:
- Tabela `Subscription.mode` em SHADOW por padrão ao criar
- Promoção SHADOW → ASSISTED só via `/acme:promote --to=assisted` (Forge-2)
- Promotion Officer agent (Forge-3) valida gates antes de aceitar
- Reviewer DeepAgents audita transições de modo no relatório mensal

**Exceções**: **nenhuma**. Mesmo cliente disposto a "pular SHADOW" precisa pelo menos 14 dias em SHADOW (regra do `decisoes_default_tecnicas.md` da Onda 0).

---

### C5 — Three-tier context (Sincra)

**Regra**: Toda skill, agent ou prompt declara em qual nível Sincra opera e **só lê dados de níveis ≤ próprio**:

| Tier | Conteúdo | Lê de |
|---|---|---|
| **L0** | Estratégico — DNA, ICP, ofertas | apenas L0 |
| **L1** | Tático — Projeto, Cliente, Briefing, BaselineCost | L0 + L1 |
| **L2** | Operacional — SKU, Outcome, AgentRun, EvalCase | L0 + L1 + L2 |

**Por quê**: Princípio Sincra (`metodologia_sincra.md`, §3) — herança evita duplicação, dá contexto consistente, permite cache. Quebrar a hierarquia (L0 lendo L2) destrói o helper pattern e estoura tokens.

**Como validar**:
- Frontmatter de toda skill em `.claude/skills/L*/`*.md` declara `tier: L0|L1|L2`
- Lint (Forge-4) bloqueia skill L0 que importe contexto de L1/L2
- Reviewer audita amostra mensal

**Exceções**: nenhuma — se uma necessidade aparente quebra a hierarquia, o problema é de modelagem, não da regra.

---

### C6 — Telemetry-by-default

**Regra**: Toda chamada a LLM em produção **deve** ter trace Langfuse correspondente (input, output, custo, latência). Sem trace, não conta como outcome auditável.

**Por quê**: ADR 001 fixa Langfuse como camada de observability. Sem trace:
- Reviewer DeepAgents não consegue auditar
- Cliente não pode contestar outcome
- Drift detection vira impossível
- D6.3.1 (auditoria mensal LLM-as-judge) não roda

**Como validar**:
- Lint regex em `src/agents/**/*.ts` exige `langfuseTrace.observe(...)` ou wrapper equivalente em chamadas a `anthropic.messages.create`
- Hook `langfuse-trace-check` (Forge-4)
- Reviewer compara contagem de outcomes no DB vs traces em Langfuse — desvio > 1% dispara FAIL

**Exceções**: scripts pontuais (`scripts/seed-*.ts`) podem rodar sem trace, desde que **não** estejam em fluxo de produção. Tooling de eval roda traces em projeto Langfuse separado (`evals`).

---

### C7 — Portability over lock-in

**Regra**: Modelos, provedores, ferramentas mudam. **Processo**, **input/output**, **handoff**, **artefato** **não**. Toda dependência específica de modelo/fornecedor é isolada em `src/llm/` (camada de abstração).

**Por quê**: Mantra Sincra (`metodologia_sincra.md`, §11). ADR 001 já declara reversibilidade alta como objetivo arquitetural — Forge não pode adicionar lock-in adicional.

**Como validar**:
- Imports de `@anthropic-ai/sdk` ou `@langchain/openai` proibidos fora de `src/llm/` (lint Forge-4)
- Schemas de prompts em `src/skus/{sku}/prompts/` são markdown/templates, sem lógica de modelo
- Trocar modelo (Claude Sonnet → Opus, ou Claude → fallback) não exige mudança em `src/skus/`, só em config

**Exceções**: SDK do reviewer DeepAgents (OpenAI) vive em pasta separada (decidida em ADR-002, Forge-3) e não conta como lock-in do core.

---

### C8 — Anti-customização heroica

**Regra**: Cliente N do mesmo SKU = **configuração**, não branch. Nenhuma pasta `src/skus/{sku}/clients/{cliente-x}/`. Customização entra como:
1. **Configuração de tenant** (campos no `TenantContext`)
2. **Variante de SKU** (novo SKU empacotado, com SKU code distinto)

**Por quê**: Princípio metodologia (`metodologia_acme.md`, §Risco R3). Customização heroica destrói margem e impede catálogo. *"Cada pedido de 'só essa pequena adaptação' do cliente vira código que não escala."*

**Como validar**:
- Nenhum diretório `clients/`, `tenants/{nome}/`, ou similar dentro de `src/skus/`
- Lint Forge-4 detecta `if (tenantId === '...')` ou `switch (tenantName)` em `src/agents/**`
- Reviewer audita drift de "customização disfarçada"

**Exceções**: durante onboarding do **primeiro cliente** de um SKU (validação inicial), pode haver hardcode temporário em `src/skus/{sku}/onboarding-{cliente}.ts` por **até 14 dias**. Após isso, vira config no `TenantContext` ou novo SKU.

---

## Hierarquia de autoridade

Quando dois princípios entram em conflito, a ordem é:

1. **C1** (Diagnose-before-design) — fundamento de tudo
2. **C2** (Outcome-first) — o que define a cláusula contratual
3. **C3, C4** (Economics e SHADOW) — proteção comercial
4. **C5, C6** (Sincra e telemetria) — disciplina técnica
5. **C7, C8** (Portability e Anti-custom) — sanity de longo prazo

Exemplo: se um cliente urgente exige autonomia imediata sem SHADOW (violando C4), e a justificativa é técnica (violando C2), o conflito **não deve ser resolvido** — o pedido viola a base. Renegociar escopo ou recusar.

---

## Mudanças nesta Constitution

Para alterar, adicionar ou remover qualquer princípio:

1. Abrir nova ADR em `docs/adr/00X-constitution-change.md` justificando
2. Bump de versão semver: alteração de regra = MINOR; remoção = MAJOR
3. Atualizar `manifest.json` com novo `constitution_version`
4. Notificar o reviewer DeepAgents (atualizar prompt do Deep Agent)
5. Comunicar ao time em onboarding e changelog do projeto

---

## Histórico

| Versão | Data | Mudança |
|---|---|---|
| 0.1.0 | 2026-04-30 | Versão inicial — 8 princípios fundadores |

---

## Referências

- `docs/metodologia.md` — Metodologia Acme clássica
- `docs/metodologia_acme.md` — Metodologia Acme SaaS² (referência primária)
- `docs/metodologia_sincra.md` — Camadas L0/L1/L2, entidades, artefatos
- `docs/forge/README.md` — Overview do Forge
- `docs/forge/reviewer-contract.md` — Como o reviewer valida cada princípio
- `docs/adr/001-stack-saas2.md` — Stack arquitetural
