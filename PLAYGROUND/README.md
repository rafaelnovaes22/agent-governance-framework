# 🎮 Foundry Playground — Aprenda com Exemplos Reais

> **4 exemplos completos** mostrando o pipeline Foundry aplicado a cada `project_type` suportado. Otimizado para você **ver fazendo** em vez de **ler sobre**.

---

## 🎯 O que tem aqui

| Pasta | project_type | ai_enabled | Caso real inspirador |
|-------|:------------:|:----------:|---------------------|
| [`01-agentic-saas-agent/`](./01-agentic-saas-agent/) | `agentic_saas` | ✅ true | Novais Digital Social — Carrossel Agent |
| [`02-platform-module/`](./02-platform-module/) | `platform` | ❌ false | EduPlatform — Módulo de Faturamento |
| [`03-hybrid/`](./03-hybrid/) | `hybrid` | ✅ true (módulo IA) | Aicfo — Análise Financeira |
| [`04-automation/`](./04-automation/) | `automation` | ❌ false | Job RPA — sync ERP→Warehouse |

Cada pasta tem:
- ✅ `README.md` — o que vamos construir e por quê
- ✅ `walkthrough.md` — passo a passo do pipeline Foundry aplicado
- ✅ `docs/foundry/project.json` — manifest do consumidor
- ✅ Artefatos de exemplo (spec, eval-cases, ADR, etc.)

---

## 🧭 Por onde começar?

### Você quer entender **agentes IA** (criar copywriter, designer, etc.)?
👉 [`01-agentic-saas-agent/`](./01-agentic-saas-agent/)

### Você quer entender **plataformas SaaS** (CRUD, gestão, financeiro)?
👉 [`02-platform-module/`](./02-platform-module/)

### Você quer entender **plataforma com features IA embutidas**?
👉 [`03-hybrid/`](./03-hybrid/)

### Você quer entender **job RPA / automação determinística** (sync, ETL, integração)?
👉 [`04-automation/`](./04-automation/)

### Você nunca usou o Foundry antes?
👉 Comece pelo **01** (agentic) — é o caso mais didático e mostra o pipeline completo SHADOW→ASSISTED→AUTONOMOUS.

---

## 📚 Conceitos que você vai dominar

Ao final dos 3 exemplos, você vai ter visto na prática:

| Conceito | Onde aparece |
|----------|--------------|
| **Outcome contratual (C2)** | 01, 02, 03 — cada exemplo tem outcome diferente |
| **Unit economics (C3)** | 01 (tokens), 02 (infra), 03 (combinado) |
| **Eval suite** | 01, 03 — LLM eval real |
| **Acceptance gate** | 02 — gate operacional sem LLM |
| **Lifecycle SHADOW→AUTONOMOUS** | 01, 03 (módulo IA) |
| **Lifecycle draft→canonical** | 02 — fluxo platform |
| **ADR (decisão arquitetural)** | 01, 02, 03 |
| **Guardian invocation** | Todos — po-guardian, unit-economist, etc. |
| **AIOS pipeline (TDD-first)** | 02 (CRUD com testes), 03 (módulo IA com eval) |
| **`project.json` declarativo** | Todos |

---

## ⚠️ Importante: exemplos didáticos vs produção

Os artefatos aqui são **mínimos viáveis** para mostrar o pipeline. Não são código de produção. **Não copie diretamente** — use como referência da estrutura e adapte ao seu contexto.

**O que você PODE reutilizar:**
- ✅ Estrutura de pastas (`docs/foundry/sku/{id}/...`)
- ✅ Formato dos artefatos (frontmatter, seções)
- ✅ Ordem do pipeline (diagnose → spec → plan → tasks → implement → eval → promote)
- ✅ Sintaxe de invocação de Guardians (`@po-guardian valide...`)

**O que você PRECISA adaptar:**
- ❌ Conteúdo do outcome (depende do seu ICP)
- ❌ Custos de baseline (depende do seu modelo de negócio)
- ❌ Eval-cases concretos (depende do domínio)
- ❌ Decisões arquiteturais (depende da sua stack)

---

## 🚀 Próximos passos

1. **Escolha 1 exemplo** que mais combina com o que você quer construir
2. **Leia o `README.md`** dele (3 min)
3. **Acompanhe o `walkthrough.md`** passo a passo (15-30 min)
4. **Compare com seu projeto real** — onde diverge? por quê?
5. **Aplique no seu projeto** seguindo o mesmo pipeline

---

**Confuso?** Rode `bash scripts/foundry start` para wizard interativo.
**Procurando referência técnica?** Veja [`QUICKSTART_DEV.md`](../QUICKSTART_DEV.md).
**Não-técnico e perdido?** Veja [`QUICKSTART_VIBE.md`](../QUICKSTART_VIBE.md).
