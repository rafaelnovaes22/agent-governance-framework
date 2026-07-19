# Playground 05 — WireLog Analytics

> **Foundry-21 (v0.22.0)** — `analytics_provider` WireLog convivendo com `llm_trace_provider` LangSmith

Este playground demonstra como configurar e usar WireLog como `analytics_provider` para rastrear eventos de negócio/outcomes em projetos Novais Digital Foundry.

## Estrutura

```
PLAYGROUND/05-wirelog-analytics/
├── README.md                           ← este arquivo
├── walkthrough.md                      ← guia passo-a-passo
├── docs/foundry/project.json             ← configuração: analytics_provider=wirelog
├── events/
│   └── sample-wirelog-events.jsonl     ← 10 eventos fake de referência
└── queries/
    └── wirelog-monthly-audit.md        ← queries para auditoria mensal
```

## Conceito central

**LangSmith ≠ WireLog** — eles têm propósitos distintos:

| | LangSmith (`llm_trace_provider`) | WireLog (`analytics_provider`) |
|---|---|---|
| **Rastreia** | Chamadas LLM, prompts, tokens | Eventos de negócio, outcomes, funis |
| **Para** | Debugging, custo de inferência, evals | Auditoria de billing, gates, promoções |
| **Obrigatório** | Sim, quando ai_enabled=true | Opcional por padrão |

## Início rápido

Leia o [`walkthrough.md`](./walkthrough.md) para entender os eventos e as queries de auditoria.

Para usar em seu projeto:
1. Declare `analytics_provider: "wirelog"` em `docs/foundry/project.json`
2. Copie `templates/observability/wirelog-adapter.ts.template` para `src/observability/wirelog-adapter.ts`
3. Configure `WIRELOG_SECRET_KEY` no ambiente
4. Use as funções de conveniência: `trackOutcomeDelivered`, `trackGateFailed`, `trackEvalCompleted`
