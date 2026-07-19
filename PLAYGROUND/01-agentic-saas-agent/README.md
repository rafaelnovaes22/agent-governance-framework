# 🎨 Exemplo 01 — Carrossel Agent (agentic_saas + ai_enabled=true)

> **Objetivo:** criar um agente de IA que gera carrosséis de Instagram (5-7 slides) no tom the CEO em até 8 minutos, com brand consistency 99%+, custo ≤ R$ 3,00 por carrossel.

---

## 📋 Contexto

**Caso real inspirador:** Novais Digital Social Media Agent (do projeto Novais_Social).

**Stack:**
- Claude Sonnet 4.6 (copywriting)
- Google Vertex AI Imagen 4 (geração de imagens)
- Ideogram v2 (fallback para text-in-image)
- Zernio API (publicação multi-rede)

**Outcome contratual (C2):**
> "Entregar 5-7 slides de carrossel + caption + legenda, no tom the CEO, com brand Novais Digital, prontos para publicar em até 8 minutos."

**Pricing model:** R$ 12 por carrossel (3x o custo de R$ 4 para margem 67%).

---

## 🛠️ O que vamos construir aqui

| Artefato | Onde fica | Propósito |
|----------|-----------|-----------|
| `project.json` | `docs/foundry/` | Declaração de tipo do consumidor |
| `diagnostic.md` | `docs/foundry/sku/carrossel-agent/` | C1 — diagnose-before-build |
| `spec.md` | `docs/foundry/sku/carrossel-agent/` | C2 — outcome contratual |
| `unit-economics.md` | `docs/foundry/sku/carrossel-agent/` | C3 — custo ≤ 25% do preço |
| `eval-cases.md` | `docs/foundry/sku/carrossel-agent/` | C4 — 20+ eval-cases |
| `decisions.md` | `docs/foundry/sku/carrossel-agent/` | C5 — ADRs locais |
| `lifecycle-stage.md` | `docs/foundry/sku/carrossel-agent/` | C4 — SHADOW→AUTONOMOUS |

---

## 🎯 Pipeline aplicado (resumo)

```
1. /novais-digital:diagnose carrossel-agent
   → @po-guardian valida outcome
   ↓
2. /novais-digital:spec --type=platform-sku
   → @unit-economist audita C3
   ↓
3. /novais-digital:plan carrossel-agent
   → @artifact-architect valida abstração
   ↓
4. /novais-digital:tasks carrossel-agent
   → decomposição em Wave 1-6
   ↓
5. /novais-digital:implement carrossel-agent
   → TDD-first (eval-cases primeiro)
   ↓
6. /novais-digital:eval carrossel-agent
   → roda 20+ eval-cases, gera score
   ↓
7. /novais-digital:promote carrossel-agent --to=shadow
   → @promotion-officer assina
   ↓ (após 7-14 dias coletando dados em SHADOW)
8. /novais-digital:promote carrossel-agent --to=assisted
   ↓ (após validação humana de SLA)
9. /novais-digital:promote carrossel-agent --to=autonomous
   → cobra cliente
```

---

## 📖 Próximo passo

Acompanhe o passo a passo completo em [`walkthrough.md`](./walkthrough.md).

---

## 🧠 Conceitos-chave deste exemplo

✅ **Outcome verificável** — "carrossel pronto para publicar" é mensurável (sim/não), não vago
✅ **Eval-suite com LLM-as-judge** — 20+ casos validados por outro LLM (não regex)
✅ **Lifecycle 3 estágios** — SHADOW (gratuito, validando) → ASSISTED (humano aprova) → AUTONOMOUS (cobra)
✅ **Unit economics em tokens** — R$ 4 de custo / R$ 12 preço = 33% (passa em C3)
✅ **Brand validation automatizada** — Claude Sonnet 4.6 vision compara output com brand guide
