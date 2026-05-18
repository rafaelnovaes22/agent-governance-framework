# Acme Forge — Integração Hermes Agent

> **Versão**: 0.1.0 | **Decisão**: F27 | **Forge**: v0.20.0+
>
> Hermes Agent (Nous Research) hospedado no Railway dispara pipelines `/acme:*`
> nos projetos consumer via GitHub Actions + Claude Code. Zero dependência da
> máquina local do operador para execução.

---

## Visão geral

```
Telegram → Hermes (Railway, Codex) → gh workflow run → GitHub Actions runner
                                                         └─ claude --print '/acme:xxx'
                                                         └─ artifact JSON + callback
                                      ← resultado consolidado ← Hermes ← Telegram
```

**Hermes é o operador remoto-móvel do Forge.** O cérebro (Codex/OpenAI) roda no Railway e é responsável por entender o intent em linguagem natural e disparar o workflow correto. A execução real dos Guardians e slash commands acontece em runners do GitHub com Claude Code instalado on-demand.

---

## Pré-requisitos

| Item | Status esperado |
|------|----------------|
| Hermes Railway | Serviço ativo, gateway Telegram configurado |
| `GH_TOKEN` | PAT GitHub com scopes `repo` + `workflow` |
| `ANTHROPIC_API_KEY` | Chave Anthropic configurada como secret GH |
| Repos consumer | `acme-startup/{school-platform,aicfo,clickup-automation,...}` no GitHub |
| `.claude/CONSTITUTION.md` | Presente em cada repo consumer |

---

## Instalação (passo a passo)

### 1. Secrets no repo `acme-startup/agent-governance-framework`

Acesse `https://github.com/acme-startup/agent-governance-framework/settings/secrets/actions` e configure:

| Secret | Obrigatório | Descrição |
|--------|-------------|-----------|
| `ANTHROPIC_API_KEY` | ✅ | Chave da API Anthropic para Claude Code |
| `GH_TOKEN` | ✅ | PAT GitHub (repo + workflow scope) |
| `HERMES_WEBHOOK_URL` | ⚪ | URL do endpoint `/forge/callback` no Hermes |
| `HERMES_WEBHOOK_SECRET` | ⚪ | HMAC para validar callbacks |
| `HERMES_PRIVILEGED_CHAT_IDS` | ✅ | CSV de chat_ids autorizados para comandos write |

### 2. Variáveis de ambiente no Railway (serviço Hermes)

Acesse o [Railway dashboard](https://railway.com/project/52bafdc5-3a22-4a45-a0ce-a5db94946866/service/aa9144ec-2761-4e26-8607-a01b4e028d77) → Settings → Variables e configure conforme `templates/hermes/railway/env.example`:

```bash
GH_TOKEN=ghp_...              # mesmo PAT do step 1
FORGE_REPO=acme-startup/agent-governance-framework
HERMES_WEBHOOK_SECRET=...     # mesmo valor do secret GH
HERMES_PRIVILEGED_CHAT_IDS=SEU_CHAT_ID
```

Para descobrir seu Telegram chat_id: envie qualquer mensagem para `@userinfobot`.

### 3. Instalar skill Forge no Hermes

Copie `templates/hermes/forge.skill.md` e `templates/hermes/status-fast.md` para o diretório de skills do Hermes:

```bash
# Via Railway Shell (ou hermes CLI local apontando para o projeto)
cp forge.skill.md ~/.hermes/skills/agent-governance-framework.skill.md
cp status-fast.md ~/.hermes/skills/agent-governance-framework-status-fast.skill.md

# Ou via hermes CLI (se disponível localmente):
hermes skills install templates/hermes/forge.skill.md
hermes skills install templates/hermes/status-fast.md
```

### 4. Verificar workflow disponível

```bash
gh workflow view forge-headless --repo acme-startup/agent-governance-framework
```

Se retornar o workflow, a instalação está completa.

---

## Como usar via Telegram

### Comandos de leitura (qualquer usuário autorizado)

| O que dizer no Telegram | Intent | Comando acionado |
|------------------------|--------|-----------------|
| "status geral" / "tudo ok?" | `status` | Caminho rápido (gh api) |
| "como está o SchoolPlatform?" | `status` | gh api REST < 5s |
| "audita todos os projetos" | `audit` | `/acme:audit-monthly` em paralelo |
| "rode pre-merge-check no Aicfo" | `pre_merge_check` | `/acme:pre-merge-check` |
| "roda eval no SchoolPlatform" | `run_eval` | `/acme:eval` |

### Comandos de escrita (requer `caller_id` privilegiado)

| O que dizer no Telegram | Intent | Comando acionado |
|------------------------|--------|-----------------|
| "implementa a onda 1 do SchoolPlatform" | `implement_now` | `/acme:implement` |
| "promove o módulo X para PILOT" | `promote` | `/acme:promote` |

> Se seu chat_id não está em `HERMES_PRIVILEGED_CHAT_IDS`, o Hermes recusará e orientará como autorizar.

### Exemplos de uso paralelo

```
Você → Telegram: "audita mês 2026-05 em school-platform e aicfo"

Hermes → GitHub Actions (2 jobs paralelos):
  Job A: /acme:audit-monthly --month 2026-05 em school-platform
  Job B: /acme:audit-monthly --month 2026-05 em aicfo

Hermes → Telegram:
  ✅ school-platform — audit-monthly concluído | Run: https://github.com/...
     [resumo do relatório]
  ✅ aicfo — audit-monthly concluído | Run: https://github.com/...
     [resumo do relatório]
```

---

## Adicionar novo consumer

1. Confirmar que o repo consumer está em `acme-startup/{nome}` no GitHub.
2. Confirmar que `.claude/CONSTITUTION.md` existe no consumer (rode `forge-sync.sh`).
3. Adicionar o slug à tabela de consumers em `templates/hermes/forge.skill.md`.
4. Testar: `gh workflow run forge-headless.yml --repo acme-startup/agent-governance-framework -f command="status" -f consumers="{nome}" -f args="" -f caller_id="test"`.

---

## Limites de segurança

| Regra | Detalhe |
|-------|---------|
| Allowlist chat_id | Apenas IDs em `HERMES_PRIVILEGED_CHAT_IDS` executam comandos write |
| Comandos write | `/acme:implement` e `/acme:promote` — exigem ID privilegiado + reconfirmação |
| Paralelismo máximo | 3 consumers por dispatch (evitar saturação de API quota) |
| Voz | Voice memos Telegram são aceitos apenas para intents read-only |
| Constitution | Hermes nunca edita `.claude/CONSTITUTION.md` — isso exige ADR humano |

---

## Ver logs e audit trail

### Logs de execução (GitHub Actions)

```
https://github.com/acme-startup/agent-governance-framework/actions/workflows/forge-headless.yml
```

Cada run tem: logs completos + artifact JSON com output do Claude + audit trail por consumer.

### Logs do Railway (Hermes gateway)

Acesse o [Railway dashboard](https://railway.com/project/52bafdc5-3a22-4a45-a0ce-a5db94946866) → serviço Hermes → Logs.

### Listar últimas execuções via CLI

```bash
gh run list \
  --repo acme-startup/agent-governance-framework \
  --workflow forge-headless.yml \
  --limit 10
```

---

## Troubleshooting

| Sintoma | Causa provável | Solução |
|---------|----------------|---------|
| "Not Found" no `gh workflow run` | GH_TOKEN sem scope `workflow` | Regenerar PAT com `workflow` scope |
| Consumer checkout falha | GH_TOKEN sem scope `repo` ou repo privado sem acesso | Verificar PAT + permissão do repo |
| `CONSTITUTION.md ausente` (exit 4) | Consumer não sincronizado com Forge | Rodar `forge-sync.sh` no consumer |
| Allowlist recusa (exit 2) | `caller_id` não privilegiado para comando write | Adicionar chat_id em `HERMES_PRIVILEGED_CHAT_IDS` |
| `claude: command not found` | `npm install -g @anthropic-ai/claude-code` falhou | Verificar Node.js 20 + `ANTHROPIC_API_KEY` |
| Webhook timeout | HERMES_WEBHOOK_URL inacessível do runner GH | Verificar URL pública do Railway + firewall |

---

## Evolução planejada

- **Fase 2 — Self-hosted runner Railway**: reduz cold start de ~60s para ~10s.
- **Fase 3 — Cron Hermes**: `schedule: cron(0 9 1 * *)` no workflow para audit mensal automática.
- **Fase 4 — MCP server Forge**: expõe tools via MCP para Codex consumir diretamente.
- **Fase 5 — Pipeline completo**: `diagnose → spec → plan → tasks → implement` disparado por uma mensagem Telegram com checkpoints intermediários.
