# Metodologia Acme — Service-as-a-Software para PMEs em modo bombeiro

## A virada conceitual: você não vende projeto, vende trabalho feito

**Service-as-a-Software (SaaS²)** inverte a lógica clássica do software empresarial. Em vez de vender uma ferramenta para o cliente operar, você vende o **resultado do trabalho** — feito por agentes de IA, cobrado por outcome entregue. O cliente não loga em nada, não treina ninguém, não gerencia processo. Ele paga por leads qualificados, tickets resolvidos, ordens processadas, propostas geradas.

Isso muda tudo na metodologia da Acme. Três implicações práticas:

1. **O modelo econômico clássico (pay-per-seat) está colapsando** — em 2026 o mercado já documentou um corte de aproximadamente **US$ 285 bilhões em valuations de SaaS tradicional** ("SaaSpocalypse"), exatamente porque clientes estão reduzindo licenças à medida que agentes de IA substituem trabalho humano. A Acme está nascendo no lado vencedor dessa transição — desde que execute o modelo certo.

2. **O risco operacional migrou do cliente para você.** Em consultoria, o cliente paga pela tentativa; em SaaS², ele paga pelo acerto. Se o agente não entrega o outcome combinado, você não fatura. Isso obriga uma metodologia obsessivamente focada em **confiabilidade mensurável**, não em entrega de escopo.

3. **O cliente PME R$2M+ em modo bombeiro é o encaixe perfeito para SaaS²**, porque ele não quer mais uma ferramenta — ele quer um problema sumir do radar. A linguagem *"demita o problema, não contrate uma ferramenta"* descreve literalmente o produto.

A referência canônica do modelo é o que Sierra, Zendesk e Salesforce já operam: Zendesk cobra **US$ 1,50 por ticket resolvido autonomamente** (definido por janela silenciosa de 72h sem reabertura); Salesforce Agentforce cobra **US$ 2 por conversa agêntica resolvida**. A Acme precisa ter sua própria unidade de outcome — escolher essa unidade é a decisão estratégica mais importante do ano.

---

## O framework Acme SaaS² — cinco fases

### Fase 0 — Diagnóstico de processo automatizável (1 semana, pago)

O diagnóstico continua sendo a porta de entrada, mas o objetivo muda: não é mais identificar *"onde IA pode ajudar"*. É identificar **qual processo repetitivo, mensurável e de alto volume pode ser convertido em outcome cobrável**.

**Critérios de qualificação de um processo para SaaS²:**

- **Repetitivo**: acontece pelo menos 50–100 vezes por mês no cliente (sem volume, não há economia de escala que pague o agente).
- **Mensurável**: existe um evento binário claro de "feito" vs. "não feito". Resposta enviada, lead qualificado, proposta gerada, classificação correta, ticket fechado sem reabertura.
- **Tolerante a erro recuperável**: se o agente errar, dá para corrigir sem dano permanente. Processos de alto risco regulatório (saúde, jurídico crítico) ficam para a v2 da empresa.
- **Atribuível**: consegue-se isolar a contribuição do agente do resto do processo. Sem isso, cobrar por outcome vira discussão eterna.

**Entregável**: relatório com 3 candidatos de processo automatizável, cada um com volume mensal estimado, definição precisa do "outcome cobrável", baseline de custo atual (quantas horas-pessoa, qual salário), e proposta de pricing por outcome.

Cobre **R$ 5–10k pelo diagnóstico**. Quem não topa, não vira cliente — e tudo bem.

---

### Fase 1 — Estruturação mínima viável (1–2 semanas)

Aqui está a diferença mais delicada do contexto PME R$2M+. Em SaaS² puro de Vale do Silício, assume-se que o cliente já tem processo digitalizado. Na realidade brasileira do seu ICP, **o processo não existe estruturado em lugar nenhum** — está na cabeça do CEO, em prints de WhatsApp, em planilhas dispersas.

Você não pode pular essa fase, mas precisa minimizá-la radicalmente:

- **Mapeamento de processo em formato "agent-ready"**: input claro (de onde vem o gatilho), regras de decisão explícitas (mesmo que toscas), output esperado (formato, destino, prazo).
- **Conexão das fontes de dados via integração leve**: WhatsApp Cloud API, Gmail/Outlook, planilha do Drive, ERP via Webhook ou n8n. Sem isso o agente não tem matéria-prima.
- **Definição operacional do outcome**: quando exatamente o ticket é considerado "resolvido"? Quando o lead é considerado "qualificado"? Essa definição é o **contrato comercial** — escreva com a precisão de uma cláusula jurídica.

Essa fase é faturada como **setup fee (R$ 8–25k dependendo da complexidade)**, não como projeto. É o que cobre o CAC operacional sem inflar o preço da recorrência.

---

### Fase 2 — Construção do agente com humano-no-loop (2–4 semanas)

Aqui entra a engenharia. Princípios não-negociáveis para SaaS²:

**Arquitetura agentic com observabilidade total.** Cada decisão do agente registrada com input, raciocínio, ação, resultado. Sem isso, você não consegue (a) cobrar por outcome com confiança, (b) auditar quando o cliente questionar, (c) melhorar o agente ao longo do tempo. Stack típica: orquestração via LangGraph ou similar, vetor store para memória de contexto, tracing via Langfuse ou equivalente, persistência em PostgreSQL.

**Eval suite antes de produção.** Conjunto de 30–100 casos reais do cliente onde se conhece a resposta certa. Acurácia mínima por categoria de outcome antes de cobrar do cliente. Define-se previamente o threshold (ex: 85% de acerto em qualificação de leads) abaixo do qual o agente continua em modo sombra.

**Modo sombra → modo assistido → modo autônomo.** Calibração de confiança em três etapas:

1. **Sombra (semanas 1–2 em produção)**: agente roda, mas humano executa. Compara-se output do agente com decisão humana. Mede-se taxa de concordância.
2. **Assistido (semanas 3–6)**: agente executa, humano aprova antes de disparar. Mede-se taxa de aprovação sem edição.
3. **Autônomo (semana 7+)**: agente executa diretamente, humano audita amostra. Mede-se taxa de erro pós-execução.

**Cobrança por outcome só começa no modo autônomo.** Antes disso, você cobra setup + mensalidade fixa de operação. Tentar cobrar por outcome em modo sombra é receita garantida de atrito comercial.

---

### Fase 3 — Operação em produção e billing por outcome (recorrente)

Esta é a fase em que SaaS² é radicalmente diferente de consultoria ou SaaS tradicional. Componentes essenciais:

**Modelo de pricing híbrido — não puro outcome.** Outcome puro é arriscado para PME por dois motivos: variabilidade de fatura assusta e custo variável de LLM (Claude/GPT por token) pode comprimir margem em meses ruins. O modelo recomendado:

- **Plataforma fixa mensal (R$ 1,5–4k)**: cobre infraestrutura, observabilidade, manutenção do agente, suporte. Garante previsibilidade para o cliente e cobertura de custo fixo para você.
- **Outcome variável**: R$ X por unidade de outcome entregue (lead qualificado, ticket resolvido, proposta gerada). Definir o preço unitário pegando o custo atual do cliente (ex: lead qualificado custa R$ 80 hoje via SDR) e oferecendo desconto significativo (R$ 25–40), criando ROI óbvio mas margem saudável.
- **Teto mensal opcional (cap)**: limita o variável a um máximo, dá segurança ao CEO bombeiro de que a fatura não explode.
- **Cláusula de SLA**: se acurácia cair abaixo do threshold combinado (ex: 80%), o cliente não paga o variável daquele mês. Isso alinha incentivos e gera confiança.

**Dashboard de outcome para o cliente.** Não é luxo — é parte do produto. Página web simples mostrando em tempo real: quantos outcomes entregues no mês, quanto o cliente economizou vs. baseline pré-agente, ROI acumulado. CEO bombeiro precisa ver o valor sem entrar em sistema.

**Auditoria automática mensal de qualidade.** Amostra aleatória de 5–10% dos outcomes do mês revisada (humano + LLM como segundo revisor). Resultado vira o relatório executivo mensal. Detecta drift do modelo antes que vire problema comercial.

---

### Fase 4 — Empacotamento e replicabilidade (transversal, contínuo)

Esta fase não é por cliente — é **por categoria de processo**. É o que separa Acme-consultoria-disfarçada de Acme-SaaS²-real. A pergunta certa não é *"como atendo o próximo cliente?"*, é *"qual o terceiro cliente do mesmo processo que custa 10% do esforço do primeiro?"*.

**Movimentos centrais:**

- **Catálogo de agentes empacotados.** Cada processo automatizado com sucesso vira um SKU: *"Agente de Triagem Comercial WhatsApp"*, *"Agente de Resposta a Cotação"*, *"Agente de Follow-up de Inadimplência"*. Cada SKU tem template de prompt, fluxo de orquestração, integrações pré-construídas, eval suite base.
- **Customização por configuração, não por código.** Cliente novo do mesmo SKU = ajuste de variáveis (tom de voz, regras de negócio específicas, integrações), não desenvolvimento do zero.
- **Vertical primeiro, horizontal depois.** Concentre os primeiros 10 clientes em um setor (sugestão pelo seu portfólio: serviços profissionais ou indústria leve, onde o gargalo comercial/operacional é universal). Domínio vertical permite reuso > 70% e venda baseada em case (*"já automatizamos isso em 8 escritórios de contabilidade"*).

---

## A unidade fundamental: definir o "outcome cobrável" da Acme

A decisão mais estratégica do próximo trimestre. Padrões observados no mercado SaaS² em 2026:

| Tipo de outcome                  | Exemplo                                              | Pricing referência                |
|----------------------------------|------------------------------------------------------|-----------------------------------|
| Resolução de interação           | Ticket fechado sem reabertura em 72h                 | US$ 1,50 (Zendesk) / R$ 4–8       |
| Lead qualificado                 | Lead com BANT validado entregue ao SDR humano        | US$ 5–25 / R$ 25–50               |
| Conversa agêntica concluída      | Atendimento finalizado autonomamente                 | US$ 2 (Salesforce) / R$ 5–10      |
| Documento processado             | Proposta gerada, contrato classificado, NF conferida | R$ 2–15 conforme complexidade     |
| Tarefa de back-office completada | Conciliação executada, relatório gerado              | R$ 10–50                          |

Para o ICP da Acme (operação caótica em PME R$2M+), os mais promissores são: **leads qualificados, tickets/conversas resolvidos, e tarefas de back-office completadas**. São processos com volume suficiente, baseline de custo claro (CEO sabe quanto paga em SDR ou atendente), e outcome inequívoco.

---

## O que muda no posicionamento e venda

A linguagem da venda precisa refletir o modelo:

- ❌ **Não vender**: *"implantação de IA na sua empresa"*, *"consultoria de inteligência artificial"*, *"automação de processos"*.
- ✅ **Vender**: *"demita os 3 problemas que mais consomem sua semana — pague só pelo que ficar resolvido"*.
- **Métrica do cliente**: horas/semana liberadas do CEO, R$ economizados ou gerados pelos outcomes do mês, % de redução em retrabalho.
- **Estrutura comercial**: setup fee curto (paga o onboarding) + mensalidade fixa baixa (paga a plataforma) + variável por outcome (onde está a margem). Isso é o que faz a Acme escalar **como produto**, e não como agência.

**A oferta inicial que faz mais sentido para sair de 1–3 clientes para 10:**

> *"Agente de [processo X] entregue como serviço. Setup em 4 semanas, primeiro mês grátis em modo sombra para você comparar com seu time atual. Depois, R$ Y de plataforma + R$ Z por outcome entregue, com teto mensal e SLA de qualidade. Se o agente não bater o resultado combinado, você não paga o variável."*

Essa estrutura vende sozinha para CEO bombeiro porque:

- **Risco percebido tende a zero** (mês grátis em sombra + SLA + teto).
- **ROI é matemática trivial** (compara R$ Z por outcome com custo atual).
- **Não exige aprendizado, mudança de equipe ou processo novo** do lado do cliente.

---

## Stack de execução recomendada (concreto)

Considerando o portfólio técnico existente (Node/TS, LangGraph, PostgreSQL, BullMQ, WhatsApp Cloud API — basicamente o stack do CarInsight), a infraestrutura SaaS² da Acme pode reaproveitar massivamente:

| Camada                  | Tecnologia                                                              |
|-------------------------|-------------------------------------------------------------------------|
| Orquestração            | LangGraph                                                               |
| Modelos                 | Claude (raciocínio crítico), GPT-4-mini ou DeepSeek (volume), open-source via Together/Groq (dados sensíveis) |
| Observabilidade         | Langfuse — essencial para SaaS² (sem trace, sem outcome auditável)      |
| Filas e persistência    | BullMQ + PostgreSQL                                                     |
| Integrações             | n8n self-hosted como camada de glue para sistemas legados               |
| Billing por outcome     | Custom em PostgreSQL nos primeiros 10 clientes; depois Stripe usage-based ou Orb |
| Dashboard cliente       | Next.js + Recharts                                                      |

A infraestrutura técnica **não é o desafio** — esse stack já é construído internamente. O desafio é a **disciplina de produto**: resistir à tentação de fazer customização heroica por cliente e forçar o caminho da catalogação.

---

## Riscos específicos de SaaS² para o estágio atual da Acme

Com 1–3 clientes, as armadilhas que matam empresas SaaS² nascentes:

**Risco 1 — Definição vaga de outcome.** Cliente acha que *"ticket resolvido"* é uma coisa, você acha que é outra. Sempre escreva a definição operacional como cláusula contratual com exemplos positivos e negativos.

**Risco 2 — Margem comprimida por custo de LLM.** Cobre R$ 5 por outcome que custa R$ 4,80 em token quando o cliente faz volume. Modele unit economics por SKU antes de assinar contrato. Regra prática: **custo de inferência ≤ 25% do preço do outcome**.

**Risco 3 — Customização fora de controle.** Cada pedido de *"só essa pequena adaptação"* do cliente vira código que não escala. Política firme: customizações entram como **configuração do SKU** ou **viram um novo SKU**, nunca como branch específico daquele cliente.

**Risco 4 — Falta de moat.** Em SaaS² o moat real é (a) **dados proprietários do flywheel** — quanto mais o agente roda no setor X, melhor ele fica para o próximo cliente do setor X — e (b) **integrações verticais profundas** (ERPs setoriais, sistemas de nicho). Comece a acumular esses dois ativos desde o cliente 1.

**Risco 5 — Dependência de um único cliente grande.** Em estágio 1–3, é tentador aceitar um cliente que paga 60% do faturamento. SaaS² com concentração alta vira refém. Defina logo um pipeline para chegar a 10 clientes pequenos do mesmo SKU em vez de 1 grande personalizado.

---

## Próximos 90 dias — prioridades táticas

Dado o estágio de 1–3 clientes:

**Mês 1.** Documentar o processo automatizado em cada cliente atual. Identificar qual deles pode virar o primeiro SKU empacotado da Acme. Definir a unidade de outcome cobrável e fazer o exercício de unit economics por SKU.

**Mês 2.** Construir a versão "configurável" do SKU escolhido — separar o que é template do que é configuração de cliente. Implementar dashboard de outcome e billing automatizado para esse SKU. Começar a vender o SKU como oferta empacotada (não como projeto).

**Mês 3.** Migrar pelo menos 1 dos clientes atuais para o modelo SaaS² puro (plataforma + outcome). Documentar o caso com números reais. Lançar a oferta empacotada para captar 3–5 leads do mesmo SKU. Ajustar com base no que o mercado responder.

A meta dos 90 dias **não é faturamento**. É ter:

1. **1 SKU empacotado**
2. **1 caso documentado**
3. **Processo de venda repetível**

Faturamento vem depois — mas só vem se essa base existir.

---

## Resumo em uma frase

> A Acme é uma empresa de **agentes de IA empacotados como SKUs verticais** para processos repetitivos de PMEs caóticas, **cobrando por outcome entregue** com plataforma fixa, **vendendo paz para CEOs bombeiros**, e escalando por catálogo — não por hora consultiva.
