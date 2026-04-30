# Acme — Portfolio em 3 categorias

> Aplicação prática do princípio C11 (extensão Acme) — portfolio multi-categoria.
> Origem da decisão: ADR-002 do projeto `acme-governanca-ia`.

---

## Visão geral

A Acme opera **3 categorias formais de oferta**, complementares e não-concorrentes:

```
                    ┌─────────────────────┐
                    │  Acme Diagnóstico │
                    │  (porta de entrada) │
                    └──────────┬──────────┘
                               │
                       qualifica em
                               ↓
              ┌────────────────┴────────────────┐
              │                                 │
              ↓                                 ↓
   ┌──────────────────┐              ┌──────────────────┐
   │ Acme Plataforma│              │ Acme Produtos  │
   │   (high-touch)   │              │   (self-serve)   │
   └──────────────────┘              └──────────────────┘
```

---

## Categoria 1 — Acme Diagnóstico

| Atributo | Valor |
|---|---|
| **ICP** | PME R$ 2M+ caótica em modo bombeiro |
| **Cliente loga?** | ❌ Não — entrega via PDF + sessão de devolução |
| **Outcome** | Relatório executivo com 3 candidatos a SKU automatizável |
| **Pricing** | R$ 5–10k one-time |
| **Time-to-value** | 5 dias úteis |
| **Escala** | Manual / consultiva (não escala via produto) |
| **Stack operacional** | Sessões 1:1, planilhas, PDF gerado |
| **Lifecycle** | N/A (cada Diagnóstico é instância única) |

Princípio C1 (Diagnose-before-design) é **operacionalizado** por esta categoria.

---

## Categoria 2 — Acme Plataforma (high-touch SaaS²)

| Atributo | Valor |
|---|---|
| **ICP** | PME R$ 2M+ pós-Diagnóstico, com volume mensal ≥ 50–100 outcomes/processo |
| **Cliente loga?** | ❌ Não — entrega async (WhatsApp, email, webhook); ClickUp é interno Acme |
| **Stack** | Node + LangGraph (ou state machine custom) + Postgres/Prisma + BullMQ + Langfuse |
| **Outcome** | Lead qualificado, ticket resolvido, etc. — cobrado por unidade entregue |
| **Pricing** | Setup R$ 8–25k + plataforma R$ 1,5–4k/mês + variável por outcome + Wave R$ 8–25k cada |
| **Time-to-value** | 30–60 dias até SHADOW; 60–90 dias até AUTONOMOUS |
| **Modos** | SHADOW → ASSISTED → AUTONOMOUS (com gates de promoção) |
| **Escala** | Catálogo de SKUs reusáveis; cliente N+1 do mesmo SKU custa < 30% do cliente 1 |
| **Lifecycle** | Por SKU: Discovery → MVP → Beta → GA → Maturity → Sunset |

### SKUs do catálogo

| SKU | Vertical | Status atual |
|---|---|---|
| `example-triagem-whatsapp` | Showcase (não-vendável) | MVP/Beta interno |
| `triagem-comercial-whatsapp` | Serviços profissionais | Discovery (CEO ainda definindo D1+D2) |
| (futuros) | A definir após cliente piloto | — |

### Estrutura comercial expandida (Onda 1B)

A Plataforma suporta **engagement comercial discreto** via Waves:

- **Subscription Essential (Rota B)**: 1 Wave única "onboarding", ticket menor, low-touch
- **Subscription Full (Rota A/C)**: N Waves ao longo do LTV (NRR > 120%)
- **Transformation fee** R$ 25–60k = setup + 1ª Wave

---

## Categoria 3 — Acme Produtos (self-serve SaaS²)

| Atributo | Valor |
|---|---|
| **ICP** | Pode diferir do ICP da Plataforma — sócio, controller, contador, gestor financeiro |
| **Cliente loga?** | ✅ **Sim** — UI é parte do produto |
| **Stack** | Variável por produto — sem lock arquitetural cross-produto |
| **Outcome** | Análise mensal, plano de ação, [outros conforme produto] — entregue via UI logada |
| **Pricing** | Mensalidade fixa low-touch (faixa R$ 97–997/mês ou usage-based) |
| **Time-to-value** | < 5 minutos (primeira interação útil) |
| **Lifecycle** | Discovery → MVP → Beta → GA → Maturity → Sunset (declarado por produto) |
| **Escala** | Marketing + onboarding self-serve; sem time de implementação por cliente |

### Produtos atuais

| Produto | Stage | Stack | Outcome principal | URL |
|---|---|---|---|---|
| **Acme Fin** | **Beta** | Lovable + Supabase | Análise financeira mensal + plano de ação | `https://financeiro.acme.com.br` |
| **Acme Educacional** | **Discovery** | TBD | TBD | — |

Detalhe em [`products/acme-fin.md`](./products/acme-fin.md) e [`products/acme-educacional.md`](./products/acme-educacional.md).

---

## Relações entre categorias

### Diagnóstico → Plataforma OU Produtos

Diagnóstico **classifica** o cliente:
- Cliente com volume alto + processo claro → **Plataforma** (custom)
- Cliente sem volume mas com dor padrão → **Produtos** (self-serve)
- Ambos podem coexistir no mesmo cliente

### Cross-sell entre categorias

- Cliente Plataforma SKU `triagem-comercial` pode comprar Produto `Acme Fin` como complemento
- Cliente Produto que cresce em uso vira candidato natural a Diagnóstico → Plataforma

---

## Métricas separadas por categoria (princípio C10)

Two-track economics: cada categoria tem KPIs próprios. **Não comparar** ARPU de Plataforma com ARPU de Produtos — são modelos distintos.

### Diagnóstico
- Conversão Diagnóstico → contrato Plataforma/Produto: meta ≥ 30%
- Tempo médio Diagnóstico → contrato: ≤ 30 dias

### Plataforma
- ARPU mensal: R$ 5–15k (variável + plataforma)
- NRR: ≥ 120% (target via Waves adicionais)
- Tempo até AUTONOMOUS: ≤ 90 dias
- Outcomes/mês/cliente: 200–500

### Produtos
- ARPU mensal: R$ 97–997
- Conversão trial → paid: ≥ 15%
- Churn mensal: ≤ 5%
- TTFO (time to first outcome): ≤ 5 min
- DAU/MAU: ≥ 30%

---

## ICP comparativo

| Dimensão | Plataforma | Produtos |
|---|---|---|
| Tomador de decisão | CEO bombeiro | Sócio / controller / contador |
| Tamanho de empresa | R$ 2M+ faturamento | R$ 500k–10M faturamento |
| Capacidade de pagar | Alta (R$ 5-15k/mês) | Média (R$ 97-997/mês) |
| Tolerância a setup longo | Sim (30-60 dias) | Não (< 5 min) |
| Demanda customização | Alta (mas fica como config) | Baixa (padronizado) |
| Quer integração custom | Sim (canais, ERP, CRM) | Não (upload de arquivo) |

---

## Decisão estratégica em vigor

ICP foco: **Rota C/A** (CEO áudio 2026-04-29):
- High-ticket B2B (Plataforma) é **foco principal**
- Low-ticket (Produtos) vira **canal de entrada** — funil para Plataforma
- Aprovação formal pendente (CEO vai analisar com números)

Implicação operacional: time concentra esforços em Plataforma; Produtos funcionam como aquisição/visibilidade e podem virar receita relevante posteriormente.

---

## ADRs relacionados (no projeto consumidor)

- ADR-001 — Stack arquitetural SaaS² (Plataforma)
- ADR-002 — Portfolio em 3 categorias (formaliza este documento)
- ADR-003 — ClickUp como sistema de governança interna
