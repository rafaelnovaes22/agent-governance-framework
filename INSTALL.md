# Instalando o Acme Forge em um projeto consumidor

> Versão atual: **0.13.0+** (Forge-13 Sprint 1 — Consumer-mode hardening).
> Instalação automática via `scripts/forge-sync.sh`; validação via `bash scripts/forge-doctor.sh --consumer`.

---

## Antes de começar — qual é o seu perfil?

| Você é... | Comece em |
|---|---|
| 🎨 **CEO / vibecoder / não-dev** | [`HELLO.md`](./HELLO.md) → [`QUICKSTART_VIBE.md`](./QUICKSTART_VIBE.md) |
| 🛠️ **Dev** (Claude Code instalado) | continue lendo este INSTALL.md |
| 🤖 **Agente IA** (DeepAgent, etc.) | [`DEEPAGENT_GUIDE.md`](./DEEPAGENT_GUIDE.md) |
| 🆘 **Não sei** | rode `bash scripts/forge start` (wizard interativo) |

---

## Pré-requisitos

- [Claude Code](https://claude.com/claude-code) instalado (`claude` CLI)
- Projeto consumidor com `git` ativo
- Repositório `agent-governance-framework` clonado localmente (canônico)
- Node.js ≥ 18 (usado pelos scripts; sem dependências runtime)

---

## Instalação automática (caminho recomendado)

### 1. Clonar o Forge canônico

```bash
git clone git@github.com:acme-startup/agent-governance-framework.git ~/Projetos/agent-governance-framework
```

### 2. Ir até o projeto consumidor

```bash
cd /path/to/seu-projeto
```

### 3. Rodar `forge-sync.sh`

```bash
bash ~/Projetos/agent-governance-framework/scripts/forge-sync.sh --from ~/Projetos/agent-governance-framework --dry-run
```

`--dry-run` mostra exatamente o que vai mudar sem escrever nada. Revise o output. Se aceitar, rode sem `--dry-run`:

```bash
bash ~/Projetos/agent-governance-framework/scripts/forge-sync.sh --from ~/Projetos/agent-governance-framework
```

O sync:
- Copia `.claude/{CONSTITUTION,agents,commands,skills}/`, `hooks/`, `scripts/forge*`, `templates/`, `reviewer/*` do canônico
- **Preserva** seu `.claude/settings.json`, `.claude/settings.local.json`, `docs/forge/manifest.json`, `docs/forge/project.json`, `CLAUDE.md`
- Atualiza no seu `docs/forge/manifest.json`: `framework.framework_version_required` + `last_synced_at`
- Registra entrada em `docs/forge/sync-history.md` (audit trail)

### 4. Criar `docs/forge/project.json` (se ainda não existe)

Declarar tipo de projeto:

```bash
cp templates/project.template.json docs/forge/project.json
# Editar: project.type (agentic_saas | platform | automation | hybrid)
#         ai_enabled (true | false)
#         modules[] (para hybrid ou platform multi-módulo)
```

### 5. Adaptar `CLAUDE.md` raiz

Se você ainda não tem CLAUDE.md, copiar do template:

```bash
cp CLAUDE.md.template CLAUDE.md
```

E editar para refletir:
- Nome e descrição do projeto
- Stack específico (Next.js, Node, Python, etc.)
- Comandos úteis (`npm run dev`, `pytest`, etc.)
- **Referência ao master-prompt** (recomendado): adicionar linha:
  ```markdown
  > Operação adaptativa sob Forge: ver [`templates/master-prompt.md`](./templates/master-prompt.md).
  ```

### 6. Validar instalação

```bash
bash scripts/forge-doctor.sh --consumer
```

Esperado: **0 FAIL**. Warns são aceitáveis na primeira instalação (ex: drift se ainda não rodou sync); ajuste conforme indicações.

### 7. (Opcional) Definir modo de operação

```bash
bash scripts/forge mode dev    # ou vibe, ou agent
```

Cria `.forge-mode` (gitignored). Hooks `friendly-errors` e `forge-router` adaptam saída.

---

## Atualizar Forge instalado (upgrade)

Quando uma nova versão do Forge canônico sair (`git pull` no `agent-governance-framework/`), no projeto consumidor:

```bash
cd /path/to/seu-projeto

# Diff prévio sem escrever (ver o que vai mudar)
bash ~/Projetos/agent-governance-framework/scripts/forge-sync.sh --from ~/Projetos/agent-governance-framework --dry-run

# Aplicar
bash ~/Projetos/agent-governance-framework/scripts/forge-sync.sh --from ~/Projetos/agent-governance-framework

# Revisar diff resultante
git diff

# Validar
bash scripts/forge-doctor.sh --consumer

# Commitar
git commit -am "chore(forge): sync v$(node -e "console.log(JSON.parse(require('fs').readFileSync('docs/forge/manifest.json','utf8')).framework.framework_version_required)")"
```

**Variável de ambiente**: pode definir `FORGE_PATH=~/Projetos/agent-governance-framework` em `.bashrc`/`.zshrc` para omitir `--from`.

---

## Instalação manual (fallback)

Apenas se `forge-sync.sh` não estiver disponível ou se você quer entender o que ele faz. Roda a partir do diretório do projeto consumidor:

```bash
FORGE=/path/to/agent-governance-framework

# Camada canônica
cp "$FORGE/.claude/CONSTITUTION.md" .claude/
cp -r "$FORGE/.claude/agents/" .claude/
cp -r "$FORGE/.claude/commands/" .claude/
cp -r "$FORGE/.claude/skills/" .claude/
cp -r "$FORGE/hooks/" .
cp -r "$FORGE/templates/" .
cp "$FORGE/scripts/forge-doctor.sh" scripts/
cp "$FORGE/scripts/forge" scripts/
cp "$FORGE/scripts/forge-sync.sh" scripts/  # para próximos updates
cp -r "$FORGE/reviewer/" .

# settings.json — copiar só se não existe (preservar customizações locais)
[ ! -f .claude/settings.json ] && cp "$FORGE/.claude/settings.json" .claude/

# CLAUDE.md.template — usar como base se você ainda não tem CLAUDE.md
[ ! -f CLAUDE.md ] && cp "$FORGE/CLAUDE.md.template" CLAUDE.md
```

---

## Validação pós-instalação

| Check | Comando | Esperado |
|---|---|---|
| Consistência consumer | `bash scripts/forge-doctor.sh --consumer` | 0 FAIL |
| Sync history | `cat docs/forge/sync-history.md` | ≥ 1 entrada |
| Project type declarado | `cat docs/forge/project.json` | `project.type` válido |
| Constitution acessível | `cat .claude/CONSTITUTION.md \| head -5` | imprime versão e princípios |
| Master prompt referenciado | `grep -q master-prompt CLAUDE.md && echo OK` | OK |
| Claude Code carrega contexto | abrir o projeto no Claude Code e digitar "/" | lista de `/acme:*` aparece |

---

## Solução de problemas

### "forge-doctor falha em consumer mode com erro de reviewer/"

Em v0.13.0+ o forge-doctor detecta consumer mode automaticamente (via `manifest.framework.canonical` ausente) e relaxa requisitos de `reviewer/*`. Se ainda falha:
- Garanta que está usando a versão `≥ 0.5.0` do `scripts/forge-doctor.sh` (rode `bash scripts/forge-doctor.sh --consumer` explicitamente).
- O canônico do Forge precisa estar acessível em `FORGE_PATH` ou `../agent-governance-framework/` para o drift check (C9) funcionar.

### "Consumer manifest perde modificações após forge-sync"

`forge-sync.sh` **NÃO** sobrescreve `docs/forge/manifest.json` do consumer (preserva via `PRESERVE_PATHS`). Apenas atualiza dois campos: `framework.framework_version_required` + `framework.last_synced_at`. Se você viu sumiço de outras chaves, abra issue.

### "Manifest tem hashes diferentes dos arquivos no consumidor"

Esperado — `sha256` no manifest é calculado em normalização LF (Linux). Em Windows, line endings (CRLF) mudam o hash. Em v0.13.0+ muitas entries têm `sha256: null` por essa razão. Hash não é gate de validação; valor `null` é OK.

### "Claude Code não carrega CONSTITUTION automaticamente"

`CLAUDE.md` raiz precisa referenciar `.claude/CONSTITUTION.md` explicitamente. O Claude Code carrega `CLAUDE.md` raiz por convenção, mas Constitution só entra no contexto se referenciada lá. Use `CLAUDE.md.template` como base — já vem com a referência correta.

### "settings.json conflita com settings.local.json"

`settings.local.json` tem prioridade — é o override do dev. Conflitos são por design. Forge nunca mexe em `settings.local.json`.

---

## Suporte

- 📋 Bugs: GitHub do `agent-governance-framework` (privado, `acme-startup/agent-governance-framework`)
- 📚 Doc operacional pós-instalação: [`templates/master-prompt.md`](./templates/master-prompt.md)
- 🎓 Aprendizado por exemplos: [`PLAYGROUND/`](./PLAYGROUND/)
- 🆘 Erros comuns: [`COMMON_ERRORS.md`](./COMMON_ERRORS.md)
