# Metodologia Novais Digital — IA aplicada para empresas R$2M+ em modo bombeiro

## O contexto define tudo

A Novais Digital não é uma startup de produto SaaS. É uma consultoria de IA aplicada com modelo de entrega por projeto, atendendo um perfil de cliente muito específico: empresas que já passaram do estágio inicial (faturamento R$2M+ comprova mercado), mas estão presas em um teto operacional porque o CEO virou bombeiro — apaga incêndio o dia inteiro, não tem processo estruturado, não tem visibilidade do próprio negócio.

Esse cliente tem três características que mudam radicalmente a metodologia:

1. **Não sabe o que pedir.** Ele sente a dor (caos, retrabalho, dependência dele para tudo) mas não consegue traduzir em requisitos. Se você perguntar "que solução de IA você quer?", a resposta vai estar errada.
2. **Não tem dados organizados.** Pular direto para "vamos treinar um modelo" é fantasia. A matéria-prima da IA — dados estruturados, processos mapeados — não existe.
3. **Tempo do CEO é o recurso mais escasso.** Qualquer metodologia que exija 8 horas por semana dele vai falhar. O design precisa respeitar isso.

A consequência é que a metodologia da Novais Digital não é "aplicar IA". É **diagnosticar → estruturar → automatizar → escalar**, nessa ordem. IA entra na fase 3, não na fase 1.

---

## O framework Novais Digital: quatro fases por engajamento

### Fase 0 — Qualificação e diagnóstico (1–2 semanas, pré-contrato)

O erro clássico de consultoria de IA é vender antes de diagnosticar. Com CEO bombeiro isso é fatal: ele compra qualquer promessa de "automatizar tudo com IA", você entrega, ele não usa, e o projeto vira fracasso em 90 dias.

**Práticas centrais:**

- **Sessão de diagnóstico estruturada de 90 minutos com o CEO.** Roteiro fixo cobrindo: onde ele gasta tempo na semana, quais decisões só ele toma, quais erros se repetem, onde está o gargalo de receita. Saída é um mapa de calor de dor.
- **Entrevistas de 30 min com 2–3 pessoas-chave** (operações, comercial, financeiro). Quase sempre o que o CEO acha que é o problema não é o problema real — a equipe sabe melhor.
- **Auditoria express de dados e ferramentas:** que sistemas a empresa usa, onde os dados moram, qual o nível de organização (planilhas soltas vs. ERP, WhatsApp como CRM vs. sistema, etc.).
- **Entregável:** relatório de diagnóstico de 5–10 páginas com top 3 oportunidades priorizadas por (impacto × facilidade de execução), cada uma com escopo, prazo e investimento estimado.

Esse diagnóstico pode ser pago (R$ 5–15k) ou gratuito como gancho comercial — em qualquer caso ele filtra cliente errado e ancora o valor do projeto seguinte. **Cliente que não topa fazer o diagnóstico não é cliente.**

### Fase 1 — Estruturação antes da IA (2–4 semanas)

Aqui é onde a maioria das consultorias de IA quebra: tenta automatizar processo que não existe. Não dá pra automatizar caos — automação de caos é caos automatizado, mais rápido.

**Sequência:**

- **Mapear o processo "as-is"** do gargalo escolhido — fluxograma simples, sem floreio acadêmico. Use Mermaid ou desenho à mão. Objetivo: deixar visível o que hoje só está na cabeça do CEO.
- **Identificar os 3–5 pontos de decisão** dentro do processo. Quem decide? Com que critério? Quanto tempo demora? O que acontece se atrasa?
- **Redesenhar o "to-be"** — ainda sem IA. Versão melhor do processo, com responsáveis claros, SLA, sistema único de registro. Muitas vezes 60% do ganho vem só dessa estruturação.
- **Implantar o "to-be" mínimo viável** com a equipe atual e ferramentas existentes (ou com complementos baratos: ClickUp, Notion, Pipefy, automação no n8n).

Só depois disso se identifica onde a IA agrega valor real — tipicamente em três pontos: **classificação/triagem, geração de conteúdo/respostas, ou predição/recomendação**. Se a IA não cabe em nenhum desses três, talvez o projeto seja de automação tradicional, não de IA — e isso está OK desde que você cobre por resultado, não por tecnologia.

### Fase 2 — Implementação da camada de IA (4–8 semanas)

Aqui sim entram as quatro camadas metodológicas clássicas (Design Thinking → Lean → CRISP-DM/CRISP-ML(Q) → MLOps), mas em escala de projeto, não de produto.

**Princípios de execução:**

- **Build vs. buy radical em 2026.** Para 80% dos casos em PME R$2M+, a resposta é orquestrar APIs prontas (Claude/GPT + Pinecone/Qdrant + n8n/Make + WhatsApp Cloud API) em vez de treinar modelo do zero. Isso comprime entrega de meses para semanas.
- **Humano-no-loop calibrado.** CEO bombeiro não confia em IA no início — e está certo. Desenhe o sistema com IA sugerindo e humano aprovando nas primeiras 4–8 semanas, depois afrouxe gradualmente conforme telemetria comprova qualidade. Tentar autonomia total no dia 1 derruba o projeto.
- **Telemetria desde o dia 1.** Toda interação da IA registrada com input, output, decisão humana posterior, resultado. Esse é o dataset que vira o moat do cliente e o caso de venda do próximo cliente.
- **Eval suite específica do cliente.** Antes de ir para produção, conjunto de 20–50 casos reais do cliente onde se sabe a resposta certa. Roda automatizado a cada mudança de prompt/modelo. Sem isso, qualquer ajuste vira roleta.

### Fase 3 — Operação assistida e transferência (4–12 semanas)

Diferente de SaaS puro, a consultoria precisa sair ou virar dependência cara. Mas em PME R$2M+ a equipe interna raramente consegue operar sozinha. A solução é a fase de operação assistida com saída programada:

- **Mês 1:** Novais Digital opera 100%, equipe do cliente observa e recebe treinamento.
- **Mês 2:** equipe opera com Novais Digital em standby (1–2h/semana de revisão).
- **Mês 3:** equipe opera, Novais Digital entra apenas em incidentes ou ajustes.
- **Mês 4+:** contrato de manutenção mensal opcional (R$ 2–5k/mês) cobrindo monitoramento, ajustes de prompt, relatório executivo mensal para o CEO.

Esse desenho resolve dois problemas: o cliente não fica refém, e a Novais Digital tem uma camada de receita recorrente em cima do projeto inicial — exatamente o que falta na consultoria pura para virar negócio escalável.

---

## O paradoxo central: vender simplicidade, entregar simplicidade

CEOs bombeiros não compram IA. Compram paz. A linguagem de venda e a linguagem de entrega precisam refletir isso:

- Não vender "agente autônomo com LangGraph e RAG vetorial". Vender "você vai parar de ser o gargalo do follow-up comercial".
- Não medir sucesso por "acurácia do modelo". Medir por "horas/semana liberadas do CEO" e "% de tarefas que não precisam mais passar por ele".
- O relatório executivo mensal é parte do produto, não overhead. CEO bombeiro precisa ver o que melhorou, em uma página, sem jargão.

---

## Estágio atual da Novais Digital (1–3 clientes) — prioridades táticas

Com 1–3 clientes, o objetivo dos próximos 90 dias **não é vender mais**. É:

1. **Padronizar o diagnóstico da Fase 0.** Roteiro de entrevista, template de relatório, calculadora de impacto. Isso vira ativo reutilizável e diminui custo de venda nos próximos clientes.
2. **Documentar 1–2 cases com números.** Antes/depois do CEO em horas, R$ economizados ou gerados, retrabalho eliminado. Sem case com número, venda B2B em PME trava no preço.
3. **Definir nicho vertical.** "Empresas R$2M+ desorganizadas" é segmento, não nicho. Escolher um setor (ex: indústria leve, serviços profissionais, e-commerce) reduz custo de aquisição e permite criar playbook setorial reutilizável — esse playbook é o que separa consultoria boutique de consultoria escalável.
4. **Construir biblioteca de blocos reutilizáveis.** Templates de prompt, fluxos n8n/Make, integrações WhatsApp/email, dashboards. A partir do cliente 5, 60–70% de cada projeto deveria ser remontagem de blocos existentes — é assim que margem de consultoria sai de 30% para 60%+.

---

## O que não fazer

Padrões que matam consultoria de IA para PME, observados consistentemente:

- **Cobrar por hora.** Cliente PME não compra hora, compra resultado. Cobre por projeto fechado com escopo definido, ou por outcome (% da economia gerada nos primeiros 12 meses).
- **Prometer "transformação digital completa".** Escopo grande = projeto que nunca termina. Vender entregas de 30/60/90 dias com valor mensurável em cada marco.
- **Dependência total de um único modelo/API.** Cliente em produção não pode parar porque OpenAI mudou preço. Arquitetura abstrai o modelo — Claude para raciocínio, GPT para volume, open-source para dados sensíveis (LGPD em PME brasileira é diferencial real).
- **Ignorar o fator humano.** 70% dos projetos de IA falham por adoção, não por tecnologia. Treinamento da equipe, change management leve e relatório executivo mensal são parte do produto.

---

## Resumo em uma frase

> A metodologia Novais Digital é: **diagnosticar a dor real (não a declarada), estruturar o processo antes de automatizar, implementar IA em camadas com humano-no-loop calibrado, e sair do cliente sem deixá-lo refém — vendendo paz, não tecnologia.**
