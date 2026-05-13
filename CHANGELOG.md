# Changelog — Acme Forge

Todas as mudanças notáveis neste framework são documentadas aqui.

Formato segue [Keep a Changelog](https://keepachangelog.com/) e versionamento [SemVer](https://semver.org/):
- **MAJOR** — quebra de Constitution (princípio removido/reformulado)
- **MINOR** — onda Forge concluída (nova capability)
- **PATCH** — correção de template/doc/hook sem mudar contrato

---

## [0.14.0] — 2026-05-13

### Added (Forge-13 Sprint 2 — Consumer-mode automation)

**Fechamento da onda Forge-13: o consumidor passa a fazer upgrade do framework com um comando.**

**`scripts/forge-sync.sh` v1.0.0 (F32):**

- Novo script consumer-side que sincroniza artefatos canônicos do Forge para o projeto consumidor sem fricção.
- **Guard contra cwd canônico**: se executado dentro do repo Forge canônico, falha com mensagem clara — sync é unidirecional (canônico → consumer).
- **Paths sincronizados** (lista canônica explícita no script para evitar deriva via manifest):
  - `.claude/CONSTITUTION.md` + `.claude/{agents,commands,skills}/`
  - `hooks/{pre-tool-use,post-tool-use,stop}/` + `hooks/scripts/`
  - `scripts/forge-doctor.sh` + `scripts/forge` (a próprio `forge-sync.sh` é copiado também para próximos upgrades)
  - `templates/` inteiro (specs platform/agentic, AIOS, CI/CD, master-prompt)
  - `reviewer/{prompt.template.md, output-schema.json, validation-rules.json, example-audit.md, README.md}` + `reviewer/deepagents/skills/`
- **Paths preservados** (nunca sobrescreve): `.claude/settings.json`, `.claude/settings.local.json`, `docs/forge/manifest.json`, `docs/forge/project.json`, `CLAUDE.md`.
- **Manifest update controlado**: atualiza no consumer apenas `framework.framework_version_required` + `framework.last_synced_at`; mantém `framework.version` (= última versão aplicada com sucesso) intocada para audit trail.
- Flags: `--dry-run` (mostra diff sem escrever), `--from <path>` (alternativa a `FORGE_PATH` env e auto-detect), `--force`, `--verbose`, `--help`.
- Audit trail: cria/atualiza `docs/forge/sync-history.md` no consumer com entrada (data, versão canônica, versão anterior, ADD/UPDATE/UNCHANGED/SKIPPED).
- **Compat Windows**: helper `to_node_path` converte paths Git Bash (`/c/...`) via `cygpath -m` antes de passar a `node`.

**`scripts/forge-doctor.sh` v0.6.0 — novo check C9 drift (F37):**

- Em modo consumer, doctor agora compara `framework.framework_version_required` (set pelo forge-sync) com versão atual do canônico local.
- Resolução do canônico: `FORGE_PATH` env → `../agent-governance-framework/` → `~/Projetos/agent-governance-framework/` → PASS com nota de "drift check pulado".
- Drift detectado vira WARN com mensagem actionable: `consumer espera vX.Y.Z; canônico atual=A.B.C — rode 'bash scripts/forge-sync.sh'`.
- Sem rede, sem dependência externa. Compat Windows via mesmo `to_node_path` helper.

**`INSTALL.md` v0.14.0 (F42):**

- Reescrito para liderar com **Surface-aware persona routing** (tabela CEO/dev/agente/wizard logo no topo).
- Caminho principal: 3 comandos (`git clone`, `cd`, `forge-sync.sh`) — não mais 6 passos manuais.
- Bloco de **upgrade** explicado com diff prévio (`--dry-run`) e commit message sugerido.
- Manual instalado movido para "fallback" (preservado para auditabilidade).
- Validação pós-instalação expandida: tabela de 6 checks (consumer doctor, sync history, project.json, Constitution, master-prompt referência, Claude Code carrega).
- 4 soluções de problemas cobrindo drift + manifest perdido + hashes Windows + Constitution não carregada.

**Manifest:**

- `install` 0.9.0 → 0.14.0 (descrição reescrita).
- `script-forge-doctor` 0.5.0 → 0.6.0 (linked_principles, descrição inclui C9).
- Nova entrada `script-forge-sync` v1.0.0.
- `forge-decisions` 0.13.0 → 0.14.0 (descrição inclui Sprint 2).
- `forge-manifest` 0.13.0 → 0.14.0.
- `changelog` 0.13.0 → 0.14.0.

### Versionamento

- **MINOR bump** (v0.13.0 → v0.14.0): adiciona capability nova (sync automation + drift detection + INSTALL reescrito). Backwards-compatible — projetos consumidores em ≤ v0.13.x continuam funcionando; sync é opcional, manual permanece como fallback.
- Não exige ADR de Constitution.

---

## [0.13.0] — 2026-05-13

### Added (Forge-13 Sprint 1 — Consumer-mode hardening)

**O framework deixa de gerar ruído ao ser executado em projeto consumidor. Resolve P0 da auditoria 2026-05-13 (após primeira adoção real por Acme Social).**

**`scripts/forge-doctor.sh` v0.5.0 (F30):**

- Detecta automaticamente se está rodando no repo canônico do Forge ou em projeto consumidor via novo campo `manifest.framework.canonical: true` (presente apenas no canônico).
- Override explícito via flags `--canonical` / `--consumer`.
- Em modo `consumer`:
  - C1: `reviewer/output-schema.json` e `reviewer/validation-rules.json` passam a ser **opcionais** (não-FAIL se ausentes); consumer pode não ter copiado o pacote reviewer/ se não roda auditoria mensal local.
  - C6: check de **artefatos órfãos é pulado** (manifest do consumer não precisa duplicar entries canônicas do framework — só registra o que ele mesmo produz).
  - C8: AIOS templates **condicional** — se `templates/aios/` não existe, check inteiro pulado (consumer pode não usar AIOS); workflows CI/CD ausentes geram PASS (opcional para consumer) em vez de FAIL.
- Banner inicial mostra modo ativo (`canonical (repo do framework)` ou `consumer (projeto consumidor)`).
- Resolve queixa documentada: consumer rodava forge-doctor e via 65 warnings de "órfão" + 2 FAILs de `reviewer/` ausente — agora vê tudo verde quando o consumer está correto.

**`docs/forge/decisions.md` — F26 duplicado resolvido (F31):**

- Decisão original de Forge-10 (TDD-first) tinha sido registrada como `F26` em 2026-05-12, colidindo com `F26` Forge-9 (delivery-type agnostic, 2026-05-08). Reviewer DeepAgent citaria "F26" ambiguamente.
- Forge-10 renomeada para **F26-bis** com nota de desambiguação explícita; F26 (Forge-9) preservada como canônica e mais referenciada externamente (PLAYGROUND, CLAUDE.md, prompt do reviewer).
- Tabela de versionamento de `decisions.md` corrigida.
- CHANGELOG referência cruzada atualizada.

**`docs/forge/manifest.json` — metadados stale corrigidos (F33):**

- `forge-decisions` `0.8.0` → `0.13.0` (descrição "F1-F26" → "F1-F29 + F26-bis").
- `forge-roadmap` `0.6.0` → `0.12.0` (descrição "7 ondas" → "12 ondas").
- `forge-manifest` `0.9.0` → `0.13.0`.
- `forge-readme` `0.9.0` → `0.12.0` (descrição atualizada).
- `changelog` `0.9.0` → `0.13.0`.
- `claude-md-meta` `0.9.0` → `0.10.0` (atualizado em Forge-11 com seção Master Prompt).
- `script-forge-doctor` `0.4.1` → `0.5.0` (linked_principles ganha C7).
- `reviewer-prompt` `0.3.0` → `0.5.0` (ver abaixo).
- Adicionado novo campo `framework.canonical: true` (lido pelo forge-doctor para auto-detect).
- Adicionada entrada `forge-audit-2026-05-13` (`docs/forge/AUDIT_2026-05-13_pendencias.md`).
- Vários `sha256` setados como `null` (recálculo deferido para evitar churn por line endings Windows/Unix).

**`reviewer/prompt.template.md` v0.5.0 — cobertura retroativa (F33):**

Prompt do reviewer v0.3.0 cobria apenas Forge-9. Auditorias mensais geradas com ele teriam blind spots em Forge-10/11/12. v0.5.0 adiciona seção "Checks adicionais introduzidos pós-v0.3.0":

- **C4.tdd.*** (Forge-10 / F26-bis) — TDD red phase files, coverage targets present, test_commands present, integration sem business mocks, Tier C blocking gates, review_agent verdict. `applies_when`: projeto declara `aios_tier` OU possui `templates/aios/`.
- **C8.master_prompt.*** (Forge-11 / F27) — master-prompt instalado, versão compatível, anti-duplicação manual no CLAUDE.md local.
- **C7.surface.*** (Forge-12 / F28+F29) — `HELLO.md` presente quando há stakeholder não-técnico, `.forge-mode` válido, hook `friendly-errors` ativo, PLAYGROUND opcional.
- **Política de retro-aplicação** — audits gerados com prompt ≤ v0.3.0 devem incluir nota explícita de blind spot conhecido e recomendar re-auditoria.

**Novo workflow dogfooded `.github/workflows/forge-validate.yml`:**

- O repo canônico do Forge passa a rodar seus próprios gates em todo PR/push para `master`.
- 4 jobs: `forge-doctor --canonical`, `skill-security-scan`, `manifest-json-valid`, `hooks-bash-syntax` + `summary` consolidado.
- Pré-merge-check e tdd-red-phase-check do template canônico **não** se aplicam ao próprio Forge (sem `src/skus/` produtivo).
- Garante que o framework não regride nos próprios gates que distribui.

**Decisões formalizadas:**

- Esta release **não** abre uma nova decisão Fxx — é Sprint 1 da onda Forge-13 catalogada em `docs/forge/AUDIT_2026-05-13_pendencias.md`. A onda completa terá ADR consolidada após Sprint 2 (F32 sync script + F42 INSTALL update).

### Versionamento

- **MINOR bump** (v0.12.0 → v0.13.0): adiciona capability nova de modo consumer + correções estruturais que afetam comportamento (forge-doctor relaxado, IDs renomeados). Tudo é backwards-compatible — projetos consumidores em ≤ v0.12.x continuam funcionando.
- Não exige ADR de Constitution.

---

## [0.12.0] — 2026-05-13

### Added (Forge-12 Fase 2 — Aprendizado por exemplos + tradução de erros)

**Fecha as 2 lacunas da Fase 1: (a) ler doc não fixa, falta ver fazendo; (b) mensagens de erro técnicas continuam hostis no modo vibe mesmo com glossário leigo. Solução: PLAYGROUND com exemplos reais + tradução automática de erros via hook.**

**Novo `PLAYGROUND/` na raiz com 3 exemplos executáveis end-to-end:**

- **`PLAYGROUND/README.md`** — visão geral, tabela comparativa dos 3 tipos, guia por onde começar.

- **`PLAYGROUND/01-agentic-saas-agent/`** (Carrossel Agent, inspirado Acme Social):
  - `README.md` — outcome contratual, stack, conceitos-chave
  - `walkthrough.md` — passo a passo do pipeline (~25 min): diagnose → spec → plan + ADR → tasks → implement (AIOS TDD-first) → eval (20+ cases LLM-as-judge) → promote SHADOW → ASSISTED → AUTONOMOUS
  - `docs/forge/project.json` — manifest real (`project_type=agentic_saas`, `ai_enabled=true`)

- **`PLAYGROUND/02-platform-module/`** (Módulo Faturamento, inspirado SchoolPlatform):
  - `README.md` — diferenças críticas vs agentic (C3 audita infra; C4 acceptance gate; lifecycle draft→canonical)
  - `walkthrough.md` (~20 min) — pipeline platform com delivery-economics, audit-trail-check, acceptance-report assinado pelo decisor cliente
  - `docs/forge/project.json` — manifest real (`platform`, `ai_enabled=false`, criticality=C para módulo financeiro)

- **`PLAYGROUND/03-hybrid/`** (Plataforma com módulo IA add-on, inspirado Aicfo):
  - `README.md` — interpretação C1-C8 por módulo, ADR obrigatório para adicionar módulo IA, hooks rodam condicionalmente, reviewer mensal ramifica
  - `docs/forge/project.json` — 3 módulos heterogêneos (2 platform_module + 1 agentic_sku) no mesmo projeto

**Novo `COMMON_ERRORS.md` na raiz (top 10 erros + soluções copy-paste):**

Cada erro segue padrão: mensagem literal → causa-raiz → diagnóstico → solução passo a passo → prevenção.

Cobertura:
1. `forge-doctor C2 path missing` (manifest ↔ filesystem)
2. `forge-doctor C3 version mismatch` (4 fontes divergentes)
3. `forge-doctor C6 artefato órfão` (arquivo sem entry no manifest)
4. Hook `outcome-clause-guard` bloqueia spec (C2 vago)
5. Hook `adr-approval-gate` bloqueia edit (C5 ausente)
6. Hook `secret-scan` bloqueia commit (env vazio)
7. `@po-guardian` rejeita spec (outcome vago, ICP fit unclear)
8. `@unit-economist` falha C3 (custo > 25% preço)
9. Hash sha256 incorreto no manifest (LF/CRLF, edição sem update)
10. TDD red phase missing (Gate G6 Forge-10)

**Novo hook `hooks/post-tool-use/friendly-errors.sh` (PostToolUse):**

- Intercepta output de tools/comandos Claude Code
- Detecta padrões de violação C1-C8 via regex (9 padrões: C1-C8, hash mismatch, secret)
- Anexa mensagem traduzida conforme `.forge-mode`:
  - **vibe** — tradução leiga: "Esse SKU está caro demais — você precisa cobrar mais ou cortar custos"
  - **dev** — tradução + detalhes técnicos + referência a COMMON_ERRORS.md
  - **agent** — passa direto sem traduzir (downstream automation)
- Não bloqueia execução (sempre exit 0)
- Fallback graceful: usa `jq` se disponível, senão `python3`, senão skip
- Timeout 3000ms (não trava sessão)

**Mudanças em `settings.json`:**

- Hook `friendly-errors` adicionado ao array `PostToolUse[].hooks[]` com matcher `Edit|Write`.
- `_ids` atualizado para incluir `friendly-errors`.

**Mudanças em `manifest.json`:**

- Nova entrada `hook-friendly-errors` em `artifacts.hooks.post_tool_use[]` v1.0.0 com `linked_principles: [C7]`.

**Decisões formalizadas:**

- **F29** em `docs/forge/decisions.md` registrando arquitetura "leitura → execução supervisionada" via PLAYGROUND, gates novos (playground completeness, common errors coverage, friendly errors fallback, mode-aware translation), mapeamento C1-C8 detalhado e trade-off aceito.

### Próximas evoluções previstas (Forge-12 Fase 3)

- `GLOSSARY_PLAIN.md` standalone (hoje embutido no QUICKSTART_VIBE)
- `forge-router` subagent — automação completa de linguagem natural → slash commands
- Modo persona auto-detectado baseado em comportamento
- PLAYGROUND 04 (automation/RPA)

### Versionamento

- **MINOR bump** (v0.11.0 → v0.12.0): adiciona capability nova (Surface layer Fase 2) sem mudar Constitution ou quebrar APIs. Tudo é OPCIONAL.
- Não exige ADR de Constitution.

---

## [0.11.0] — 2026-05-13

### Added (Forge-12 Fase 1 — Camada de usabilidade adaptativa por persona)

**O Forge passa a ter portas de entrada distintas para 3 personas reais (CEO vibecoder, dev novo no time, agente IA) sem mudar a base técnica. Foco em reduzir tempo-até-primeira-contribuição de dias para minutos.**

**Novos arquivos na raiz:**

- **`HELLO.md`** — landing adaptativo. Pergunta "quem é você?" e direciona para 1 de 4 caminhos:
  - 🎨 CEO / vibecoder → `QUICKSTART_VIBE.md`
  - 🛠️ dev → `QUICKSTART_DEV.md`
  - 🤖 agente IA → `templates/master-prompt.md`
  - 🆘 não sei → wizard interativo (`bash scripts/forge start`)

- **`QUICKSTART_VIBE.md`** — guia em linguagem natural, sem jargão técnico (5 min de leitura). Inclui:
  - 3 exemplos do mundo real (criar carrossel, criar agente, entender erro)
  - Glossário leigo (Forge = "regras invisíveis"; Outcome = "o que o cliente paga")
  - 5 receitas práticas (templates de pedido natural)
  - Sinais de "tá tudo bem" vs "para aí"
  - Frases mágicas para socorro ("me explica em português")
  - Como pedir bem (3 elementos obrigatórios: O que / Para quem / Em qual canal)

- **`QUICKSTART_DEV.md`** — cheatsheet técnico de 1 página (15 min). Otimizado para scanning:
  - Estrutura do repo em 30s
  - Setup em 3 min
  - Tabelas dos 15 slash commands + 10 Guardians + 9 hooks + 8 princípios C1-C8
  - "Como adicionar X" (skill, command, Guardian, hook, template)
  - Top 10 erros + como resolver
  - Loop de desenvolvimento (do diff ao push)
  - Checklist pré-PR

**Novo script:**

- **`scripts/forge`** — CLI wrapper unificado (bash 4+, compatível Windows via git bash). 5 verbos canônicos:
  - `start` — wizard interativo (detecta persona, salva em `.forge-mode` gitignored)
  - `doctor` — alias para `scripts/forge-doctor.sh`
  - `version` — versão + fase Forge + modo local
  - `mode <vibe|dev|agent>` — define modo de operação
  - `help [verbo]` — ajuda contextual
  
  Fallback graceful: usa `jq` se disponível, depois `node`, depois `grep`. Cores ANSI apenas se terminal suporta. Resolução de path Unix↔Windows via `cd` para path relativo (evita problemas no Node).

**Mudanças em manifest.json:**

- Nova entrada `script-forge-cli` em `artifacts.scripts[]` v1.0.0 com `linked_principles: [C7]` (portability).

**Mudanças em .gitignore:**

- `.forge-mode` adicionado (preferência de modo por usuário, não commitar).

**Decisões formalizadas:**

- **F28** em `docs/forge/decisions.md` registrando arquitetura Surface/Translator/Core, princípio fundador ("traduzir, não esconder"), gates novos (persona-aware entry, vibe glossary, dev cheatsheet scannability, CLI verb whitelist), mapeamento com Constitution e trade-off aceito.

### Próximas evoluções previstas (Forge-12 Fases 2-3)

- **Fase 2** — `PLAYGROUND/` com 3 exemplos executáveis para dev; `COMMON_ERRORS.md` top 10 erros e soluções; hook `friendly-errors` que traduz erros C1-C8 para humano.
- **Fase 3** — `GLOSSARY_PLAIN.md` standalone; `forge-router` subagent (automação linguagem natural → slash commands); modo persona detectado automaticamente.

### Versionamento

- **MINOR bump** (v0.10.0 → v0.11.0): adiciona capability nova (camada de surface) sem mudar Constitution ou quebrar APIs. Projetos consumidores em Forge ≤ 0.10.x continuam funcionando — toda Fase 1 é **opcional** e **adicional**.
- Não exige ADR de Constitution.

---

## [0.10.0] — 2026-05-13

### Added (Forge-11 — Master prompt universal para projetos consumidores)

**O Forge passa a distribuir um único ponto de entrada canônico que projetos consumidores instalam para operar sob o framework sem manter instruções manuais duplicadas em cada CLAUDE.md.**

**Novo `templates/master-prompt.md` v1.0.0:**

- Documento operacional de 12 seções (~17.5 KB) que substitui ~200 linhas duplicadas nos CLAUDE.md dos consumidores.
- **Detecção automática** de `project_type` (`agentic_saas` | `platform` | `automation` | `hybrid`) + `ai_enabled` lendo `docs/forge/manifest.json` (ou `project.json`) do consumidor — não exige instrução manual.
- **Interpretação adaptativa de C1-C8** conforme matriz já estabelecida em F26:
  - `agentic_saas`: C3 audita tokens, C4 exige eval-suite LLM, C6 Langfuse obrigatório, lifecycle SHADOW→ASSISTED→AUTONOMOUS
  - `platform` (ai_enabled=false): C3 audita infra/operação, C4 usa acceptance gate, C6 condiciona Langfuse, lifecycle draft→staging→pilot→canonical
  - `hybrid`: per-module via ADR
- **Roteamento por tipo** dos slash commands `/acme:*` (ex.: `/acme:spec --type=platform-sku` para agentic; `--type=platform-module` para platform).
- **Catálogo dos 10 Guardians** com modo (ATIVO/PASSIVO) e ordem de invocação.
- **3 fluxos completos** documentados: Criar agente IA, Criar módulo platform, Adicionar feature IA em platform.
- **Guardrails universais** (NUNCA editar Constitution sem ADR; SEMPRE invocar po-guardian em specs novas; etc.).
- **Output padronizado em 5 seções**: Diagnóstico, Rota proposta, Riscos, Próximo passo, Outputs esperados.
- **Critérios de escalação** para conflito entre Guardians, Constitution ambígua, custo extrapola >30% baseline.

**Entrada em `manifest.json`:**

- Novo template `template-master-prompt` v1.0.0 vinculado a TODOS os 8 princípios (C1-C8) — único template com escopo universal no Forge.
- `applies_to_project_types: [agentic_saas, platform, automation, hybrid]`.

**Nova seção em `CLAUDE.md` raiz:**

- Documentação "Master Prompt para projetos consumidores" explicando como projetos consumidores instalam (cópia ou referência relativa).
- Tabela dos 3 modos de operação derivados de `project_type × ai_enabled`.
- Regras de versionamento do master prompt (PATCH para refinamentos, MINOR se adiciona capability nova).

**Decisões formalizadas:**

- **F27** em `docs/forge/decisions.md` registrando contexto (drift entre CLAUDE.md de consumidores), decisão, gates novos (Manifest-driven detection, Adaptive C1-C8 interpretation, Output 5-seções, Escalation triggers), mapeamento com Constitution e trade-off aceito.

### Próximas evoluções previstas (Forge-11.x)

- `forge-router` subagent que lê input em linguagem natural ("crie um post sobre X") e dispara automaticamente o pipeline correto, eliminando necessidade do operador conhecer slash commands.
- Adoção real por Acme Social, Aicfo e SchoolPlatform — cada um copia/referencia `master-prompt.md` em seu CLAUDE.md local.

### Versionamento

- **MINOR bump** (v0.9.0 → v0.10.0): adiciona capability nova sem mudar Constitution ou quebrar APIs. Projetos consumidores em Forge ≤ 0.9.x continuam funcionando — o master prompt é **opcional**, substitui instruções manuais quando adotado.
- Não exige ADR de Constitution.

---

## [0.9.0] — 2026-05-12

### Added (Forge-10 — AIOS pipeline TDD-first)

**O pipeline AIOS deixa de ser "test-after" e passa a ser TDD real, com arquivos físicos de teste e coverage gate por tier mecanicamente enforçado na CI.**

**`templates/aios/agents/test_agent/` v0.2.0 — TDD-first:**

- Novo parâmetro `mode` ∈ `red` | `verify`:
  - `mode="red"` (default, antes do build): lê **APENAS** `docs/specs/{module}.md` (não pode ver o backend que ainda não existe — isolamento C5 reforçado). Materializa **arquivos físicos** em `tests/{module}/{unit,integration,e2e}/`. Gera matriz "requisito da spec → teste" no plano em `docs/specs/_tests_{module}.md`. Não sobrescreve testes editados manualmente — cria `.proposed` ao lado.
  - `mode="verify"` (após o build): revisa cobertura vs. requisitos; aponta gaps; veredicto parseável (`VEREDICTO: TESTES SUFICIENTES | ADICIONAR TESTES`).
- 3 camadas obrigatórias de teste: **unit** (lógica pura, sem rede/DB), **integration** (API + DB real ephemeral, nunca mocka regra de negócio), **e2e** (Playwright/Cypress quando há UI).
- Coverage targets por tier lidos de `aios/config.yaml → coverage_targets` (defaults: A=70%, B=85%, C=95% de cobertura de linha; critical_path 100%).
- Para Tier C: cada edge case financeiro/cancelamento da spec gera ≥ 1 teste unit + ≥ 1 teste integration; valores limítrofes obrigatórios (zero, negativo, máximo, mínimo, casas decimais, DST, ano bissexto).

**`templates/aios/orchestrator.py.template` v0.2.0 — pipeline reordenado:**

```
spec → schema → test(red) → build(back+front em paralelo) → test(verify) → review
```

- 3 gates humanos C4 explícitos: pós-spec, pós-RED (operador roda os testes localmente e confirma que **falham**), pós-build (operador confirma que viraram GREEN).
- Subcomando `test --mode red|verify`.
- Status filesystem-based passa a contar arquivos físicos em `tests/{module}/`.

**`templates/aios/agents/review_agent/` v0.2.0 — gate TDD:**

- Inventário automático de `tests/{module}/{unit,integration,e2e}/` no contexto enviado ao LLM.
- Checklist ganha bloco TDD: plano RED presente, arquivos físicos por camada, `VEREDICTO: TESTES SUFICIENTES`, cobertura ≥ tier-target.
- Se qualquer item TDD desmarcado → `APROVADO PARA MERGE: Não` (exceto e2e para módulos `has_ui: false` com justificativa).

**`templates/aios/config.yaml.template` v0.2.0 — novos blocos:**

- `stack.tests_unit`, `stack.tests_integration`, `stack.tests_e2e` (separados por camada).
- `stack.tests` mantido como **fallback** para backwards-compat com Forge ≤ 0.8.x.
- `coverage_targets: {A,B,C}: {line, branch, critical_path}`.
- `test_commands: {install, lint, typecheck, unit, integration, e2e, coverage_report_path}` — comandos lidos pelo CI sem hardcode.
- `modules[].has_ui` (default `true`) — determina se e2e é exigido.

**`templates/cicd/github-actions-test.template.yml` v0.1.0 — NOVO workflow:**

- 6 jobs em sequência: `resolve-config` → `lint-typecheck` → `unit-tests` (matrix por módulo + coverage gate por tier) → `integration-tests` (matrix com **Postgres ephemeral via service container**) → `e2e-tests` (apenas `has_ui: true` + Playwright) → `summary` (comentário no PR).
- Coverage gate compara `line`/`branch` com `coverage_targets[tier]` — falha o build abaixo do threshold.
- Tier C bloqueia se `tests/{module}/integration/` vazio; Tier C com UI bloqueia se `tests/{module}/e2e/` vazio.

**`templates/cicd/github-actions-validate.template.yml` v0.2.0 — gate G6:**

- Novo job `tdd-red-phase-check`: para cada caminho `src/{modules,features,domains}/{nome}/*` modificado no PR, exige `tests/{nome}/unit/` com ≥ 1 arquivo. Impede merge de código novo sem fase RED.

**`templates/cicd/cicd-checklist.template.md` v0.2.0:**

- Nova seção 3 "Testes funcionais do projeto cliente" com 11 itens 🔴 (workflow ativo, `test_commands` preenchidos, coverage gate, integration sem mocks, e2e para módulos com UI, Tier C bloqueante).
- Total atualizado: **39 itens (29 🔴, 10 🟡)**. Branch protection adiciona checks obrigatórios `tdd-red-phase-check`, `unit-tests`, `integration-tests`.

**`scripts/forge-doctor.sh` — novo check C8 "AIOS templates TDD-ready":**

- C8.1: `test_agent/config.json.template` declara `modes: [red, verify]`.
- C8.2: orchestrator aceita `--mode red|verify`.
- C8.3: `config.yaml.template` tem `coverage_targets` + `test_commands`.
- C8.4: workflow `forge-test.template.yml` presente.
- C8.5: `forge-validate.template.yml` tem job `tdd-red-phase-check`.

**Mapeamento com a Constitution** — F26-bis em [`docs/forge/decisions.md`](./docs/forge/decisions.md) (originalmente registrada como F26 em 2026-05-12, renomeada para F26-bis em v0.13.0 para evitar colisão com F26 Forge-9). Pipeline TDD-first não muda nenhum princípio da Constitution (MINOR bump).

**Trade-off aceito**: projetos consumidores precisam configurar `test_commands` + ter runner de teste + service container para DB. Em troca, regressão de regra de negócio em Tier C **não passa silenciosamente** — a CI bloqueia mecanicamente PRs que reduzam cobertura abaixo de 95% line em código financeiro.

---

## [0.8.1] — 2026-05-08

### Added (Forge-9.x — Pendentes de Forge-9 concluídos)

**F9.11 — Hooks runtime condicionais por `ai_enabled`:**
- `hooks/post-tool-use/langfuse-trace-check.sh` — lê `docs/forge/project.json`; exit 0 imediato quando `ai_enabled=false` (não penaliza plataformas)
- `hooks/post-tool-use/unit-economics-recalc.sh` — ramo platform: avisa quando `docs/modules/*/delivery-economics-*.md` muda; ramo agentic: comportamento original (prompts)
- `hooks/stop/eval-suite-fresh.sh` — lê `project.json`; skip completo quando `ai_enabled=false` (platform usa E2E, não LLM evals)
- `hooks/stop/5-gates-summary.sh` G3 — ramo platform: verifica presença de `pilot-state.md` por módulo em `docs/modules/`; ramo agentic: verifica eval suites ≥ 30 casos (comportamento original)

**F9.12 — DeepAgent skills atualizadas:**
- `reviewer/deepagents/skills/L2/artifact-prompt-builder/SKILL.md` — `applies_when: ai_enabled=true`; plataforma usa `acceptance-report.template.md`
- `reviewer/deepagents/skills/L2/eval-case-author/SKILL.md` — `applies_when: ai_enabled=true`; plataforma usa E2E tests
- `reviewer/deepagents/skills/L2/shadow-mode-runner/SKILL.md` — `applies_when: ai_enabled=true`; plataforma usa STAGING→PILOT com `pilot-state.template.md`
- `reviewer/deepagents/skills/L1/baseline-cost-builder/SKILL.md` v0.2.0 — path duplo: agentic (custo inferência/preço) e platform (`platform_margin`); Step P + inputs platform + Template P6
- `reviewer/deepagents/skills/reviewer/forge-auditor/SKILL.md` — step 3.5 carrega `project.json`; step 5 ramifica escopo (subscriptions OU modules); step 6 passa project_type a sub-agents; rubric C1-C8 com ramos agentic/platform; instrução explícita anti-FAIL para Langfuse quando `ai_enabled=false`

**F9.14 — `/acme:plan` e `/acme:tasks` ramificados:**
- `/acme:plan` v0.2.0 — step 0 resolve `project_type` de `project.json`; seções 2P (camadas service), 4P (audit log), 6P (cronograma PILOT) para platform; output com `plan_variant` e campos platform/agentic separados; pre-conditions bifurcadas
- `/acme:tasks` v0.2.0 — step 0 resolve `project_type`; Waves 1P-4P + 6P para platform (`scaffolding → service build → E2E → PILOT prep → CI/CD`); T6.2P (`forge-tests`) substitui T6.2 (`forge-eval`) em plataformas; DAG platform; frontmatter com `project_type` optional arg

---

## [0.8.0] — 2026-05-08

### Added (Forge-9 — Delivery-type agnostic)

**O Forge passa a suportar formalmente múltiplos tipos de projeto consumidor sem quebrar projetos agentic existentes.**

**Conceito introduzido — `project_type` × `ai_enabled`:**

- `project_type` ∈ `agentic_saas` (default histórico) | `platform` (SaaS/operacional, ex: school-platform/CAPSYSTEM) | `automation` (jobs/RPA) | `hybrid` (plataforma com módulos agênticos)
- `ai_enabled` (boolean) — quando `false`, o reviewer **não** marca FAIL por ausência de LLM/Langfuse/prompts; usa-se audit log + structured logging em vez disso

**Novo template `templates/project.template.json`** — fonte canônica de declaração do projeto consumidor; copiado para `docs/forge/project.json` no consumidor; lido pelo reviewer DeepAgent e pelos commands antes de qualquer check. Backwards compat: ausência → defaults legados (`agentic_saas` + `ai_enabled=true`).

**Constitution v0.3.0** — cada princípio C1-C8 ganhou matriz "Como validar — por `project_type`":

- **C1** renomeado de "Diagnose-before-design" para "Diagnose-before-build" — vale para módulo/job/agente igualmente.
- **C3** generalizado de "Cost ≤ 25% of price" para "Economic viability": modelo `cost_per_outcome` (IA) **OU** `platform_margin` ((infra + suporte + manutenção) / receita). Limite default 25% configurável em `project.economics.cost_to_price_ratio_max`.
- **C4** ganha vocabulário paralelo: `SHADOW/ASSISTED/AUTONOMOUS` (IA) ou `DRAFT/STAGING/PILOT/CANONICAL/DEPRECATED` (platform/automation). Janela mínima em PILOT: ≥14d críticos / ≥7d standard / ≥3d simples.
- **C6** ganha audit-log como provedor obrigatório quando `ai_enabled=false` (substitui Langfuse).
- **C7** ampliado para integrações (CRM/ERP/WhatsApp/pagamento), infra (DB/queue/storage/auth), além de LLMs.
- **C2/C5/C8** mantêm letra; ampliam escopo para módulos de plataforma.

**4 templates novos para platform/automation:**

- `templates/platform-module-spec.template.md` — spec de módulo CRUD/CRM/financeiro/etc. Outcome operacional verificável + audit log entry esperado.
- `templates/platform-pilot-state.template.md` — append-only log de transições DRAFT→STAGING→PILOT→CANONICAL→DEPRECATED. Versão platform de `subscriptions/{id}/promotions.md`.
- `templates/platform-acceptance-report.template.md` — registro formal de aceite humano antes de CANONICAL. Substitui eval suite + shadow-mode-runner em projetos sem IA.
- `templates/delivery-economics.template.md` — cálculo de C3 quando `ai_enabled=false`: (infra + suporte + manutenção) / receita ≤ 25%.

**`reviewer/validation-rules.json` v0.3.0** — restruturado em seções:

- `common` (sempre aplica) — C1.common.*, C2.common.*, C5.common.*, C7.common.*, C8.common.*
- `agentic_saas` (aplica quando ai_enabled=true) — C3.ai.*, C4.ai.*, C6.ai.*, C7.ai.*
- `platform` (aplica quando ai_enabled=false) — C3.platform.*, C4.platform.*, C6.platform.*, C7.platform.*
- `automation` (herda platform com C2.automation.* específico)
- `hybrid` (compõe platform + agentic_saas por módulo)

**`reviewer/prompt.template.md` v0.3.0** — passo obrigatório de carregar `docs/forge/project.json` antes de qualquer check; ramificação da matriz por princípio; **NÃO marca FAIL por ausência de LLM em `ai_enabled=false`** (instrução explícita anti-FAIL falso). Variantes de drift por modelo econômico.

**`docs/forge/reviewer-contract.md` v0.2.0** — `project.json` adicionado como input contratual obrigatório (§3.2 NOVO); §3.5 separa eval suites (IA) de testes E2E + acceptance-report (platform); §4 com tabela "agentic vs platform" por princípio.

**Commands ramificados (todos `project_type_aware: true`):**

- `/acme:diagnose` v0.2.0 — aceita `--project_type` e `--ai_enabled`; bloco 5 do roteiro adapta-se (classified_outcome / operational_action / execution_event); output emite `proposed_outcome.kind` e `audit_log_event_expected`.
- `/acme:spec` v0.2.0 — `--type` aceita `platform-module` e `automation-job` (template `platform-module-spec.template.md`); `type_compatibility_matrix` valida combinação com project_type.
- `/acme:promote` v0.3.0 — aceita transições agentic (start_shadow/shadow_to_assisted/assisted_to_autonomous) **OU** platform (to_staging/to_pilot/to_canonical/to_deprecated). 6 gates reinterpretados: testes E2E + acceptance-report.md em vez de eval suite + shadow-mode-runner. Persistência em `pilot-state.md` para platform. Decisor cliente obrigatório para `to_canonical` com `criticality: critical`.
- `/acme:audit-monthly` v0.2.0 — auditoria ramificada: `outcomes`+LLM trace para agentic, `audited_actions`+audit log para platform; `--module_filter`.

**Manifest v0.8.0:**

- Novo campo `framework.supported_project_types` (4 entradas com lifecycle/economics/outcome_kind)
- `principles[]` enriquecido com `interpretation_modes` por tipo
- 5 novos templates registrados (project + 4 platform)
- `version_bumps.0.7.0_to_0.8.0` documentando a transição

**Decisão fundacional:**

- F26 (NOVO) — Forge delivery-type agnostic: motivação (caso `school-platform`), implicações arquiteturais, SemVer, pendências.

### Backwards compatibility — preservada

Projetos consumidores **sem** `docs/forge/project.json` continuam funcionando exatamente como na v0.7.0:
- defaults retroativos: `project_type: agentic_saas`, `ai_enabled: true`
- todos os checks LLM-centric continuam disparando
- eval suites + Langfuse + SHADOW/ASSISTED/AUTONOMOUS mantidos
- nenhum SKU/produto agentic existente quebra

O reviewer registra em `audit_metadata.limitations_encountered` quando aplica defaults legados, sugerindo criar `project.json` na próxima janela.

### Pendências (Forge-9.x)

- **Hooks** (`unit-economics-recalc`, `langfuse-trace-check`) ainda assumem `ai_enabled=true`. Em projeto platform, simplesmente não disparam (paths/patterns LLM ausentes). Refator condicional explícito → Forge-9.1.
- **Skills DeepAgent** (`reviewer/deepagents/skills/`) seguem cobrindo agentic_saas. Conversão para platform → Forge-9.2 (não bloqueia adoção pelo `school-platform`).
- **Primeira auditoria real** de projeto platform (`school-platform`) será o teste de stress da v0.8.0.

### Migração para projetos consumidores

**Projetos `agentic_saas` existentes**: nada a fazer. Defaults legados garantem compat.

**Projetos `platform` (incluindo `school-platform`)**:

1. Copiar `templates/project.template.json` → `docs/forge/project.json` no repo do consumidor
2. Preencher: `project.type=platform`, `ai_enabled=false`, `economics.model=platform_margin`, `telemetry.audit_log_provider`, `telemetry.structured_logging_provider`, `telemetry.error_tracking_provider`
3. Para cada módulo: criar `docs/specs/{module}.md` a partir de `platform-module-spec.template.md`
4. Antes de cada `to_pilot`/`to_canonical`: criar `pilot-state.md` (template) e `acceptance-report.md` (template)
5. Para cada módulo CANONICAL: manter `delivery-economics-{module}.md` atualizado a cada 90 dias

---

## [0.7.0] — 2026-05-07

### Added (Forge-8 — CI/CD esteira completa para produção)

**Nenhum SKU pode promover para AUTONOMOUS sem CI/CD pipeline ativo verificável — Gate 6 obrigatório no `/acme:promote`:**

**Novo diretório `templates/cicd/`:**

- `templates/cicd/github-actions-validate.template.yml` — workflow de validação para todo PR: forge-doctor (7 checks estruturais) + skill-security-scan (S1-S5) + pre-merge G1-G5 (C7 imports, C8 anti-hardcode, C6 observe(), manifest sync, eval freshness). Copiar para `.github/workflows/forge-validate.yml`.
- `templates/cicd/github-actions-eval.template.yml` — eval automático em mudanças de `prompts/`: detecta artifact_id modificado, roda eval por categoria via `scripts/eval-runner.py`, falha PR se `pass_rate < agreement_rate_min`, trace Langfuse obrigatório em CI (C6), comentário automático no PR com resumo. Copiar para `.github/workflows/forge-eval.yml`.
- `templates/cicd/github-actions-audit.template.yml` — auditoria mensal via cron (1ª seg. 06:00 UTC): invoca reviewer DeepAgent (`forge-auditor`), commit automático de `docs/forge/audits/{YYYY-MM}.md`, cria Issue se SLA breach detectado. Trigger manual via `workflow_dispatch`. Copiar para `.github/workflows/forge-audit.yml`.
- `templates/cicd/cicd-checklist.template.md` — checklist platform-agnostic com **27 itens em 7 seções** (validação estrutural, pre-merge G1-G5, eval automático, auditoria mensal, branch protection, secrets, rastreabilidade de deploys). **18 itens 🔴 obrigatórios** para Gate 6; 9 itens 🟡 recomendados. Preencher em `docs/cicd-checklist-{artifact_id}.md`.

**Gate 6 CI/CD adicionado ao `/acme:promote`:**

- Gate 6 é **obrigatório apenas para `assisted_to_autonomous`** (skipped para start_shadow e shadow_to_assisted)
- Evidências exigidas: `docs/cicd-checklist-{artifact_id}.md` com `gate_6_status: pass`, todos os 18 itens 🔴 marcados, `ci_pipeline_url` preenchido, `last_ci_run_status: passing`, workflows `forge-validate` + `forge-eval` + `forge-audit` presentes
- `gate_count: 5 → 6`; output structured expandido com `cicd_pipeline_active: pass | skipped`
- Tabela anti-rationalization: "CI/CD é DevOps, não bloqueia AUTONOMOUS" → bloqueado; completar Wave 6 e apresentar checklist

**Wave 6 CI/CD adicionada ao `/acme:tasks`:**

- 5 tasks (T6.1–T6.5): workflow validate, workflow eval + `scripts/eval-runner.py`, branch protection rules, workflow audit, checklist assinado
- DAG expandido; T6.5 produz `docs/cicd-checklist-{artifact_id}.md` com `gate_6_status: pass`
- `total_waves: 5 → 6`; verification gate e anti-rationalization atualizados

**`promotion-officer.md` atualizado:**

- Gate 6 na seção `assisted_to_autonomous`: lê `docs/cicd-checklist-{artifact_id}.md`, valida `gate_6_status: pass`, verifica existência dos 3 workflows em `.github/workflows/`
- Anti-rationalization: "CI/CD já existe, não preciso do checklist" → bloqueado
- Verification gate: "5 outros gates + Gate 6 para autonomous"

**Decisão registrada (F25):**

- `docs/forge/decisions.md` — F25 documenta a decisão de tornar CI/CD um Gate obrigatório (vs. recomendado), mapeamento com Constitution C1/C4/C6/C7, trade-off (custo adicional da Wave 6 em troca de garantia mecânica contra regressão em produção)

### Changed

- `manifest.json` versão `0.6.0 → 0.7.0`; `phase` atualizado; novo bloco `artifacts.templates_cicd.files[]` com 4 entradas; `version_bumps.0.6.0_to_0.7.0` adicionado
- `docs/forge/roadmap.md` — header status atualizado para v0.7.0; tabela expandida para **8 ondas**; nova seção **"Forge-8 — CI/CD esteira completa"** completa com tasks F8.1-F8.6 e critério de pronto
- `docs/forge/decisions.md` — F25 adicionada; histórico expandido com linha v0.7.0
- `.claude/commands/acme/tasks.md` — v0.1.0 → v0.2.0; Wave 6 adicionada; DAG expandido; verification gate atualizado
- `.claude/commands/acme/promote.md` — v0.1.0 → v0.2.0; Gate 6 adicionado; gate_count 5→6; output structured expandido
- `.claude/agents/promotion-officer.md` — v0.1.0 → v0.2.0; Gate 6 integrado ao fluxo de `assisted_to_autonomous`

---

## [0.6.0] — 2026-05-07

### Added (Forge-7 — AIOS agentes portáveis em templates físicos canônicos)

**6 agentes AIOS extraídos como templates canônicos versionados na Forge — qualquer novo projeto consumidor recebe os agentes prontos via `/acme:aios-init` (sem hardcode de cliente, sem dependência da implementação de referência SchoolPlatform/EDIX):**

**Novo diretório `templates/aios/`:**

- `templates/aios/README.md` — documentação dos placeholders (`{PROJECT_NAME}`, `{MODULE}`, `{TIER}`, `{STACK_*}`), estrutura física e tabela de diferenças vs. SchoolPlatform/EDIX
- `templates/aios/orchestrator.py.template` — pipeline multiagente que lê `aios/config.yaml → modules:` (sem hardcode de lista de módulos), com gates humanos C4 obrigatórios em pipeline completo
- `templates/aios/config.yaml.template` — config canônica AIOS com novos blocos `project.*` (name, tenant_field) e `stack.*` (backend, frontend, database, tests) + `modules:` array

**6 agentes em `templates/aios/agents/`:**

- `spec_agent/` (**especializado** por módulo) — converte descrição em spec executável; tier configurável A/B/C
- `backend_agent/` (**especializado**) — implementa API/service layer; **stack lida de `aios/config.yaml → stack.backend`** (sem cravamento de Next.js/FastAPI/Rails)
- `frontend_agent/` (**especializado**) — implementa UI/telas; **stack lida de `stack.frontend`**
- `schema_agent/` (**compartilhado, stack-agnostic**) — gera schema na stack declarada em `stack.database`; se vazia, propõe 1-3 stacks com tradeoffs e pede decisão humana antes do schema definitivo
- `test_agent/` (**compartilhado**) — gera testes priorizando edge cases financeiros; stack via `stack.tests`
- `review_agent/` (**compartilhado**) — revisa output contra spec + checklist Constitution C5-C8; output parseável (linha "APROVADO PARA MERGE: Sim/Não")

Cada `entry.py.template` inclui obrigatoriamente:
- Bloco `langfuse.trace() → generation.end()` envolvendo `send_request()` (C6)
- `_MockTrace` fallback para dev local sem Langfuse (não substitui — apenas evita crash em dev)
- Comentário-cabeçalho declarando que o SYSTEM_PROMPT funciona standalone em Claude Code sem o kernel AIOS (C7)
- `tenantId` lido de `task_input["tenant_id"]`, nunca hardcoded (C8)
- Carregamento de `aios/config.yaml` para `_PROJECT_NAME` e `_STACK_*` em runtime (zero hardcode de cliente)

**`/acme:aios-init` bumped para v0.2.0:**

- Passa a **copiar dos templates físicos** em `templates/aios/` em vez de gerar boilerplate inline
- Cobre os 6 agentes (Forge-6 cobria só 3): especializados são regenerados a cada chamada; compartilhados (schema/test/review) são **idempotentes** — só criados se ausentes
- Cria `aios/orchestrator.py` e `aios/config.yaml` quando ausentes, copiando dos templates
- Atualiza `aios/config.yaml → modules:` automaticamente com o novo módulo
- Validation gate aumentado de 4 para 7 checks (adiciona: forge_root, pyyaml, langfuse-warning)
- Resolução de `${FORGE_ROOT}` em ordem: `ACME_FORGE_ROOT` env → `./forge/` → `./.claude/forge/`

**Decisão registrada (F24):**

- `docs/forge/decisions.md` — F24 documenta a extração dos agentes como templates canônicos, mapeamento com Constitution e trade-off (evolução coordenada via 6 arquivos centralizados em troca de garantia C7/C8 e propagação automática para todos os consumidores)

### Changed

- `manifest.json` versão `0.5.0 → 0.6.0`; novo bloco `artifacts.templates_aios.files[]` com 9 entradas (README + orchestrator + config + 6 agent dirs); `command-aios-init` bumped para v0.2.0; `_status` de `commands.aios` atualizado para "Forge-2+5+6+7"; `version_bumps.0.5.0_to_0.6.0` adicionado
- `docs/forge/roadmap.md` — header status atualizado para v0.6.0; tabela de visão geral expandida para **7 ondas**; nova seção **"Forge-7 — AIOS agentes portáveis"** completa com tasks F7.1-F7.6 e critério de pronto (todas marcadas `[x]`)
- `docs/forge/decisions.md` — F24 adicionada; histórico expandido com linha v0.6.0

### Constitution

8 princípios C1–C8 **inalterados**. Forge-7 é evolução de empacotamento da Forge-6 (camada de implementação no consumidor), não princípio novo — não exige MAJOR bump.

---

## [0.5.0] — 2026-05-06

### Added (Forge-6 — AIOS Server camada de implementação multiagente)

**Suporte nativo no framework para projetos consumidores que adotam AIOS Server (`agiresearch/AIOS` v0.2.2, arXiv 2403.16971) como kernel LLM OS:**

**3 novos slash commands em `.claude/commands/acme/`:**

- `/acme:aios-init` — scaffolda estrutura `aios/agents/{module}/` (spec_agent + backend_agent + frontend_agent) com 4 checks pré-criação (spec existe, aios/config.yaml existe, Python 3.10+, ANTHROPIC_API_KEY)
- `/acme:aios-run` — wrapper para `python aios/orchestrator.py pipeline` com health check do kernel + **gates humanos C4 obrigatórios** após cada step (spec/build/test/review). Não re-executa automaticamente após gate rejeitado
- `/acme:aios-status` — comando read-only que exibe tabela de status de todos os módulos (spec/backend/frontend/testes/review/kernel) com detecção de BLOCKERs em review e fallback filesystem sem kernel

**3 commands existentes atualizados (mudanças condicionais — comportamento original preservado quando `aios_tier` ausente):**

- `/acme:plan` — seção 9 condicional "Classificação AIOS" com tabela de módulos, aviso C7 portabilidade (SYSTEM_PROMPTs standalone), próximos passos por tier
- `/acme:tasks` — Wave 2-AIOS com 4 tasks (T2-AIOS-1 init → T2-AIOS-2 build → T2-AIOS-3 test+review → T2-AIOS-4 mover para src/) emitida quando `spec.aios_tier` presente
- `/acme:implement` — bloco "Modo de implementação" no topo com detecção de `--via aios` ou `spec.aios_tier`, health check do kernel, redirecionamento para `/acme:aios-run`. Argumento opcional `via_aios` adicionado ao frontmatter

**Padrão de telemetria oficial:**

- `docs/forge/aios-telemetry-pattern.md` — Langfuse `trace.generation()` → `generation.end()` em cada `send_request()`, campos obrigatórios (`name`, `agent`, `module`, `tier`, `aios_version`, `trace_id`), mock fallback `_MockTrace` para dev local sem `LANGFUSE_PUBLIC_KEY`, integração com hook existente `langfuse-trace-check.sh`, mapeamento explícito C6/C7/C8

**Template atualizado:**

- `templates/platform-sku-spec.template.md` — campos `aios_tier` (A=autônomo, B=iterativo, C=Rafael-dirige) e `aios_context_boundaries` (spec_agent/backend_agent/frontend_agent) adicionados ao frontmatter após `owners:`. Defaults vazios — opt-in apenas se projeto consumidor usa AIOS

**Decisão registrada (F23):**

- `docs/forge/decisions.md` — F23 documenta adoção de AIOS pelo projeto consumidor SchoolPlatform/EDIX e o **mapeamento com a Constitution sem alterar princípios**: Tier A/B/C ↔ C5; `send_request()` + Langfuse ↔ C6; SYSTEM_PROMPTs standalone ↔ C7; `tenantId` em `task_input` ↔ C8

### Changed

- `manifest.json` versão `0.4.1 → 0.5.0`; nova seção `artifacts.commands.aios[]` com 3 entradas; `forge-aios-telemetry-pattern` adicionado em `forge_docs[]`; `_status` de commands atualizado para "Forge-2+5+6 — 15 commands"; `version_bumps.0.4.1_to_0.5.0` adicionado
- `docs/forge/roadmap.md` — header status atualizado para v0.5.0; tabela de visão geral expandida com Forge-6; nova seção **"Forge-6 — AIOS Server"** completa com tasks F6.1–F6.6 e critério de pronto (todas marcadas `[x]`)
- `docs/forge/decisions.md` — histórico expandido com linha v0.5.0 / F23

### Constitution

8 princípios C1–C8 **inalterados**. Forge-6 é camada de implementação no consumidor, não princípio novo — não exige MAJOR bump.

---

## [0.4.1] — 2026-05-04

### Fixed (sincronização de metadados — F22)

**6 divergências de versão/status corrigidas após auditoria interna pré-CI:**

- `README.md` — badges atualizados (`version-0.2.0` → `0.4.1`, `phase-Forge-0` → `Forge-5`); tabela "Status atual" corrigida para refletir Forge-1..5 concluídas; seção "Forge resolve com" expandida (items 5-8 adicionados: hooks, commands, agents, skills); "Estrutura do repositório" expandida com `.claude/{skills,agents,commands}/`, `hooks/`, `docs/playbooks/`, `docs/retrospectives/`, 3 templates novos e `reviewer/deepagents/`
- `.claude/settings.json` — `_forge_version: "0.3.0"` → `"0.4.1"`; `_constitution_version: "0.1.0"` → `"0.2.0"` (Constitution é fonte canônica — settings espelha)
- `docs/forge/decisions.md` — título e header atualizados para "F1–F22 / v0.4.1"; F22 adicionada documentando a sincronização e a política sha256
- `docs/forge/roadmap.md` — header de status atualizado para v0.4.1
- `docs/forge/manifest.json` — `manifest_version` e `framework.version` bumped para `0.4.1`; versões individuais de readme, changelog, forge-decisions, forge-roadmap, forge-manifest, claude-settings atualizadas; `sha256_policy: "post-install"` adicionado em `_meta`; `path_kind: "directory"` adicionado em `examples/acme/`; `version_bumps.0.4.0_to_0.4.1` adicionado

### Added

- `reviewer/README.md` — índice do diretório `reviewer/`, ordem de leitura para deep-agent e dev humano, tabela de assets, ponteiro para `deepagents/README.md` e `reviewer-contract.md`
- `docs/forge/manifest.json` — entry `reviewer-readme` em `artifacts.reviewer_assets`

---

## [0.4.0] — 2026-05-01

### Added (Forge-5 — Playbooks verticais)

**Infraestrutura para reutilização vertical (meta: cliente 2 ≤ 30% esforço do cliente 1):**

- `templates/playbook.template.md` — template de playbook vertical com blocos reutilizáveis por tier (confiança alta/média/baixa), padrão de TenantContext, métricas de esforço cliente 1 vs. cliente 2
- `templates/retrospective.template.md` — retrospectiva por SKU com compliance C1-C8, gate failures, métricas reais (C3 custo/preço, C4 SHADOW, C6 trace coverage), lições aprendidas
- `/acme:playbook-extract` — slash command que guia extração de playbook a partir de SKU em AUTONOMOUS; gera `docs/playbooks/{vertical}/playbook.md` + `docs/retrospectives/{sku}/`
- `docs/playbooks/README.md` + `docs/retrospectives/` — estrutura de diretórios no framework

**Decisões adicionadas:**
- **F19** — Estratégia de playbooks: blocos classificados por tier e confiança; PII fora do playbook; critério ≤30% obrigatório
- **F20** — Reavaliação F5.5 (deploy global `~/.claude/`): manter projeto-scoped; reavaliar com ≥5 projetos
- **F21** — Reavaliação F5.6 (plugin publication): não publicar ainda; critérios definidos (≥3 projetos AUTONOMOUS, ≥3 auditorias reais, Constitution estável ≥6 meses)

### Changed

- `manifest.json` versão `0.3.0 → 0.4.0` (12 commands: +playbook-extract; 12 templates: +playbook + retrospective)
- `docs/forge/decisions.md` — F19, F20, F21 adicionadas; histórico atualizado

---

## [0.3.0] — 2026-05-01

### Added (Forge-4 — Hooks runtime)

**9 hooks ativos em `.claude/settings.json`:**

| Hook | Tipo | Exit | Propósito |
|---|---|---|---|
| `outcome-clause-guard` | PreToolUse | 2 (block) | Bloqueia edição de outcome clauses aprovadas |
| `adr-approval-gate` | PreToolUse | 2 (block) | Bloqueia edição de ADRs assinadas |
| `secret-scan` | PreToolUse | 2 (block) | Detecta API keys / connection strings |
| `any-type-guard` | PreToolUse | 2 (block) | Bloqueia `any` TypeScript em src/skus + src/agents |
| `langfuse-trace-check` | PostToolUse | 1 (warn) | LLM calls sem trace Langfuse (C6) |
| `unit-economics-recalc` | PostToolUse | 1 (warn) | Prompts mudaram — recalc C3 necessário |
| `manifest-sync` | PostToolUse | 0 (info) | Artefatos Forge mudaram sem update de manifest |
| `5-gates-summary` | Stop | 0/1 | Relatório dos 5 gates ao fim de sessão |
| `eval-suite-fresh` | Stop | 0/1 | Eval suites < 30 casos (C4) ao fim de sessão |

**Bypass auditado:** `ACME_FORGE_BYPASS=<motivo>` em env ou `settings.local.json` (gitignored). Todos os bypasses registrados em `docs/forge/bypass-log/YYYY-MM-DD.md`.

**Skill security scan standalone:** `hooks/scripts/skill-security-scan.sh` — 5 checks (S1-S5: secrets, URLs, destrutivos, bypass, frontmatter) — para uso em CI/PR.

**Relatórios de sessão:** `docs/forge/session-gate-reports/` — persistidos pelo `5-gates-summary` hook.

### Changed

- `settings.json` `_forge_version` bumped `0.1.0 → 0.3.0`
- `settings.json` `_planned_features` → `_forge_features` (hooks_path adicionado)
- `manifest.json` versão `0.2.0 → 0.3.0`

---

## [0.2.0] — 2026-04-30

### Repositioning

**Forge agora é repositório standalone consumível por N projetos** (devs com Claude Code + DeepAgents + outros agentes autônomos), não mais framework embarcado em `acme-governanca-ia`.

### Added (multi-consumer enablement)

- **README.md** reescrito para 3 audiências (dev humano, deep-agent, framework-maintainer)
- **QUICKSTART.md** — instalar Forge em projeto novo em <5 minutos
- **ARCHITECTURE.md** — visão estrutural, fluxos, camadas de governança (1-6)
- **DEEPAGENT_GUIDE.md** — como agente autônomo navega o Forge para auditoria mensal
- **GLOSSARY.md** — vocabulário compartilhado entre humanos e agentes
- **CONTRIBUTING.md** — processo de evolução do framework

### Added (templates novos — 5)

- `templates/product-spec.template.md` — produtos self-serve (cliente loga; mensalidade fixa)
- `templates/diagnostic-spec.template.md` — Diagnóstico/Fase 0 cobrável
- `templates/lifecycle-stage.template.md` — declaração de stage (Discovery → Sunset) com critérios
- `templates/monthly-audit.template.md` — output do reviewer DeepAgent
- `templates/clickup-blueprint.template.md` — estrutura ClickUp aplicando Three-tier (opcional)

### Added (reviewer enablement — pasta `reviewer/`)

- `reviewer/prompt.template.md` — system prompt completo do DeepAgent reviewer
- `reviewer/output-schema.json` — JSON schema da auditoria mensal (validação machine-readable)
- `reviewer/validation-rules.json` — checks formais para cada princípio C1-C8
- `reviewer/example-audit.md` — exemplo sintético de relatório bem-feito (gabarito)

### Added (caso real como exemplo — pasta `examples/acme/`)

- `examples/acme/README.md` — overview do caso Acme
- `examples/acme/portfolio.md` — 3 categorias formais (Diagnóstico/Plataforma/Produtos)
- `examples/acme/constitution-extension.md` — princípios C9, C10, C11 específicos Acme (lifecycle, two-track economics, portfolio)
- `examples/acme/clickup-blueprint.md` — estrutura ClickUp interno Acme
- `examples/acme/methodology/` — 3 metodologias originais (clássica, SaaS², Sincra)
- `examples/acme/products/acme-fin.md` — Acme Fin (Beta em produção)
- `examples/acme/products/acme-educacional.md` — Acme Educacional (Discovery)

### Changed

- **Constitution v0.1.0 → v0.2.0**: princípios C1-C8 desacoplados de Acme específico; vocabulário multi-domínio (Tier 1/2/3 ou L0/L1/L2 ou Strategic/Tactical/Operational); refs Acme hardcoded movidas para `examples/acme/constitution-extension.md`
- **Manifest enriquecido**: `consumer_types[]`, `principle_extensions_path`, `reviewer.artifacts{}`, `templates[]` expandido para 9, `reviewer_assets[]`, `examples[]`
- **Decisions F2** atualizado: instalação como projeto-only → repositório standalone consumível externamente
- **`templates/sku-spec.template.md` → `templates/platform-sku-spec.template.md`**: renomeado para clareza (existem agora 3 tipos de spec: platform-sku, product, diagnostic)

### New decisions registered

- **F13** — Constitution genérica vs Acme-específica (extensões em `examples/`)
- **F14** — `examples/` como caso real, não conteúdo prescritivo
- **F15** — SemVer estrito com regras de bump claras
- **F16** — Distribuição privada por enquanto; reavaliar pós Forge-5

### Constitution principles status

8 princípios genéricos (inalterados em essência, refinados em vocabulário):

- C1 — Diagnose-before-design
- C2 — Outcome-first, never tech-first
- C3 — Cost ≤ 25% of price
- C4 — SHADOW antes de cobrar
- C5 — Three-tier context
- C6 — Telemetry-by-default
- C7 — Portability over lock-in
- C8 — Anti-customização heroica

Extensões Acme (em `examples/acme/constitution-extension.md`):

- C9 — Lifecycle declarado por produto/SKU
- C10 — Two-track economics
- C11 — Portfolio em 3 categorias

---

## [0.1.0] — 2026-04-30

### Added (Forge-0 — Fundação)

- **Constitution v0.1.0** com 8 princípios versionados (`.claude/CONSTITUTION.md`)
  - C1 Diagnose-before-design
  - C2 Outcome-first, never tech-first
  - C3 Custo ≤ 25% do preço
  - C4 SHADOW antes de cobrar
  - C5 Three-tier context (Sincra L0/L1/L2)
  - C6 Telemetry-by-default
  - C7 Portability over lock-in
  - C8 Anti-customização heroica
- **`.claude/settings.json`** com:
  - Allow list de comandos seguros (npm, prisma, git read-only, docker compose)
  - Deny list de comandos destrutivos (`rm -rf`, `npm publish`, `prisma migrate reset --force`, `git push --force`, `docker volume rm`)
  - Hooks placeholders documentando intent (Forge-4 implementa)
- **4 templates fundamentais** (`templates/`):
  - `sku-spec.template.md` — consolida D1 + D2 da Onda 0 Acme com cláusula contratual de outcome
  - `adr.template.md` — Architecture Decision Record padrão
  - `eval-case.template.md` — caso de eval suite por SKU com gabarito justificado
  - `unit-economics.template.md` — consolida D5 com gate C3 (custo ≤ 25%)
- **6 documentos do framework** (`docs/forge/`):
  - `README.md` — overview interno e ponteiros
  - `decisions.md` — F1-F8 com defaults aprovados pelo CEO + override F4 (DeepAgents/GPT-5.5)
  - `roadmap.md` — 5 ondas Forge-0 a Forge-5 com tasks e critérios de pronto
  - `reviewer-contract.md` — contrato formal com reviewer externo DeepAgents/GPT-5.5
  - `out-of-scope.md` — o que explicitamente NÃO entra no Forge
  - `manifest.json` — inventory machine-readable consumido pelo reviewer
- **`CLAUDE.md.template`** — template para projeto consumidor adaptar como CLAUDE.md raiz
- **`README.md` raiz** + **`INSTALL.md`** — onboarding e instalação manual

### Decisões registradas

- **F1** Nome: Acme Forge ✅
- **F2** Instalação: projeto-only primeiro (cross-project será reavaliado pós Forge-3) ✅
- **F3** `lc-spec-driven`: pular até confirmar nome correto (não encontrado no GitHub) ✅
- **F4** Reviewer: **DeepAgents/GPT-5.5** ⚠️ (override de Gemini Pro inicialmente sugerido)
- **F5** Plugin marketplace: não na Forge-0 ✅
- **F6** BMAD helper pattern: sim, apenas em L0 ✅
- **F7** Smart model routing: aceitar default (Opus / Sonnet / Haiku) ✅
- **F8** `legacy-pmo/`: usar como L0 temporário até Onda 5 da Acme ✅

### Repos absorvidos (origem dos componentes)

- `github/spec-kit` → Constitution pattern + pipeline `/diagnose → /promote`
- `vbomfim/sdlc-guardian-agents` → spec template + 5 quality gates + Guardian roles
- `addyosmani/agent-skills` → anti-rationalization tables + verification gates
- `aj-geddes/claude-code-bmad-skills` → helper pattern (token reduction in L0)
- `carlrannaberg/claudekit` → file-guard hook + secret scan + bash deny list
- `peterkrueck/Claude-Code-Development-Kit` → estrutura documental + cross-LLM review
- `VoltAgent/awesome-claude-code-subagents` → smart model routing
- `anthropics/skills` → skill format reference (frontmatter)
- `giuseppe-trisciuoglio/developer-kit` → path-scoped auto-activation
- `alirezarezvani/claude-skills` → skill security auditor pattern

### Excluído explicitamente

- `rohitg00/awesome-claude-code-toolkit` (meta-list redundante)
- Multi-provider de `feiskyer` (ADR 001 fixa Claude primário)
- Skills marketing/C-suite de `alirezarezvani` (fora do escopo eng)
- BMAD personas completas (sobreposição com Guardians)
- ClickUp interface (proibido pela ADR 001)

### Pendências para próximas ondas

- F9: Stack do reviewer (Python `deepagents` vs Node/TS LangGraph) — Forge-3
- F10: Provedor (OpenAI direto vs OpenRouter vs Vertex) — Forge-3
- F11: Cadência da auditoria (mensal default; eventos críticos disparam?) — Forge-3
- F12: Adoção em outros projetos do workspace (CarInsight, FacilIAuto) — pós Forge-5

---

## [Unreleased] — Forge-3 em execução

### Added (2026-05-01) — 10 subagents Claude Code (`.claude/agents/`)

- **4 Guardians Opus** (decisão estratégica):
  - `po-guardian` — Product Owner; valida cláusula de outcome (C2), ICP fit, catalog fit; cross-approver mandatório do `/acme:promote` Gate 5
  - `artifact-architect` — **renomeado de `sku-architect`** (alinhamento v0.2.0 — multi-type artifact); plan 8 seções, `agent_readiness_score`, abstração C5/C7/C8; `target_model` advisory apenas
  - `unit-economist` — economic firewall; valida `c3_check`, baseline-cost, força recalc quando `prompt_hash` muda; bloqueia `/acme:sla-threshold` se unviable
  - `promotion-officer` — autoridade de transição de modo; Gate 5 do `/acme:promote`; cross-approval com `po-guardian`; refuta self-approval; gate adicional para `assisted_to_autonomous`
- **4 Guardians Sonnet** (validação técnica):
  - `eval-engineer` — eval suite quality; coverage por outcome_category, source_mode breakdown (real/synthetic/edge/adversarial), ground-truth justified, regressão por `prompt_hash`
  - `tenant-context-curator` — anti-customização (C8); lint regex de `tenantId === '...'`, `switch(tenantName)`, pastas `clients/{nome}/`; valida TenantContext schema
  - `observability-guardian` — telemetry-by-default (C6); Section 8 dos prompts, `observe()` wrapper, trace_coverage ≥99%, `prompt_hash` drift detection
  - `security-privacy-guardian` — PII/LGPD/secrets; lint em eval-cases, prompts, traces sample; **assinatura terceira mandatória** para `assisted_to_autonomous`
- **2 cross-LLM reviewers**:
  - `code-reviewer-claude` (Sonnet) — code review nativo Claude para PRs (focado em src/, prompts/, evals/)
  - `code-reviewer-cross` (Haiku, delegator) — **bridge** para o DeepAgent externo (`forge-auditor` via deepagents CLI); não revisa diretamente; orquestra invocação + traduz output

### Added — Template ADR-002

- `templates/adr-reviewer-runtime.template.md` — template para projeto consumidor adaptar como `docs/adr/002-reviewer-runtime.md`. Cobre 7 decisões (D1-D7): local de execução, modelo do DeepAgent, provedor de telemetria, cadência, output, auto-rollback, credenciais

### Smart routing

| Tier de decisão | Modelo | Quantidade |
|---|---|---|
| Estratégico (outcome, arquitetura, economics, promotion) | Opus | 4 |
| Validação técnica (eval, tenant, telemetry, security) | Sonnet | 4 |
| Code review nativo | Sonnet | 1 |
| Delegator para DeepAgent externo | Haiku | 1 |

### Renaming registrado

- `sku-architect` → `artifact-architect` (v0.2.0 já abriu caminho com `templates/{platform-sku,product,diagnostic}-spec.template.md`; agora consistente também nos guardians). Histórico em `naming_history` no frontmatter.

### Manifest

- `artifacts.agents{}` populado com 3 grupos (`guardians_opus`, `guardians_sonnet`, `cross_llm_reviewers`) — total 10 entradas
- `artifacts.templates[]` cresce de 9 para 10 (adiciona `template-adr-reviewer-runtime`)
- `framework.phase` indica "Forge-3 in progress — 10 SKILL.md + 8 Guardians + 2 cross-LLM reviewers delivered"

### Pendente em Forge-3 (responsabilidade do consumer)

- ADR-002 efetiva no projeto consumidor (template entregue)
- Primeira auditoria mensal de teste com `forge-auditor` rodando contra repo real

---

## [Pré-Forge-3 agents] — Reviewer DeepAgent infraestrutura

### Added (2026-05-01) — Reviewer DeepAgent (F17 + F18)

- **Decisões F17/F18 registradas** em `docs/forge/decisions.md`:
  - F17: stack do reviewer = **`deepagents` CLI (Python, LangChain) v0.0.34+**; processo separado, modelo configurável via `DEEPAGENTS_MODEL`
  - F18: tradução Claude Code → Deep Agents via `andersonamaral2/Claude-Code-to-Deep-Agents-Skills-Converter` (MIT); skills do Forge ficam canônicas em `.claude/skills/`, versão Deep Agents em `reviewer/deepagents/skills/` é **gerada** (nunca editada à mão)

- **Estrutura `reviewer/deepagents/`** criada:
  - `README.md` — guia de instalação (Deep Agents CLI + converter + 10 skills) e uso
  - `conversion-log.md` — histórico de conversões com hash da origem para detectar drift
  - `skills/L0/{company-dna,icp-loader,offerings-loader}/SKILL.md` — 3 skills Tier 1 convertidas
  - `skills/L1/{baseline-cost-builder,diagnostic-runner,process-mapper}/SKILL.md` — 3 skills Tier 2 convertidas
  - `skills/L2/{artifact-prompt-builder,eval-case-author,shadow-mode-runner}/SKILL.md` — 3 skills Tier 3 convertidas
  - `skills/reviewer/forge-auditor/SKILL.md` — **skill nativa Deep Agents** (não convertida) que orquestra a auditoria mensal C1-C8 via 9 sub-agents `task` paralelos

- **8 transformações T1-T8** aplicadas em cada conversão:
  - T1 Execution Context (tabela de tools `read_file/write_file/execute/task`)
  - T2 Execution Plan (`write_todos` checklist)
  - T3 Prerequisites (verificação tools/env via `execute`)
  - T4 Explicit `write_file`
  - T5 Inline tests via `execute`
  - T6 Sub-agents via `task` (quando aplicável)
  - T7 Usage guide (3 modos: interactive, one-shot, CI/CD)
  - T8 Troubleshooting

- **Manifest** atualizado: `framework.reviewer.stack` declarado, `implementation_status` mudado de `specified-not-implemented` para `infrastructure-complete`, lista completa dos 10 SKILL.md em `deepagents_skills[]`

- **Output do reviewer**: `forge-auditor` produz `docs/forge/audits/{YYYY-MM}.md` validado contra `reviewer/output-schema.json`. Auditoria roda 9 checks em paralelo (C1-C8 + structural drift) via `task`.

### Pendente em Forge-3

- 8 Subagent Guardians (`po-guardian`, `sku-architect`, `unit-economist`, `eval-engineer`, `tenant-context-curator`, `observability-guardian`, `promotion-officer`, `security-privacy-guardian`)
- 2 Cross-LLM reviewers (`code-reviewer-claude`, `code-reviewer-cross`)
- ADR-002 do projeto consumidor (decisão de runtime do reviewer no consumer)
- Primeira auditoria mensal de teste

---

## [Pré-Forge-3] — Forge-1 em execução

### Added (Forge-1 — Tier 1 entregue, 2026-04-30)

- **3 skills L0 (Tier 1 estratégico)** em `.claude/skills/L0/` com helper pattern BMAD:
  - `company-dna.md` — carrega DNA da organização (purpose, mission, values, north-star) em YAML compacto cacheável
  - `icp-loader.md` — carrega Ideal Customer Profile com sinais de qualificação e **anti-ICP** mandatório
  - `offerings-loader.md` — carrega catálogo de ofertas com `lifecycle_stage` e `pricing_model` declarados
- **`docs/forge/helper-pattern.md`** — documenta padrão BMAD (cache `ephemeral-strong`, namespace `__forge_cache.<key>`, regras hard R1-R4) com meta de ≥70% redução de tokens
- **Manifest** atualizado: `artifacts.skills.L0[]` populado com 3 entradas; `framework.phase` mudada para `Forge-1 in progress`

### Padrão das skills L0 (canonical reference)

Cada skill segue estrutura:
- Frontmatter Anthropic (`name`, `description`) + extensões Forge (`tier`, `linked_principles`, `helper_pattern`, `cache_strategy`, `reads_from_tier`, `must_not_read`, `activation.{paths,keywords,explicit_invocation}`)
- Tabela anti-rationalization (Addy Osmani) — 5 tentações comuns × resposta correta
- Verification gate com checklist
- C5 hard rule (Tier 1 **não** lê Tier 2/3)
- Saída de erro estruturada com enum

### Scope decision

Forge-1 escopo enxuto: apenas **9 skills genéricas** no Forge. As 4 skills Acme-específicas (`tenant-onboarding`, `outcome-classifier`, `billing-calculator`, `flywheel-collector`) ficam em `examples/acme/skills/` (consumidas por `acme-governanca-ia`), respeitando F13/F14.

### Added (Forge-2 — validation entregue, 2026-04-30) — **Forge-2 completa: 11/11 commands**

- **4 slash commands** em `.claude/commands/acme/` fechando o pipeline:
  - `/acme:eval` — executa eval suite com **pass rate por outcome_category** + **source_mode breakdown** (real/synthetic/edge/adversarial) + detecção de **regressão** vs último run com mesmo `prompt_hash`. Sub-trace por case (100%, sem amostragem)
  - `/acme:promote` — **único caminho legítimo** para mudar `subscription.mode`; valida **5 gates** obrigatórios (C2 outcome clause hash match, C3 viable + recalc clean, C4 SLA pré-contratada com signature, eval recente verde, aprovação cruzada PO × Promotion Officer). Append-only log em `subscriptions/{id}/promotions.md`
  - `/acme:audit-monthly` — sample 5-10% de runs ASSISTED/AUTONOMOUS, audit estrutural C1-C8 (lint regex C7/C8 + correspondência prompt ↔ baseline-cost), drift detection, formato consumível pelo reviewer DeepAgent (`reviewer/output-schema.json`). Suporta `auto_rollback_on_breach: false` (default — bypass exige flag explícita)
  - `/acme:pre-merge-check` — **read-only**, < 30s, **5 gates** mecânicos (G1 C7 imports, G2 C8 hardcode, G3 C6 observe, G4 manifest sync, G5 eval green). Exit code 0/1/2 para CI/pre-commit; integração com hook `pre-merge-check` virá em Forge-4

- **Pipeline completo end-to-end** agora encadeado nos 11 commands:
  ```
  /diagnose → /spec → /unit-economics → /sla-threshold
            → /plan → /tasks → /implement
            → /eval → /promote --to_mode=start_shadow
            → (14+ dias) → /eval → /promote --to_mode=shadow_to_assisted
            → (30+ dias) → /promote --to_mode=assisted_to_autonomous
            → /audit-monthly (mensal)
  /pre-merge-check em todo PR
  ```

- **Bloqueio mecânico de promoção**: nenhuma skill ou command (exceto `/acme:promote`) pode mudar `subscription.mode`. `@shadow-mode-runner.start` checked twice (pre-condição em command + skill).

### Pendente em Forge-2

- Nenhum item — onda concluída.

- **3 slash commands** em `.claude/commands/acme/` para a fase de implementação:
  - `/acme:plan` — gera plano técnico em **8 seções canônicas** (escopo derivado da spec, camadas C5/C7, fluxo input→output, pontos de instrumentação C6, TenantContext schema C8, cronograma com faixas, riscos enumerados, critérios de pronto). `target_model_advisory` apenas — escolha de modelo concreto fica para ADR-002 ou config (C7)
  - `/acme:tasks` — quebra plan em **DAG validado** (sem ciclos) distribuído em 5 ondas: (1) scaffolding C5/C6/C7/C8, (2) prompt build via `@artifact-prompt-builder`, (3) eval seed via `@eval-case-author` em loop até `c4_threshold_met: true` por categoria, (4) SHADOW prep (sem iniciar), (5) métricas e alertas. Cada task tem gate de pronto verificável (lint, test, hash)
  - `/acme:implement` — executa as 5 ondas em ordem topológica do DAG, gera **stubs boilerplate** (`src/llm/adapters/`, `src/observability/trace.ts`, `src/tenants/context.ts`, `src/skus/{id}/index.ts`, `src/skus/{id}/prompt.ts`), enforce mecânico de C6/C7/C8 (lint regex), pausa em gates subjetivos. **Nunca inicia SHADOW** — bloqueio enforced via `error: shadow_start_attempted`

- **Princípio de design**: implement gera estrutura mínima viável com `TODO` explícito; conhecimento de domínio fica com o dev. Provider e modelo concretos são decisão do consumidor, não do framework

### Pendente em Forge-2

- F2.3 validação: `/acme:eval`, `/acme:promote`, `/acme:audit-monthly`, `/acme:pre-merge-check` (4 commands)

---

### Added (Forge-2 — spec/economics entregue, 2026-04-30) — 4/11 commands

- **4 slash commands** em `.claude/commands/acme/` orquestrando as skills do Forge-1:
  - `/acme:diagnose` — Fase 0 cobrável; orquestra `@diagnostic-runner` + helpers L0; persiste `docs/clients/{client_id}/diagnostic.md`
  - `/acme:spec` — **renomeada de `/acme:spec-sku`**; aceita `--type=platform-sku|product|diagnostic` resolvendo o template correto pós-v0.2.0; cláusula de outcome copiada literalmente do diagnostic com hash registrado
  - `/acme:unit-economics` — invoca `@baseline-cost-builder`; **bloqueia** `/acme:sla-threshold` se `c3_check.status == unviable`; cross-valida volume diagnostic vs process-map (±20%)
  - `/acme:sla-threshold` — pré-contrata `c4_thresholds` com **aprovação humana explícita + signature_hash**, hard floor `min_window_days >= 14`, validação de consistência com C3, bloqueio de self-approval (checks-and-balances comercial × engenharia)

- **Padrão de slash command** estabelecido (canonical para F2.2/F2.3):
  - Frontmatter: `description`, `allowed-tools`, `arguments.{required,optional}`, `linked_principles`, `invokes_skills`, `output_artifact`, `trace_required`, opcional `human_approval_required`
  - Pre-conditions explícitas (estado do repo necessário antes de iniciar)
  - Sequência de execução numerada (start trace → helpers → tier 2 reads → core skill → persist → end trace)
  - Output structured (YAML) com `next_step` apontando próximo command
  - Verification gate com checklist
  - Tabela anti-rationalization
  - Saída de erro estruturada com enum
  - Trace Langfuse mesmo em uso manual (C6)

- **Decisão de naming**: `/acme:spec-sku` → `/acme:spec` para alinhar ao reposicionamento v0.2.0 (3 templates de spec disponíveis). Mudança documentada no histórico do command.


---

### Added (Forge-1 — Tier 3 entregue, 2026-04-30) — todas as skills genéricas concluídas (9/9)

- **3 skills L2 (Tier 3 operacional)** em `.claude/skills/L2/` fechando a cadeia operacional:
  - `artifact-prompt-builder.md` — constrói system prompt versionado em **9 seções canônicas** (identidade, contexto Tier 1 cacheado, cláusula de outcome literal, schema de input/output, processo do mapper, guard-rails C3, instrumentação C6 obrigatória, anti-hardcode C8). Persiste em `prompts/{artifact}/v{version}/system.md` com `prompt_hash` (sha256:16) e flag `recalc_unit_economics_required: true` em todo build
  - `eval-case-author.md` — gera eval cases em 4 source modes (`real | synthetic | edge | adversarial`), enforça sanitização PII pré-persistência, exige justificativa do gabarito, persiste em `evals/{artifact}/cases/`. Cap default ≤ 40% sintético; alvo ≥ 60% real após 90 dias
  - `shadow-mode-runner.md` — coordena SHADOW em 3 ações (`start | tick | report`), enforça mecanicamente C4 (≥ 14 dias, `delivered: false` em todo trace, `prompt_hash` imutável durante janela), produz `report-{artifact}-{date}.md` com recomendação **mas não auto-promove** (assinatura humana mandatória)
- **Padrão Tier 3** estabelecido: `reads_from_tier: [1, 2, 3]`, `must_not_read: []`, output em paths versionados ou cliente-específicos, hash sha256:16 para imutabilidade auditável

---

### Added (Forge-1 — Tier 2 entregue, 2026-04-30)

- **3 skills L1 (Tier 2 tático)** em `.claude/skills/L1/` com handoffs declarados entre si:
  - `baseline-cost-builder.md` — calcula custo humano (volume × tempo × custo-hora) e deriva `min_price_per_outcome` para satisfazer C3 (custo ≤ 25%); persiste em `docs/clients/{client}/baseline-cost-{process}.md`
  - `diagnostic-runner.md` — roteiro estruturado de **10 blocos** (problema, custo do não-resolvido, baseline, tentativas, outcome candidato, métrica, tolerância, ICP fit, catálogo fit, próximos passos) com handoff para `baseline-cost-builder` e `process-mapper`; persiste `diagnostic.md`
  - `process-mapper.md` — mapeia processo as-is em formato agent-ready (trigger, atores, steps tabulares, decision points, métricas) + `agent_readiness_score` heurístico; persiste `process-{name}.md`
- **Padrão Tier 2** (canonical para Tier 3): `helper_pattern: none` (consome cache L0, não cacheia), `reads_from_tier: [1, 2]`, `must_not_read: [3]`, `requires_helper:` declara dependências L0, parâmetros obrigatórios incluem `client_id`/`process_id`, output persistido em arquivo (não in-memory)
- **Manifest** atualizado: `artifacts.skills.L1[]` populado; `framework.phase` → `Tier 1 + Tier 2 generic skills delivered: 6/9`

### Pendente em Forge-1

- 4 skills Acme-específicas em `examples/acme/skills/` (F1.6 — escopo opcional)
- Validação empírica do `≥70% redução de tokens` (medível só em Forge-3 com Langfuse)

---

## [Próximas ondas]

### Forge-1 (resíduo) — Acme examples

- 4 skills em `examples/acme/skills/` (`tenant-onboarding`, `outcome-classifier`, `billing-calculator`, `flywheel-collector`)

### Forge-2 — Slash commands

- 11 commands do pipeline `/diagnose → /spec → /unit-economics → /sla → /plan → /tasks → /implement → /eval → /promote → /audit-monthly → /pre-merge-check`

### Forge-3 — Subagents Guardian + Reviewer

- 8 Guardians + 2 Cross-LLM reviewers
- ADR-002: stack do reviewer DeepAgents/GPT-5.5
- Primeira auditoria mensal de teste

### Forge-4 — Hooks runtime

- Hooks PreToolUse, PostToolUse, Stop ativos
- `manifest-sync` automatizado
- Bypass auditado (`ACME_FORGE_BYPASS=incident`)

### Forge-5 — Playbooks verticais (contínuo)

- Extração de playbooks pós primeiro cliente em AUTONOMOUS
- Reavaliação F2 (promoção a `~/.claude/` global) e F5 (plugin marketplace)

---

## Convenções deste arquivo

- Datas em formato ISO `YYYY-MM-DD`
- Toda mudança de Constitution exige nova ADR no projeto consumidor
- Bump MAJOR exige comunicação ao reviewer DeepAgents (atualizar prompt)
