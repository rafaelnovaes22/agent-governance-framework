---
target_workspace: "Novais Digital Governança"
purpose: "internal-governance"
constitution_version: "0.2.0"
constitution_extension_version: "0.1.0"
created_at: "2026-04-30"
last_updated: "2026-04-30"
version: "0.1.0"
---

# ClickUp Blueprint — Novais Digital Governança

> Estrutura proposta do ClickUp **interno Novais Digital** aplicando Sincra L0/L1/L2.
> Cliente final **nunca** acessa este ClickUp — é cockpit interno do time Novais Digital.
> Aplicação prática do template [`clickup-blueprint.template.md`](../../templates/clickup-blueprint.template.md).

---

## 1. Propósito declarado

**Tipo de uso**: `internal-governance`

**Justificativa**: Princípio C8 (Anti-customização) recomenda manter ClickUp **interno**. Cliente externo prefere produto próprio (Novais Digital Fin web app, dashboards) a ClickUp da Novais Digital.

> Origem: ADR-003 do projeto `novais-digital-governanca-ia`.

---

## 2. Estrutura

```
🏢 Workspace: Novais Digital Governança

📂 Space 1 — ESTRATÉGICO (L0, read-mostly)
   ├─ 📜 Novais Digital DNA & Manifesto             (1-3 docs, raramente muda)
   ├─ 🎯 ICP & Personas                      (segmentos por categoria — Plataforma vs Produtos)
   ├─ 📦 Catálogo de Ofertas                 (Diagnóstico, Plataforma SKUs, Produtos)
   ├─ ⚖️  Princípios (Constitution + extensão)
   └─ 🧠 Knowledge Layer                     (BUSINESS_PROCESS, ONTOLOGY, BUSINESS_RULE, REFERENCE_DATA)

📂 Space 2 — COMERCIAL (L1, pipeline)
   ├─ 🎣 Leads                               NOVO → CONTATADO → QUALIFICADO → DESQUALIFICADO
   ├─ 🩺 Diagnósticos                        PROPOSTO → CONTRATADO → SESSÃO → ANÁLISE → ENTREGUE → CONVERTIDO/NÃO
   ├─ 📜 Propostas                           RASCUNHO → ENVIADA → NEGOCIANDO → ACEITA/RECUSADA
   └─ 🏢 Clientes (master)                   consolida cliente em todos os produtos/SKUs

📂 Space 3 — PLATAFORMA (L1+L2, high-touch SaaS²)
   ├─ 📋 Subscriptions                       NEGOCIANDO → SETUP → SHADOW → ASSISTED → AUTONOMOUS → SUNSET
   ├─ 🌊 Waves                               PROPOSED → CONTRACTED → IN_DELIVERY → DELIVERED
   ├─ ✅ Setup/Onboarding (tarefas)          BACKLOG → DOING → REVIEW → DONE
   ├─ 🔁 Outcomes em produção (espelho)      sync DB→ClickUp via webhook
   ├─ ⚠️  Incidentes / SLA Breach            NOVO → INVESTIGANDO → MITIGADO → RESOLVIDO
   └─ 🧪 Eval Suites                         DRAFT → ACTIVE → DEPRECATED

📂 Space 4 — PRODUTOS (L1+L2, Novais Digital Fin + Educacional + futuros)
   ├─ 🚀 Roadmap por produto                 BACKLOG → SPECING → BUILDING → RELEASED
   ├─ 🐛 Bugs & Issues                       REPORTADO → TRIAGE → FIX → RESOLVIDO
   ├─ 💬 Feedback / Beta Users               RECEBIDO → PROCESSADO → ATENDIDO/IGNORADO
   ├─ 📊 Métricas vivas                      1 task por métrica (target/atual/trend)
   └─ 🎓 Lifecycle Stage                     DISCOVERY → MVP → BETA → GA → MATURITY → SUNSET

📂 Space 5 — ENGENHARIA INTERNA (L2)
   ├─ 🛠️  Foundry ondas (Foundry-1, -2, ...)
   ├─ 🧪 Pesquisa & Spike
   ├─ 🏗️  Refactors / Tech Debt
   └─ ✅ Sprint atual do time Novais Digital

📂 Space 6 — AUDITORIA & GOVERNANÇA (L2)
   ├─ 📊 Auditorias Mensais (DeepAgent)      1 task/mês com relatório anexado
   ├─ 🚨 Issues abertas pelo Reviewer        NOVO → ATRIBUÍDO → CORRIGINDO → RESOLVIDO
   ├─ 🕳️  Bypass Log                          registros NOVAIS_FOUNDRY_BYPASS=incident
   └─ 📋 ADRs                                PROPOSTA → APROVADA → SUPERSEDED
```

**Total**: 6 Spaces, 25 listas. Cada lista mapeia 1:1 para enums do `prisma/schema.prisma` quando aplicável.

---

## 3. Mapeamento DB ↔ Lista (sync via webhook)

| Tabela DB | Lista ClickUp | Direção sync | Trigger |
|---|---|---|---|
| `Lead` | Space 2 / Leads | bidirecional | DB→CU em status change; CU→DB em webhook |
| `Diagnostic` | Space 2 / Diagnósticos | bidirecional | manual + webhook |
| `Subscription` | Space 3 / Subscriptions | bidirecional | DB→CU em mode change |
| `Wave` | Space 3 / Waves | bidirecional | DB→CU em status change |
| `Outcome` | Space 3 / Outcomes em produção | DB→ClickUp apenas | Job batch a cada 1h |
| `EvalCase` | Space 3 / Eval Suites | manual + webhook | criação no ClickUp = INSERT no DB |
| `Tenant` (clientes) | Space 2 / Clientes | bidirecional | onboarding |
| `KnowledgeAsset` | Space 1 / Knowledge Layer | bidirecional | versionamento |
| Audit Reports (filesystem) | Space 6 / Auditorias Mensais | docs→CU apenas | Cron mensal |
| ADRs (filesystem) | Space 6 / ADRs | docs→CU apenas | manual ao criar ADR |

---

## 4. Permissões internas

| Role | Acesso |
|---|---|
| **CEO** | Todos os Spaces, leitura + edição |
| **Tech Lead** | Spaces 1, 3, 4, 5, 6 — leitura+edição; Space 2 — leitura |
| **Engenharia** | Spaces 3, 4, 5, 6 — leitura+edição; Spaces 1, 2 — leitura |
| **Comercial** | Spaces 1, 2 — leitura+edição; outros — leitura |
| **Operação** | Spaces 3, 4, 6 — leitura+edição; outros — leitura |
| **Cliente externo** | ❌ Sem acesso ao ClickUp interno |

---

## 5. Bootstrap automatizado

### Pré-requisitos
- API token ClickUp com permissão de criar Spaces/Listas no workspace `9011695857` (já existente)
- Cliente API ClickUp (`src/clickup/client.ts` já implementado)

### Comando

```bash
npm run clickup:bootstrap -- --workspace=9011695857 --blueprint=docs/clickup-blueprint.md
```

(Script ainda não implementado — entrega em Foundry-3 — `scripts/clickup-bootstrap.ts`).

### Comportamento esperado

- Idempotente: rodar 2x produz mesmo resultado
- Não-destrutivo: Spaces/Listas existentes mantidos; só cria o que falta
- Loga drift no final em `docs/foundry/audits/clickup-drift-{YYYY-MM-DD}.md`

---

## 6. Hook de drift detection (Foundry-4)

Hook mensal compara estado real do ClickUp vs blueprint declarado:

```
.claude/settings.json
├── hooks
│   └── PostToolUse
│       └── clickup-drift-detector
│           ├── matcher: '*'  # roda independente de tool
│           ├── frequency: 'monthly'  # mas só dispara mensalmente
│           └── output: docs/foundry/audits/clickup-drift-{YYYY-MM-DD}.md
```

Drift detectado abre issue em **Space 6 / Issues abertas pelo Reviewer**.

---

## 7. Reviewer DeepAgent — checks adicionais para ClickUp

Além dos checks C1-C8 padrão, reviewer audita:

| Check | Validação |
|---|---|
| ClickUp Spaces declarados existem | API call `GET /workspace/{id}/space` |
| Listas declaradas existem em cada Space | API call `GET /space/{id}/list` |
| Status workflows declarados configurados | API call para inspecionar statuses |
| Webhook handler do projeto consumidor instalado | Endpoint `/webhooks/clickup` retorna 200 |
| Sync DB↔ClickUp coerente | Conta entidades em DB vs tasks em CU; desvio > 5% = WARN |

---

## 8. Workspace ClickUp atual da Novais Digital

| Atributo | Valor |
|---|---|
| **Workspace ID** | `9011695857` |
| **URL** | (ClickUp interno) |
| **Estado as-is** | A mapear antes de aplicar bootstrap |
| **Estrutura legacy** | PMO clássico (Charter/WBS/RACI) — em sunset por D3 |

> Antes do bootstrap rodar, time Novais Digital deve **mapear** o que já existe no workspace e marcar para migração ou remoção.

---

## 9. Implementação proposta — outras sessões

A implementação concreta do ClickUp blueprint (criação de Spaces, listas, status) está sendo trabalhada em **outra sessão Claude Code** que tem o contexto técnico completo do `src/clickup/`.

Esta sessão (a que escreveu o Foundry v0.2) deixa o blueprint **especificado**; outra sessão executa.

---

## 10. Aprovação

- [ ] Mantenedor leu e aprovou estrutura
- [ ] Workspace ClickUp atual mapeado (estado as-is)
- [ ] Permissões §4 configuradas
- [ ] Webhook handler do projeto `novais-digital-governanca-ia` em rota `/webhooks/clickup`
- [ ] Bootstrap script implementado (Foundry-3)
- [ ] Hook drift-detector instalado (Foundry-4)
- [ ] Primeira auditoria DeepAgent inclui drift ClickUp

**Status atual** (2026-04-30): `⏳ blueprint especificado; implementação em outra sessão`
