# 📖 Walkthrough — Módulo Faturamento (passo a passo)

> **Tempo de leitura:** ~20 min | **Pré-requisito:** ter lido [`README.md`](./README.md)

Mostra como o Foundry se aplica a **plataforma SaaS sem IA**. Constitution C1-C8 mantém os IDs mas a interpretação é local.

---

## 🟢 Passo 1 — Diagnose (C1 — Diagnose-before-build)

### Comando

```bash
/novais-digital:diagnose faturamento --project_type=platform
```

### O que acontece (diferente do agentic)

- Sistema lê `project.json` → detecta `platform + ai_enabled=false`
- `po-guardian` aplica matriz platform: outcome **operacional** (não LLM outcome)
- Skills LLM-centric (`artifact-prompt-builder`, `eval-case-author`) **não são invocadas**
- `diagnostic-runner` (Tier 2 skill) usa template platform

### Artefato gerado: `docs/foundry/modules/faturamento/diagnostic.md`

```markdown
---
module_id: faturamento
project_type: platform
ai_enabled: false
diagnose_date: 2026-05-13
outcome_clause: "Emitir NF-e + calcular impostos + sync ERP em ≤ 30s, com audit trail"
icp_fit: "Empresas LTDA/SA tributação Simples/Lucro Presumido com ERP TOTVS/SAP"
po_guardian_approval: ✅
---

## Diagnóstico Operacional

**Problema do cliente:** processo manual de faturamento leva 15min/nota, propenso a erro.

**Outcome contratual (C2):**
- ✅ Positivo: NF-e emitida + impostos calculados + ERP atualizado em 25s, sem intervenção
- ❌ Negativo: NF-e emitida em 25s mas ERP não sincronizou
- ❌ Negativo: NF-e correta porém em 5 minutos (viola SLA)

**Hipóteses operacionais:**
1. API SEFAZ tem latência aceitável (<10s) na maioria dos estados?
2. Audit trail completo cabe em PostgreSQL sem indexação cara?
3. Sync ERP por webhook é robusto vs polling?

**Riscos identificados:**
- SEFAZ instável em horários de pico → fila resiliente + retry
- Diferentes regimes tributários → estratégia/policy pattern
- ERPs incompatíveis → adapter por fornecedor (TOTVS, SAP, etc.)
```

---

## 🟢 Passo 2 — Spec contratual (C2 + C3)

### Comando

```bash
/novais-digital:spec faturamento --type=platform-module
```

### O que muda vs agentic

- Template `platform-module-spec.template.md` (não `platform-sku-spec`)
- `unit-economist` aplica `delivery-economics` (não `unit-economics` em tokens)
- Outcome não envolve LLM — só métricas operacionais

### Artefato gerado: `docs/foundry/modules/faturamento/spec.md` (resumo)

```markdown
---
module_id: faturamento
module_version: 0.1.0
project_type: platform
ai_enabled: false
criticality: C  # crítico — toca dinheiro
current_stage: draft
spec_status: po_guardian_approved
has_ui: true
---

# Spec: Módulo Faturamento

## 1. Outcome contratual (C2)

**Promessa:** Para cada solicitação de emissão, entregar:
- NF-e validada pela SEFAZ
- Impostos calculados conforme regime do tenant (Simples / Lucro Presumido / Lucro Real)
- ERP do tenant atualizado via webhook ou API
- Audit log inserido em `audit_trail` table

**Tempo SLA:** P95 ≤ 30s | P99 ≤ 60s

**Critério de aceite verificável:**
- [x] HTTP 200 retornado com `xml_nfe`, `tax_calculation`, `erp_sync_status`
- [x] Row inserida em `audit_trail` com `actor`, `action`, `before/after`, `timestamp`
- [x] Webhook fired ou ERP API call confirmada

## 2. Delivery economics (C3 reinterpretado)

**Custo NÃO é por token — é por tenant.**

**Receita por tenant:** R$ 2.500/mês × 50 tenants = R$ 125.000/mês (R$ 1.5M/ano)
**Custo do módulo:**
- Infra (PostgreSQL + compute): R$ 8.000/mês
- Suporte (compartilhado): R$ 5.000/mês
- Integrações terceiros (SEFAZ + ERPs): R$ 4.000/mês
- **TOTAL:** R$ 17.000/mês = R$ 204.000/ano

**Margem do módulo:** (R$ 1.500.000 - R$ 204.000) / R$ 1.500.000 = **86,4%** ✅
**C3 platform check:** custo/receita = 13,6% ≤ 25% ✅

## 3. Lifecycle (C4 reinterpretado)

- **draft** (atual) — dev local
- → **staging** — ambiente interno, smoke tests, sem clientes
- → **pilot** — 1 cliente real (consentido), 14 dias monitoramento
- → **canonical** — disponibilizado para todos os tenants

## 4. Telemetry (C6 reinterpretado)

- ❌ LANGSMITH: NÃO (sem LLM)
- ✅ Logs estruturados (Pino → Sentry)
- ✅ Audit trail (PostgreSQL `audit_trail` table)
- ✅ SLOs: P95 latency, error rate, ERP sync success rate

## 5. Portability (C7)

- Adapter pattern para ERPs (`lib/erp-adapters/` com TOTVS, SAP, Bling, etc.)
- Adapter pattern para SEFAZ (federal/estaduais)
- Domain layer não conhece HTTP nem DB (Clean Architecture)

## 6. Tenant context (C8)

- Multi-tenant: cada NF-e tem `tenant_id`
- RLS (Row Level Security) no PostgreSQL
- Audit trail particionado por tenant
```

---

## 🟢 Passo 3 — Plan técnico + ADRs

### Comando

```bash
/novais-digital:plan faturamento
```

### Artefatos gerados

`plan.md` com fases adaptadas para platform:
- Fase 1P — Setup Next.js + Prisma + audit_trail table
- Fase 2P — Adapters (SEFAZ, ERPs, regimes tributários)
- Fase 3P — Endpoints + UI (forms, listagem, retry de falhas)
- Fase 4P — Acceptance criteria + smoke tests + Playwright E2E
- Fase 6P — CI/CD (foundry-test workflow ativo)

`decisions.md` com:
- ADR-001: Fila SQS para retry de SEFAZ instável
- ADR-002: Strategy pattern para regimes tributários
- ADR-003: Webhook-first, fallback para polling no sync ERP
- ADR-004: Audit trail particionado por tenant_id para escalabilidade

---

## 🟢 Passo 4 — Tasks (Waves 1P-4P + 6P)

### Comando

```bash
/novais-digital:tasks faturamento
```

### Artefato gerado (resumo)

```markdown
## Wave 1P — Foundation
- [ ] T1P.1 — Schema Prisma com `nf_e`, `audit_trail`, `tenant_tax_regime`
- [ ] T1P.2 — RLS no PostgreSQL por tenant_id
- [ ] T1P.3 — `lib/erp-adapters/` + interface comum

## Wave 2P — Domain
- [ ] T2P.1 — Strategy pattern para 3 regimes (Simples, Lucro Pres, Lucro Real)
- [ ] T2P.2 — SEFAZ adapter (federal + 27 estaduais simplificados)
- [ ] T2P.3 — ERP adapter TOTVS + SAP

## Wave 3P — Interface (TDD-first)
- [ ] T3P.1 — Endpoints REST com Fastify
- [ ] T3P.2 — UI Next.js (form + listagem + retry)
- [ ] T3P.3 — Webhook handlers

## Wave 4P — Acceptance + Tests
- [ ] T4P.1 — Acceptance criteria checklist
- [ ] T4P.2 — Vitest unit tests (≥85% coverage Tier B... ou 95% Tier C)
- [ ] T4P.3 — Vitest integration tests (Postgres ephemeral)
- [ ] T4P.4 — Playwright E2E (criar nota, calcular, sync, retry)

## Wave 6P — CI/CD
- [ ] T6P.1 — Workflow foundry-test ativo
- [ ] T6P.2 — Branch protection com check `unit-tests`, `integration-tests`, `e2e-tests`
- [ ] T6P.3 — Coverage gate Tier C bloqueante
```

---

## 🟢 Passo 5 — Implement (AIOS TDD-first)

### Comando

```bash
/novais-digital:aios-run faturamento
```

### Pipeline (Foundry-10)

Idêntico ao Exemplo 01, mas **sem eval LLM**:

```
spec → schema → test(red) → build → test(verify) → review
```

Diferenças:
- `test_agent` em mode=red gera testes Vitest + Playwright (não eval-cases LLM)
- Coverage target Tier C (95% line, 100% critical_path) — porque módulo financeiro
- `review_agent` checa audit-trail em services modificados (hook `audit-trail-check`)

---

## 🟢 Passo 6 — Pre-merge check

### Comando

```bash
/novais-digital:pre-merge-check
```

### O que valida

- ✅ Testes unit/integration/e2e passam
- ✅ Coverage Tier C ≥ 95% line
- ✅ `audit-trail-check` hook detectou log em todos os services modificados
- ✅ `security-privacy-guardian` revisou queries SQL (sem SQLi)
- ✅ `code-reviewer-cross` aprovou

**Sem eval-suite LLM** — não há prompts a avaliar.

---

## 🟢 Passo 7 — Promote para staging

### Comando

```bash
/novais-digital:promote faturamento --to=staging
```

### Gates platform (4, não 5)

1. Spec aprovada ✅
2. Delivery economics ≤ 25% custo/receita ✅
3. Coverage Tier C atingido ✅
4. Audit trail funcional em staging ✅

---

## 🟢 Passos 8-9 — Pilot → Canonical

```bash
# Após 7 dias em staging com smoke tests OK
/novais-digital:promote faturamento --to=pilot
```

### Acceptance gate (substitui eval LLM)

Para promover **pilot → canonical**, é exigido um `acceptance-report.md` **assinado por decisor cliente real**:

```markdown
---
module_id: faturamento
pilot_tenant: empresa-x-ltda
pilot_period: 2026-05-20 → 2026-06-03
decisor_cliente: João Silva (CFO)
signature_hash: sha256:abc123...   # exigido para criticality=C
acceptance_status: APPROVED
---

## Acceptance Report

### Métricas operacionais durante o pilot (14 dias)

| Métrica | Target | Realizado | Status |
|---------|--------|-----------|:------:|
| P95 latency | ≤ 30s | 18.4s | ✅ |
| Error rate | ≤ 0.5% | 0.12% | ✅ |
| ERP sync success | ≥ 99% | 99.7% | ✅ |
| Audit trail completeness | 100% | 100% | ✅ |
| Customer-reported bugs | ≤ 3 | 1 (resolvido em 4h) | ✅ |

### Aceite formal

Eu, João Silva (CFO da Empresa X LTDA), declaro que o módulo Faturamento
atende aos requisitos contratados e autorizo sua promoção para canonical.

Data: 2026-06-03
Signature hash: sha256:abc123...
```

```bash
# Com acceptance-report assinado:
/novais-digital:promote faturamento --to=canonical
```

---

## ✅ Resultado final

Você criou um módulo de plataforma com:
- ✅ Outcome operacional verificável (C2)
- ✅ Margem 86% comprovada (C3 platform)
- ✅ 95% coverage Tier C + audit trail (C4 platform)
- ✅ 4 ADRs documentando trade-offs (C5)
- ✅ Logs estruturados + audit (C6 platform)
- ✅ Adapters portáveis (C7)
- ✅ RLS multi-tenant (C8)

---

## 🧠 Insights deste exemplo

1. **Plataforma também usa Foundry** — sem IA, sem eval LLM, sem LANGSMITH, mas com MESMO rigor
2. **C3 muda de "tokens" para "infra+suporte"** — mas o limite de 25% permanece
3. **Acceptance gate substitui eval** — humano assina aceite formal vs LLM-as-judge
4. **Lifecycle muda nomenclatura** — draft/staging/pilot/canonical (não SHADOW/AUTONOMOUS)
5. **Audit trail é o "trace" do platform** — equivalente operacional do LANGSMITH
6. **Constitution não muda — interpretação muda** — F26 (Foundry-9) formalizou isso

---

**Próximo exemplo:** [`../03-hybrid/`](../03-hybrid/) — plataforma com 1 módulo IA embutido.
