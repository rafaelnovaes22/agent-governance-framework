# Quickstart — Novais Digital Foundry em 5 minutos

> Para devs que querem começar a usar o Foundry em um projeto. Setup mínimo, primeira spec saindo.

**Pré-requisitos**: Claude Code CLI instalado, projeto-alvo com `git` ativo, Node 20+.

---

## Passo 1 — Instalar (1 min)

```bash
# Em qualquer pasta de trabalho
git clone https://github.com/rafaelnovaes22/agent-governance-framework.git ~/agent-governance-framework

# Ir até o projeto-alvo
cd /caminho/do/seu/projeto

# Copiar artefatos do Foundry
FOUNDRY=~/agent-governance-framework
mkdir -p .claude templates docs/foundry

cp "$FOUNDRY/.claude/CONSTITUTION.md" .claude/
cp "$FOUNDRY/.claude/settings.json" .claude/
cp -r "$FOUNDRY/templates/"* templates/
cp -r "$FOUNDRY/docs/foundry/"* docs/foundry/
cp "$FOUNDRY/CLAUDE.md.template" CLAUDE.md

echo "✅ Foundry instalado"
```

> ⚠️ **Não toque** em `.claude/settings.local.json` se existir — é override do dev.

---

## Passo 2 — Adaptar `CLAUDE.md` (1 min)

Abra `CLAUDE.md` raiz e ajuste 3 seções:

1. **Nome do projeto** + descrição (1 linha)
2. **Stack**: liste tecnologias do projeto
3. **Comandos npm úteis** — copie do seu `package.json`

Pode deixar tudo o resto como está. As referências a `.claude/CONSTITUTION.md`, `templates/`, `docs/foundry/` continuam válidas.

---

## Passo 3 — Validar instalação (1 min)

```bash
# Manifest válido?
node -e "console.log(JSON.parse(require('fs').readFileSync('docs/foundry/manifest.json','utf8')).framework.version)"
# Deve imprimir: 0.2.0

# Constitution carrega no Claude Code?
claude --version
# Abra o projeto no Claude Code; em qualquer prompt cite "Constitution C3"
# Claude deve referenciar o princípio "Cost ≤ 25% of price"
```

✅ Se ambos funcionam, Foundry está operacional.

---

## Passo 4 — Primeira spec (2 min)

Crie a spec do primeiro agente/produto/SKU do projeto:

```bash
# Decida o tipo: platform-sku, product, ou diagnostic
# Exemplo: produto self-serve (cliente loga, ticket fixo)
mkdir -p src/products/meu-produto
cp templates/product-spec.template.md src/products/meu-produto/spec.md

# Edite spec.md preenchendo os {{ placeholders }}
```

Os 4 templates principais:

| Template | Quando usar |
|---|---|
| [`platform-sku-spec.template.md`](./templates/platform-sku-spec.template.md) | SKU vertical em plataforma high-touch (cliente não loga, entrega async) |
| [`product-spec.template.md`](./templates/product-spec.template.md) | Produto self-serve (cliente loga, mensalidade fixa) |
| [`diagnostic-spec.template.md`](./templates/diagnostic-spec.template.md) | Diagnóstico/Fase 0 cobrável |
| [`unit-economics.template.md`](./templates/unit-economics.template.md) | Validar regra C3 (custo ≤ 25%) — sempre par com a spec acima |

---

## Passo 5 — Pedir review do Claude (30s)

No Claude Code, peça:

```
Revise src/products/meu-produto/spec.md contra a Constitution.
Cite cada princípio C1-C8 e o status (PASS/WARN/FAIL).
```

Claude vai validar a spec contra os 8 princípios e apontar gaps.

---

## Próximos passos

| Quero... | Ler |
|---|---|
| Entender a estrutura do framework | [`ARCHITECTURE.md`](./ARCHITECTURE.md) |
| Ver caso real de uso | [`examples/novais-digital/`](./examples/novais-digital/) |
| Configurar reviewer DeepAgent (auditoria mensal) | [`DEEPAGENT_GUIDE.md`](./DEEPAGENT_GUIDE.md) |
| Aprofundar instalação ou atualizar versão | [`INSTALL.md`](./INSTALL.md) |
| Vocabulário do Foundry | [`GLOSSARY.md`](./GLOSSARY.md) |
| Evoluir o framework | [`CONTRIBUTING.md`](./CONTRIBUTING.md) |

---

## Troubleshooting rápido

### "Claude Code não cita Constitution"

`CLAUDE.md` raiz precisa **explicitamente** referenciar `.claude/CONSTITUTION.md`. Verifique linha que diz:
```
Antes de qualquer coisa: leia [.claude/CONSTITUTION.md]
```

### "Manifest tem hashes diferentes dos arquivos locais"

Esperado. Hashes são da origem canônica (LF endings). Em Windows, CRLF muda hash. Em Foundry-4, hook `manifest-sync` recalcula com normalização LF.

### "Não sei qual template usar"

Pergunte ao Claude:
```
Meu projeto vai construir um agente que [descrição]. Qual template do Foundry devo usar?
```

Claude orienta entre os 4 templates principais com base no caso.

---

**Tempo total**: ~5 min para instalar + ~2 min para criar primeira spec. Já está usando Foundry.
