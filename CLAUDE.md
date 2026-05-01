# agent-governance-framework — Guia para Claude Code

> Este é o **repositório do framework Acme Forge**.
> Trabalho aqui é **EVOLUIR o framework**, não operar a Acme.

---

## Contexto: você está no repo errado para...

- ❌ Implementar SKUs SaaS² da Acme → use `acme-governanca-ia`
- ❌ Operar pipeline de outcomes → use `acme-governanca-ia`
- ❌ Editar metodologia Acme SaaS² → editar nos `metodologia*.md` de `acme-governanca-ia`

Você está no lugar certo para...

- ✅ Adicionar/refinar princípios da Constitution (exige ADR)
- ✅ Criar skills L0/L1/L2 (Forge-1)
- ✅ Criar slash commands (Forge-2)
- ✅ Criar subagents Guardian (Forge-3)
- ✅ Criar hooks runtime (Forge-4)
- ✅ Atualizar templates fundamentais
- ✅ Implementar reviewer DeepAgents/GPT-5.5

---

## Antes de qualquer coisa: leia a Constitution

[`.claude/CONSTITUTION.md`](./.claude/CONSTITUTION.md)

Os 8 princípios C1–C8 são **não-negociáveis** e orientam todo desenvolvimento do framework. Mudança em qualquer princípio exige:

1. ADR justificando (em projeto consumidor — neste repo, registrar em `docs/forge/decisions.md`)
2. Bump MAJOR de versão
3. Atualização do `manifest.json`
4. Comunicação ao reviewer DeepAgents (atualizar prompt)
5. Entrada no `CHANGELOG.md`

---

## Documentos canônicos

- [`README.md`](./README.md) — Overview e onboarding
- [`INSTALL.md`](./INSTALL.md) — Como instalar em projeto consumidor
- [`CHANGELOG.md`](./CHANGELOG.md) — Histórico de versões
- [`docs/forge/README.md`](./docs/forge/README.md) — Overview interno
- [`docs/forge/decisions.md`](./docs/forge/decisions.md) — Decisões F1-F12
- [`docs/forge/roadmap.md`](./docs/forge/roadmap.md) — 5 ondas
- [`docs/forge/reviewer-contract.md`](./docs/forge/reviewer-contract.md) — Contrato do reviewer
- [`docs/forge/manifest.json`](./docs/forge/manifest.json) — Inventory
- [`docs/forge/out-of-scope.md`](./docs/forge/out-of-scope.md) — O que NÃO entra

---

## Convenções do framework

### Naming

- Slash commands: `/acme:{verbo}` (ex: `/acme:diagnose`)
- Skills: kebab-case com tier no path (`.claude/skills/L1/diagnostic-runner.md`)
- Agents/Guardians: kebab-case (`po-guardian.md`, `sku-architect.md`)
- Hooks IDs: kebab-case (`outcome-clause-guard`, `manifest-sync`)
- Templates: `{name}.template.md` em `templates/`

### Versionamento (SemVer)

- **MAJOR** — quebra Constitution
- **MINOR** — onda Forge concluída
- **PATCH** — correções sem mudar contrato

Versão atual está em `docs/forge/manifest.json` → `framework.version` e refletida em `CHANGELOG.md`.

### Manifest

Toda adição/remoção de artefato deve atualizar `docs/forge/manifest.json`:

- Novo arquivo → adicionar entrada com `path`, `type`, `version`, `sha256`, `description`, `linked_principles`
- Hash: `sha256sum <arquivo> | cut -c1-16` (primeiros 16 hex)
- Arquivos com line endings inconsistentes (Windows CRLF) podem ter hash diferente — normalizar para LF antes de hash final

### Estrutura simétrica com consumidor

Repo segue **estrutura simétrica** ao projeto consumidor:

```
agent-governance-framework/                    projeto-consumidor/
├── .claude/                     ├── .claude/
│   ├── CONSTITUTION.md          │   ├── CONSTITUTION.md  (cópia canônica)
│   └── settings.json            │   ├── settings.json    (cópia canônica)
│                                │   └── settings.local.json (NÃO toca - dev override)
├── templates/                   ├── templates/           (cópia canônica)
├── docs/forge/                  ├── docs/forge/          (cópia canônica)
└── CLAUDE.md.template           └── CLAUDE.md            (adaptado do template)
```

Isso facilita sync (`cp -r`) entre origem canônica e cópias nos projetos consumidores.

---

## Como adicionar um novo componente

### Adicionar nova skill (Forge-1)

1. Criar `.claude/skills/L{0|1|2}/{nome}.md` com frontmatter padrão
2. Adicionar entrada em `manifest.json` → `artifacts.skills.L{tier}`
3. Atualizar `roadmap.md` marcando task como concluída
4. Bump PATCH e atualizar `CHANGELOG.md`

### Adicionar novo slash command (Forge-2)

1. Criar `.claude/commands/acme/{verbo}.md` com:
   - Frontmatter (description, allowed-tools)
   - Verification gate explícito
   - Output structured
2. Adicionar entrada em `manifest.json` → `artifacts.commands`
3. Atualizar `roadmap.md` + `CHANGELOG.md`

### Adicionar novo subagent Guardian (Forge-3)

1. Criar `.claude/agents/{nome}.md` com:
   - Frontmatter (model, description, tools)
   - Persona e responsabilidades
   - Smart routing declarado (Opus/Sonnet/Haiku)
2. Adicionar entrada em `manifest.json` → `artifacts.agents`
3. Atualizar `roadmap.md` + `CHANGELOG.md`

### Adicionar novo hook (Forge-4)

1. Editar `.claude/settings.json` → `hooks.{PreToolUse|PostToolUse|Stop}`
2. Adicionar implementação (script bash/node) — local TBD em ADR-002+
3. Adicionar entrada em `manifest.json` → `artifacts.hooks`
4. Atualizar `roadmap.md` + `CHANGELOG.md`

### Mudar Constitution (raro!)

1. Abrir issue propondo mudança com justificativa
2. Atualizar `decisions.md` registrando histórico
3. Bump MAJOR de versão
4. Atualizar `manifest.json` → `framework.constitution_version`
5. Atualizar `CHANGELOG.md` com seção `### Breaking Changes`
6. Atualizar prompt do reviewer (DeepAgents)

---

## Reviewer interno (durante desenvolvimento do framework)

Enquanto o reviewer DeepAgents/GPT-5.5 não está implementado (chega em Forge-3), use o próprio Claude Code como reviewer interno:

- PR pequeno (≤ 5 arquivos por mudança)
- Auto-review com `/review` antes de pedir review humano
- Validar `manifest.json` parse JSON: `node -e "JSON.parse(require('fs').readFileSync('docs/forge/manifest.json'))"`
- Validar links markdown manualmente em PRs novos

---

## Operações que exigem confirmação humana

Mesmo nos limites do `.claude/settings.json` deny list, **sempre** confirme antes de:

- Editar `.claude/CONSTITUTION.md` (precisa nova ADR)
- Bump MAJOR de versão
- Push para `master` (preferir branch + PR)
- Adicionar ou remover entrada em `manifest.json` → `principles[]`
- Mudar contrato do reviewer (`reviewer-contract.md`)

Operações livres: edição de skills, commands, templates, doc, hooks experimentais em branch.

---

## Comandos úteis

```bash
# Validar manifest JSON
node -e "console.log(JSON.parse(require('fs').readFileSync('docs/forge/manifest.json','utf8')).framework.version)"

# Recalcular hash de um arquivo
sha256sum docs/forge/manifest.json | cut -c1-16

# Listar todos os artefatos
find . -type f -not -path './.git/*' -not -path './node_modules/*' | sort

# Diff vs último commit
git diff HEAD --stat
```

---

## Status atual

- ✅ Forge-0 entregue (v0.1.0 + reposicionamento v0.2.0)
- ✅ Forge-1 genéricas concluídas: **9/9 skills** (3 L0 + 3 L1 + 3 L2) com helper pattern documentado
- ✅ Forge-2 concluída: **11/11 slash commands** (spec/economics 4 + implementation 3 + validation 4); pipeline end-to-end de `/diagnose` a `/audit-monthly`
- 🔄 Forge-3 em execução: **reviewer DeepAgent (10 SKILL.md) + 8 Guardians + 2 cross-LLM reviewers entregues** (F17/F18)
- ⏳ Pendências do consumidor: ADR-002 efetiva (template entregue) + primeira auditoria mensal de teste
- ⏳ Próximo no framework: **Forge-4 — Hooks runtime** (PreToolUse, PostToolUse, PreCommit, manifest-sync, deepagents-resync)
- ⏳ Resíduo Forge-1 (opcional): 4 skills Acme-específicas em `examples/acme/skills/`

Veja [`docs/forge/roadmap.md`](./docs/forge/roadmap.md) para detalhes.
