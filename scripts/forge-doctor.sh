#!/usr/bin/env bash
# Acme Forge — forge-doctor.sh
# Valida consistência do framework: JSON, paths, versões, hooks, artefatos.
# Uso: bash scripts/forge-doctor.sh
# Exit: 0 = OK, 1 = WARN, 2 = FAIL

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Acumulador via arquivo temporário — funciona mesmo em subshells e process substitution
TMP=$(mktemp 2>/dev/null || echo "/tmp/forge-doctor-$$")
trap 'rm -f "$TMP"' EXIT

pass() { printf 'P\n' >> "$TMP"; printf '  ✅  %s\n' "$1"; }
warn() { printf 'W\n' >> "$TMP"; printf '  ⚠️   %s\n' "$1"; }
fail() { printf 'F\n' >> "$TMP"; printf '  ❌  %s\n' "$1"; }
sep()  { printf '\n─── %s\n' "$1"; }

if ! command -v node >/dev/null 2>&1; then
  printf '  ❌  node.js não encontrado — necessário para todos os checks JSON\n'
  exit 2
fi

# ─── C1: JSON parse ──────────────────────────────────────────────────
sep "C1  JSON parse"
for f in docs/forge/manifest.json \
         reviewer/output-schema.json \
         reviewer/validation-rules.json \
         .claude/settings.json; do
  if node -e "JSON.parse(require('fs').readFileSync('$f','utf8'))" 2>/dev/null; then
    pass "$f"
  else
    fail "$f — JSON inválido ou inacessível"
  fi
done

# ─── C2: Paths do manifest existem no filesystem ─────────────────────
sep "C2  Paths manifest → filesystem"
while IFS= read -r line; do
  case "$line" in
    OK:*)      pass "${line#OK:}" ;;
    MISSING:*) fail "ausente: ${line#MISSING:}" ;;
  esac
done < <(node -e "
const fs=require('fs');
const m=JSON.parse(fs.readFileSync('docs/forge/manifest.json','utf8'));
const entries=[];
function collect(o){
  if(!o||typeof o!=='object')return;
  if(typeof o.path==='string') entries.push({p:o.path,k:o.path_kind||'file'});
  Object.values(o).forEach(collect);
}
collect(m.artifacts);
const missing=entries.filter(({p,k})=>{
  if(!fs.existsSync(p)) return true;
  if(k==='directory'&&!fs.statSync(p).isDirectory()) return true;
  return false;
});
if(missing.length===0) console.log('OK:'+entries.length+' paths verificados, nenhum faltando');
else missing.forEach(({p})=>console.log('MISSING:'+p));
" 2>/dev/null)

# ─── C3: Coerência de versão framework ───────────────────────────────
sep "C3  Coerência de versão (manifest / settings / README badge / CHANGELOG)"
while IFS= read -r line; do
  case "$line" in
    OK:*)   pass "${line#OK:}" ;;
    DIFF:*) fail "${line#DIFF:}" ;;
  esac
done < <(node -e "
const fs=require('fs');
const m=JSON.parse(fs.readFileSync('docs/forge/manifest.json','utf8'));
const s=JSON.parse(fs.readFileSync('.claude/settings.json','utf8'));
const readme=fs.readFileSync('README.md','utf8');
const changelog=fs.readFileSync('CHANGELOG.md','utf8');
const v=m.framework.version;
const sv=s._forge_version;
const badge=(readme.match(/version-([\d.]+)-blue/)||[])[1];
const cl=(changelog.match(/## \[([\d.]+)\]/)||[])[1];
const errs=[];
if(sv!==v) errs.push('settings._forge_version='+sv+' ≠ manifest='+v);
if(badge!==v) errs.push('README badge='+badge+' ≠ manifest='+v);
if(cl!==v) errs.push('CHANGELOG top='+cl+' ≠ manifest='+v);
if(errs.length===0) console.log('OK:'+v+' coerente em 4 fontes');
else errs.forEach(e=>console.log('DIFF:'+e));
" 2>/dev/null)

# ─── C4: Coerência de versão da Constitution ─────────────────────────
sep "C4  Coerência constitution (manifest / settings / CONSTITUTION.md)"
while IFS= read -r line; do
  case "$line" in
    OK:*)   pass "${line#OK:}" ;;
    DIFF:*) fail "${line#DIFF:}" ;;
  esac
done < <(node -e "
const fs=require('fs');
const m=JSON.parse(fs.readFileSync('docs/forge/manifest.json','utf8'));
const s=JSON.parse(fs.readFileSync('.claude/settings.json','utf8'));
const con=fs.readFileSync('.claude/CONSTITUTION.md','utf8');
const v=m.framework.constitution_version;
const sv=s._constitution_version;
const cv=(con.match(/\*\*Versão\*\*: ([\d.]+)/)||[])[1];
const errs=[];
if(sv!==v) errs.push('settings._constitution_version='+sv+' ≠ manifest='+v);
if(cv!==v) errs.push('CONSTITUTION.md header='+cv+' ≠ manifest='+v);
if(errs.length===0) console.log('OK:'+v+' coerente em 3 fontes');
else errs.forEach(e=>console.log('DIFF:'+e));
" 2>/dev/null)

# ─── C5: Sintaxe dos hooks (bash -n) ─────────────────────────────────
sep "C5  Sintaxe de hooks bash (bash -n)"
HOOK_COUNT=0
while IFS= read -r -d '' hook; do
  HOOK_COUNT=$((HOOK_COUNT+1))
  if bash -n "$hook" 2>/dev/null; then
    pass "$hook"
  else
    fail "$hook — erro de sintaxe bash"
  fi
done < <(find hooks -name '*.sh' -print0 2>/dev/null)
[[ $HOOK_COUNT -eq 0 ]] && warn "nenhum .sh encontrado em hooks/"

# ─── C6: Artefatos órfãos (filesystem sem entry no manifest) ─────────
sep "C6  Artefatos órfãos (filesystem → manifest)"
while IFS= read -r line; do
  case "$line" in
    OK:*)     pass "${line#OK:}" ;;
    ORPHAN:*) warn "sem entry no manifest: ${line#ORPHAN:}" ;;
  esac
done < <(node -e "
const fs=require('fs');
const m=JSON.parse(fs.readFileSync('docs/forge/manifest.json','utf8'));
const manifPaths=new Set();
function collect(o){
  if(!o||typeof o!=='object')return;
  if(typeof o.path==='string') manifPaths.add(o.path);
  Object.values(o).forEach(collect);
}
collect(m.artifacts);
const scopes=[
  {dir:'.claude/skills', ext:'.md'},
  {dir:'.claude/agents', ext:'.md'},
  {dir:'.claude/commands/acme',ext:'.md'},
  {dir:'templates', ext:'.md'},
  {dir:'hooks', ext:'.sh'},
  {dir:'scripts', ext:'.sh'},
];
const orphans=[];
function walk(d,ext){
  if(!fs.existsSync(d)) return;
  fs.readdirSync(d).forEach(f=>{
    const fp=d+'/'+f;
    if(fs.statSync(fp).isDirectory()){walk(fp,ext);return;}
    if(fp.endsWith(ext)&&!manifPaths.has(fp)) orphans.push(fp);
  });
}
scopes.forEach(({dir,ext})=>walk(dir,ext));
if(orphans.length===0) console.log('OK:nenhum artefato órfão nos escopos verificados');
else orphans.forEach(o=>console.log('ORPHAN:'+o));
" 2>/dev/null)

# ─── C7: Permissions sanity ──────────────────────────────────────────
sep "C7  Permissions sanity (.claude/settings.json)"
while IFS= read -r line; do
  case "$line" in
    OK:*)    pass "${line#OK:}" ;;
    ISSUE:*) warn "${line#ISSUE:}" ;;
  esac
done < <(node -e "
const s=JSON.parse(require('fs').readFileSync('.claude/settings.json','utf8'));
const issues=[];
['allow','deny'].forEach(k=>{
  const arr=(s.permissions&&s.permissions[k])||[];
  const seen=new Set();
  arr.forEach((v,i)=>{
    if(!v||!v.trim()) issues.push('permissions.'+k+'['+i+'] está vazio');
    if(seen.has(v)) issues.push('permissions.'+k+': duplicata \"'+v+'\"');
    seen.add(v);
  });
});
const na=(s.permissions&&s.permissions.allow||[]).length;
const nd=(s.permissions&&s.permissions.deny||[]).length;
if(issues.length===0) console.log('OK:allow='+na+' deny='+nd+' entradas, sem duplicatas ou vazios');
else issues.forEach(i=>console.log('ISSUE:'+i));
" 2>/dev/null)

# ─── Sumário ─────────────────────────────────────────────────────────
PASS_N=$(grep -c '^P$' "$TMP" 2>/dev/null) || PASS_N=0
WARN_N=$(grep -c '^W$' "$TMP" 2>/dev/null) || WARN_N=0
FAIL_N=$(grep -c '^F$' "$TMP" 2>/dev/null) || FAIL_N=0

printf '\n════════════════════════════════════════════\n'
printf '  Forge Doctor — resultado\n'
printf '  ✅  %s OK   ⚠️   %s WARN   ❌  %s FAIL\n' "$PASS_N" "$WARN_N" "$FAIL_N"
printf '════════════════════════════════════════════\n\n'

if [[ "$FAIL_N" -gt 0 ]]; then
  exit 2
elif [[ "$WARN_N" -gt 0 ]]; then
  exit 1
else
  exit 0
fi
