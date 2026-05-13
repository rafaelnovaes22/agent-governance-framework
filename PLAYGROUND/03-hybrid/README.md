# 🔀 Exemplo 03 — Plataforma com Módulo IA Embutido (hybrid)

> **Objetivo:** plataforma SaaS sem IA no core, MAS com 1 módulo específico (Análise Financeira) que usa LLM para gerar insights automáticos.

---

## 📋 Contexto

**Caso real inspirador:** Aicfo — plataforma FinTech B2B com módulo de análise financeira por IA.

**Stack base (sem IA):**
- Next.js + Prisma + PostgreSQL (plataforma)
- Stripe (cobrança)
- Sentry + logs estruturados

**Stack do módulo IA:**
- Anthropic SDK (Claude Opus 4.6) — para análise narrativa
- Langfuse — telemetria do módulo IA APENAS
- LangChain JS — orquestração

**Outcome contratual base:** acesso à plataforma R$ 1.500/mês por tenant
**Outcome do módulo IA:** R$ 50 por análise financeira gerada (add-on)

---

## 🧩 Por que "hybrid"?

`hybrid` = `platform` (core) + `agentic_saas` (em módulos específicos)

Forge-9 (F26) formalizou: **a interpretação dos princípios C1-C8 é por módulo, não por projeto inteiro**.

| Aspecto | Core platform | Módulo IA |
|---------|:-------------:|:---------:|
| project_type aplicado | platform | agentic_saas |
| ai_enabled | false | true |
| C3 audita | Infra+suporte | Tokens LLM |
| C4 valida via | Acceptance gate | Eval-suite LLM |
| C6 | Logs+audit | Langfuse |
| Lifecycle | draft→canonical | SHADOW→AUTONOMOUS |
| Spec template | platform-module-spec | platform-sku-spec |

---

## 🛠️ Estrutura do projeto

```
aicfo-style-hybrid/
├── docs/forge/
│   ├── project.json                       (project_type=hybrid)
│   ├── modules/
│   │   ├── core-billing/                  (platform module — sem IA)
│   │   │   ├── spec.md
│   │   │   ├── delivery-economics.md
│   │   │   └── acceptance-report.md
│   │   ├── core-dashboard/                (platform module — sem IA)
│   │   │   └── ...
│   │   └── ai-financial-analysis/         (agentic SKU — COM IA)
│   │       ├── spec.md                    (template platform-sku-spec)
│   │       ├── unit-economics.md          (tokens)
│   │       ├── eval-cases.md              (20+ casos LLM-as-judge)
│   │       └── lifecycle-stage.md         (SHADOW→AUTONOMOUS)
│   └── decisions.md                       (ADRs globais + por módulo)
```

---

## 🎯 Pipeline aplicado

### Para módulos core (platform):
- Mesmo fluxo do Exemplo 02 (draft → staging → pilot → canonical)
- Sem Langfuse, sem eval LLM

### Para módulo IA (`ai-financial-analysis`):
- Mesmo fluxo do Exemplo 01 (SHADOW → ASSISTED → AUTONOMOUS)
- Com Langfuse + eval-suite + unit-economics em tokens

**Como o Forge sabe qual fluxo aplicar?**

Lê `module.ai_enabled` no `project.json` E `module.type`:
- `type=platform_module + ai_enabled=false` → lifecycle platform
- `type=agentic_sku + ai_enabled=true` → lifecycle agentic

---

## 📊 Diferenças críticas para o pipeline

### 1. ADR obrigatório no nível projeto

Antes de adicionar módulo IA em projeto platform, é **obrigatório criar ADR**:

```markdown
## ADR-005 — Adicionar módulo IA (ai-financial-analysis)

**Status:** Aceito 2026-05-13

**Contexto:** Plataforma Aicfo core não usa IA. Cliente solicitou feature de análise narrativa automática dos números financeiros.

**Decisão:** Adicionar módulo `ai-financial-analysis` como `agentic_sku` dentro da plataforma `hybrid`.

**Consequências:**
- ✅ Cliente paga R$ 50 add-on por análise (margem positiva)
- ⚠️ Plataforma precisa configurar Langfuse (não tinha)
- ⚠️ Eval-suite LLM adicional vai precisar manutenção
- ✅ Resto do core continua sob regime platform (sem regressão)
```

### 2. Manifest do consumidor declara módulos heterogêneos

```json
{
  "project_type": "hybrid",
  "modules": [
    { "id": "core-billing", "type": "platform_module", "ai_enabled": false, "current_stage": "canonical" },
    { "id": "core-dashboard", "type": "platform_module", "ai_enabled": false, "current_stage": "canonical" },
    { "id": "ai-financial-analysis", "type": "agentic_sku", "ai_enabled": true, "current_stage": "shadow" }
  ]
}
```

### 3. Hooks rodam condicionalmente

`langfuse-trace-check` só dispara em arquivos do módulo `ai-financial-analysis/`. Para `core-billing/`, ignora.

### 4. Reviewer mensal ramifica

DeepAgent reviewer audita C1-C8 com lógica diferente por módulo no mesmo projeto.

---

## 🎯 Cenário típico

```
Cliente: "Quero ver análise narrativa dos meus números financeiros do mês"
                              ↓
              [Aicfo Core - billing/dashboard]
              identifica cliente, valida assinatura,
              busca dados financeiros do mês
                              ↓
            [Módulo ai-financial-analysis ✨]
            envia dados para Claude Opus 4.6
            gera análise narrativa (3 parágrafos)
            valida via eval-suite LLM-as-judge
            cobra R$ 50 (autonomous)
                              ↓
              [Aicfo Core - billing]
              registra cobrança add-on
              dispara invoice
```

---

## 🧠 Conceitos-chave deste exemplo

✅ **Hybrid é a regra, não exceção** — quase toda plataforma vai querer features IA em algum momento
✅ **Forge sabe lidar com mistura** — interpretação por módulo (F26 Forge-9)
✅ **ADR é obrigatório** quando adiciona módulo IA — força reflexão sobre custo de manutenção dual
✅ **Reuso de adapters** — core já tem Stripe/auth/multi-tenant; módulo IA reusa
✅ **Promotion isolada** — módulo IA promove SHADOW→AUTONOMOUS sem afetar core canonical
✅ **Eval-suite só onde precisa** — não impõe overhead LLM no que é CRUD puro

---

## 📖 Walkthrough resumido

Como o pipeline para core é idêntico ao Exemplo 02, e o pipeline para módulo IA é idêntico ao Exemplo 01, este walkthrough cobre **apenas as 3 etapas que são diferentes**:

### Etapa A — Adicionar módulo IA em projeto existente

```bash
# 1. ADR obrigatório
/acme:diagnose ai-financial-analysis --project_type=agentic_sku --in_hybrid=true
# Gera ADR template e exige aprovação humana antes de continuar

# 2. Atualizar project.json
# Adicionar entrada no modules[] com type=agentic_sku, ai_enabled=true

# 3. Configurar Langfuse (se ainda não tem)
# Hook langfuse-trace-check vai exigir antes do próximo PR
```

### Etapa B — Pipeline normal do módulo IA

Igual ao Exemplo 01, mas dentro de `docs/forge/modules/ai-financial-analysis/` (não `docs/forge/sku/`).

### Etapa C — Reviewer mensal lê ambos

```bash
/acme:audit-monthly
```

DeepAgent gera relatório separado:
- ✅ Core modules: 100% canonical, audit trails OK, SLOs verde
- ⚠️ ai-financial-analysis: ainda em SHADOW, eval-suite pass rate 87% (target 80%)
- ✅ ADR-005 (decisão de hybrid) revisitada: ainda válida, margem 62%

---

## 🚨 Riscos comuns em hybrid (cuidado)

| Risco | Mitigação |
|-------|-----------|
| Time não distingue "platform module" de "agentic SKU" | Master prompt (Forge-11) detecta automaticamente |
| Custo IA escala mais que receita | Unit-economist vigia per-tenant token usage |
| Eval-suite negligenciada (porque "é só 1 módulo") | Coverage gate Tier B do módulo IA bloqueia merge se eval < 85% pass |
| Core regressed por mudança no módulo IA | Hooks isolam — `langfuse-trace-check` não dispara em core files |
| Cliente é cobrado pelo add-on sem usar | C4 SHADOW→ASSISTED exige cliente ativar consciente |

---

## ✅ Resultado final

Plataforma com **78 módulos core** (sem IA) e **3 módulos IA add-on**, todos auditados sob a mesma Constitution, com interpretação local correta por tipo.

---

**Voltar para:** [`../README.md`](../README.md) — comparar com os outros exemplos.
