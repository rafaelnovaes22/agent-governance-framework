# 📖 Walkthrough — Plataforma híbrida com módulo IA (passo a passo)

> Pipeline completo para construir um projeto `hybrid`: plataforma SaaS sem IA com **um módulo específico que usa LLM**. Interpretação dos princípios C1-C8 é **por módulo**, não pelo projeto inteiro.
> **Duração**: ~25 min leitura + execução em consumer real.
> **Pré-req**: Foundry v0.13.0+, `docs/foundry/project.json` com `project_type=hybrid`.

---

## Cenário

Plataforma B2B de gestão financeira (inspirada em Aicfo). 95% do código é CRUD/contábil sem IA. Mas existe **um módulo de Análise Financeira** que gera insight narrativo via LLM (Claude Opus). Esse módulo precisa de evals, LANGSMITH, custo controlado por outcome.

---

## 🟢 Passo 1 — Declarar o projeto como `hybrid` no `project.json`

```json
{
  "project_type": "hybrid",
  "ai_enabled": "per-module",
  "modules": [
    {"id": "tenant-mgmt", "type": "platform_module", "ai_enabled": false, "criticality": "B"},
    {"id": "billing-stripe", "type": "platform_module", "ai_enabled": false, "criticality": "C"},
    {"id": "ai-financial-analysis", "type": "platform_sku", "ai_enabled": true, "criticality": "B"}
  ]
}
```

Foundry usa esse arquivo para ramificar checks por módulo. po-guardian, unit-economist, security-privacy-guardian **TODOS** sabem ler `ai_enabled` por módulo.

---

## 🟢 Passo 2 — Diagnose por subset (módulo IA isolado)

```bash
> /novais-digital:diagnose --project_type=hybrid --module=ai-financial-analysis
```

O comando reconhece que precisa rodar **dois fluxos paralelos**:

| Fluxo | Aplica em | Output |
|---|---|---|
| Diagnose platform | módulos sem IA | `docs/clients/{X}/diagnostic-platform.md` |
| Diagnose agentic | módulo IA | `docs/clients/{X}/diagnostic-ai-financial-analysis.md` |

Para este walkthrough focamos no módulo IA (o caminho `platform` é igual ao PLAYGROUND/02).

Output do diagnose IA:
```yaml
module_id: ai-financial-analysis
client_pain: "Analistas levam 3-5h gerando narrativa de balanço; cliente paga R$ 800 por relatório"
proposed_outcome: "Insight narrativo de 1 página com 3 conclusões + 3 riscos detectados"
unit: classified_outcome
sla:
  agreement_rate_with_analyst: ">= 85% após 14d SHADOW"
  cost_per_outcome_brl: "<= 12.50 (25% de R$ 50)"
```

---

## 🟢 Passo 3 — ADR obrigatória para adicionar módulo IA

Aqui está a diferença chave de `hybrid`: **adicionar módulo IA dentro de uma plataforma core sem IA exige ADR** porque expande C7 (portability) — a plataforma agora depende de provider de inferência.

```bash
> /novais-digital:spec --type=adr --module=ai-financial-analysis
```

ADR-007 (exemplo):

```markdown
## Contexto
Plataforma Aicfo core é deterministic (SQL, regras contábeis).
Adicionar módulo de análise narrativa via LLM expande superfície de:
- Custo variável (tokens) — antes 100% fixo
- Provider lock-in (Anthropic) — antes nenhum
- Latência indeterminada — antes p99 < 200ms
- Qualidade variável — antes binária (correto/incorreto)

## Decisão
Adotar Anthropic Claude como provider primário do módulo, com adapter pattern
para permitir trocar por OpenAI/Gemini se preço/qualidade divergirem >30%.

## Consequências
- C3 do módulo IA segue cost_per_outcome (≤25%); platform mantém platform_margin.
- C6 exige LANGSMITH APENAS para módulo IA.
- C7 — adapter em src/llm/adapters/anthropic.ts; nenhum import direto fora dele.
- Eval suite obrigatória (não acceptance gate) — módulo IA segue caminho agentic.
```

ADR assinada por arquiteto + product owner. Foundry usa hook `adr-approval-gate` para impedir edição posterior sem nova ADR.

---

## 🟢 Passo 4 — Spec do módulo IA (template `platform-sku-spec`)

```bash
> /novais-digital:spec --type=platform-sku --module=ai-financial-analysis
```

Spec inclui:
- Outcome contratual classificado em 4 categorias
- Eval suite plan: ≥ 30 casos por categoria
- System prompt versionado (`prompts/ai-financial-analysis-v1.md`)
- TenantContext: nenhum hardcode por cliente
- Section 8 (instrumentação): LANGSMITH trace_id + observe() em toda chamada LLM
- Section 9 (AIOS): `aios_tier: B` — coverage gate 85% line

---

## 🟢 Passo 5 — Plan paralelo: platform sem IA + módulo IA

`/novais-digital:plan` gera **plano composto**:

```
src/modules/tenant-mgmt/        # platform — sem IA
src/modules/billing-stripe/     # platform — sem IA (Tier C)
src/modules/ai-financial/       # agentic — COM IA
src/llm/adapters/anthropic.ts   # adapter compartilhado (C7)
src/infra/audit-log/            # compartilhado entre todos os módulos
prompts/ai-financial-v1.md      # APENAS para módulo IA
evals/ai-financial/cases/       # APENAS para módulo IA (≥30 casos)
tests/{tenant-mgmt,billing-stripe,ai-financial}/  # todos têm TDD
```

Cronograma:
- Platform modules: `draft → staging → pilot (14d) → canonical`
- Módulo IA: `SHADOW (14d) → ASSISTED (≥30d, ≥90% approval) → AUTONOMOUS`

---

## 🟢 Passo 6 — Tasks + Implement (Waves híbridas)

`/novais-digital:tasks` emite **6 ondas** para platform + **5 ondas agentic** apenas para módulo IA:

| Wave | Platform modules | Módulo IA |
|---|---|---|
| 1 | scaffolding CRUD | scaffolding com prompt-builder |
| 2 | service build | prompt + eval seed |
| 3 | E2E tests | eval suite real (30+ casos) |
| 4 | PILOT prep | SHADOW prep + LANGSMITH |
| 5 | — | metrics |
| 6 | CI/CD | CI/CD compartilhado |

Implement gera scaffolding com `// TODO` por módulo. Operador preenche regras contábeis (platform) e tom narrativo (módulo IA) com conhecimento de domínio.

---

## 🟢 Passo 7 — Eval do módulo IA (sem afetar platform)

```bash
> /novais-digital:eval --module=ai-financial-analysis
```

Roda APENAS contra o módulo IA. 30 casos categorizados:
- 10 balanço sem riscos críticos → narrativa positiva esperada
- 10 balanço com 1-2 riscos → menção obrigatória
- 10 balanço deteriorando → narrativa cautelosa
- 5 adversarial (dados ruidosos / faltantes) → recusa graciosa

Pass rate por categoria ≥ 80% para promover SHADOW → ASSISTED.

---

## 🟢 Passo 8 — Promover módulos SEPARADAMENTE

Cada módulo tem seu próprio ciclo de promoção:

```bash
> /novais-digital:promote --to=pilot --module=billing-stripe       # platform, 14d crítico
> /novais-digital:promote --to=canonical --module=billing-stripe   # após PILOT
> /novais-digital:promote --to=assisted --module=ai-financial-analysis  # após SHADOW + eval verde
> /novais-digital:promote --to=autonomous --module=ai-financial-analysis  # após 30d ASSISTED + Gate 6 CI
```

Foundry bloqueia `autonomous` do módulo IA se `billing-stripe` ainda em pilot — algumas dependências cruzadas exigem que infra esteja sólida.

---

## 🟢 Passo 9 — Auditoria mensal ramificada

`/novais-digital:audit-monthly` lê `project.json → modules[]` e ramifica:

- Para módulos `ai_enabled=false`: audita `audited_actions` table, calcula `platform_margin`, valida pilot-state.md de cada um
- Para módulos `ai_enabled=true`: amostra 5-10% de outcomes em LANGSMITH, valida `cost_per_outcome`, valida eval suite recente

Output em `docs/foundry/audits/2026-06.md` tem **2 seções separadas**, uma por classe de módulo.

---

## 🎯 O que aprendemos com este exemplo

1. **`hybrid` é interpretação por módulo, não por projeto inteiro** — F26 (Foundry-9) formalizou
2. **Adicionar módulo IA em platform exige ADR** — expande C7 e introduz custo variável
3. **Adapters compartilhados** preservam C7 mesmo em hybrid (`src/llm/adapters/`)
4. **Lifecycles independentes** — cada módulo promove no seu ritmo, com seus gates
5. **Reviewer mensal ramifica automaticamente** — sem reescrever prompt
6. **CI/CD pode ser compartilhado** — um único `foundry-validate.yml` cobre todos os módulos com matrix

---

## Próximo passo

Compare com [`02-platform-module/walkthrough.md`](../02-platform-module/walkthrough.md) (caminho puro platform) e [`01-agentic-saas-agent/walkthrough.md`](../01-agentic-saas-agent/walkthrough.md) (caminho puro agentic). Hybrid é a interseção.

Ou aplique em consumer real seguindo [`INSTALL.md`](../../INSTALL.md).
