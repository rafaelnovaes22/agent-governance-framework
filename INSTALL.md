# Instalando o Acme Forge em um projeto consumidor

> Versão atual: **0.1.0** (Forge-0).
> Em Forge-2 será disponibilizado script automatizado `./install.sh <target>`.
> Por enquanto, instalação manual conforme abaixo.

---

## Pré-requisitos

- Claude Code instalado (`claude` CLI)
- Projeto consumidor com `git` ativo
- Repositório `agent-governance-framework` clonado localmente

---

## Instalação manual (Forge-0)

A partir do diretório do projeto consumidor (ex: `acme-governanca-ia`):

### 1. Copiar `.claude/` (sem sobrescrever overrides do dev)

```bash
FORGE=/path/to/agent-governance-framework

# Constitution (sempre sobrescreve — é a fonte canônica)
cp "$FORGE/.claude/CONSTITUTION.md" .claude/

# settings.json — Forge layer (versionado).
# ⚠️ NUNCA sobrescreva settings.local.json (overrides do dev)
cp "$FORGE/.claude/settings.json" .claude/
```

### 2. Copiar `templates/`

```bash
mkdir -p templates
cp "$FORGE/templates/"* templates/
```

### 3. Copiar `docs/forge/`

```bash
mkdir -p docs/forge
cp "$FORGE/docs/forge/"* docs/forge/
```

### 4. Adaptar `CLAUDE.md` raiz

```bash
cp "$FORGE/CLAUDE.md.template" CLAUDE.md
# Editar manualmente para adaptar ao contexto do projeto:
# - Nome e descrição do projeto
# - Stack específico
# - Comandos npm úteis
# - Paths específicos do projeto
```

### 5. Validar instalação

```bash
# Verificar manifest válido
node -e "console.log(JSON.parse(require('fs').readFileSync('docs/forge/manifest.json','utf8')).framework.version)"
# Deve imprimir: 0.1.0

# Verificar Constitution carrega no Claude Code
claude --version
# Abrir Claude Code no projeto e checar que CONSTITUTION é citada no contexto inicial
```

---

## Adaptações esperadas no projeto consumidor

Após copiar, **editar** os seguintes arquivos para refletir realidade do projeto:

| Arquivo | O que adaptar |
|---|---|
| `CLAUDE.md` raiz | Stack, comandos npm, paths, links para metodologia local |
| `docs/forge/manifest.json` | Atualizar `linked_methodology_docs` e `linked_onda_artifacts` para paths reais |
| `docs/forge/decisions.md` | Confirmar F1-F8 ou registrar overrides |
| `.claude/settings.json` | Adicionar permissões específicas do projeto sob `permissions.allow` |

**Não adaptar** (são canônicos do framework):
- `.claude/CONSTITUTION.md`
- `templates/*.template.md`
- `docs/forge/reviewer-contract.md`
- `docs/forge/out-of-scope.md`

---

## Atualizar Forge instalado (sync com origem canônica)

Quando uma nova versão do `agent-governance-framework` sair (ex: Forge-1 entrega skills):

```bash
cd /path/to/projeto-consumidor
FORGE=/path/to/agent-governance-framework

# Sync arquivos canônicos
cp "$FORGE/.claude/CONSTITUTION.md" .claude/
cp -r "$FORGE/templates/"* templates/
cp -r "$FORGE/docs/forge/"* docs/forge/

# Diff dos arquivos adaptados (revisar manualmente, NÃO sobrescrever)
diff "$FORGE/.claude/settings.json" .claude/settings.json
diff "$FORGE/CLAUDE.md.template" CLAUDE.md

# Verificar versão
node -e "console.log(JSON.parse(require('fs').readFileSync('docs/forge/manifest.json','utf8')).framework.version)"
```

---

## Roadmap de instalação automatizada

| Onda | Recurso |
|---|---|
| **Forge-2** | Script `./install.sh <target-path>` que faz cópia + diff de adaptados |
| **Forge-3** | Validação automática pós-instalação (reviewer mock) |
| **Forge-5** | Avaliação de submodule git ou plugin Claude Code marketplace |

---

## Solução de problemas

### "CONSTITUTION não aparece no contexto inicial do Claude Code"

Verificar que `CLAUDE.md` raiz tem referência explícita a `.claude/CONSTITUTION.md`. O Claude Code carrega `CLAUDE.md` raiz automaticamente, mas a Constitution só entra se referenciada lá.

### "settings.json conflita com settings.local.json"

`settings.local.json` tem prioridade sobre `settings.json` para overrides do dev. Se houver conflito de permissão, a entrada em `local.json` ganha. Isso é por design.

### "Manifest tem hashes diferentes dos arquivos no consumidor"

Esperado — hashes são da origem canônica (Linux LF). Em Windows, line endings (CRLF) podem mudar o hash. Em Forge-4, o hook `manifest-sync` recalcula hashes localmente com normalização LF.

---

## Suporte

Issues: GitHub do `agent-governance-framework` (privado).
