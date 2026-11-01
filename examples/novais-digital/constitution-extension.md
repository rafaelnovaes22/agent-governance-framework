# Constitution Extension — Novais Digital

> Princípios **C9, C10, C11** específicos do contexto Novais Digital.
> Extensão da Constitution genérica do Foundry ([`.claude/CONSTITUTION.md`](../../.claude/CONSTITUTION.md)).
> Outros projetos podem definir suas próprias extensões.

---

## Versão

- **Constitution base**: 0.2.0 (Foundry)
- **Extensão Novais Digital**: 0.1.0
- **Data**: 2026-04-30

Mudanças em qualquer princípio C9-C11 exigem:
1. ADR no `novais-digital-governanca-ia`
2. Bump de versão desta extensão
3. Comunicação ao reviewer DeepAgent (atualizar prompt customizado)

---

## C9 — Lifecycle declarado por produto/SKU

**Regra**: Todo produto/SKU/agente declara explicitamente seu **stage** atual no frontmatter da spec:

```yaml
status: discovery|mvp|beta|ga|maturity|sunset
```

Cada stage tem critérios objetivos para promoção.

**Por quê**:
- Sem stage explícito, "produto em beta" e "produto em GA" recebem o mesmo nível de cobrança/SLA
- Cliente que paga full não deveria estar usando MVP
- Stage define expectativa de qualidade, suporte e pricing

**Como validar**:
- Frontmatter de toda spec em `src/skus/`, `src/products/` declara `status`
- Arquivo `lifecycle.md` correspondente lista critérios para promoção ao próximo stage
- Reviewer DeepAgent audita correspondência stage declarado ↔ comportamento real

**Stages**:

| Stage | Definição |
|---|---|
| **discovery** | Hipótese; sem código de produção; sem usuários |
| **mvp** | Código rodando mas não vendível |
| **beta** | Usuários reais com pricing subsidiado e comunicação clara de "beta" |
| **ga** | Pricing pleno + SLA contratual + comunicação comercial pública |
| **maturity** | Produto estável; otimização contínua |
| **sunset** | Em descontinuação; migração de usuários |

Detalhe em [`templates/lifecycle-stage.template.md`](../../templates/lifecycle-stage.template.md).

**Exceções**: nenhuma — stage é mandatório.

---

## C10 — Two-track economics

**Regra**: Novais Digital mantém **duas estruturas de custo separadas**:

| Track | Características |
|---|---|
| **Plataforma (high-touch)** | CAC alto, ticket alto (R$ 5-15k/mês), LTV via NRR > 120% |
| **Produtos (self-serve)** | CAC baixo, ticket baixo (R$ 97-997/mês), LTV via volume |

**Não misturar** ARPU médio "Novais Digital total" — esconde realidade de cada track.

**Por quê**:
- Métricas misturadas levam a decisões erradas (otimizar conversão Plataforma quando o gargalo é onboarding Produtos)
- Investidores e CEO precisam ver track-by-track
- Decisão de alocação de tempo do time depende de saber qual track está pagando o quê

**Como validar**:
- Relatório financeiro mensal **separa** Plataforma de Produtos
- KPIs por track (ver [`portfolio.md`](./portfolio.md) §Métricas separadas)
- Reviewer audita que métricas reportadas estão segregadas

**Implicação operacional**:
- Plataforma SKUs em `src/skus/` (no `novais-digital-governanca-ia`)
- Produtos em diretórios próprios ou repos separados (`financeiro.novais-digital.com.br` em Lovable+Supabase)
- Billing systems separados ou claramente segregados em mesmo sistema

**Exceções**: cliente que comprou ambas categorias — receita atribuída individualmente, mas relatório consolida ARR total.

---

## C11 — Portfolio em 3 categorias

**Regra**: Toda oferta Novais Digital pertence a **uma das 3 categorias** formalmente definidas:

1. **Novais Digital Diagnóstico** (Categoria 1) — porta de entrada paga
2. **Novais Digital Plataforma** (Categoria 2) — high-touch SaaS² com SKUs verticais
3. **Novais Digital Produtos** (Categoria 3) — self-serve SaaS² padronizado

**Por quê**:
- Sem categoria explícita, equipe trata todo cliente igual e mistura modelos
- Princípios condicionais por categoria (ver §Aplicação condicional abaixo) só fazem sentido com categoria declarada
- Pipeline comercial precisa segregar por categoria (Lead → qual produto)

**Como validar**:
- Toda spec, ADR, ou contrato declara `category: diagnostic|platform|product`
- ClickUp blueprint (`docs/clickup-blueprint.md` no projeto consumidor) tem Spaces separados por categoria
- Reviewer audita correspondência

**Adicionar 4ª categoria**: requer ADR + bump MINOR desta extensão + atualização do `portfolio.md`.

**Categorias atuais ativas**:
- Diagnóstico: modelado, sem cliente atual
- Plataforma: em construção (Onda 0-2 fechadas)
- Produtos: Novais Digital Fin (Beta), Novais Digital Educacional (Discovery)

---

## Aplicação condicional dos princípios C1-C8 por categoria

Princípios genéricos da Constitution (C1-C8) aplicam a todas as 3 categorias, **mas com nuances**:

### C1 — Diagnose-before-design

| Categoria | Aplicação |
|---|---|
| Diagnóstico | É o cumprimento do C1 — válido por construção |
| Plataforma | Hard rule — sem Diagnóstico (Fase 0), sem contrato |
| Produtos | Relax — primeira análise/uso **é** o diagnóstico de fato; mas produto declara critérios próprios de qualificação |

### C2 — Outcome-first

| Categoria | Aplicação |
|---|---|
| Diagnóstico | Outcome = "relatório com 3 candidatos qualificados" — declarado no contrato |
| Plataforma | Cláusula custom por cliente |
| Produtos | Cláusula em **Termos de Uso** padronizados (não custom por cliente) |

### C3 — Cost ≤ 25%

| Categoria | Aplicação |
|---|---|
| Diagnóstico | N/A (não roda LLM em volume) |
| Plataforma | Por outcome — `custo_inferência / preço_outcome ≤ 25%` |
| Produtos | Por usuário ativo — `custo_inferência_mensal / ARPU_mensal ≤ 25%` |

### C4 — SHADOW antes de cobrar

| Categoria | Aplicação |
|---|---|
| Diagnóstico | N/A (não há agente em produção) |
| Plataforma | Hard rule — SHADOW → ASSISTED → AUTONOMOUS obrigatório |
| Produtos | Beta declarado funciona como SHADOW (custo subsidiado, sem SLA contratual) |

### C5 — Three-tier context (Sincra L0/L1/L2)

| Categoria | Aplicação |
|---|---|
| Diagnóstico | Aplica a templates de relatório |
| Plataforma | Hard rule — `TenantContext` é L0; helper pattern obrigatório |
| Produtos | L0 auto-extraído do uso (não onboarding humano) |

### C6 — Telemetry-by-default

| Categoria | Aplicação |
|---|---|
| Todas | Hard rule sem exceção. Em Produtos beta, instrumentação é prioridade P0 antes de promover a GA |

### C7 — Portability

| Categoria | Aplicação |
|---|---|
| Plataforma | Hard rule — abstração obrigatória |
| Produtos beta | Aceita stack divergente (ex: Novais Digital Fin = Lovable+Supabase) **se** plano de migração existir |
| Produtos GA | Camada motor portável obrigatória |

### C8 — Anti-customização

| Categoria | Aplicação |
|---|---|
| Diagnóstico | N/A |
| Plataforma | Hard rule — config no TenantContext, não branch por cliente |
| Produtos | **Mais forte** — zero customização por cliente; tudo é padronizado |

---

## Hierarquia de autoridade (extensão)

A hierarquia da Constitution genérica (C1 → C2 → C3/C4 → C5/C6 → C7/C8) é mantida.

**Adicional para Novais Digital**:
- **C11** (Portfolio) tem prioridade sobre **C9** (Lifecycle): primeiro identifica categoria, depois stage
- **C10** (Two-track) é regra contábil/relatório, não bloqueia decisões técnicas

---

## Exemplo prático

**Cenário**: time Novais Digital quer construir agente que ajude usuários do Novais Digital Fin a entender melhor a Análise gerada.

Como Constitution + extensão se aplicam:

1. **C11**: agente pertence à categoria "Produtos" (Novais Digital Fin é Produto) → aplicar regras de Produtos
2. **C1**: cliente Novais Digital Fin **já passou** pela primeira análise (= diagnóstico de fato, conforme C1 com relax para Produtos) → OK
3. **C9**: declarar stage do agente — provavelmente `mvp` ou `beta` se está em construção
4. **C2**: cláusula de outcome é parte dos Termos de Uso padronizados, não custom por cliente
5. **C3**: validar `custo_inferência_mensal / ARPU` ≤ 25%
6. **C4**: agente em beta serve como SHADOW (Novais Digital Fin já está em beta — agente novo segue mesmo regime)
7. **C5**: skill do agente é Tier 3 (operacional, lê contexto do usuário); pode ler Tier 1 (DNA do produto)
8. **C6**: instrumentar LANGSMITH antes de soltar
9. **C7**: stack pode ser Supabase Edge Function (mesmo do produto), mas com camada de abstração para LLM
10. **C8**: padronizado — nada de "para usuário X mostra Y"
11. **C10**: receita do agente atribuída a Produtos (não Plataforma)

---

## Histórico

| Versão extensão | Data | Mudança |
|---|---|---|
| 0.1.0 | 2026-04-30 | Versão inicial — C9, C10, C11 fundadores |
