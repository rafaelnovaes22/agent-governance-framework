# Metodologia Sincra

> Síntese da metodologia apresentada por Pedro Valério (Affluence), em live com Alan e Thiago Fit. A Sincra é uma metodologia **task-first** para sincronizar trabalho entre humanos e IA dentro do ClickUp, eliminando microtarefas, gaps de tempo e dependência de reuniões de alinhamento.

---

## 1. Contexto e motivação

A Sincra nasceu na Affluence (agência boutique de TikTok ads que atende Magalu, Amazon, Mercado Livre, Globo, Nestlé, Disney) como resposta a três sintomas crônicos:

- **Founder/CEO como gargalo**: tudo afunilava em uma pessoa que aprovava tudo e ficava apagando incêndio até as 22h.
- **Reuniões infinitas de "alinhamento"**: "se você faz reunião de alinhamento toda hora, é porque não tem nada alinhado".
- **Ilusão de controle**: documentação bonita, flow charts, PowerPoints — que em 2 ou 3 meses não representam mais a realidade. *"A ilusão de controle é pior que o descontrole."*

Resultado da aplicação: Affluence saiu de R$ 1M para R$ 9M de faturamento mantendo o mesmo time (29 → 42 → 25 pessoas), enquanto concorrentes diretos têm de 200 a 500 pessoas.

> Não é sobre eliminar pessoas. É sobre aumentar a **produtividade por hora valiosa** — eliminar as horas de baixo valor (control-C/control-V, criar pasta, vincular link) para que reste só o tempo em que o humano faz o que só humano faz.

---

## 2. Princípios centrais

### 2.1. Task-first, com executor variável
Toda tarefa tem **um responsável humano**, mas o **executor pode variar**:
- **Worker (humano)**: criatividade, responsabilidade, assinatura, decisão.
- **Agent (IA / LLM)**: burocrático, repetitivo, estruturado.
- **Híbrido**: humano operando ferramenta de IA.

A proporção saudável observada na Affluence é de ~70% das tasks executadas por IA.

### 2.2. IA é ferramenta, não responsável
> "Você não responsabiliza o martelo por martelar seu dedo."

Quando a IA entrega errado, o problema é de input/contexto/processo — não dela.

### 2.3. Humano absorve ruído; IA não
O humano consegue receber input bruto/ruim e transformar em output bom. A IA, não — entropia ruim entra, entropia pior sai. Por isso o mapeamento de processos para IA precisa ser muito mais granular do que o tradicional (BPMN, Six Sigma, Lean), que assumiam executor humano.

### 2.4. Migalhas de pão (granularidade certa)
A IA precisa de "migalhas de pão" — pedaços pequenos e bem definidos de contexto:
- **Migalhas muito longe**: ela se perde.
- **Pão inteiro no caminho**: ela alucina, varia, não chega ao destino.
- **Tamanho certo**: cada output de uma task é input limpo da próxima.

### 2.5. Reduzir cliques é objetivo de negócio
Mudança de tela custa de 30min a 1h por dia por pessoa só em quebra de flow. Multiplique pelo time. Toda automação Sincra começa perguntando: *"como reduzo cliques aqui?"*

### 2.6. "Se não está no ClickUp, não aconteceu"
Tudo precisa deixar rastro (journey log) em uma única plataforma — fingerprints irrefutáveis do que ocorreu, sem o qual não há análise nem melhoria.

---

## 3. Arquitetura em três níveis

A empresa é organizada em **camadas que herdam contexto** da camada superior:

```
┌─────────────────────────────────────────┐
│  L0 — ESTRATÉGICO                       │
│  Quem somos, para quem, o que entregamos│
│  (DNA, ICP, ofertas, produtos, serviços)│
└─────────────────────────────────────────┘
                  ↓ herda
┌─────────────────────────────────────────┐
│  L1 — TÁTICO                            │
│  Configura os processos operacionais    │
│  (entidade Projeto, Cliente, Briefing)  │
└─────────────────────────────────────────┘
                  ↓ herda
┌─────────────────────────────────────────┐
│  L2 — OPERACIONAL                       │
│  Executa o trabalho em si               │
│  (entidade Criativo, Cópia, Material)   │
└─────────────────────────────────────────┘
```

- **Estratégico** define identidade e fonte da verdade. Documentos como *Company DNA*, *ICP*, *Ofertas* — acessados tanto pelo time quanto por agentes de IA.
- **Tático** é a "orquestra": o nível Projeto configura quantos criativos, quais regras de legenda, qual guia do criador serão usados.
- **Operacional** materializa: produzir cópia, gravar, editar, postar.

A camada inferior **herda por relacionamento** — não duplica informação. Se o briefing muda no nível Projeto, todas as regras de legenda dos Criativos vinculados são atualizadas automaticamente.

---

## 4. Entidades

### 4.1. Definição
Uma **entidade** é qualquer "coisa" que sua empresa entrega ou processa, com ciclo de vida definido por status. Exemplos: Projeto, Criativo, Cópia, Material Bruto, Cliente, Fornecedor, Vaga, Candidato.

### 4.2. Regra de ouro
> **Uma entidade nasce e morre em uma única lista.**

Antipadrão comum: criar uma pasta por cliente e dentro dela uma lista de Projetos do Cliente X. Em 250 clientes, são 250 pastas — escala no caos, força mudança de tela, impede análise transversal.

Padrão Sincra: **uma única lista de Projetos** onde todos os projetos da empresa moram, vinculados por relacionamento ao Cliente correspondente.

### 4.3. Status como ciclo de vida
Cada entidade tem seus próprios status (ex: Projeto → `Backlog → Setup → Briefing → Em produção → Revisão → Postagem → Concluído`). O trabalho do humano é "matar entidades" — pegar a que acabou de nascer e levá-la ao status final.

---

## 5. Artefatos e handoffs

Cada **task gera um artefato** (output estruturado) que é o **input da próxima task**. Esse é o nível certo de mapeamento:

- **Alto demais** (só status): perde-se contexto.
- **Baixo demais** (campo a campo): vira preenchimento de formulário, não processo.
- **Certo** (artefato): conjunto de campos com template que faz handoff entre BUs.

Exemplo do fluxo criativo da Affluence:

```
Briefing do cliente (cru, desorganizado)
        ↓ Briefing Guardian (agente) organiza no template
Briefing estruturado
        ↓ extração
Idontes / Regras de legenda / Guia do criador  (artefatos separados)
        ↓
Cópia (artefato)
        ↓ handoff → BU Produção
Material Bruto (artefato — pode vir de filmmaker, creator OU geração com IA)
        ↓ handoff → BU Edição
Criativo (artefato)
        ↓ Decupagem (agente acessa lista de inventário)
        ↓ Validação (Creative IA Validator)
Postagem
```

Repare: independente de **quem executa** o Material Bruto (filmmaker humano, creator gravando, ou geração 100% por IA via Symphony), o artefato resultante é o mesmo, e o resto do pipeline não muda.

---

## 6. Pré-checklist e qualidade

Antes do material bruto chegar ao editor, há um **checklist pré** automatizado. Sem ele, 100% dos conteúdos chegam ao editor; com 20% de erro, ele revisa o lote inteiro e devolve 20%. Com pré-checklist, ele recebe os 80% que já passaram. **Você não joga 100 para o editor produzir 80; você joga 80.**

Princípio análogo se aplica a qualquer ponto de handoff entre BUs.

---

## 7. Resultados quantitativos relatados

| Tarefa                       | Antes      | Depois  |
|------------------------------|------------|---------|
| Abertura de projeto          | 45 min     | 3 min   |
| Análise de briefing          | 3 horas    | 3 min   |
| Triagem de cash (creators)   | 3 dias     | 4 horas |
| Landing page (Thiago Fit)    | 12 dias    | 2 horas |

Economia consolidada: **~5.000 horas/ano** na operação da Affluence. De 55 microtarefas para criar uma landing page, 50 passaram a ser executadas por IA com a mesma qualidade.

---

## 8. Workspace curator e documentação viva

A documentação não fica em Notion separado, drive ou Confluence — fica **dentro do próprio ClickUp**, em templates reaproveitáveis (ex: *Company DNA*, *Briefing*, *Guia do criador*). Cada template tem:

- **Estrutura fixa** (seções obrigatórias).
- **Agente associado** com instruções de como preenchê-lo.
- **Acesso por herança** (L0/L1/L2) para outros agentes consumirem.

Onboarding de novo colaborador: o vídeo POP de cada task fica **dentro da própria task**. Quando alguém abre "Setup do projeto", o vídeo de "como fazer setup" está ali — sem precisar mudar de aba para ver playbook.

---

## 9. Squads de agentes

### 9.1. Process Mapper (nível tático)
Agente que conduz elicitação iterativa para mapear processos novos. Não cria documentação genérica — faz perguntas específicas, propõe trade-offs (mapear tudo de uma vez vs. começar pelo processo central), e devolve estrutura de listas/entidades já compatível com ClickUp.

### 9.2. Workspace Curator (nível estratégico)
Cria artefatos-fonte-da-verdade (Company DNA, ICP, ofertas) seguindo templates e instruções pré-configuradas.

### 9.3. Materializadores (nível operacional)
- **Briefing Guardian**: pega briefing cru do cliente, organiza no template, separa migalhas (idontes, regras de legenda, guia do criador).
- **Decupador técnico**: ativado quando entidade Criativo muda para status `decupagem` E custom field `cópia` está preenchido. Acessa lista de inventário, identifica itens em falta, monta plano de produção.
- **Creative IA Validator**: faz QA de qualidade no criativo final.
- **Gerador de legenda**: lê o vídeo + regras de legenda do projeto vinculado, gera legenda alinhada à campanha.

### 9.4. Ativação por automação
Agentes não rodam por gosto — são acionados quando uma entidade muda de status e satisfaz condições específicas em custom fields. Exemplo: *"sai de qualquer status → entra em decupagem E cópia ≠ vazio"*.

---

## 10. Ordem de implementação recomendada

1. **Não comece pela empresa toda.** A Affluence começou em um único processo (gestão de Projetos), em um único time pequeno.
2. **Mapeie o processo central primeiro** (a entidade que configura as outras). Só então conecte entidades derivadas.
3. **Identifique microtarefas**: pare e conte os átomos de cada fluxo. (Ex: "criar landing page" parecia 10 passos; eram 55.)
4. **Automatize as tarefas D** (burras, sem inteligência humana necessária): criar pasta, vincular link, control-C/control-V, organizar checklist.
5. **Difunda lateralmente**: quando uma área para de fazer trabalho que odiava, ela divulga sozinha. As outras áreas pedem.
6. **Top-down OU bottom-up**: founder/CEO impondo OU colaborador "indispensável" trazendo. Ambos os caminhos funcionam.

---

## 11. O que muda e o que não muda

**Não muda** (palavras eternas):
- Processo
- Input → Output
- Handoff entre responsáveis
- Artefato

**Muda** (volátil, ferramentável):
- Qual LLM, qual provedor (OpenAI, Anthropic, etc.)
- Qual ferramenta de orquestração (n8n, Make, Zapier, IoX)
- Qual interface (ClickUp é só o frontend escolhido)

Por isso a Sincra é **ferramenta-agnóstica em essência** mas **ClickUp-nativa em prática** — a metodologia foi codificada nas regras do ClickUp para ser acionável imediatamente, sem esperar uma plataforma própria ser construída.

---

## 12. Anti-padrões a evitar

- ❌ Reuniões de alinhamento recorrentes como solução para falta de clareza.
- ❌ Documentação Powerpoint/flow-chart sem amarração com o sistema de execução.
- ❌ Uma pasta de projeto por cliente (ou qualquer organização que force mudança de tela).
- ❌ Mapear processo só com IA, sem vivência: ela idealiza o "futuro perfeito" e você confunde com o presente.
- ❌ Mapear no nível errado: status (alto demais) ou campo (baixo demais).
- ❌ Mandar briefing inteiro para a IA quando ela precisa só das regras de legenda.
- ❌ Tratar IA como humano que aceita input ruim: ela amplifica ruído.
- ❌ Querer automatizar 100%: existem tasks que só humano pode/deve assinar.
- ❌ Esperar plataforma própria pronta: comece com ClickUp + IoX hoje.

---

## 13. Glossário rápido

| Termo                | Significado                                                                |
|----------------------|----------------------------------------------------------------------------|
| **Sincra**           | Metodologia de sincronização humano + IA, task-first, em três níveis.      |
| **Entidade**         | Coisa entregável com ciclo de vida (status). Mora em uma única lista.      |
| **Artefato**         | Output estruturado de uma task; vira input da próxima.                     |
| **Worker**           | Executor humano de uma task.                                               |
| **Agent**            | Executor IA (LLM ou automação) de uma task.                                |
| **Migalha de pão**   | Granularidade certa de contexto entregue à IA.                             |
| **Journey log**      | Registro irrefutável de tudo que aconteceu em uma task.                    |
| **Tarefa D**         | Tarefa "burra", sem inteligência humana necessária — candidata a automação.|
| **Task D vs C**      | D = burocrática; C = criativa/decisória (humana).                          |
| **L0 / L1 / L2**     | Nível Estratégico / Tático / Operacional.                                  |
| **BU**               | Business Unit (ex: Cópia, Produção, Edição).                               |
| **Handoff**          | Passagem de bastão entre BUs via artefato padronizado.                     |
| **IoX**              | Framework de desenvolvimento com squads de agentes (complementar à Sincra).|

---

## 14. Frases-chave (mantras)

- *"Reunião de alinhamento toda hora = nada está alinhado."*
- *"A ilusão de controle é pior que o descontrole."*
- *"Se não está no ClickUp, não aconteceu."*
- *"A IA é ferramenta. Você não responsabiliza o martelo por martelar seu dedo."*
- *"Humano transforma input ruim em output bom. IA transforma input ruim em output pior."*
- *"Você não joga 100 para o editor entregar 80. Você joga 80."*
- *"Uma entidade nasce e morre em uma única lista."*
- *"O que muda: ferramenta, LLM, interface. O que não muda: processo, input/output, handoff, artefato."*
