# 👋 Olá! Bem-vindo ao Acme Forge

> Antes de qualquer coisa: **escolha o seu caminho**. O Forge funciona de jeitos diferentes para pessoas diferentes.

---

## 🎯 Quem é você?

### 🎨 **Sou CEO / founder / criador — quero construir vibecodando**

Você usa o Claude Code para criar coisas (posts, agentes, módulos) descrevendo o que quer em linguagem natural. **Não precisa saber comandos técnicos.**

👉 **Vá para:** [`QUICKSTART_VIBE.md`](./QUICKSTART_VIBE.md) — 5 minutos de leitura

**Exemplos do que você vai aprender:**
- Como pedir "crie um carrossel sobre IA" e funcionar
- Como entender o que o agente fez
- Como pedir ajustes sem quebrar nada
- Como pedir socorro quando der erro

---

### 🛠️ **Sou dev — vou contribuir com código no framework ou nos projetos**

Você entende git, terminal, JSON, Markdown. Quer saber onde estão as coisas e como adicionar/mudar.

👉 **Vá para:** [`QUICKSTART_DEV.md`](./QUICKSTART_DEV.md) — cheatsheet de 1 página

**Exemplos do que você vai aprender:**
- Estrutura do repo em 30 segundos
- Como adicionar skill / command / Guardian / hook
- Comandos mais usados (`forge doctor`, `/acme:*`)
- Top 5 erros e como resolver

---

### 🤖 **Sou um agente de IA (Claude / DeepAgent / outro)**

Você é a IA executando tarefas neste repositório. Precisa do contrato operacional completo.

👉 **Vá para:** [`templates/master-prompt.md`](./templates/master-prompt.md) — referência completa (12 seções)

Esse documento descreve detecção de tipo, interpretação de C1-C8, roteamento de comandos e invocação de Guardians.

---

### 🆘 **Ainda não sei / quero ver opções**

Use o **wizard interativo**:

```bash
bash scripts/forge start
```

Ele faz 3 perguntas e te direciona para o lugar certo.

---

## 🧭 Atalhos universais (qualquer persona)

| Quero... | Comando |
|----------|---------|
| Verificar se o framework está saudável | `bash scripts/forge doctor` |
| Ver versão atual | `bash scripts/forge version` |
| Ver ajuda contextual | `bash scripts/forge help` |
| Trocar de modo (vibe ↔ dev) | `bash scripts/forge mode vibe` ou `mode dev` |

---

## 🤔 Não encontrou o que precisa?

| Situação | Onde olhar |
|----------|------------|
| Quer entender o que é o Forge no geral | [`README.md`](./README.md) |
| Quer instalar em um projeto novo | [`INSTALL.md`](./INSTALL.md) |
| Tem um termo técnico que não entendeu | [`GLOSSARY.md`](./GLOSSARY.md) |
| Quer ver o histórico de versões | [`CHANGELOG.md`](./CHANGELOG.md) |
| Quer entender a arquitetura interna | [`ARCHITECTURE.md`](./ARCHITECTURE.md) |
| Vai contribuir com PR | [`CONTRIBUTING.md`](./CONTRIBUTING.md) |

---

## 💡 Princípio do Forge em uma frase

> **"Construa rápido. Sem quebrar. Sem precisar adivinhar."**

O Forge é o conjunto de regras invisíveis que garante que tudo o que você cria:
- ✅ Tem um propósito claro (alguém vai pagar por isso?)
- ✅ Tem custo previsível (você não vai quebrar o caixa)
- ✅ Tem teste (não vai quebrar depois)
- ✅ Está documentado (a próxima pessoa entende)

Você não precisa saber **como** o Forge garante isso. Só precisa saber **que** garante.

---

**Próximo passo:** escolha sua persona acima e vá para o quickstart correspondente. ⬆️
