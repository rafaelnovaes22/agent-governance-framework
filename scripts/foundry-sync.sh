#!/usr/bin/env bash
# Novais Digital Foundry — foundry-sync.sh
# Sincroniza artefatos canônicos do Foundry para um projeto consumidor.
# Uso: bash scripts/foundry-sync.sh [--from <path>] [--dry-run] [--force]
# Exit: 0 = OK, 1 = WARN (drift sem --force), 2 = FAIL
#
# Por padrão, --from é detectado automaticamente:
#   - Se este script roda DENTRO do repo Foundry canônico (manifest.framework.canonical=true),
#     o cwd vira o destino e --from precisa ser passado explicitamente.
#   - Se cwd é um consumer (sem manifest.framework.canonical), --from busca
#     ../agent-governance-framework/ adjacente, depois $FOUNDRY_PATH env, depois falha pedindo --from.
#
# O que sincroniza:
#   - .claude/CONSTITUTION.md
#   - .claude/{agents,commands,skills}/**
#   - hooks/**
#   - scripts/foundry-doctor.sh, scripts/foundry
#   - templates/**
#   - reviewer/{prompt.template.md,output-schema.json,validation-rules.json,example-audit.md,README.md}
#   - reviewer/deepagents/skills/**
#
# O que NUNCA sincroniza (consumer-owned):
#   - .claude/settings.json, .claude/settings.local.json
#   - docs/foundry/manifest.json (consumer mantém o seu — apenas atualiza framework_version_required)
#   - docs/foundry/project.json
#   - docs/clients/, docs/specs/, docs/adr/, docs/audits/, docs/modules/
#   - src/, prompts/, evals/, subscriptions/, tests/, prisma/
#   - CLAUDE.md raiz
#
# Princípios: C7 (portabilidade — sync por valor, não por symlink), C8 (sem hardcode de cliente)

set -euo pipefail

# ─── Parsing ─────────────────────────────────────────────────────────
FROM=""
DRY_RUN="false"
FORCE="false"
VERBOSE="false"
for arg in "$@"; do
  case "$arg" in
    --from=*)   FROM="${arg#--from=}" ;;
    --from)     shift ;;
    --dry-run)  DRY_RUN="true" ;;
    --force)    FORCE="true" ;;
    --verbose|-v) VERBOSE="true" ;;
    --help|-h)
      grep -E '^# ' "$0" | sed 's/^# //'
      exit 0
      ;;
  esac
done
# Suporte a --from <path> (espaço em vez de =)
i=1
while [[ $i -le $# ]]; do
  if [[ "${!i:-}" == "--from" ]]; then
    next=$((i+1))
    FROM="${!next:-}"
  fi
  i=$((i+1))
done

CONSUMER_ROOT="$(pwd)"

# ─── Path helper: Git Bash → Node-friendly ───────────────────────────
# Node on Windows não entende paths /c/... do Git Bash. Converte para C:/...
to_node_path() {
  local p="$1"
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -m "$p" 2>/dev/null || echo "$p"
  else
    echo "$p"
  fi
}

# ─── Detecção: cwd é canônico ou consumer? ───────────────────────────
is_canonical() {
  local m_input="${1:-docs/foundry/manifest.json}"
  [[ -f "$m_input" ]] || return 1
  local m
  m="$(to_node_path "$m_input")"
  node -e "
    const m=JSON.parse(require('fs').readFileSync('$m','utf8'));
    process.exit(m.framework && m.framework.canonical===true ? 0 : 1);
  " 2>/dev/null
}

if is_canonical "$CONSUMER_ROOT/docs/foundry/manifest.json"; then
  echo "❌ foundry-sync.sh é para projetos consumidores, não para o repo canônico."
  echo "   Você está dentro do Foundry canônico (manifest.framework.canonical=true)."
  echo "   Para distribuir mudanças, vá ao consumidor e rode lá apontando --from para este path."
  exit 2
fi

# ─── Resolver FROM (fonte canônica) ──────────────────────────────────
if [[ -z "$FROM" ]]; then
  # Tenta $FOUNDRY_PATH env
  if [[ -n "${FOUNDRY_PATH:-}" ]] && [[ -f "$FOUNDRY_PATH/docs/foundry/manifest.json" ]]; then
    FROM="$FOUNDRY_PATH"
  # Tenta diretório adjacente comum
  elif [[ -f "../agent-governance-framework/docs/foundry/manifest.json" ]]; then
    FROM="../agent-governance-framework"
  elif [[ -f "$HOME/Projetos/agent-governance-framework/docs/foundry/manifest.json" ]]; then
    FROM="$HOME/Projetos/agent-governance-framework"
  else
    echo "❌ Não consegui resolver fonte canônica do Foundry."
    echo "   Passe --from <path/para/agent-governance-framework> ou defina FOUNDRY_PATH."
    exit 2
  fi
fi

# Normalizar path
FROM="$(cd "$FROM" && pwd)"

# Validar que FROM é o repo canônico
if ! is_canonical "$FROM/docs/foundry/manifest.json"; then
  echo "❌ $FROM não é o repo canônico do Foundry (manifest.framework.canonical != true)."
  exit 2
fi

# ─── Versão canônica e consumer ──────────────────────────────────────
FROM_NODE_MANIFEST="$(to_node_path "$FROM/docs/foundry/manifest.json")"
CANONICAL_VERSION=$(node -e "console.log(JSON.parse(require('fs').readFileSync('$FROM_NODE_MANIFEST','utf8')).framework.version)")
CONSUMER_VERSION=""
CONSUMER_REQUIRED=""
if [[ -f "$CONSUMER_ROOT/docs/foundry/manifest.json" ]]; then
  CONSUMER_NODE_MANIFEST="$(to_node_path "$CONSUMER_ROOT/docs/foundry/manifest.json")"
  CONSUMER_VERSION=$(node -e "
    const m=JSON.parse(require('fs').readFileSync('$CONSUMER_NODE_MANIFEST','utf8'));
    console.log(m.framework && m.framework.version || 'unknown');
  ")
  CONSUMER_REQUIRED=$(node -e "
    const m=JSON.parse(require('fs').readFileSync('$CONSUMER_NODE_MANIFEST','utf8'));
    console.log(m.framework && m.framework.version_required || m.framework && m.framework.framework_version_required || '');
  " 2>/dev/null || echo "")
fi

# ─── Banner ──────────────────────────────────────────────────────────
mode_label="LIVE sync"
[[ "$DRY_RUN" == "true" ]] && mode_label="DRY-RUN (nada será escrito)"
printf '\n┌─ foundry-sync ────────────────────────────────────\n'
printf '│ De  : %s\n' "$FROM"
printf '│ Para: %s\n' "$CONSUMER_ROOT"
printf '│ Versão canônica : %s\n' "$CANONICAL_VERSION"
printf '│ Versão consumer : %s\n' "${CONSUMER_VERSION:-(não encontrada)}"
printf '│ Modo: %s\n' "$mode_label"
printf '└──────────────────────────────────────────────────\n\n'

# ─── Listagem canônica de paths sincronizáveis ───────────────────────
# Mantida explícita aqui (e validada contra o manifest canônico) para
# evitar que mudanças no manifest do consumer alterem o escopo de sync.
SYNC_PATHS=(
  ".claude/CONSTITUTION.md"
  ".claude/agents"
  ".claude/commands"
  ".claude/skills"
  "hooks"
  "scripts/foundry-doctor.sh"
  "scripts/foundry"
  "templates"
  "reviewer/prompt.template.md"
  "reviewer/output-schema.json"
  "reviewer/validation-rules.json"
  "reviewer/example-audit.md"
  "reviewer/README.md"
  "reviewer/deepagents"
)

# Paths que devem ser preservados se já existirem no consumer (NUNCA sobrescrever)
PRESERVE_PATHS=(
  ".claude/settings.json"
  ".claude/settings.local.json"
  "docs/foundry/manifest.json"
  "docs/foundry/project.json"
  "CLAUDE.md"
)

# ─── Sync ────────────────────────────────────────────────────────────
N_ADD=0
N_UPDATE=0
N_UNCHANGED=0
N_SKIPPED=0
N_PRESERVED=0

copy_path() {
  local rel="$1"
  local src="$FROM/$rel"
  local dst="$CONSUMER_ROOT/$rel"

  if [[ ! -e "$src" ]]; then
    [[ "$VERBOSE" == "true" ]] && echo "  ⏭️   skip (fonte ausente): $rel"
    N_SKIPPED=$((N_SKIPPED+1))
    return
  fi

  # Diretório
  if [[ -d "$src" ]]; then
    # Garante destino existe
    if [[ "$DRY_RUN" == "false" ]]; then
      mkdir -p "$dst"
    fi
    # Recursão por arquivos (relativos a $src)
    while IFS= read -r -d '' file; do
      local sub_rel="${file#$src/}"
      copy_file_relative "$rel/$sub_rel" "$src/$sub_rel" "$dst/$sub_rel"
    done < <(find "$src" -type f -print0)
    return
  fi

  # Arquivo único
  copy_file_relative "$rel" "$src" "$dst"
}

copy_file_relative() {
  local rel="$1"
  local src="$2"
  local dst="$3"

  # Preservation guard — mesmo se incluído em SYNC_PATHS por engano
  for p in "${PRESERVE_PATHS[@]}"; do
    if [[ "$rel" == "$p" ]]; then
      [[ "$VERBOSE" == "true" ]] && echo "  🔒  preserve: $rel"
      N_PRESERVED=$((N_PRESERVED+1))
      return
    fi
  done

  if [[ ! -f "$dst" ]]; then
    echo "  ➕  ADD     $rel"
    if [[ "$DRY_RUN" == "false" ]]; then
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
    fi
    N_ADD=$((N_ADD+1))
    return
  fi

  if cmp -s "$src" "$dst"; then
    [[ "$VERBOSE" == "true" ]] && echo "  ✓   unchanged: $rel"
    N_UNCHANGED=$((N_UNCHANGED+1))
    return
  fi

  echo "  🔄  UPDATE  $rel"
  if [[ "$DRY_RUN" == "false" ]]; then
    cp "$src" "$dst"
  fi
  N_UPDATE=$((N_UPDATE+1))
}

echo "─── Sincronizando artefatos canônicos ───"
for path in "${SYNC_PATHS[@]}"; do
  copy_path "$path"
done

# ─── Atualizar framework_version_required no manifest do consumer ────
if [[ -f "$CONSUMER_ROOT/docs/foundry/manifest.json" ]] && [[ "$DRY_RUN" == "false" ]]; then
  echo ""
  echo "─── Atualizando manifest do consumer ───"
  CONSUMER_NODE_MANIFEST="$(to_node_path "$CONSUMER_ROOT/docs/foundry/manifest.json")"
  node -e "
    const fs=require('fs');
    const p='$CONSUMER_NODE_MANIFEST';
    const m=JSON.parse(fs.readFileSync(p,'utf8'));
    m.framework = m.framework || {};
    const prev = m.framework.framework_version_required || m.framework.version_required;
    m.framework.framework_version_required = '$CANONICAL_VERSION';
    m.framework.last_synced_at = new Date().toISOString().slice(0,10);
    fs.writeFileSync(p, JSON.stringify(m, null, 2) + '\n');
    console.log('  ✓ framework.framework_version_required:', prev||'(absent)', '→', '$CANONICAL_VERSION');
    console.log('  ✓ framework.last_synced_at:', m.framework.last_synced_at);
  "
fi

# ─── Audit trail ─────────────────────────────────────────────────────
if [[ "$DRY_RUN" == "false" ]]; then
  mkdir -p "$CONSUMER_ROOT/docs/foundry"
  HIST="$CONSUMER_ROOT/docs/foundry/sync-history.md"
  if [[ ! -f "$HIST" ]]; then
    cat > "$HIST" <<HEAD
# Foundry Sync — Histórico

Toda execução de \`scripts/foundry-sync.sh\` registra uma entrada aqui.
Útil para auditar drift e correlacionar mudanças de comportamento com upgrades do framework.

| Data       | De (versão canônica) | Para (versão anterior do consumer) | ADD | UPDATE | UNCHANGED | SKIPPED |
|------------|----------------------|------------------------------------|-----|--------|-----------|---------|
HEAD
  fi
  printf '| %s | %s | %s | %d | %d | %d | %d |\n' \
    "$(date -u +%Y-%m-%d)" \
    "$CANONICAL_VERSION" \
    "${CONSUMER_VERSION:-unknown}" \
    "$N_ADD" "$N_UPDATE" "$N_UNCHANGED" "$N_SKIPPED" \
    >> "$HIST"
fi

# ─── Sumário ─────────────────────────────────────────────────────────
printf '\n════════════════════════════════════════════\n'
printf '  foundry-sync — resultado\n'
printf '  ➕  %d ADD   🔄  %d UPDATE   ✓ %d unchanged\n' "$N_ADD" "$N_UPDATE" "$N_UNCHANGED"
printf '  🔒  %d preserved   ⏭️   %d skipped\n' "$N_PRESERVED" "$N_SKIPPED"
printf '════════════════════════════════════════════\n'

if [[ "$DRY_RUN" == "true" ]]; then
  printf '\n⚠️  Dry-run: nenhum arquivo foi escrito. Rode sem --dry-run para aplicar.\n\n'
  exit 0
fi

# Drift check pós-sync
if [[ "$N_UPDATE" -gt 0 ]] && [[ "$FORCE" != "true" ]]; then
  printf '\n💡 %d arquivo(s) atualizado(s). Revise as mudanças antes de commitar:\n' "$N_UPDATE"
  printf '   git -C "%s" diff\n\n' "$CONSUMER_ROOT"
fi

printf '\nPróximos passos:\n'
printf '  1. bash scripts/foundry-doctor.sh --consumer    # validar consumer\n'
printf '  2. git -C "%s" diff                           # revisar mudanças\n' "$CONSUMER_ROOT"
printf '  3. git -C "%s" commit -am "chore(foundry): sync v%s"\n\n' "$CONSUMER_ROOT" "$CANONICAL_VERSION"

exit 0
