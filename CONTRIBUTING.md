# Contributing — Acme Forge

> Como evoluir o framework. Lê quem **mantém** o Forge ou contribui com mudanças (adiciona templates, skills, refinamentos na Constitution, etc.).

---

## Antes de qualquer coisa

1. **Leia** [`.claude/CONSTITUTION.md`](./.claude/CONSTITUTION.md) inteira
2. **Leia** [`docs/forge/decisions.md`](./docs/forge/decisions.md) para entender F1-F12
3. **Leia** [`docs/forge/out-of-scope.md`](./docs/forge/out-of-scope.md) para evitar adicionar algo deliberadamente excluído
4. **Conheça** o caso real em [`examples/acme/`](./examples/acme/)

---

## Tipos de contribuição

### A. Adicionar/modificar template

**Quando**: identificar padrão repetido em projetos consumidores que merece template canônico.

**Processo**:
1. Issue descrevendo padrão e justificativa
2. Branch `forge/template-{nome}`
3. Criar arquivo em `templates/{nome}.template.md` seguindo formato dos existentes:
   - Frontmatter YAML com metadata
   - Seções numeradas
   - Placeholders `{{ ... }}` claros
   - Checklist de pronto ao final
4. Atualizar `docs/forge/manifest.json` — adicionar entrada em `artifacts.templates[]`
5. Atualizar `CHANGELOG.md` (PATCH se template novo, MINOR se modifica template público)
6. PR

### B. Adicionar/modificar skill

**Quando**: capability transversal a vários projetos consumidores que pode virar skill reutilizável.

**Processo**:
1. Issue descrevendo skill e Tier (1/2/3)
2. Branch `forge/skill-{nome}`
3. Criar arquivo em `.claude/skills/L{0|1|2}/{nome}.md` (Forge-1)
4. Frontmatter padrão Anthropic com `tier`, `name`, `description`, activation rules
5. Tabela anti-rationalization + verification gates
6. Manifest update
7. CHANGELOG entry
8. PR

### C. Adicionar slash command

**Quando**: workflow recorrente que merece comando.

**Processo**:
1. Issue descrevendo o comando e seu lugar no pipeline
2. Branch `forge/command-{verbo}`
3. Criar `.claude/commands/{escopo}/{verbo}.md` (Forge-2)
4. Frontmatter (description, allowed-tools), verification gate explícito, output structured
5. Manifest update
6. CHANGELOG
7. PR

### D. Adicionar subagent / Guardian

**Quando**: papel específico de revisão/garantia que vale ter como subagent dedicado.

**Processo**:
1. Issue descrevendo papel e modelo recomendado (Opus/Sonnet/Haiku)
2. Branch `forge/agent-{nome}`
3. Criar `.claude/agents/{nome}.md` (Forge-3)
4. Frontmatter (model, description, tools), persona, smart routing
5. Manifest update
6. CHANGELOG
7. PR

### E. Mudar a Constitution

**Quando**: princípio fundador precisa evolução real (caso raro).

**Processo**:
1. Issue **detalhada** com motivação
2. Branch `forge/constitution-X.Y.Z`
3. ADR no projeto consumidor (não no Forge) justificando
4. Atualizar `.claude/CONSTITUTION.md`:
   - Bump SemVer (MINOR para alteração de regra; MAJOR para remoção/quebra)
   - Adicionar entrada na tabela "Histórico"
5. Atualizar `manifest.json` → `framework.constitution_version`
6. Atualizar `reviewer/prompt.template.md` se a mudança afeta validação
7. Atualizar `CHANGELOG.md` raiz com seção `### Breaking Changes` se MAJOR
8. PR + revisão **explícita** do mantenedor (não auto-merge)
9. Comunicar consumidores (release note + bumpar versão de projetos que adotam)

### F. Adicionar exemplo de domínio

**Quando**: novo caso de uso real (não-Acme) adota o Forge e quer contribuir como exemplo.

**Processo**:
1. Pasta `examples/{nome-do-projeto}/` com conteúdo análogo a `examples/acme/`
2. README explicando o contexto
3. Adaptar Constitution caso necessário (nunca alterar a do Forge — adicionar `constitution-extension.md` próprio)
4. Manifest update (campo `examples`)
5. CHANGELOG
6. PR

---

## Versionamento

SemVer estrito:

| Mudança | Bump |
|---|---|
| Adicionar template/skill/command novo | **PATCH** (0.X.Y → 0.X.Y+1) |
| Modificar template público (mantém compatibilidade) | **PATCH** |
| Adicionar princípio à Constitution | **MINOR** (0.X.Y → 0.X+1.0) |
| Concluir Onda Forge (Forge-1, Forge-2, ...) | **MINOR** |
| Modificar regra de princípio existente | **MAJOR** (X.Y.Z → X+1.0.0) |
| Remover princípio | **MAJOR** |
| Mudar formato de manifest.json (breaking) | **MAJOR** |

Tags git: `vX.Y.Z` no commit que bumpa a versão.

### Processo para MAJOR bumps (breaking changes)

MAJOR bump quebra contrato e força ação no consumidor. **Raríssimo** — só justificável quando o custo de manter compatibilidade é maior que o custo do consumidor migrar. Em geral, **prefira MINOR com deprecation path de ≥3 versões**.

**Antes de propor MAJOR**:

1. **Verifique alternativas MINOR**:
   - Adicionar capability nova ao lado da antiga (deprecated) → MINOR
   - Adicionar campo opcional ao manifest com default backwards-compatible → MINOR
   - Renomear arquivo mantendo old path como symlink/wrapper → MINOR

2. **Se MAJOR for inevitável**, abra issue com header `[MAJOR proposal]` contendo:
   - Princípio afetado (C1-C8) ou contrato quebrado
   - Justificativa econômica/técnica
   - Lista de consumidores conhecidos impactados (Acme Social, Aicfo, SchoolPlatform, etc.)
   - Estimativa de esforço de migração POR consumidor
   - Plano de deprecation path se aplicável

**Processo formal de MAJOR**:

1. Issue aprovada pelo mantenedor + ≥1 reviewer externo (cross-LLM ou humano)
2. Branch `forge/major-vX.0.0` com:
   - ADR formal em `docs/forge/decisions.md` (próxima Fxx disponível)
   - Bump da `framework.version` E `manifest.framework.constitution_version` (se C1-C8 afetada)
   - `CHANGELOG.md` com seção `### Breaking Changes` explicando:
     - O que quebrou
     - Como migrar (passo-a-passo)
     - Qual versão LTS anterior permanece suportada e até quando
   - Migration guide em `docs/forge/migrations/vX.0.0-to-vY.0.0.md` com exemplos antes/depois
3. PR aberto com tag `[BREAKING]` no título
4. **Aviso prévio aos consumidores conhecidos** (≥7 dias antes do merge):
   - Issue ou comentário no manifest.json deles
   - Convite a testar o branch antes do release
5. Após merge: tag `vX.0.0`, anúncio em CHANGELOG, release notes detalhadas

**O que MAJOR bump NÃO precisa exigir** (regra anti-bloat):
- Reescrita de todos os templates (apenas os afetados)
- Quebra de manifest schema (preferir migration via campo `manifest_version`)
- Renomeação de princípios sem mudança de semântica (use `renamed_from_v{X}_{Y}` field, mantém ID)

**Suporte de versão N-1**:

Quando v(N).0.0 sai, o framework mantém v(N-1).x.y em "security-only support" por **6 meses** ou até o último consumidor conhecido migrar, o que vier primeiro. Bugs sérios em v(N-1) recebem patch, mas features novas não. Documentar em `docs/forge/support-policy.md` (se aplicável).

**Quando o último MAJOR aconteceu**: até v0.13.0 (Forge-13 Sprint 1), **ZERO MAJOR bumps** ocorreram desde Forge-0. Toda evolução foi feita via MINOR com matriz de interpretação ou flags backwards-compat. Isso é o caso desejado — preserve.

---

## Estilo

### Markdown

- Frontmatter YAML em todo arquivo de template/skill/agent
- Headings começam em `#` (uma única H1 por arquivo)
- Tabelas para informação estruturada; bullets para listas
- Code blocks com linguagem declarada (` ```ts`, ` ```bash`, ` ```mermaid`)
- Links relativos para outros arquivos do Forge
- Sem emojis no código; emojis em headings de seção apenas para sinalizar tipo (✅/❌/⚠️/🔴)

### Manifest JSON

- Campos obrigatórios: `id`, `path`, `type`, `version`, `description`
- Campos opcionais: `sha256`, `linked_principles`, `owner`
- IDs em kebab-case
- Paths relativos à raiz do repo
- Versões em SemVer

### Naming

| Tipo | Convenção |
|---|---|
| Templates | `{nome}.template.md` |
| Skills | `{tier-folder}/{nome}.md` |
| Commands | `{escopo}/{verbo}.md` |
| Agents | `{papel}.md` |
| ADRs | `{NNN}-{slug}.md` |
| Examples | `examples/{dominio}/` |

---

## Processo de PR

### Checklist do autor

- [ ] Branch nomeada conforme tipo (`forge/template-X`, `forge/skill-Y`, etc.)
- [ ] Manifest atualizado (`docs/forge/manifest.json`)
- [ ] CHANGELOG.md atualizado com entrada na seção `[Unreleased]`
- [ ] Tests passing (se aplicável a essa contribuição)
- [ ] Documentação interna do framework atualizada se mudança afeta usuário (README, QUICKSTART, ARCHITECTURE)
- [ ] Constituição **não** mudou OU se mudou: ADR + bump MINOR/MAJOR + comunicação aos consumidores

### Revisão

- Revisor humano leitura completa
- (Após Forge-3) Reviewer DeepAgent pode ser invocado em PRs grandes para sanity check independente
- Sem auto-merge para mudanças de Constitution

### Após merge

- Tag git `vX.Y.Z` no commit
- Push da tag
- Atualizar CHANGELOG.md movendo entradas de `[Unreleased]` para nova seção `[X.Y.Z]`

---

## O que NÃO fazer

- ❌ Adicionar dependência de stack específico (Node, Python, etc.) ao **core** do Forge — Forge é markdown + JSON + (Forge-3+) scripts opcionais
- ❌ Inserir lógica Acme-específica em arquivos genéricos (`templates/`, `.claude/CONSTITUTION.md`, etc.) — vai para `examples/acme/`
- ❌ Adicionar princípio C9+ à Constitution genérica — extensões viram `examples/{dominio}/constitution-extension.md`
- ❌ Modificar `examples/acme/` sem confirmar com mantenedor da Acme
- ❌ Criar templates redundantes (verificar `templates/` antes)
- ❌ Bumpar MAJOR sem motivo real (quebrar compatibilidade exige justificativa forte)

---

## Roadmap das Ondas Forge (referência)

Ver [`docs/forge/roadmap.md`](./docs/forge/roadmap.md) para detalhe.

| Onda | Foco | Status |
|---|---|---|
| Forge-0 | Fundação | ✅ Concluída em v0.2.0 |
| Forge-1 | Skills L0/L1/L2 | 🔜 Próxima |
| Forge-2 | Slash commands | 🔜 Pendente |
| Forge-3 | Subagents Guardian + reviewer | 🔜 Pendente |
| Forge-4 | Hooks runtime | 🔜 Pendente |
| Forge-5 | Playbooks verticais | 🔜 Pendente |

Cada Onda concluída = bump MINOR.

---

## Comunicação

| Canal | Quando |
|---|---|
| GitHub Issues | Propor mudanças, reportar problemas |
| GitHub PRs | Submeter contribuições |
| CHANGELOG.md | Histórico oficial de mudanças |
| Release notes (tag) | Comunicação curta no momento do release |
| Email mantenedor | Casos sensíveis (segurança, propriedade intelectual) |

---

## Licença

Repositório privado. Contribuições aceitas mediante autorização do mantenedor (Acme / Novais Digital).
