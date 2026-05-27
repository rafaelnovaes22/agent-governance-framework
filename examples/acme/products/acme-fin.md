---
product_code: "acme-fin"
product_name: "Acme Fin"
category: "self-serve-product"
status: "beta"
constitution_version: "0.2.0"
constitution_extension_version: "0.1.0"
linked_diagnostic: "N/A (primeira análise mensal funciona como diagnóstico — relax C1 para Produtos)"
linked_unit_economics: "TBD — pendente instrumentação LANGSMITH"
linked_lifecycle: "products/acme-fin/lifecycle.md (a criar)"
owners:
  product_lead: "Rafael Novaes"
  tech_lead: "Rafael Novaes (solo)"
created_at: "2026-04 (data exata TBD)"
last_updated: "2026-04-30"
version: "0.1.0"
production_url: "https://financeiro.acme.com.br"
---

# Product Spec — Acme Fin

> **Aplicação prática** do [`templates/product-spec.template.md`](../../../templates/product-spec.template.md).
> Acme Fin está atualmente em **Beta** em produção em `https://financeiro.acme.com.br`.

---

## 1. Cláusula de outcome

### 1.1. Definição em uma frase

```
Acme Fin entrega análise financeira mensal estruturada (DRE + leitura
da história + plano de ação) quando o cliente importa lançamentos de
1 mês via 1 dos 4 métodos suportados (planilha colada, PDF do contador,
Excel/CSV, lançamento manual).
```

### 1.2. Outcomes principais cobráveis

| # | Outcome | Definição | Frequência típica |
|---|---|---|---|
| 1 | `analise-mensal-completa` | DRE estruturado + leitura da história (3 cards categorizados) + plano de ação 3-horizontes com R$ projetado | 1/mês/cliente |
| 2 | `gargalo-identificado` | Card individual sinalizando gargalo crítico/atenção/saudável com benchmark setorial | 2-5/mês/cliente |
| 3 | `acao-priorizada` | Ação concreta no plano com economia/receita estimada, prazo, esforço, risco | 3-9/mês/cliente |

### 1.3. Três exemplos POSITIVOS

| # | Cenário | Output esperado |
|---|---|---|
| 1 | Cliente agência de marketing importa 142 lançamentos do mês via colar planilha | DRE completo + 3 cards (gargalo crítico em ROAS, atenção em folha, saudável em MRR) + plano de ação curto prazo com R$ 11.400/mês |
| 2 | Cliente upload PDF do contador (DRE já formatado) | Sistema extrai estrutura + complementa com leitura de história + plano |
| 3 | Cliente lança 30 transações manuais ao longo do mês | Análise gerada automaticamente ao final do mês com mesmas seções |

### 1.4. Três exemplos NEGATIVOS

| # | Cenário | Por que NÃO entrega |
|---|---|---|
| 1 | Cliente importa apenas 5 lançamentos | Volume insuficiente para DRE (mínimo declarado: N) |
| 2 | Cliente faz upload de PDF de extrato bancário (sem categorização) | Não é DRE; sistema responde "envie DRE ou planilha categorizada" |
| 3 | Cliente solicita análise de período < 30 dias | Granularidade mensal é o produto; não suporta semanal/quinzenal |

### 1.5. Termos de uso (resumo)

```
Acme Fin entrega análises mensais baseadas nos lançamentos importados pelo
cliente. Limites:
- Mínimo de N lançamentos por mês para gerar análise
- Benchmarks setoriais são aproximações — não garantia de precisão setorial
- Análise é informativa, não substitui consultoria contábil/fiscal

Garantias:
- DRE estruturado conforme padrão brasileiro
- Leitura da história gerada com IA (Claude/GPT)
- Plano de ação com R$ estimado conservador

Não garante:
- Precisão de benchmarks em setores nicho
- Aconselhamento contábil/fiscal vinculante
- SLA durante fase Beta
```

---

## 2. ICP do produto

| Campo | Valor |
|---|---|
| **Persona primária** | Sócio de PME que toma decisões financeiras + controller / responsável financeiro interno |
| **Tamanho de empresa** | 5-50 funcionários, faturamento R$ 500k-10M |
| **Vertical** | Inicialmente agnóstico; benchmarks setoriais melhoram com volume |
| **Pain principal** | Não tem visibilidade financeira mensal sem pagar consultor (R$ 3-8k/mês) |
| **Como descobre o produto** | Inicialmente: indicação CEO + organic SEO; futuro: anúncio Meta/Google |

---

## 3. UX e fluxo

### 3.1. Onboarding
```
Tela 1 (login Supabase Auth)
  → Tela 2 (criar workspace)
    → Tela 3 (escolher método de import)
      → Tela 4 (importar lançamentos do mês)
        → Tela 5 (Hub de análise com primeira análise gerada)

Tempo total: < 5 min se cliente já tem planilha pronta
```

### 3.2. Telas principais

| # | Tela | Função | Ação principal |
|---|---|---|---|
| 1 | Hub de análise | Visão geral do mês de referência + histórico | Ver DRE / Ver Plano |
| 2 | DRE facilitado | Demonstrativo com leitura da história | Toggle Valores / % / vs mês ant |
| 3 | Plano de ação | 3 horizontes (curto/médio/longo) com R$ projetado | Selecionar horizonte; ver ações |
| 4 | Importar dados | 4 métodos | Upload/colar/manual |
| 5 | Lançamentos | Lista detalhada das transações importadas | Editar/categorizar |

### 3.3. Inputs do cliente

- [x] Upload de arquivo (Excel/CSV)
- [x] Colar planilha
- [x] PDF do contador (parsing IA)
- [x] Lançamento manual em formulário
- [ ] Integração via OAuth (futuro)
- [ ] Webhook / API (futuro)

---

## 4. Pipeline de agentes

### 4.1. Agentes/etapas (não-visível ao cliente)

| Etapa | Agente | Modelo | Responsabilidade | Output |
|---|---|---|---|---|
| 1 | `parser-input` | Sonnet | Parsing de planilha/PDF/CSV | Lista normalizada de lançamentos |
| 2 | `categorizer` | Sonnet | Categorização contábil | Lançamentos categorizados |
| 3 | `dre-builder` | regra | Monta DRE estruturado | Objeto DRE |
| 4 | `story-reader` | Opus | Gera 3 cards "leitura da história" com benchmarks | Cards categorizados |
| 5 | `plan-builder` | Opus | Gera plano de ação 3 horizontes com R$ | Lista de ações priorizadas |
| 6 | `qa-gate` | regra | Validação automática de coerência | passa ou retry |

### 4.2. Telemetria

⚠️ **Status atual (Beta)**: LANGSMITH **não instrumentado**. Princípio C6 violado.

**Plano**: instrumentar antes de promover Beta → GA. Issue P0 aberta no roadmap.

---

## 5. Eval suite

⚠️ **Status atual (Beta)**: eval suite **não criada**. Validação manual ad-hoc.

**Meta antes de GA**:
- ≥ 30 casos de eval cobrindo:
  - Cada estrutura de empresa (agência, indústria leve, e-commerce, serviços)
  - Cada formato de input (4 métodos)
  - Casos edge: poucos lançamentos, lançamentos descategorizados, valores extremos
- Localização: `evals/acme-fin/cases/` (no repo do produto, não no `acme-governanca-ia`)

---

## 6. Unit economics

⚠️ **Status atual**: **não medido formalmente**. Estimativa preliminar:

| Métrica | Valor estimado |
|---|---|
| Tokens médios in/out por análise mensal | ~15k input / ~5k output (estimado) |
| Custo médio por análise (Sonnet+Opus) | R$ 1,50-3,00 (estimado) |
| Custo médio mensal por usuário (1 análise/mês) | R$ 1,50-3,00 |
| Pricing planejado (ARPU) | R$ 97-297/mês (a definir) |
| **Razão custo/preço** | ~1-3% se ARPU R$ 100; **dentro de C3 ≤ 25%** ✅ |

**Confirmar com LANGSMITH instrumentado** antes de promover.

---

## 7. Lifecycle stage atual

**Status declarado**: `beta`

**Critérios atuais (Beta)**:
- [x] Código rodando em produção (`https://financeiro.acme.com.br`)
- [x] Usuários reais (quantidade real TBD pelo product lead)
- [ ] ⚠️ Pricing pleno (ainda subsidiado/gratuito?)
- [ ] ⚠️ SLA contratual (não há)
- [ ] ⚠️ Comunicação clara de "beta" na UI

**Critérios para promover Beta → GA**:
- [ ] Eval suite ≥ 30 casos passing
- [ ] Razão custo/ARPU validada com volume real (C3)
- [ ] Sem incidente P0 nos últimos 30 dias
- [ ] Termos de uso GA aprovados juridicamente
- [ ] Pricing GA definido e comunicável
- [ ] Reviewer DeepAgent emitiu auditoria sem FAIL crítico
- [ ] ≥ N usuários ativos pagantes (definir N)
- [ ] LANGSMITH instrumentado (C6)
- [ ] Camada de abstração LLM presente (C7)

Detalhe completo em `lifecycle.md` (a criar).

---

## 8. Configuração por tenant (C8)

Cliente novo do produto = **configuração**, não branch. Variáveis:

| Campo | Tipo | Default | Exemplo |
|---|---|---|---|
| `industry_segment` | enum | "geral" | "agência", "indústria", "serviços", "e-commerce" |
| `tone_of_voice` | string | "neutro-profissional" | "informal", "formal" |
| `currency` | enum | "BRL" | (futuro: USD, EUR) |
| `accounting_standard` | enum | "BR-padrão" | (futuro: IFRS, US-GAAP) |

Storage: tabela Supabase `tenant_config` com 1 linha por tenant.

---

## 9. Stack técnica

| Camada | Tecnologia | Justificativa |
|---|---|---|
| Frontend | **Lovable** (SPA Vite no-code) | Time-to-market em Beta (decisão consciente; aceitar lock-in temporário durante Beta) |
| Auth | Supabase Auth | Padrão Lovable; OAuth Google + email/senha |
| Backend / API | Supabase Edge Functions (Deno) | Padrão Lovable; reduz infra |
| DB | Supabase Postgres | Multi-tenant via RLS |
| LLM | Anthropic (Claude Sonnet 4.6 + Opus para análise complexa) | Escolha Forge default |
| LLM provider auxiliar | OpenAI (fallback opcional) | Não usado atualmente |
| Observability | ⚠️ **Não instrumentado** (issue P0 antes de GA) | Plano: LANGSMITH cloud |
| Pagamentos | TBD | Inicialmente subsidiado/gratuito; futuro: Stripe |
| Hosting | Lovable / Cloudflare CDN | Default Lovable |

> ⚠️ Princípio C7 (Portability): atualmente Lovable+Supabase é lock-in alto. Aceitável durante Beta; plano de migração para Node+Postgres tradicional precisa existir antes de GA (ADR específica). Alternativa: manter Supabase e isolar lógica LLM em Edge Functions desacopladas (já é o caso).

---

## 10. Riscos específicos

| Risco | Mitigação |
|---|---|
| Benchmarks setoriais alucinados (ex: "folha 28-32% para agências") | Eval suite com gabarito + reviewer DeepAgent valida amostra mensal |
| Custo de inferência cego (sem LANGSMITH) | Instrumentar antes de cobrar pricing pleno |
| Lock-in Lovable+Supabase | Plano de migração antes de GA OU justificativa explícita pra manter |
| Cliente entende análise como aconselhamento contábil | Termos de Uso explícitos + disclaimer na UI |
| Drift de qualidade da análise gerada por LLM ao longo dos meses | Eval suite trimestral + auditoria reviewer |
| Concorrência (Conta Azul, Omie já têm dashboards) | Diferencial é leitura de história + plano de ação com R$ — não dashboard genérico |

---

## 11. Métricas de sucesso

### Operacionais (Beta)
- Outcomes/usuário ativo/mês: ≥ 1 (1 análise/mês)
- Tempo médio até primeiro outcome (TTFO): < 5 min
- Taxa de sucesso de geração de análise: ≥ 95%

### Comerciais (após sair de Beta)
- Conversão trial → paid: ≥ 15%
- Churn mensal: ≤ 5%
- NPS: ≥ 30

### Técnicas (C3)
- Custo de inferência / ARPU: ≤ 25%
- Latência p95 da análise mensal: < 60 segundos
- Trace coverage: ≥ 99% (após instrumentação LANGSMITH)

---

## 12. Histórico de versões

| Versão | Data | Mudança | Autor |
|---|---|---|---|
| 0.1.0 | 2026-04-30 | Spec inicial documentando estado Beta atual | Claude (assistido) |

---

## 13. Próximos passos prioritários

1. **P0**: Instrumentar LANGSMITH (cumprir C6)
2. **P0**: Decidir pricing GA e timeline para sair de Beta
3. **P1**: Construir eval suite ≥ 30 casos
4. **P1**: Plano de migração / decisão de manter Lovable+Supabase (cumprir ou ajustar C7)
5. **P2**: Termos de Uso GA + revisão jurídica
6. **P2**: Implementar dashboard de unit economics em tempo real

## 14. Aprovação

- [ ] CEO leu e aprovou spec atualizada
- [ ] Tech lead validou métricas e stack
- [ ] Reviewer DeepAgent (quando implementado) auditou primeira vez

**Aprovado por**: pendente em 2026-04-30
