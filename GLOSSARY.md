# Glossary — Acme Forge

> Vocabulário compartilhado entre humanos, devs e agentes autônomos. Em ordem alfabética.

---

## A

### ADR (Architecture Decision Record)
Documento que registra **decisões arquiteturais** com contexto, alternativas consideradas, decisão tomada e consequências. ADRs são **imutáveis após assinatura** — mudanças exigem nova ADR. Template em [`templates/adr.template.md`](./templates/adr.template.md).

### Agent (do Forge)
Instância operacional que executa tarefas. Pode ser:
- **Subagent Claude Code** (`.claude/agents/*.md`) — papel especialista invocado pelo Claude
- **Agent de domínio** (no projeto consumidor) — orquestração LLM real (LangGraph, custom, etc.) que entrega outcome cobrável

### AUTONOMOUS
Modo de operação onde agente executa diretamente, humano audita amostra pós-execução. Billing variável ativo. Promoção exige passar por SHADOW e ASSISTED primeiro (princípio C4).

### ASSISTED
Modo intermediário onde agente propõe e humano aprova antes de executar/entregar. Sem billing variável. Mede taxa de aprovação sem edição.

### Audit / Auditoria mensal
Validação independente do projeto contra Constitution, executada pelo reviewer DeepAgent. Output: relatório markdown + JSON em `docs/forge/audits/YYYY-MM-DD.md`. Cadência padrão: último dia útil do mês.

---

## B

### Baseline (custo humano)
Custo por outcome no método humano atual do cliente. Usado para validar pricing por outcome (princípio C3) e mostrar economia no dashboard cliente.

### Beta (lifecycle stage)
Stage de produto que opera com **usuários reais** mas com pricing subsidiado/gratuito, sem SLA contratual, e comunicação clara de "estamos em beta". Antes de GA.

### Block
Unidade reutilizável de processamento (no contexto Acme, em `src/core/blocks/`). Composto em Agents via `AgentBlockComposition`. Permite reuso entre tenants do mesmo padrão.

### Bypass
Override emergencial de hooks/checks via `ACME_FORGE_BYPASS=incident`. Toda invocação fica registrada em `docs/forge/bypass-log/` e é citada pelo reviewer no próximo relatório.

---

## C

### C1–C8
Os 8 princípios da Constitution v0.2.0:
- C1 Diagnose-before-design
- C2 Outcome-first, never tech-first
- C3 Cost ≤ 25% of price
- C4 SHADOW antes de cobrar
- C5 Three-tier context
- C6 Telemetry-by-default
- C7 Portability over lock-in
- C8 Anti-customização heroica

### Cláusula de outcome
Seção da spec que define **contratualmente** o que conta como "outcome entregue". Inclui definição em 1 frase + 3 exemplos positivos + 3 exemplos negativos + janela temporal de estabilidade + evento técnico que dispara `DELIVERED`.

### Constitution
Arquivo `.claude/CONSTITUTION.md` com 8 princípios versionados. Fonte canônica de regras do framework. Mudanças exigem ADR + bump SemVer.

### Cost ratio (custo/preço)
Razão `custo_inferência_por_outcome / preço_por_outcome`. Princípio C3 exige ≤ 25%. Em produtos com pricing fixo, traduz-se para `custo_mensal_por_usuário / ARPU_mensal`.

---

## D

### Acme Diagnóstico
Categoria 1 do portfolio Acme: porta de entrada paga (Fase 0, 5 dias úteis). Cliente paga R$ 5–10k para receber relatório com 3 candidatos a SKU automatizável. Não escala via produto.

### Acme Plataforma
Categoria 2 do portfolio Acme: SaaS² high-touch com SKUs verticais. Cliente não loga (entrega async via WhatsApp/email/webhook). Setup R$ 8–25k + plataforma R$ 1,5–4k/mês + variável por outcome.

### Acme Produtos
Categoria 3 do portfolio Acme: produtos self-serve. Cliente loga em UI dedicada. Pricing mensalidade fixa. Atualmente: Acme Fin (beta), Acme Educacional (discovery).

### DeepAgent
Reviewer externo independente que audita projetos Forge mensalmente. Implementação default: GPT-5.5 via OpenAI SDK (Python `deepagents` ou Node/TS `@langchain/langgraph`).

### Diagnostic
Modelo de DB e processo da Fase 0. Cobrável (R$ 5–10k). Output: 3 candidatos qualificados + baseline + proposta de pricing.

### Discovery (lifecycle stage)
Primeiro stage de produto: hipótese, sem código de produção, sem usuários. Foco em validar problema vale a pena resolver.

### Drift
Degradação ao longo do tempo. Tipos:
- **Drift de qualidade**: acurácia cai ≥ 5pp mês-a-mês
- **Drift de custo**: custo médio outcome sobe ≥ 15% mês-a-mês
- **Drift de volume**: volume oscila ≥ 30% mês-a-mês
Reviewer detecta automaticamente e abre issue.

### DRE (Demonstrativo de Resultados do Exercício)
Relatório financeiro que decompõe receita em custos, despesas e resultado. Output principal do Acme Fin.

---

## E

### Eval Suite
Conjunto de 30+ casos de teste com gabarito conhecido para cada SKU/produto. Roda em `npm run eval:{sku}`. Threshold mínimo definido em pré-contrato (princípio C4). Templates em [`templates/eval-case.template.md`](./templates/eval-case.template.md).

---

## F

### Fase 0
Diagnóstico cobrável de 5 dias úteis que precede oferta de Plataforma ou Produto. Princípio C1.

### Forge
Curto para "Acme Forge". O framework em si.

### Forge-0 a Forge-5
Ondas de implementação do framework:
- Forge-0: Fundação (concluída)
- Forge-1: Skills L0/L1/L2
- Forge-2: Slash commands
- Forge-3: Subagents Guardian + reviewer
- Forge-4: Hooks runtime
- Forge-5: Playbooks verticais (pós primeiro caso real)

### Frontmatter
Bloco YAML no início de arquivos `.md` com metadata estruturada (versão, owner, status, etc.). Lido por scripts e pelo reviewer.

---

## G

### GA (General Availability)
Stage de produto vendável com pricing pleno, SLA contratual, comunicação comercial pública. Sucessor do Beta.

### Gate
Decisão (humana ou automática) entre nós do pipeline. Gates de promoção (SHADOW→ASSISTED→AUTONOMOUS) requerem critérios objetivos.

### Guardian
Subagent Claude Code com papel específico de validação/garantia. Ex: PO Guardian (valida outcome contratual), Unit Economist (valida C3), Security Guardian (valida C7/C8).

---

## H

### Helper pattern
Técnica de redução de tokens (origem: BMAD): contexto Tier 1 (DNA, ICP, ofertas) é referenciado como `{{l0.dna}}` em prompts em vez de duplicado, com `cache_control: ephemeral` no Anthropic. Reduz tokens em 70-85%.

### Hooks
Scripts disparados pelo Claude Code em eventos específicos (PreToolUse, PostToolUse, PreCommit, Stop). Configurados em `.claude/settings.json`. Forge-4 entrega hooks runtime.

---

## I

### ICP (Ideal Customer Profile)
Perfil do cliente ideal. Cada categoria do portfolio Acme pode ter ICP distinto.

### Idempotente
Operação que produz o mesmo resultado quando executada múltiplas vezes com os mesmos inputs. Aplicado a: scripts de bootstrap, seeds, e ao próprio reviewer.

---

## K

### KnowledgeAsset
Modelo de DB que representa substrato cognitivo do tenant. 4 tipos: BUSINESS_PROCESS, ONTOLOGY, BUSINESS_RULE, REFERENCE_DATA. Versionado.

### Knowledge Layer
Camada do projeto consumidor que carrega e cacheia KnowledgeAssets para uso em prompts (Tier 1).

---

## L

### L0 / L1 / L2 (Sincra)
Vocabulário Sincra para Three-tier context (princípio C5):
- L0 = Tier 1 = Estratégico (DNA/ICP/ofertas)
- L1 = Tier 2 = Tático (cliente/projeto/baseline)
- L2 = Tier 3 = Operacional (outcome/run/eval)

### Langfuse
Provedor de observability LLM (open-source, self-hostable). Default do Forge para princípio C6, mas substituível por Helicone, Phoenix, ou custom.

### LangGraph
Framework de orquestração de agentes (LangChain). Default do Forge para pipelines de agentes — substituível por state machine custom, CrewAI, AutoGen.

### Lifecycle
Conjunto de stages de um produto: Discovery → MVP → Beta → GA → Maturity → Sunset. Detalhado em [`templates/lifecycle-stage.template.md`](./templates/lifecycle-stage.template.md).

### Lock-in
Acoplamento difícil de reverter (modelo, provedor, stack). Princípio C7 minimiza lock-in via camada de abstração.

---

## M

### Manifest
Arquivo `docs/forge/manifest.json` com inventário machine-readable de todos os artefatos do framework no projeto consumidor. Lido pelo reviewer.

### Maturity (lifecycle stage)
Stage estável de produto, sem mudanças disruptivas. Foco em otimização e retenção.

### MVP (Minimum Viable Product)
Stage entre Discovery e Beta: código rodando mas não vendível.

---

## O

### Onda
Bloco discreto de trabalho. Dois usos:
- **Onda Forge** (Forge-0, Forge-1, ...): bloco de implementação do framework
- **Onda Acme** (Onda 0, Onda 1, ...): bloco de implementação do projeto consumidor `acme-governanca-ia`
- **Wave**: engagement comercial discreto sobre Subscription (Acme Plataforma)

### Outcome
Unidade de entrega cobrável. Ex: lead-qualificado, ticket-resolvido, análise-financeira. Definido em §1 da spec.

### OutcomeFlywheelData
Modelo de DB que captura par (decisão humana, decisão agente) para alimentar **moat de dados** — quanto mais o agente roda no setor X, melhor ele fica para próximo cliente do mesmo setor.

---

## P

### Pipeline
Sequência de nodes (agentes/etapas) que processa input → outcome. Implementado em `src/core/pipeline/runner.ts` ou equivalente.

### Plataforma
Curto para Acme Plataforma (Categoria 2 do portfolio).

### Portfolio (Acme)
Conjunto das 3 categorias de oferta Acme: Diagnóstico, Plataforma, Produtos.

### Princípio (do Forge)
Regra fundadora da Constitution. Versionada. Mudança exige ADR.

### Promoção (de modo)
Transição entre modos de operação: SHADOW → ASSISTED → AUTONOMOUS. Exige gates passing.

### Produto (Acme)
Curto para Acme Produtos (Categoria 3 do portfolio).

---

## Q

### Quality Gate
Critério verificável de promoção entre stages ou modos. Detalhado em [`templates/lifecycle-stage.template.md`](./templates/lifecycle-stage.template.md).

---

## R

### Reviewer
Agente externo (DeepAgent / GPT-5.5) que audita projetos Forge mensalmente. Detalhe em [`reviewer/`](./reviewer/) e [`DEEPAGENT_GUIDE.md`](./DEEPAGENT_GUIDE.md).

### Rota A / B / C (Acme)
Modelos comerciais hipotéticos analisados pelo CEO Acme:
- Rota A: high-ticket B2B puro
- Rota B: low-ticket cauda longa
- Rota C: híbrido (low-ticket como entrada, high-ticket como upsell)

CEO inclinou para C/A em áudio 2026-04-29. Aprovação formal pendente.

---

## S

### SaaS² (Service-as-a-Software)
Modelo onde se vende **outcome entregue** (lead, ticket, análise) em vez de licença de software. Cliente paga por resultado, não por seat. Origina o nome "Acme SaaS²".

### SHADOW
Modo de operação inicial: agente roda mas output não é entregue/cobrado. Humano executa em paralelo. Mede concordância. Princípio C4.

### Sincra
Metodologia task-first com camadas L0/L1/L2 (origem: Affluence/Pedro Valério). Inspira princípio C5 (Three-tier context).

### SKU
Unidade vendável do catálogo. Em Acme Plataforma, cada SKU é vertical/processo específico (ex: triagem-comercial-whatsapp).

### SLA (Service Level Agreement)
Threshold de qualidade contratual (ex: 85% de acurácia agregada). Breach mensal: cliente não paga variável daquele mês.

### Spec
Documento que descreve um agente/produto/SKU. Templates em `templates/`.

### Subscription
Modelo de DB representando assinatura de um Tenant a um SKU. Tem campos: `mode` (SHADOW/ASSISTED/AUTONOMOUS), `confidenceThreshold`, `slaThreshold`, pricing.

### Subagent
No Claude Code: agente especialista invocado dentro de uma sessão. Tem contexto isolado e tools restritos.

### Sunset (lifecycle stage)
Stage de descontinuação. Migração de usuários, encerramento de contratos, remoção de código legado.

---

## T

### Telemetria
Observação de chamadas LLM em runtime: input, output, custo, latência. Princípio C6. Provedor default: Langfuse.

### TenantContext
Modelo de DB representando Tier 1 (L0) da Sincra para um tenant: companyDna, icp, ofertas, glossario, toneOfVoice. Cacheado via helper pattern.

### Three-tier context
Hierarquia de contexto em 3 níveis (Estratégico/Tático/Operacional). Princípio C5.

### Tier 1 / 2 / 3
Vocabulário do Forge para Three-tier (equivalente a L0/L1/L2 da Sincra). Ver C5 da Constitution.

### Trace
Registro de uma execução LLM em provedor de telemetria (Langfuse). Inclui input, output, custo, latência, metadata.

### Two-track economics
Princípio (extensão Acme, C10) que separa estrutura de custo da Plataforma (CAC alto, ticket alto) da estrutura de Produtos (CAC baixo, ticket baixo, escala por volume).

---

## U

### Unit economics
Análise de custo unitário vs preço unitário. Documento canônico em `unit-economics.md` por SKU/produto. Princípio C3 exige razão custo/preço ≤ 25%.

---

## W

### Wave (Acme Plataforma)
Engagement comercial discreto dentro de uma Subscription. Cada Wave entrega 1+ agente com pricing R$ 8–25k. Subscription Essential = 1 Wave; Subscription Full = N Waves.

---

## Sigla rápida

| Sigla | Significado |
|---|---|
| C1–C8 | Princípios da Constitution |
| C9–C11 | Extensões Acme da Constitution |
| F1–F12 | Decisões fundadoras do Forge |
| L0/L1/L2 | Camadas Sincra (= Tier 1/2/3) |
| GA | General Availability |
| MVP | Minimum Viable Product |
| ARPU | Average Revenue Per User |
| ICP | Ideal Customer Profile |
| LTV | Lifetime Value |
| NRR | Net Revenue Retention |
| ADR | Architecture Decision Record |
| SLA | Service Level Agreement |
| TTFO | Time To First Outcome |
