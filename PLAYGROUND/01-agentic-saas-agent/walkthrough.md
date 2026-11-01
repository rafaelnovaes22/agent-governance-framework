# 📖 Walkthrough — Carrossel Agent (passo a passo)

> **Tempo de leitura:** ~25 min | **Pré-requisito:** ter lido [`README.md`](./README.md)

Este walkthrough mostra como o pipeline Foundry é aplicado **na prática** para criar um agente IA. Cada passo tem o comando real, o que esperar, e os artefatos gerados.

---

## 🟢 Passo 1 — Diagnose (C1)

### Comando

```bash
/novais-digital:diagnose carrossel-agent --outcome="gerar carrossel publicável em 8 min"
```

### O que acontece

- `po-guardian` é invocado para validar se o outcome é contratualmente claro
- Sistema verifica `project.json` e detecta `project_type=agentic_saas + ai_enabled=true`
- Aplica matriz de interpretação de C1-C8 (Foundry-9/F26)

### Artefato gerado: `docs/foundry/sku/carrossel-agent/diagnostic.md`

```markdown
---
sku_id: carrossel-agent
diagnose_date: 2026-05-13
outcome_clause: "Entregar carrossel publicável (5-7 slides + caption) em ≤ 8 min"
icp_fit: "Founders B2B/B2C que postam 3x/semana em Instagram"
po_guardian_approval: ✅
---

## Diagnóstico

**Problema do cliente:** demora 5h para criar 1 carrossel manual.

**Outcome contratual (C2):**
- ✅ Positivo: 5 slides + caption no tom requisitado, brand-compliant, em 8 min
- ❌ Negativo: 4 slides genéricos sem tom específico em 30 min
- ❌ Negativo: 5 slides off-brand entregues em 8 min

**Hipóteses a validar:**
1. Tom the CEO é detectável por LLM-as-judge? (testar com 20 casos)
2. Brand consistency atinge 99%+ com Imagen 4 + ADR de fallback Ideogram?
3. Custo médio fica abaixo de R$ 4 por carrossel?

**Riscos identificados:**
- Imagen 4 pode rejeitar prompts com brand reconhecível → fallback Ideogram
- Tom the CEO exige treino com exemplos curados
```

---

## 🟢 Passo 2 — Spec contratual (C2 + C3)

### Comando

```bash
/novais-digital:spec carrossel-agent --type=platform-sku
```

### O que acontece

- Template `platform-sku-spec.template.md` é instanciado
- `@unit-economist` é invocado para auditar economia ANTES de qualquer código
- Spec é validada estruturalmente (frontmatter + seções obrigatórias)

### Artefato gerado: `docs/foundry/sku/carrossel-agent/spec.md`

```markdown
---
sku_id: carrossel-agent
sku_version: 0.1.0
project_type: agentic_saas
ai_enabled: true
current_stage: draft
spec_status: po_guardian_approved
created_at: 2026-05-13
---

# Spec: Carrossel Agent

## 1. Outcome contratual (C2)

**Promessa:** Entregar 1 carrossel pronto-para-publicar em ≤ 8 min.

**Critério de aceite verificável:**
- [x] 5-7 slides JPG 1080×1080 com brand Novais Digital aplicado
- [x] Caption ≤ 2200 caracteres no tom solicitado
- [x] Caption tem CTA explícito
- [x] Tempo total ≤ 480s entre request e arquivo entregue

**Exemplos:**
- ✅ "Carrossel sobre IA generativa para industriais, tom the CEO" → 6 slides + caption persuasiva
- ❌ "Faz alguma coisa bonita" → REJEITA (outcome vago, exige briefing mínimo)

## 2. Unit economics (C3)

**Preço de venda:** R$ 12,00 por carrossel
**Custo máximo aceitável (25%):** R$ 3,00
**Custo estimado real:**
- Claude Sonnet 4.6 (copy): ~R$ 0,80 (5K tokens IO)
- Imagen 4 (5 slides × R$ 0,40): R$ 2,00
- Ideogram v2 (1 slide com texto): R$ 0,30
- Infra (Lambda + DB): R$ 0,10
- **TOTAL:** R$ 3,20 ⚠️ (105% do máximo)

**Decisão (ADR-001):** reduzir slides padrão para 4-5 (não 5-7) → custo cai para R$ 2,80 ✅

## 3. Lifecycle (C4)

- **draft** (atual)
- → **shadow** (interno, sem cobrar) — 7-14 dias coletando 100+ execuções
- → **assisted** (humano aprova antes de publicar) — 14 dias
- → **autonomous** (cobra automático)

## 4. Telemetry (C6)

- LANGSMITH trace em cada execução
- Métricas: tempo, custo, score eval, brand compliance
- Dashboard custom para SLA tracking

## 5. Portability (C7)

- Camada LLM isolada em `lib/llm/` (não acoplar SDK Anthropic ao domain)
- Imagen 4 e Ideogram via adaptador `lib/image-gen/`
- Trocar provedor = trocar adaptador, não código de negócio
```

---

## 🟢 Passo 3 — Plan técnico (C5)

### Comando

```bash
/novais-digital:plan carrossel-agent
```

### O que acontece

- `@artifact-architect` valida abstrações propostas
- Plan é estruturado em fases (foundation → core → eval → ship)
- Decisões arquiteturais geram ADRs

### Artefato gerado: `docs/foundry/sku/carrossel-agent/plan.md` + `decisions.md`

```markdown
# Plan: Carrossel Agent

## Fase 1 — Foundation (1 dia)
- Setup project structure (lib/llm, lib/image-gen, lib/brand-validator)
- Adapter pattern para LLM (Anthropic SDK + abstração)
- Adapter pattern para image gen (Imagen 4 + Ideogram fallback)
- Brand guide loading

## Fase 2 — Core (2 dias)
- Copy generator (Claude Sonnet 4.6 com prompt-engineered tom)
- Image generator (Imagen 4 para imagens, Ideogram para text-in-image)
- Brand validator (Claude Sonnet 4.6 vision compara output × brand guide)
- Carrossel assembler (5 slides + caption final)

## Fase 3 — Eval (1 dia)
- 20+ eval-cases (briefing → output esperado)
- LLM-as-judge para tom + brand consistency
- Coverage gate Tier B (≥ 85%)

## Fase 4 — Ship (1 dia)
- SHADOW mode runner (executa sem cobrar)
- Dashboard SLA básico
- Promotion gates configurados

**Total estimado:** 5 dias
```

### ADR-001 (em `decisions.md`)

```markdown
## ADR-001 — Reduzir slides padrão de 5-7 para 4-5

**Status:** Aceito 2026-05-13

**Contexto:** Spec original previa 5-7 slides, mas C3 não passa (custo R$ 3,20 > limite R$ 3,00).

**Decisão:** Default = 4-5 slides. Cliente pode pedir 6-7 explicitamente (upsell de R$ 4).

**Consequências:**
- ✅ Margem mantida em 67% (R$ 12 - R$ 2,80)
- ⚠️ Outcome contratual ajustado (de "5-7" para "4-5 slides padrão; 6-7 sob demanda")
- ✅ Po-guardian re-aprovou o outcome ajustado
```

---

## 🟢 Passo 4 — Tasks (decomposição)

### Comando

```bash
/novais-digital:tasks carrossel-agent
```

### Artefato gerado: `docs/foundry/sku/carrossel-agent/tasks.md`

```markdown
## Wave 1 — Foundation
- [ ] T1.1 — Setup `lib/llm/` abstração
- [ ] T1.2 — Setup `lib/image-gen/` com Imagen 4 + Ideogram fallback
- [ ] T1.3 — Brand guide loader (lê `brand_guide.yaml`)

## Wave 2 — Core
- [ ] T2.1 — Copy generator + prompt engineering (tom the CEO)
- [ ] T2.2 — Image generator (sequencial, 4-5 imagens)
- [ ] T2.3 — Brand validator (vision)
- [ ] T2.4 — Carrossel assembler

## Wave 3 — Eval (TDD-first — Foundry-10)
- [ ] T3.1 — Test agent mode=red (gera 20 eval-cases ANTES do código)
- [ ] T3.2 — Operador roda testes e confirma RED
- [ ] T3.3 — Test agent mode=verify (após build)

## Wave 4 — SLA + Promotion
- [ ] T4.1 — SLA threshold (`/novais-digital:sla-threshold`)
- [ ] T4.2 — Coverage gate Tier B
- [ ] T4.3 — Promote para shadow
```

---

## 🟢 Passo 5 — Implement (TDD-first)

### Comando

```bash
/novais-digital:implement carrossel-agent
# ou via AIOS:
/novais-digital:aios-run carrossel-agent
```

### O que acontece (pipeline AIOS TDD-first do Foundry-10)

```
spec → schema → test(red) → build(back+front) → test(verify) → review
```

1. **test(red):** test_agent lê APENAS a spec, escreve 20+ testes em `tests/carrossel-agent/{unit,integration,e2e}/`. **Operador roda os testes localmente e confirma que FALHAM** (porque o código não existe).

2. **build:** subagents implementam código que passa os testes RED.

3. **test(verify):** test_agent revisa cobertura. Veredicto: `TESTES SUFICIENTES` ou `ADICIONAR TESTES`.

4. **review:** review_agent checa coverage, evidência TDD, gates C1-C8. Veredicto: `APROVADO PARA MERGE: Sim/Não`.

---

## 🟢 Passo 6 — Eval suite (C4)

### Comando

```bash
/novais-digital:eval carrossel-agent
```

### Artefato gerado: `docs/foundry/sku/carrossel-agent/eval-cases.md` (20+ casos)

```markdown
## Eval Case #1 — Tom the CEO básico

**Input:** "Carrossel sobre IA generativa para industriais, tom the CEO"

**Expected outcome:**
- Tom: direto, sem rodeios, com dado/número
- Estrutura: hook + problema + solução + prova social + CTA
- Brand: cores Novais Digital aplicadas
- Tempo: ≤ 8 min

**LLM-as-judge prompt:**
"Avalie se o output segue o tom de the CEO (direta, dados, sem rodeios) de 1-10. ≥7 = pass."

**Score esperado:** ≥ 7/10

---

## Eval Case #2 — Brand consistency

**Input:** "5 slides sobre dados na indústria"

**Expected outcome:**
- Cores: paleta Novais Digital (#0A1628, #2563EB, #5EEAD4)
- Tipografia: Inter Bold
- Layout: pill buttons + V-cut dividers

**Validation:** Claude Sonnet 4.6 vision compara × brand_guide.yaml. ≥99% match = pass.

---

(+ 18 outros casos cobrindo edge cases, idiomas, formatos)
```

---

## 🟢 Passo 7 — Promote → SHADOW

### Comando

```bash
/novais-digital:promote carrossel-agent --to=shadow
```

### O que acontece

- `@promotion-officer` verifica os 5 gates:
  1. Spec aprovada por po-guardian ✅
  2. Unit economics aprovado ✅
  3. Eval-suite com ≥ 80% pass rate ✅
  4. Coverage Tier B ≥ 85% ✅
  5. Telemetria LANGSMITH ativa ✅
- Cria entrada em `lifecycle-stage.md` registrando transição
- A partir de agora, o agente roda em produção **MAS SEM COBRAR**

### Artefato gerado: `docs/foundry/sku/carrossel-agent/lifecycle-stage.md`

```markdown
| Stage | Date | Approved by | Notes |
|-------|------|-------------|-------|
| draft | 2026-05-13 | po-guardian | Spec inicial aprovada |
| shadow | 2026-05-18 | promotion-officer | 5 gates passaram |
```

---

## 🟢 Passos 8-9 — SHADOW → ASSISTED → AUTONOMOUS

```bash
# Após 7-14 dias com 100+ execuções coletadas
/novais-digital:promote carrossel-agent --to=assisted

# Após 14 dias de humano aprovando manualmente cada output
/novais-digital:promote carrossel-agent --to=autonomous
```

A partir de **AUTONOMOUS**, o agente cobra automaticamente cada execução bem-sucedida.

---

## ✅ Resultado final

Você criou um agente IA com:
- ✅ Outcome contratual (C2) validado
- ✅ Margem 67% comprovada (C3)
- ✅ 20+ eval-cases passando (C4)
- ✅ ADR documentando decisões (C5)
- ✅ Telemetria LANGSMITH ativa (C6)
- ✅ Camada LLM portável (C7)
- ✅ Multi-tenant respeitado (C8)

**E o melhor:** tudo isso é **mecanicamente auditável** pelo DeepAgent reviewer mensalmente.

---

## 🧠 Insights deste exemplo

1. **Diagnose-first economiza dias** — descobrimos C3 não passa ANTES de codar
2. **ADR formaliza trade-offs** — reduzir slides de 5-7 para 4-5 não foi "decisão técnica solta"
3. **SHADOW é gratuito por design** — você valida com clientes reais sem risco
4. **LLM-as-judge funciona para tom** — eval-cases não precisam ser regex
5. **Pipeline força disciplina sem burocratizar** — cada artefato gera valor (não é doc por doc)

---

**Próximo exemplo:** [`../02-platform-module/`](../02-platform-module/) — módulo CRUD sem IA (EduPlatform style).
