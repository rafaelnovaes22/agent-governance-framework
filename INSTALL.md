# Instalando o Novais Digital Foundry em um projeto consumidor

> Versão atual: **0.13.0+** (Foundry-13 Sprint 1 — Consumer-mode hardening).
> Instalação automática via `scripts/foundry-sync.sh`; validação via `bash scripts/foundry-doctor.sh --consumer`.

---

## Antes de começar — qual é o seu perfil?

| Você é... | Comece em |
|---|---|
| 🎨 **CEO / vibecoder / não-dev** | [`HELLO.md`](./HELLO.md) → [`QUICKSTART_VIBE.md`](./QUICKSTART_VIBE.md) |
| 🛠️ **Dev** (Claude Code instalado) | continue lendo este INSTALL.md |
| 🤖 **Agente IA** (DeepAgent, etc.) | [`DEEPAGENT_GUIDE.md`](./DEEPAGENT_GUIDE.md) |
| 🆘 **Não sei** | rode `bash scripts/foundry start` (wizard interativo) |

---

## Pré-requisitos

- [Claude Code](https://claude.com/claude-code) instalado (`claude` CLI)
- Projeto consumidor com `git` ativo
- Repositório `agent-governance-framework` clonado localmente (canônico)
- Node.js ≥ 18 (usado pelos scripts; sem dependências runtime)

---

## Instalação automática (caminho recomendado)

### 1. Clonar o Foundry canônico

```bash
git clone git@github.com:rafaelnovaes22/agent-governance-framework.git ~/Projetos/agent-governance-framework
```

### 2. Ir até o projeto consumidor

```bash
cd /path/to/seu-projeto
```

### 3. Rodar `foundry-sync.sh`

```bash
bash ~/Projetos/agent-governance-framework/scripts/foundry-sync.sh --from ~/Projetos/agent-governance-framework --dry-run
```

`--dry-run` mostra exatamente o que vai mudar sem escrever nada. Revise o output. Se aceitar, rode sem `--dry-run`:

```bash
bash ~/Projetos/agent-governance-framework/scripts/foundry-sync.sh --from ~/Projetos/agent-governance-framework
```

O sync:
- Copia `.claude/{CONSTITUTION,agents,commands,skills}/`, `hooks/`, `scripts/foundry*`, `templates/`, `reviewer/*` do canônico
- **Preserva** seu `.claude/settings.json`, `.claude/settings.local.json`, `docs/foundry/manifest.json`, `docs/foundry/project.json`, `CLAUDE.md`
- Atualiza no seu `docs/foundry/manifest.json`: `framework.framework_version_required` + `last_synced_at`
- Registra entrada em `docs/foundry/sync-history.md` (audit trail)

### 4. Criar `docs/foundry/project.json` (se ainda não existe)

Declarar tipo de projeto:

```bash
cp templates/project.template.json docs/foundry/project.json
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
  > Operação adaptativa sob Foundry: ver [`templates/master-prompt.md`](./templates/master-prompt.md).
  ```

### 6. Validar instalação

```bash
bash scripts/foundry-doctor.sh --consumer
```

Esperado: **0 FAIL**. Warns são aceitáveis na primeira instalação (ex: drift se ainda não rodou sync); ajuste conforme indicações.

### 7. (Opcional) Definir modo de operação

```bash
bash scripts/foundry mode dev    # ou vibe, ou agent
```

Cria `.foundry-mode` (gitignored). Hooks `friendly-errors` e `foundry-router` adaptam saída.

---

## Atualizar Foundry instalado (upgrade)

Quando uma nova versão do Foundry canônico sair (`git pull` no `agent-governance-framework/`), no projeto consumidor:

```bash
cd /path/to/seu-projeto

# Diff prévio sem escrever (ver o que vai mudar)
bash ~/Projetos/agent-governance-framework/scripts/foundry-sync.sh --from ~/Projetos/agent-governance-framework --dry-run

# Aplicar
bash ~/Projetos/agent-governance-framework/scripts/foundry-sync.sh --from ~/Projetos/agent-governance-framework

# Revisar diff resultante
git diff

# Validar
bash scripts/foundry-doctor.sh --consumer

# Commitar
git commit -am "chore(foundry): sync v$(node -e "console.log(JSON.parse(require('fs').readFileSync('docs/foundry/manifest.json','utf8')).framework.framework_version_required)")"
```

**Variável de ambiente**: pode definir `FOUNDRY_PATH=~/Projetos/agent-governance-framework` em `.bashrc`/`.zshrc` para omitir `--from`.

---

## Instalação manual (fallback)

Apenas se `foundry-sync.sh` não estiver disponível ou se você quer entender o que ele faz. Roda a partir do diretório do projeto consumidor:

```bash
FOUNDRY=/path/to/agent-governance-framework

# Camada canônica
cp "$FOUNDRY/.claude/CONSTITUTION.md" .claude/
cp -r "$FOUNDRY/.claude/agents/" .claude/
cp -r "$FOUNDRY/.claude/commands/" .claude/
cp -r "$FOUNDRY/.claude/skills/" .claude/
cp -r "$FOUNDRY/hooks/" .
cp -r "$FOUNDRY/templates/" .
cp "$FOUNDRY/scripts/foundry-doctor.sh" scripts/
cp "$FOUNDRY/scripts/foundry" scripts/
cp "$FOUNDRY/scripts/foundry-sync.sh" scripts/  # para próximos updates
cp -r "$FOUNDRY/reviewer/" .

# settings.json — copiar só se não existe (preservar customizações locais)
[ ! -f .claude/settings.json ] && cp "$FOUNDRY/.claude/settings.json" .claude/

# CLAUDE.md.template — usar como base se você ainda não tem CLAUDE.md
[ ! -f CLAUDE.md ] && cp "$FOUNDRY/CLAUDE.md.template" CLAUDE.md
```

---

## Validação pós-instalação

| Check | Comando | Esperado |
|---|---|---|
| Consistência consumer | `bash scripts/foundry-doctor.sh --consumer` | 0 FAIL |
| Sync history | `cat docs/foundry/sync-history.md` | ≥ 1 entrada |
| Project type declarado | `cat docs/foundry/project.json` | `project.type` válido |
| Constitution acessível | `cat .claude/CONSTITUTION.md \| head -5` | imprime versão e princípios |
| Master prompt referenciado | `grep -q master-prompt CLAUDE.md && echo OK` | OK |
| Claude Code carrega contexto | abrir o projeto no Claude Code e digitar "/" | lista de `/novais-digital:*` aparece |

---

## Solução de problemas

### "foundry-doctor falha em consumer mode com erro de reviewer/"

Em v0.13.0+ o foundry-doctor detecta consumer mode automaticamente (via `manifest.framework.canonical` ausente) e relaxa requisitos de `reviewer/*`. Se ainda falha:
- Garanta que está usando a versão `≥ 0.5.0` do `scripts/foundry-doctor.sh` (rode `bash scripts/foundry-doctor.sh --consumer` explicitamente).
- O canônico do Foundry precisa estar acessível em `FOUNDRY_PATH` ou `../agent-governance-framework/` para o drift check (C9) funcionar.

### "Consumer manifest perde modificações após foundry-sync"

`foundry-sync.sh` **NÃO** sobrescreve `docs/foundry/manifest.json` do consumer (preserva via `PRESERVE_PATHS`). Apenas atualiza dois campos: `framework.framework_version_required` + `framework.last_synced_at`. Se você viu sumiço de outras chaves, abra issue.

### "Manifest tem hashes diferentes dos arquivos no consumidor"

Esperado — `sha256` no manifest é calculado em normalização LF (Linux). Em Windows, line endings (CRLF) mudam o hash. Em v0.13.0+ muitas entries têm `sha256: null` por essa razão. Hash não é gate de validação; valor `null` é OK.

### "Claude Code não carrega CONSTITUTION automaticamente"

`CLAUDE.md` raiz precisa referenciar `.claude/CONSTITUTION.md` explicitamente. O Claude Code carrega `CLAUDE.md` raiz por convenção, mas Constitution só entra no contexto se referenciada lá. Use `CLAUDE.md.template` como base — já vem com a referência correta.

### "settings.json conflita com settings.local.json"

`settings.local.json` tem prioridade — é o override do dev. Conflitos são por design. Foundry nunca mexe em `settings.local.json`.

---

## Suporte

- 📋 Bugs: GitHub do `agent-governance-framework` (`rafaelnovaes22/agent-governance-framework`)
- 📚 Doc operacional pós-instalação: [`templates/master-prompt.md`](./templates/master-prompt.md)
- 🎓 Aprendizado por exemplos: [`PLAYGROUND/`](./PLAYGROUND/)
- 🆘 Erros comuns: [`COMMON_ERRORS.md`](./COMMON_ERRORS.md)
