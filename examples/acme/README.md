# Examples — Acme

> **Caso de uso real** que originou o Acme Forge. Funciona como gabarito para outros projetos que adotem o framework.

---

## Contexto

A Acme é uma consultoria de IA aplicada que pivotou para **plataforma multi-categoria SaaS²** atendendo PMEs R$ 2M+ em modo bombeiro.

Este diretório contém:
- **Metodologias** que originaram a Constitution (3 docs)
- **Portfolio** em 3 categorias formais (Diagnóstico / Plataforma / Produtos)
- **Constitution extensions** específicas Acme (C9, C10, C11)
- **ClickUp blueprint** para governança operacional interna
- **Specs de produtos** (Acme Fin em beta, Acme Educacional em discovery)

---

## Conteúdo

### Metodologias

[`methodology/`](./methodology/) — 3 documentos que precedem a Constitution:

- `metodologia.md` — Metodologia Acme clássica (4 fases por engajamento)
- `metodologia_acme.md` — Metodologia Acme SaaS² (referência primária do Forge)
- `metodologia_sincra.md` — Camadas L0/L1/L2, entidades, artefatos (origem do princípio C5)

### Portfolio

[`portfolio.md`](./portfolio.md) — 3 categorias de oferta Acme com ICP, pricing, lifecycle:

1. **Acme Diagnóstico** — porta de entrada paga (Fase 0)
2. **Acme Plataforma** — high-touch SaaS² (cliente não loga; entrega async)
3. **Acme Produtos** — self-serve (cliente loga; pricing fixo)

### Constitution Extensions

[`constitution-extension.md`](./constitution-extension.md) — princípios C9, C10, C11 específicos do contexto Acme:

- C9 — Lifecycle declarado por produto/SKU
- C10 — Two-track economics (Plataforma vs Produtos)
- C11 — Portfolio em 3 categorias

### ClickUp Blueprint

[`clickup-blueprint.md`](./clickup-blueprint.md) — estrutura do ClickUp interno Acme com 6 Spaces e ~25 listas, aplicando Sincra L0/L1/L2.

### Produtos

[`products/`](./products/):

- `acme-fin.md` — Análise financeira inteligente (atualmente em **Beta** em produção em `https://financeiro.acme.com.br`)
- `acme-educacional.md` — Em **Discovery**, sem detalhes ainda

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

## Status atual da Acme (2026-04-30)

| Categoria | Status |
|---|---|
| Diagnóstico | Modelado em D7; processo definido; sem cliente atual |
| Plataforma | Em construção (`acme-governanca-ia`); SKU showcase rodando; 1º cliente piloto pendente |
| Produtos — Acme Fin | Beta em produção (`financeiro.acme.com.br`); usuários reais |
| Produtos — Acme Educacional | Discovery; conceitual em 2026 |

---

## Repositório principal

Este caso real é mantido em [`github.com/rafaelnovaes22/acme-governanca-ia`](https://github.com/rafaelnovaes22/acme-governanca-ia) (privado).

O Forge é mantido em [`github.com/rafaelnovaes22/agent-governance-framework`](https://github.com/rafaelnovaes22/agent-governance-framework) (privado).

A relação entre eles: `agent-governance-framework` é a **origem canônica** do framework; `acme-governanca-ia` é o **primeiro consumidor real**.
