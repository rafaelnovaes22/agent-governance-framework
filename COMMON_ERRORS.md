# 🚨 Erros Comuns no Forge — Top 10 + Soluções

> Os 10 erros mais frequentes ao usar o agent-governance-framework, com **causa-raiz**, **diagnóstico**, **solução copy-paste** e **como prevenir**. Otimizado para scanning.

---

## Como usar este documento

1. **Encontre seu erro** pelo título ou pela mensagem literal
2. **Leia a causa-raiz** para entender o porquê
3. **Aplique a solução** (copia-cola)
4. **Implemente a prevenção** para não repetir

Se seu erro **não está aqui**: rode `bash scripts/forge doctor` para diagnóstico completo + abra issue no repo.

---

## 1️⃣ `forge-doctor` falha em **C2 (path missing)`

### Mensagem típica
```
─── C2  Paths manifest → filesystem
  ❌  manifest aponta para: templates/master-prompt.md (NOT FOUND)
```

### Causa-raiz
Você adicionou entrada em `manifest.json` mas o arquivo físico **não existe**, OU removeu o arquivo mas esqueceu de atualizar manifest.

### Diagnóstico
```bash
# Veja TODOS os paths declarados no manifest
node -e "const m=require('./docs/forge/manifest.json'); JSON.stringify(m,null,2).split('\n').filter(l=>l.includes('\"path\"')).forEach(l=>console.log(l))"

# Para cada path, verifique se existe
ls -la <path>
```

### Solução
**Caso A — arquivo foi deletado intencionalmente:**
```bash
# Remova a entrada do manifest
# Edite docs/forge/manifest.json e delete o bloco { "id": "...", "path": "<path>", ... }
```

**Caso B — arquivo deveria existir:**
```bash
# Crie o arquivo conforme template
# Ou git restore se foi removido por engano:
git restore <path>
```

### Prevenção
- Sempre que mover/renomear arquivo, **atualize manifest na mesma commit**
- Rode `bash scripts/forge doctor` **antes de commit** (não depois)

---

## 2️⃣ `forge-doctor` falha em **C3 (version mismatch)`

### Mensagem típica
```
─── C3  Coerência de versão
  ❌  manifest.framework.version=0.11.0
  ❌  settings._forge_version=0.10.0  (divergente!)
  ❌  README badge=0.10.0  (divergente!)
```

### Causa-raiz
Você fez bump de versão em **um arquivo** mas esqueceu de atualizar nos outros 3 lugares onde a versão aparece.

### Diagnóstico
```bash
grep -nE "0\.[0-9]+\.[0-9]+" docs/forge/manifest.json .claude/settings.json README.md CHANGELOG.md | head -20
```

### Solução
**Atualize todos os 4 lugares para a mesma versão:**

```bash
# 1. docs/forge/manifest.json
# Mude: "manifest_version" + "framework.version" (2 ocorrências)

# 2. .claude/settings.json
# Mude: "_forge_version"

# 3. README.md
# Mude badge: [![Version](https://img.shields.io/badge/version-X.Y.Z-blue)](./CHANGELOG.md)

# 4. CHANGELOG.md
# Adicione entrada [X.Y.Z] no topo (acima da entrada anterior)
```

### Prevenção
- Use script `bash scripts/forge version` para verificar sincronização
- Considere automatizar com Husky hook ou pre-commit

---

## 3️⃣ `forge-doctor` warning **C6 (artefato órfão)`

### Mensagem típica
```
─── C6  Artefatos órfãos (filesystem → manifest)
  ⚠️   sem entry no manifest: templates/novo-template.md
```

### Causa-raiz
Você criou arquivo em pasta versionada (`templates/`, `.claude/skills/`, etc.) mas não adicionou entrada em `manifest.json`.

### Diagnóstico
O próprio output do forge-doctor já indica qual arquivo.

### Solução
```bash
# Calcule o hash sha256 (primeiros 16 chars)
sha256sum templates/novo-template.md | cut -c1-16
# Exemplo de output: a1b2c3d4e5f67890

# Adicione no manifest.json em artifacts.templates[]:
```

```json
{
  "id": "template-novo-template",
  "path": "templates/novo-template.md",
  "type": "template",
  "version": "1.0.0",
  "sha256": "a1b2c3d4e5f67890",
  "linked_principles": ["C5"],
  "description": "Descrição curta do que esse template faz"
}
```

### Prevenção
- Sempre adicione entrada no manifest **na mesma commit** que cria o arquivo
- Rode `bash scripts/forge doctor` antes de push

---

## 4️⃣ Hook `outcome-clause-guard` bloqueia spec

### Mensagem típica
```
❌ Hook outcome-clause-guard rejected the edit:
Spec must contain a non-empty "## Outcome contratual" section with 3+/- examples.
```

### Causa-raiz
Você está criando ou editando uma spec **sem outcome contratual claro** (viola C2).

### Diagnóstico
Verifique se a spec tem a seção:
```bash
grep -A 10 "## Outcome contratual" docs/forge/sku/<id>/spec.md
```

Deve ter:
- ✅ 1 outcome positivo verificável
- ❌ Pelo menos 2 outcomes negativos (o que NÃO conta)

### Solução
Adicione na spec:

```markdown
## Outcome contratual (C2)

**Promessa:** [verbo no infinitivo] + [objeto] + [critério verificável].

**Exemplos:**
- ✅ Positivo: [exemplo concreto do que CONTA como sucesso]
- ❌ Negativo: [exemplo do que NÃO conta como sucesso]
- ❌ Negativo: [outro exemplo do que NÃO conta]
```

### Prevenção
- Use o template `platform-sku-spec.template.md` (já tem seção pré-pronta)
- Pergunte sempre: "como o cliente vai medir se eu cumpri?"

---

## 5️⃣ Hook `adr-approval-gate` bloqueia edição

### Mensagem típica
```
❌ Hook adr-approval-gate rejected the edit:
This change appears to modify architecture (new module/abstraction).
Create an ADR first in docs/forge/decisions.md (Fxx).
```

### Causa-raiz
Você está fazendo uma mudança arquitetural (novo módulo, nova abstração, nova dependência) sem documentar em ADR (viola C5).

### Diagnóstico
A mudança envolve algum destes?
- Nova pasta em `src/modules/` ou `lib/`
- Novo arquivo `*.adapter.ts` ou similar
- Nova dependência em `package.json`
- Mudança em `schema.prisma`

Se sim → precisa ADR.

### Solução
1. Crie ADR no fim de `docs/forge/decisions.md` (próximo número Fxx)
2. Use template:

```markdown
## F<próximo número> (NOVO YYYY-MM-DD) — [Título da decisão]

**Status:** ✅ Aceito YYYY-MM-DD

**Contexto:** [Por que essa decisão é necessária]

**Decisão:** [O que decidimos fazer]

**Consequências:**
- ✅ [Consequência positiva 1]
- ⚠️ [Trade-off aceito]
- ❌ [Consequência negativa contornada]
```

3. Re-tente a edição.

### Prevenção
- ADR ANTES de codar mudança arquitetural — não depois

---

## 6️⃣ Hook `secret-scan` bloqueia commit

### Mensagem típica
```
❌ Hook secret-scan blocked the commit:
Found pattern matching secret in file:
- .env: line 3 (DATABASE_URL=postgres://...)
- src/config.ts: line 12 (API_KEY = "sk-...")
```

### Causa-raiz
Você tem **secrets hardcoded** ou está tentando committar arquivo `.env`.

### Diagnóstico
```bash
git diff --staged | grep -iE "(api_key|secret|password|token|sk-|AKIA)"
```

### Solução
**Caso A — `.env` foi staged por engano:**
```bash
git restore --staged .env
echo ".env" >> .gitignore
```

**Caso B — secret hardcoded em código:**
```typescript
// Antes (ERRADO):
const API_KEY = "sk-abc123...";

// Depois (correto):
const API_KEY = process.env.ANTHROPIC_API_KEY;
if (!API_KEY) throw new Error("Missing ANTHROPIC_API_KEY env var");
```

### Prevenção
- Use `.env.example` (sem valores reais) para documentar variáveis necessárias
- Configure pre-commit hook local também
- **NUNCA** use `git add .` em pastas onde `.env` está

---

## 7️⃣ `@po-guardian` rejeita spec

### Mensagem típica
```
@po-guardian review:
❌ REJECTED — outcome is vague or ICP fit unclear.

Issues:
1. "ajudar empresas a vender mais" is not contractually verifiable
2. Target ICP not defined (B2B? B2C? size? industry?)
3. No positive/negative examples
```

### Causa-raiz
Outcome contratual está **vago demais** — não dá pra medir se foi cumprido.

### Solução
**Reescreva o outcome em UMA frase mensurável:**

| ❌ Vago (rejeitado) | ✅ Específico (aceito) |
|---------------------|----------------------|
| "Ajudar empresas a vender mais" | "Aumentar conversão de landing pages em 20%+ em 30 dias para SaaS B2B com >R$100k MRR" |
| "Análise inteligente de dados" | "Gerar relatório narrativo (3 parágrafos) sobre demonstrativo financeiro mensal em < 10s" |
| "Atendimento 24/7" | "Responder DM Instagram em < 30s, qualificar como lead se contém budget>5k + timeline<3meses" |

**Sempre inclua:**
1. **Verbo** mensurável ("gerar", "entregar", "reduzir")
2. **Métrica** quantitativa ("em ≤ 30s", "20%+ de melhoria")
3. **ICP** específico ("SaaS B2B", "PMEs LTDA tributação Simples")

### Prevenção
- Antes de invocar po-guardian, faça você mesmo o teste: "como eu mediria se cumpri?"

---

## 8️⃣ `@unit-economist` falha **C3**

### Mensagem típica
```
@unit-economist review:
❌ C3 VIOLATION — cost per outcome exceeds 25% of price.

Calculation:
- Price per outcome: R$ 12.00
- Cost per outcome: R$ 4.50 (37.5%) ← VIOLATION
  - Claude tokens: R$ 1.20
  - Imagen 4 (7 slides): R$ 2.80
  - Infra: R$ 0.50
- Acceptable max (25%): R$ 3.00
```

### Causa-raiz
O custo de produzir o outcome **excede 25% do preço de venda** — margem insuficiente.

### Soluções (3 opções)

**Opção A — Reduzir custo:**
```markdown
ADR-XXX: Reduzir slides default de 7 para 4-5
Custo recalculado:
- Imagen 4 (4 slides): R$ 1.60 (-R$ 1.20)
- Total: R$ 3.30 ≈ 27.5% (ainda viola, ajustar mais)
```

**Opção B — Aumentar preço:**
```markdown
ADR-XXX: Reposicionar carrossel como "premium"
Preço novo: R$ 18 (de R$ 12)
Custo % = R$ 4.50 / R$ 18 = 25% ✅
```

**Opção C — Combinar A + B:**
Reduzir slides para 5 + preço para R$ 15.

### Prevenção
- Calcule unit-economics ANTES da spec — força realismo
- Use spreadsheet com várias hipóteses de pricing × custo

---

## 9️⃣ Hash sha256 incorreto no manifest

### Mensagem típica
```
─── C2  Paths manifest → filesystem
  ⚠️  hash mismatch para templates/foo.md
     manifest:   a1b2c3d4e5f67890
     filesystem: f0e9d8c7b6a54321
```

### Causa-raiz
Você editou o arquivo mas esqueceu de **atualizar o hash** no manifest. Comum quando:
- Linha foi alterada (mesmo 1 espaço)
- Encoding mudou (CRLF vs LF)
- File foi tocado por outro programa

### Diagnóstico
```bash
# Hash atual real
sha256sum <path> | cut -c1-16

# Hash declarado no manifest
grep -A 5 '"<path>"' docs/forge/manifest.json | grep sha256
```

### Solução
```bash
# 1. Pegue o hash novo
NEW_HASH=$(sha256sum templates/foo.md | cut -c1-16)
echo "Novo hash: $NEW_HASH"

# 2. Edite manifest.json
# Mude "sha256": "<antigo>" para "sha256": "<NEW_HASH>"
```

### Prevenção
- Configure editor para usar LF (não CRLF) — `.editorconfig`
- Considere automatizar hash com script `update-manifest-hashes.sh`

---

## 🔟 TDD red phase missing (Forge-10)

### Mensagem típica
```
❌ Gate G6 (tdd-red-phase-check) failed:

Module 'carrossel-agent' was modified in this PR, but:
- tests/carrossel-agent/unit/ is empty or missing
- No evidence of RED phase (tests written before code)
```

### Causa-raiz
Você modificou código em `src/modules/<nome>/` MAS **não criou testes em `tests/<nome>/unit/` primeiro** — viola pipeline TDD-first do Forge-10.

### Solução

**1. Rode test_agent em mode=red ANTES de editar código:**

```bash
/acme:aios-run carrossel-agent --step=test --mode=red
```

Isso gera arquivos físicos em:
- `tests/carrossel-agent/unit/` (≥ 1 arquivo)
- `tests/carrossel-agent/integration/` (se Tier B/C)
- `tests/carrossel-agent/e2e/` (se has_ui=true e Tier C)

**2. Rode os testes localmente — eles DEVEM FALHAR:**

```bash
npm test -- carrossel-agent
# Esperado: tests fail (porque código ainda não existe)
```

**3. Confirme RED phase humanamente:**

```bash
# Crie arquivo de evidência
echo "RED phase confirmed at $(date)" > tests/carrossel-agent/_red-evidence.txt
```

**4. AGORA implemente o código** que faz os testes passarem.

### Prevenção
- Use sempre o pipeline `/acme:aios-run` (não pule etapas)
- Pense em "qual teste deveria existir?" antes de "qual código preciso escrever?"

---

## 🆘 Erro não está aqui?

### Passo 1 — Diagnóstico completo
```bash
bash scripts/forge doctor
```

### Passo 2 — Procure no glossário
[`GLOSSARY.md`](./GLOSSARY.md) — termos técnicos com explicação

### Passo 3 — Procure no roadmap
[`docs/forge/roadmap.md`](./docs/forge/roadmap.md) — pode ser pendência conhecida

### Passo 4 — Abra issue
```
https://github.com/acme-startup/agent-governance-framework/issues/new
```

Inclua:
- Output completo do `forge-doctor`
- Comando que disparou o erro
- Conteúdo do `manifest.json` (sem secrets!)
- Versão do Forge (`bash scripts/forge version`)

---

## 💡 Padrão Geral de Erros do Forge

A maioria dos erros segue 1 dos 3 padrões:

1. **Estrutura quebrada** (manifest desatualizado, hash divergente, path missing)
   → Solução: `bash scripts/forge doctor` indica + ajuste manual

2. **Governança violada** (outcome vago, C3 acima de 25%, ADR ausente)
   → Solução: voltar 1 passo, fazer direito antes de seguir

3. **Pipeline TDD violado** (código antes de teste, eval-suite vazia)
   → Solução: usar `/acme:aios-run` em vez de pular etapas

**Quando em dúvida:** o Forge é **rigoroso por design**. Não há atalho — só caminho.
