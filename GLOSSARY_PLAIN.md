# Glossário em português claro

> O Foundry tem muitas palavras técnicas. Esse arquivo traduz tudo para linguagem do dia-a-dia.
> Foi feito para CEO, fundador, decisor de cliente, e qualquer pessoa que não programa.

---

## Como usar

Procure a palavra (Ctrl+F) ou role lendo. Cada entrada tem 3 partes:

1. **O que é** — em linguagem natural
2. **Por que importa** — quando você vai encontrar
3. **Equivalente técnico** — palavra que o dev usa (para você reconhecer)

---

## A

### **Agente**
**O que é**: um software que recebe um pedido e devolve um resultado, usando inteligência artificial. Pode ser texto, imagem, decisão.
**Por que importa**: o que vocês vendem.
**Equivalente técnico**: agentic SKU, LLM agent.

### **AIOS**
**O que é**: o "modo de trabalho em equipe" do Foundry para construir coisas grandes. Ele divide o trabalho em 6 especialistas: spec, frontend, backend, schema, test, review. Cada um faz sua parte.
**Por que importa**: quando você pede algo grande ao Claude, ele usa AIOS por trás. Não precisa entender — só saber que existe.
**Equivalente técnico**: AIOS Server multi-agent pipeline.

### **Audit log**
**O que é**: um diário automático que o sistema escreve a cada coisa que ele faz. Igual a um caixa registrando cada venda no fim do dia.
**Por que importa**: se algo der errado, isso é o que mostra "o que aconteceu". Obrigatório por lei em coisas financeiras.
**Equivalente técnico**: structured log + audit trail.

### **AUTONOMOUS**
**O que é**: o estado em que o agente já provou que funciona e cobra do cliente sozinho.
**Por que importa**: é o "modo produção" — onde a empresa faz dinheiro.
**Equivalente técnico**: subscription.mode = AUTONOMOUS.

---

## B

### **Baseline**
**O que é**: quanto custa hoje fazer aquilo SEM o agente IA. Tipo "antes eu pagava R$ 80 por hora-homem; agora pago R$ 5 por outcome".
**Por que importa**: é a base do preço que você cobra. Se você não sabe o baseline, não sabe se o cliente está economizando.
**Equivalente técnico**: baseline_cost, current_method_cost.

---

## C

### **C1-C8**
**O que é**: 8 regras invisíveis que o Foundry **força** todo agente a seguir. Tipo "tem que ter logs", "não pode custar mais que 25% do preço", etc.
**Por que importa**: você nunca vai mexer nelas. O Foundry avisa quando alguma é quebrada.
**Equivalente técnico**: Constitution C1-C8.

### **Canonical**
**O que é**: o estado em que o módulo de plataforma já está em produção e funcionando estável (similar a AUTONOMOUS, mas para platform/plataforma).
**Por que importa**: confirma que está "pronto pra vender".
**Equivalente técnico**: lifecycle_stage = canonical.

### **Constitution**
**O que é**: as 8 regras fundamentais do Foundry.
**Por que importa**: você não muda essas regras sem reunião formal (ADR + bump major).
**Equivalente técnico**: `.claude/CONSTITUTION.md`.

---

## D

### **DRAFT**
**O que é**: o estado inicial de um módulo platform. "Estou desenhando."
**Por que importa**: ainda não pode ir pro cliente.
**Equivalente técnico**: lifecycle_stage = draft.

### **DeepAgent**
**O que é**: outro agente IA, diferente do Claude, que **revisa** o trabalho mensalmente. Pense como auditor externo.
**Por que importa**: dá segunda opinião automática, evita que o Claude "passe pano" no próprio trabalho.
**Equivalente técnico**: DeepAgent reviewer / GPT-5.5.

### **Diagnóstico**
**O que é**: a primeira reunião com cliente novo, onde você descobre o problema dele com perguntas. O Foundry tem um roteiro pronto.
**Por que importa**: sem diagnóstico, você não tem outcome contratual.
**Equivalente técnico**: `/novais-digital:diagnose` + `docs/clients/{X}/diagnostic.md`.

---

## E

### **Eval (suite de eval)**
**O que é**: um conjunto de casos de teste com gabarito que valida se o agente IA está acertando. Tipo prova final do agente.
**Por que importa**: sem eval, você não sabe se o agente regrediu quando o prompt mudou.
**Equivalente técnico**: eval suite, evaluation cases.

---

## F

### **Foundry**
**O que é**: o framework (estrutura de regras + scripts + agentes auxiliares) que torna seu projeto auditável e cobrável.
**Por que importa**: é o que você está usando agora. Sem ele, cada projeto seria do zero.
**Equivalente técnico**: Novais Digital Foundry — github.com/novais-digital/agent-governance-framework.

### **Foundry-router**
**O que é**: um agente que escuta você falar normalmente em português ("quero diagnosticar o cliente X") e descobre qual comando técnico chamar.
**Por que importa**: você não precisa decorar `/novais-digital:diagnose` — pode falar natural.
**Equivalente técnico**: `foundry-router` subagent.

---

## G

### **Gate**
**O que é**: uma checagem obrigatória antes de avançar. Tipo "não pode promover para AUTONOMOUS sem CI/CD ativo".
**Por que importa**: o Foundry **bloqueia** quando gate falha. Não é negociável.
**Equivalente técnico**: gate (mecânico ou humano).

### **Guardian**
**O que é**: agente especialista que valida UMA coisa específica. Tipo:
- `po-guardian` — valida se o outcome do cliente faz sentido
- `unit-economist` — valida se o preço é viável
- `security-privacy-guardian` — valida se não tem dados pessoais expostos
**Por que importa**: você invoca chamando `@nome-guardian` no Claude.
**Equivalente técnico**: subagent Guardian em `.claude/agents/`.

---

## H

### **Hook**
**O que é**: regra automática que dispara antes/depois de você fazer algo. Tipo "antes de salvar arquivo de spec, checa se tem outcome contratual".
**Por que importa**: você não vê eles trabalhando, só quando bloqueiam algo.
**Equivalente técnico**: PreToolUse/PostToolUse/Stop hooks em `.claude/settings.json`.

### **Hybrid**
**O que é**: projeto que é mistura — plataforma SaaS comum + módulos com IA dentro.
**Por que importa**: ex: Aicfo = software de análise financeira (sem IA) + módulo "explicar gráfico" (com IA).
**Equivalente técnico**: project_type = hybrid.

---

## I

### **ICP** (Ideal Customer Profile)
**O que é**: o perfil de cliente que você sabe atender bem. "Empresa entre 50 e 500 funcionários do setor jurídico" é um ICP.
**Por que importa**: se cliente não bate com ICP, Foundry avisa antes de você queimar 2 semanas com ele.
**Equivalente técnico**: ICP doc + icp-loader skill.

### **Idempotência**
**O que é**: garantia de que rodar a mesma coisa duas vezes dá o mesmo resultado, sem duplicar.
**Por que importa**: jobs RPA precisam disso. Se cron rodar 2x, não pode criar 2 registros idênticos.
**Equivalente técnico**: idempotency_key, dedup_key.

---

## L

### **Lifecycle**
**O que é**: as fases por onde um artefato passa. Diferem por tipo de projeto:
- **agentic** (IA): SHADOW → ASSISTED → AUTONOMOUS
- **platform** (plataforma): DRAFT → STAGING → PILOT → CANONICAL → DEPRECATED
- **automation** (job): igual a platform
**Por que importa**: você só promove um estado por vez, sempre seguindo a ordem.
**Equivalente técnico**: subscription.mode (agentic) ou module.current_stage (platform/automation).

---

## M

### **Manifest**
**O que é**: um arquivo `manifest.json` que lista tudo que existe no Foundry. Tipo "índice da biblioteca".
**Por que importa**: você raramente edita à mão. Foundry atualiza automaticamente.
**Equivalente técnico**: `docs/foundry/manifest.json`.

### **Master Prompt**
**O que é**: o "manual operacional" que o Claude recebe ao abrir seu projeto. Substitui você ter que dizer "olha, leia esses 20 arquivos" toda vez.
**Por que importa**: sem master prompt, Claude não saberia que tem que respeitar Constitution e invocar Guardians.
**Equivalente técnico**: `templates/master-prompt.md` (canônico) ou `MASTER_PROMPT.md` no seu projeto.

### **Mode (`.foundry-mode`)**
**O que é**: arquivo escondido que diz para o Foundry como falar com você:
- `vibe` → linguagem leiga
- `dev` → linguagem técnica
- `agent` → JSON puro (para outra IA consumir)
**Por que importa**: você nunca edita à mão. O Foundry detecta automático na primeira vez. Pode trocar com `bash scripts/foundry mode vibe`.
**Equivalente técnico**: `.foundry-mode` (gitignored).

### **Módulo (em platform)**
**O que é**: uma parte da plataforma. Ex: "Módulo Financeiro", "Módulo CRM", "Módulo Cobranças".
**Por que importa**: cada módulo tem seu próprio lifecycle. Pode ter um em pilot, outro em canonical.
**Equivalente técnico**: platform_module.

---

## O

### **Outcome**
**O que é**: o que o cliente PAGA. Pode ser:
- "1 lead qualificado" (R$ 50)
- "1 análise financeira gerada" (R$ 12)
- "1 carrossel pronto para postar" (R$ 8)
- "1 mês de plataforma ativa" (R$ 2500)
**Por que importa**: se outcome é vago, contrato vira disputa.
**Equivalente técnico**: classified_outcome (agentic), operational_action (platform), execution_event (automation).

---

## P

### **PILOT**
**O que é**: o estado em que o módulo platform está rodando com cliente real, sob observação. 14 dias mínimo para módulos críticos.
**Por que importa**: cliente já paga, mas você ainda monitora de perto.
**Equivalente técnico**: lifecycle_stage = pilot.

### **Platform**
**O que é**: software comum (sem IA), tipo plataforma SaaS de gestão. SchoolPlatform é assim.
**Por que importa**: Foundry sabe lidar com isso — não exige LLM, eval, prompts.
**Equivalente técnico**: project_type = platform, ai_enabled = false.

### **Princípios C1-C8**
**O que é**: as 8 regras fundamentais. Veja "Constitution".
**Por que importa**: você não vai violar à mão — Foundry avisa.

### **Project Type**
**O que é**: tipo de projeto. Tem 4:
- `agentic_saas` — entrega agentes IA (Novais Digital Social)
- `platform` — entrega software SaaS (SchoolPlatform)
- `automation` — entrega job/script RPA
- `hybrid` — mistura (Aicfo)
**Por que importa**: declarar isso no `project.json` faz o Foundry se adaptar ao caso.
**Equivalente técnico**: `docs/foundry/project.json → project_type`.

### **Prompt**
**O que é**: o texto que você dá pro agente IA seguir. Tipo "redija um post de Instagram sobre X com tom amigável".
**Por que importa**: prompt define o agente. Pequenas mudanças mudam tudo.
**Equivalente técnico**: system prompt em `prompts/{artifact_id}.md`.

---

## R

### **Reviewer**
**O que é**: o auditor automático mensal, separado do Claude. Veja "DeepAgent".
**Por que importa**: ele que detecta drift e pega coisas que passariam batido.
**Equivalente técnico**: foundry-auditor DeepAgent.

---

## S

### **SHADOW**
**O que é**: estado inicial do agente IA — ele responde, mas as respostas vão para o operador humano revisar antes de irem ao cliente. Mínimo 14 dias.
**Por que importa**: garante que o agente não estraga reputação enquanto aprende.
**Equivalente técnico**: subscription.mode = SHADOW.

### **SKU**
**O que é**: um agente IA específico que você vende como produto. Tipo "Carrossel Agent", "Triagem WhatsApp", "Analista Financeiro".
**Por que importa**: é a unidade comercial do seu portfolio agentic.
**Equivalente técnico**: platform_sku, artifact_id = "{sku-id}".

### **Spec**
**O que é**: documento que descreve o agente/módulo: o que ele faz, qual outcome, qual stack, quais critérios de aceite.
**Por que importa**: sem spec, time fica adivinhando. Foundry tem template pronto.
**Equivalente técnico**: `docs/specs/{artifact_id}.md`.

### **Subagent**
**O que é**: um agente Claude especialista (Guardian, router, etc.). Você invoca chamando `@nome-do-agent`.
**Por que importa**: cada um tem expertise focada. Eficiente.
**Equivalente técnico**: subagent em `.claude/agents/`.

### **Sync**
**O que é**: comando que pega a versão nova do Foundry canônico e aplica no seu projeto.
**Por que importa**: ao sair Foundry v0.14.0, você roda `foundry-sync.sh` no seu projeto e atualiza tudo de uma vez.
**Equivalente técnico**: `bash scripts/foundry-sync.sh --from /path/to/agent-governance-framework`.

---

## T

### **TDD (Test-Driven Development)**
**O que é**: você escreve os testes ANTES do código. Garante que pensou no que tem que dar certo.
**Por que importa**: o Foundry força TDD em módulos Tier C (críticos, financeiros). CI bloqueia sem isso.
**Equivalente técnico**: test_agent --mode red → build → test_agent --mode verify.

### **Telemetry**
**O que é**: dados de execução que o sistema grava — quantos tokens gastou, quanto tempo demorou, qual foi a saída.
**Por que importa**: sem isso, você não consegue auditar nada. Foundry exige.
**Equivalente técnico**: LangSmith trace (agentic) ou audit log (platform).

### **Tenant**
**O que é**: um cliente específico dentro do seu sistema multi-cliente. Tipo "o cliente Novais Digital tem suas configurações isoladas do cliente Beta".
**Por que importa**: o Foundry proíbe `if (cliente === "Novais Digital") fazer X` — força configuração genérica.
**Equivalente técnico**: TenantContext, multi-tenant config.

### **Tier (criticality)**
**O que é**: nível de risco do módulo:
- **A** — informacional (catálogo, blog) — baixo risco
- **B** — operacional (CRM, dashboard) — médio risco
- **C** — crítico (financeiro, contratual, LGPD) — alto risco
**Por que importa**: Tier C exige TDD, audit log especial, 14 dias de PILOT.
**Equivalente técnico**: module.criticality ∈ {A, B, C}.

---

## U

### **Unit economics**
**O que é**: a conta de quanto custa fazer uma unidade vs quanto cobra. Ex: "custa R$ 1,80 em tokens; cobro R$ 8 por carrossel; margem 77%".
**Por que importa**: se custo passa de 25% do preço, Foundry bloqueia. C3.
**Equivalente técnico**: cost_per_outcome (agentic) ou platform_margin (platform).

---

## V

### **Versionamento (SemVer)**
**O que é**: regras de quando o número da versão muda:
- **MAJOR** (1.x.x → 2.0.0) — quebra Constitution (raro)
- **MINOR** (0.13.x → 0.14.0) — ganha capability nova
- **PATCH** (0.14.0 → 0.14.1) — corrige bug
**Por que importa**: ao ver v0.13.0 → v0.14.0 você sabe "tem coisa nova mas nada quebrou".
**Equivalente técnico**: SemVer 2.0.0.

### **Vibe (modo vibe)**
**O que é**: modo "linguagem leiga" para CEO/decisor não-técnico. Foundry traduz mensagens automaticamente nesse modo.
**Por que importa**: você não precisa entender técnico para usar o Foundry.
**Equivalente técnico**: `.foundry-mode = vibe`.

---

## W

### **Walkthrough**
**O que é**: tutorial passo-a-passo de cada exemplo no PLAYGROUND.
**Por que importa**: melhor que ler doc seca — você acompanha o pipeline real.
**Equivalente técnico**: `PLAYGROUND/{NN}-{tipo}/walkthrough.md`.

### **WireLog**
**O que é**: a "câmera de segurança do negócio" do Foundry. Registra o que aconteceu com cada resultado entregue — foi criado? foi entregue? foi cobrado? Alguém tentou mudar o status e falhou?
**Por que importa**: o LangSmith (câmera técnica) grava o que o agente fez internamente. O WireLog grava o que aconteceu no negócio. São câmeras diferentes com propósitos diferentes. Você, como CEO, se importa mais com a câmera do negócio.
**Equivalente técnico**: `analytics_provider=wirelog` em `project.json`.

### **Wizard**
**O que é**: assistente interativo. `bash scripts/foundry start` faz perguntas e te ajuda a configurar.
**Por que importa**: primeira vez? Use o wizard.

---

## Não está aqui?

Se a palavra não está aqui, abra issue no repo do Foundry ou pergunte direto ao Claude: "me explica essa palavra em linguagem do dia-a-dia". O Claude tem este glossário em contexto e vai traduzir.

---

**Próximos passos**:
- [`HELLO.md`](./HELLO.md) — landing para 4 personas
- [`QUICKSTART_VIBE.md`](./QUICKSTART_VIBE.md) — guia leigo completo (5 min)
- [`PLAYGROUND/`](./PLAYGROUND/) — exemplos para ver fazendo
