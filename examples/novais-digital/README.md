# Examples — Novais Digital

> **Caso de uso real** que originou o Novais Digital Foundry. Funciona como gabarito para outros projetos que adotem o framework.

---

## Contexto

A Novais Digital é uma consultoria de IA aplicada que pivotou para **plataforma multi-categoria SaaS²** atendendo PMEs R$ 2M+ em modo bombeiro.

Este diretório contém:
- **Metodologias** que originaram a Constitution (3 docs)
- **Portfolio** em 3 categorias formais (Diagnóstico / Plataforma / Produtos)
- **Constitution extensions** específicas Novais Digital (C9, C10, C11)
- **ClickUp blueprint** para governança operacional interna
- **Specs de produtos** (Novais Digital Fin em beta, Novais Digital Educacional em discovery)

---

## Conteúdo

### Metodologias

[`methodology/`](./methodology/) — 3 documentos que precedem a Constitution:

- `metodologia.md` — Metodologia Novais Digital clássica (4 fases por engajamento)
- `metodologia_novais.md` — Metodologia Novais Digital SaaS² (referência primária do Foundry)
- `metodologia_sincra.md` — Camadas L0/L1/L2, entidades, artefatos (origem do princípio C5)

### Portfolio

[`portfolio.md`](./portfolio.md) — 3 categorias de oferta Novais Digital com ICP, pricing, lifecycle:

1. **Novais Digital Diagnóstico** — porta de entrada paga (Fase 0)
2. **Novais Digital Plataforma** — high-touch SaaS² (cliente não loga; entrega async)
3. **Novais Digital Produtos** — self-serve (cliente loga; pricing fixo)

### Constitution Extensions

[`constitution-extension.md`](./constitution-extension.md) — princípios C9, C10, C11 específicos do contexto Novais Digital:

- C9 — Lifecycle declarado por produto/SKU
- C10 — Two-track economics (Plataforma vs Produtos)
- C11 — Portfolio em 3 categorias

### ClickUp Blueprint

[`clickup-blueprint.md`](./clickup-blueprint.md) — estrutura do ClickUp interno Novais Digital com 6 Spaces e ~25 listas, aplicando Sincra L0/L1/L2.

### Produtos

[`products/`](./products/):

- `novais-fin.md` — Análise financeira inteligente (atualmente em **Beta** em produção em `https://financeiro.novais-digital.com.br`)
- `novais-educacional.md` — Em **Discovery**, sem detalhes ainda

---

## Como ler como gabarito

Outros projetos podem usar este diretório como **referência prática** de:

- Como traduzir uma metodologia em Constitution
- Como organizar portfolio multi-categoria
- Como mapear governança interna ao princípio C5 (Three-tier)
- Como declarar lifecycle de produtos
- Como o reviewer DeepAgent vê um caso real (cross-reference com [`reviewer/example-audit.md`](../../reviewer/example-audit.md))

**Não copie**, adapte. Cada domínio tem sua própria realidade.

---

## Status atual da Novais Digital (2026-04-30)

| Categoria | Status |
|---|---|
| Diagnóstico | Modelado em D7; processo definido; sem cliente atual |
| Plataforma | Em construção (`novais-digital-governanca-ia`); SKU showcase rodando; 1º cliente piloto pendente |
| Produtos — Novais Digital Fin | Beta em produção (`financeiro.novais-digital.com.br`); usuários reais |
| Produtos — Novais Digital Educacional | Discovery; conceitual em 2026 |

---

## Repositório principal

Este caso real é mantido em [`github.com/rafaelnovaes22/novais-digital-governanca-ia`](https://github.com/rafaelnovaes22/novais-digital-governanca-ia) (privado).

O Foundry é mantido em [`github.com/rafaelnovaes22/agent-governance-framework`](https://github.com/rafaelnovaes22/agent-governance-framework) (privado).

A relação entre eles: `agent-governance-framework` é a **origem canônica** do framework; `novais-digital-governanca-ia` é o **primeiro consumidor real**.
