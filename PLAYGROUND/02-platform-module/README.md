# 🏢 Exemplo 02 — Módulo Faturamento (platform + ai_enabled=false)

> **Objetivo:** criar um módulo CRUD de faturamento (emitir nota, calcular impostos, sincronizar com ERP) **sem IA**, com acceptance gate operacional ao invés de eval LLM.

---

## 📋 Contexto

**Caso real inspirador:** EduPlatform — plataforma SaaS/operacional para gestão educacional.

**Stack:**
- Next.js 14 + TypeScript
- Prisma 6 + PostgreSQL 16
- Vitest + Playwright (testes)
- Sentry (errors) + logs estruturados
- **SEM Anthropic / OpenAI / qualquer LLM**

**Outcome contratual (C2):**
> "Emitir nota fiscal eletrônica, calcular impostos conforme regime tributário, sincronizar com ERP do cliente em ≤ 30s. Audit log de todas as transações."

**Pricing model:** assinatura mensal (não per-outcome) — R$ 2.500/mês por cliente.

---

## 🧩 Diferenças críticas vs Exemplo 01 (agentic)

| Aspecto | Exemplo 01 (agentic) | Exemplo 02 (platform) |
|---------|---------------------|----------------------|
| **C3 audita** | Tokens LLM | Infra + suporte |
| **C4 valida via** | Eval-suite LLM-as-judge | Acceptance gate + testes E2E |
| **Lifecycle** | SHADOW→ASSISTED→AUTONOMOUS | draft→staging→pilot→canonical |
| **C6 LANGSMITH** | Obrigatório | Não exigido (logs estruturados + Sentry) |
| **Telemetry foco** | Cost-per-outcome | Operational SLOs |
| **Promotion gates** | 5 (incluindo eval) | 4 (sem eval LLM, com audit-trail) |
| **Spec template** | `platform-sku-spec` | `platform-module-spec` |
| **Hook ativo** | `langfuse-trace-check` | `audit-trail-check` |

---

## 🛠️ O que vamos construir aqui

| Artefato | Onde fica | Propósito |
|----------|-----------|-----------|
| `project.json` | `docs/foundry/` | Declaração `project_type=platform, ai_enabled=false` |
| `diagnostic.md` | `docs/foundry/modules/faturamento/` | C1 — diagnose-before-build |
| `spec.md` | `docs/foundry/modules/faturamento/` | C2 — outcome operacional |
| `delivery-economics.md` | `docs/foundry/modules/faturamento/` | C3 — variante platform de unit-economics |
| `acceptance-report.md` | `docs/foundry/modules/faturamento/` | C4 — gate platform (substitui eval LLM) |
| `pilot-state.md` | `docs/foundry/modules/faturamento/` | C4 — append-only log de transições |
| `decisions.md` | `docs/foundry/modules/faturamento/` | C5 — ADRs locais |

---

## 🎯 Pipeline aplicado (resumo)

```
1. /novais-digital:diagnose faturamento --project_type=platform
   → @po-guardian valida outcome operacional
   ↓
2. /novais-digital:spec --type=platform-module
   → @unit-economist audita delivery-economics
   ↓
3. /novais-digital:plan faturamento
   → @artifact-architect valida abstração
   ↓
4. /novais-digital:tasks faturamento (Wave 1P-4P + 6P)
   ↓
5. /novais-digital:implement (AIOS TDD-first com vitest/playwright)
   ↓
6. /novais-digital:pre-merge-check
   → audit-trail-check hook valida log em services
   → testes funcionais passam (não eval LLM)
   ↓
7. /novais-digital:promote faturamento --to=staging
   → @promotion-officer assina
   ↓ (após 7 dias em staging com smoke tests)
8. /novais-digital:promote faturamento --to=pilot
   → cliente real testa em ambiente isolado
   ↓ (após acceptance-report assinado pelo decisor cliente)
9. /novais-digital:promote faturamento --to=canonical
   → módulo entra em produção para todos os tenants
```

---

## 📖 Próximo passo

Acompanhe o passo a passo em [`walkthrough.md`](./walkthrough.md).

---

## 🧠 Conceitos-chave deste exemplo

✅ **Outcome operacional** — "nota emitida + impostos calculados + ERP sincronizado" é verificável sem LLM
✅ **Acceptance gate** — substitui eval-suite; humano (cliente) assina aceite formal
✅ **Audit trail obrigatório** — toda mutação em services críticos gera log auditável
✅ **C3 reinterpretado** — custo de infra + suporte ÷ ARR atribuído ≤ 25%
✅ **Lifecycle 4 estágios** — draft (dev) → staging (interno) → pilot (1 cliente) → canonical (todos)
✅ **TDD-first ainda obrigatório** — gate G6 do Foundry-10 aplica em platform também
