# Auditoria de Pendências — Novais Digital Foundry

> **Data**: 2026-05-13
> **Versão auditada**: v0.12.0 (Foundry-12 Fase 2)
> **Trigger**: primeira adoção real do framework por consumidor (Novais Digital Social)
> **Auditor**: Claude Code (Opus 4.7 1M ctx) — sessão interna do mantenedor
> **Status**: 📋 Planejamento (NÃO implementar nada a partir deste doc até decisão de roadmap)

---

## Diagnóstico

A v0.12.0 concluiu **toda a camada Surface** (HELLO, quickstarts, scripts/foundry, PLAYGROUND, COMMON_ERRORS, friendly-errors hook) e o framework tecnicamente cobre os 4 `project_type` × 2 `ai_enabled`. **Mas a primeira adoção real (Novais Digital Social, hoje) expôs que o framework ainda fala como criador, não como consumidor**: `foundry-doctor` foi escrito assumindo que é executado dentro do próprio repo canônico, e o consumidor recebe ~65 falsos warnings + 2 fails que confundem o operador. Também foi expandido em ondas (Foundry-9/10/11/12) com algumas inconsistências de metadados que se acumularam sem auditoria — manifest tem 7 entries com `version` desatualizado vs `manifest_version: 0.12.0`, e há **uma colisão real de IDs**: existem dois "F26" em `decisions.md` (linha 10 — Foundry-9; linha 527 — Foundry-10). Por fim, **dois itens de UX que o master-prompt promete (foundry-router + persona auto-detect) ainda não existem**, o que mantém a porta de entrada `vibe` mais aspiracional do que operacional.

Resumo em números: **6 P0** (bloqueadores reais), **9 P1** (degradam UX), **8 P2** (nice-to-have) = **23 pendências catalogadas**, das quais 8 já estão no roadmap (Foundry-12 Fase 3 + Foundry-5 dependências) e 15 são novas/escondidas.

---

## Rota proposta

1. **Foundry-13 — Consumer-mode hardening** (~3-4 dias): resolve P0/P1 que bloqueiam adoção (foundry-doctor `--consumer`, sync script foundry→consumidor, correção de F26 duplicado + metadados obsoletos, fixes de descrições no manifest). **Sem novas capabilities** — apenas torna o framework "consumível" sem fricção de mantenedor.
2. **Foundry-14 — Surface Layer Fase 3** (~3-5 dias): entrega `foundry-router` subagent + persona auto-detect + GLOSSARY_PLAIN standalone + PLAYGROUND/04-automation. Completa promessa de UX feita em Foundry-11/12.
3. **Foundry-15 — Real-world validation onda 1** (~5-7 dias): adoção formal por Aicfo e EduPlatform + primeira auditoria mensal real do `edu-platform` (F9.13) + primeiro playbook vertical do Novais Digital Social pós-AUTONOMOUS.
4. **Foundry-16+ longer-term**: plugin marketplace (reaval F21), publicação npm/pip, multi-language reviewer (Anthropic + OpenAI + Gemini).

---

## Riscos

- **Sync foundry↔consumidores ad-hoc**: cada bump de versão exige operador lembrar de `cp -r` artefatos canônicos. Sem script de sync + validação `framework_version_required`, drift silencioso é certo em ≤3 meses.
- **foundry-router pode virar scope creep**: parse de linguagem natural → comando é fronteira ambígua. Sem critério claro de "quando o router se rende e devolve controle", risco de virar reescrita do master-prompt.
- **PLAYGROUND quebra com bumps**: exemplos têm hashes/refs que vão divergir quando a Constitution evoluir. Sem teste automático que rode os 3 walkthroughs em CI a cada release, vira documentação morta em 6 meses.
- **F26 duplicado** já está em produção (v0.8.0 e v0.9.0 ambos referenciam "F26"). Renumerar quebra histórico em ADRs já assinadas no consumidor. Tem que ser uma **emenda explícita** (F26-a / F26-b ou F26 mantida + nova F26-bis), não rebatismo.
- **LGPD/GDPR no sync script**: se o futuro `foundry sync` ler `.env` ou logs do consumidor para validação, vira coletor de dados sensíveis. Manter scope exclusivamente em `docs/foundry/`, `.claude/`, `templates/`, `hooks/`, `scripts/` — **nunca tocar src/, .env, data/**.
- **C7 (portability)**: nenhuma das pendências propostas pode acoplar provider específico. Em especial, `foundry-router` não pode assumir Claude Code (precisa funcionar com DeepAgent também).

---

## Próximo passo

**Decisão pendente do mantenedor**:
- Aprovar/ajustar agrupamento Foundry-13/14/15
- Decidir tratamento de F26 duplicado (manter ambos + adicionar `(a)`/`(b)` ou renomear segundo como F26-bis)
- Priorizar entre Foundry-13 (consumer hardening) e Foundry-14 (Surface Fase 3) — opinião do auditor: **Foundry-13 primeiro**, porque sem ele a adoção de Aicfo/EduPlatform vai sangrar.

---

## Outputs esperados

- ✅ Este documento (`docs/foundry/AUDIT_2026-05-13_pendencias.md`) — entregue
- ⏳ Roadmap.md atualizado com Foundry-13/14/15 — **aguarda decisão**
- ⏳ Issues GitHub abertas para cada P0 — **aguarda decisão**
- ⏳ Patch `foundry-doctor --consumer` se Foundry-13 aprovada — **fora do escopo deste audit**

---
---

# Seção 1 — Pendências priorizadas

Total: **23 pendências**. P0 = 6 bloqueadores reais, P1 = 9 importantes, P2 = 8 nice-to-have.

## 🔴 P0 — Bloqueadores reais (adoção ou UX quebrada)

### F30 — `foundry-doctor.sh --consumer` mode
- **Nome**: Modo consumidor do foundry-doctor (suprime falsos órfãos)
- **Por que importa**: Em Novais Digital Social hoje, `foundry-doctor` gera ~65 warnings de "artefato órfão" (porque manifest local não duplica entries do framework) + 2 FAILs sobre `reviewer/` ausente. Operador novo vê tela vermelha logo na primeira execução e desconfia do framework inteiro.
- **Esforço**: 4-6h (adicionar flag `--consumer`/auto-detect via ausência de `docs/foundry/` próprio do framework, condicionar checks C6/reviewer)
- **Bloqueia**: adoção fluida por Aicfo, EduPlatform, futuros consumidores
- **Tipo**: bug (regressão de UX em consumidores)

### F31 — Resolver F26 duplicado em decisions.md
- **Nome**: Renomear segunda F26 (Foundry-10 TDD) para F26-bis ou similar
- **Por que importa**: ID colidente em decisions canônicas — afeta rastreabilidade do reviewer DeepAgent que cita "F26" em prompt. Audits geradas hoje referenciam "F26" ambiguamente.
- **Esforço**: 1-2h (decisão de nomenclatura + edição + grep cross-repo + bump PATCH)
- **Bloqueia**: confiabilidade do reviewer DeepAgent (ele cita IDs); fica esquisito em ADRs do consumidor que referenciam F26
- **Tipo**: bug (dívida histórica)

### F32 — Script `foundry sync` para consumidores
- **Nome**: Sync artefatos canônicos foundry → consumidor com validação de versão
- **Por que importa**: Hoje `cp -r` manual. Sem isso, todo bump (12 ondas em 7 semanas) vai gerar drift silencioso em consumidores. Bloqueia também rollback de versão e auditoria de "qual versão do Foundry cada cliente está rodando".
- **Esforço**: 1-1.5 dias (script + manifest_consumer.json com `framework_version_required` + verificação cross-version + dry-run + relatório diff)
- **Bloqueia**: manutenção sustentável quando >2 consumidores em produção
- **Tipo**: feature
- **Risco C7**: implementar como bash + node (já no stack), não introduzir Python/Go novo

### F33 — Metadados desatualizados no manifest
- **Nome**: Corrigir 7+ entries com `version` obsoleto + descrições stale
- **Por que importa**: `foundry-decisions.description` diz "F1-F26" mas chega em F29; `foundry-roadmap.description` diz "7 ondas" mas são 12; `foundry-decisions.version: 0.8.0`, `foundry-roadmap.version: 0.6.0`, `foundry-manifest.version: 0.9.0`, `claude-md-meta.version: 0.9.0`, `install.version: 0.9.0`, `changelog.version: 0.9.0` — manifest está em 0.12.0. Reviewer faz match por versão → relatórios podem reportar drift falso ou desatualizado.
- **Esforço**: 2-3h (varredura + atualização + recálculo sha256 + validação `foundry-doctor.sh`)
- **Bloqueia**: precisão do reviewer mensal (F9.13 — primeira auditoria real)
- **Tipo**: bug (drift documental)

### F34 — `foundry-router` subagent
- **Nome**: Subagent que traduz linguagem natural → pipeline `/novais-digital:*`
- **Por que importa**: Master-prompt promete "operador CEO vibecoder não precisa conhecer slash commands" mas hoje precisa. Promessa quebrada de Foundry-11/12. Quebra a porta de entrada `vibe`.
- **Esforço**: 1.5-2 dias (criar `.claude/agents/foundry-router.md` Sonnet, decidir 6-8 intents canônicos, mapeamento intent→comando+args, fallback para "não entendi, sugiro X")
- **Bloqueia**: modo vibe operacional para CEO real (Ana — F12.x critério de pronto)
- **Tipo**: feature
- **Risco scope creep**: limitar a 6-8 intents canônicos na v1; **não** tentar parse genérico de linguagem natural; sempre devolver controle ao master-prompt quando incerto

### F35 — Modo persona auto-detect
- **Nome**: Detecção automática vibe/dev/agent baseada em comportamento
- **Por que importa**: Hoje exige `foundry mode vibe`. CEO real nunca vai rodar esse comando. Sem auto-detect, modo vibe é teoricamente disponível mas nunca acionado.
- **Esforço**: 1 dia (heurística simples: linguagem do prompt + presença de jargão técnico + comandos digitados nos últimos N turnos; persistir em `.foundry-mode` mas com `auto:true`; permitir override)
- **Bloqueia**: friendly-errors funcionar para CEO real (hoje sempre cai em modo `dev` default)
- **Tipo**: feature
- **LGPD**: a heurística NÃO pode coletar conteúdo do prompt — só sinais agregados (presença de jargão sim/não, sem armazenar a string)

---

## 🟡 P1 — Importante (degrada UX, não bloqueia)

### F36 — PLAYGROUND/04-automation
- **Nome**: 4º exemplo executável (RPA/jobs)
- **Por que importa**: Foundry-9 declarou `project_type=automation` como suportado, mas PLAYGROUND tem só 3 (agentic/platform/hybrid). Consumidor RPA não tem walkthrough.
- **Esforço**: 4-6h (espelhar estrutura de 02-platform-module + walkthrough job scheduler simples + project.json)
- **Bloqueia**: nada hoje (nenhum consumidor RPA declarado), mas mantém promessa F9 fechada
- **Tipo**: doc / feature

### F37 — Sync drift detector standalone
- **Nome**: Check em `foundry-doctor.sh` (rodando no consumidor) para detectar `framework_version_required` < `framework.version` canônico
- **Por que importa**: Detectar consumidores desatualizados sem precisar do humano rodar sync manualmente. Complementar a F32.
- **Esforço**: 3-4h (precisa de fonte de verdade publicada — pode ser arquivo `latest.json` no repo Foundry servido via raw.githubusercontent ou commit hash recente)
- **Bloqueia**: nada agudo
- **Tipo**: feature

### F38 — `templates/playbook.template.md` ainda não consumido
- **Nome**: Primeiro playbook vertical real (depende de cliente 1 em AUTONOMOUS)
- **Por que importa**: F5.1 entregou infraestrutura mas sem playbook real, KPI "cliente N+1 custa ≤30%" não pode ser medido.
- **Esforço**: 2-3 dias (mas precisa de Novais Digital Social ou outro em AUTONOMOUS primeiro — não é trabalho do framework, é trabalho do consumidor)
- **Bloqueia**: validação real de Foundry-5
- **Tipo**: doc (responsabilidade do consumidor)

### F39 — ADR-002 do consumidor (reviewer runtime)
- **Nome**: Primeira ADR-002 assinada em projeto consumidor decidindo onde rodar DeepAgent
- **Por que importa**: F3.6 pendente; template existe (`adr-reviewer-runtime.template.md`) mas nenhum consumidor assinou. Sem ADR-002, reviewer mensal não roda.
- **Esforço**: 1 dia (decidir local — GitHub Actions vs Render workers vs Modal; documentar custo/latência; assinar)
- **Bloqueia**: primeira auditoria mensal real (F9.13)
- **Tipo**: doc (responsabilidade do consumidor — Novais Digital Social ou EduPlatform)

### F40 — Primeira auditoria mensal real (`edu-platform` platform)
- **Nome**: F9.13 — stress test da v0.8.x em projeto `platform`
- **Por que importa**: Foundry-9 generalizou para platform mas nunca foi exercitada com auditoria real. Bugs prováveis no ramo `applies_when: ai_enabled=false`.
- **Esforço**: 0.5 dia (rodar reviewer) + 0.5-1 dia (corrigir bugs detectados)
- **Bloqueia**: confiabilidade do framework para projetos `platform`
- **Tipo**: validation

### F41 — CI automatizado dos walkthroughs PLAYGROUND
- **Nome**: Workflow GitHub Actions que valida que os 3 PLAYGROUND/walkthroughs rodam end-to-end a cada release
- **Por que importa**: Sem isso, PLAYGROUND fica desatualizado em ≤3 versões. Hoje é doc, vira documentação morta.
- **Esforço**: 1 dia (workflow + scripts headless para cada walkthrough)
- **Bloqueia**: confiabilidade do exemplo como onboarding tool
- **Tipo**: feature / test
- **Risco**: walkthroughs incluem invocação de LLM real → custo + flakiness. Mitigação: mock LLM calls com fixtures + apenas validar que comandos não-LLM passam

### F42 — `INSTALL.md` desatualizado vs realidade Foundry-12
- **Nome**: Revisar INSTALL.md para refletir HELLO + scripts/foundry
- **Por que importa**: INSTALL.md está em version 0.9.0 (pré-Surface). Novo consumidor pula HELLO.md e segue INSTALL desatualizado.
- **Esforço**: 2-3h
- **Bloqueia**: adoção de qualquer novo consumidor que abrir INSTALL primeiro
- **Tipo**: doc

### F43 — Versionar e validar templates AIOS
- **Nome**: Schema check para `templates/aios/agents/*/config.json.template`
- **Por que importa**: 6 agentes com config JSON sem schema validado — drift entre eles é certo. foundry-doctor C8 só checa `test_agent`.
- **Esforço**: 4-6h (criar JSON schema para config dos agentes + adicionar check C8.6 no doctor)
- **Bloqueia**: confiabilidade dos templates AIOS após próximo bump
- **Tipo**: feature / test

### F44 — Hook `friendly-errors` cobre só 9 padrões
- **Nome**: Expandir cobertura para 15+ padrões + observação real em Novais Digital Social
- **Por que importa**: Foundry-12 Fase 2 entregou 9 padrões mas critério de "validação real" não foi cumprido. Pode haver padrões críticos descobertos via uso (ex: erros do AIOS pipeline, erros do reviewer DeepAgent).
- **Esforço**: 0.5 dia (observar logs de Novais Digital Social por 1-2 semanas + adicionar padrões emergentes)
- **Bloqueia**: cumprir critério "8+ padrões úteis em uso real" da Fase 2
- **Tipo**: feature

---

## 🟢 P2 — Nice-to-have (melhora mas não impacta uso atual)

### F45 — `GLOSSARY_PLAIN.md` standalone
- **Nome**: F12.13 — extrair glossário leigo do QUICKSTART_VIBE para arquivo próprio
- **Esforço**: 2-3h
- **Tipo**: doc

### F46 — Plugin marketplace (reaval F21)
- **Nome**: Reavaliação de publicar Foundry como plugin Claude Code marketplace
- **Esforço**: 2-3 dias se decisão for "publicar"; trigger: ≥3 consumidores em AUTONOMOUS
- **Tipo**: feature (futuro)

### F47 — Multi-provider reviewer
- **Nome**: Suportar reviewer rodando em Gemini ou Anthropic (hoje só GPT-5.5 via DeepAgents)
- **Esforço**: 1-2 dias
- **Tipo**: feature
- **Risco C7**: requer abstração de provider no reviewer skill

### F48 — Telemetria interna do próprio framework
- **Nome**: Logging anônimo de uso (com opt-in) — quais comandos mais usados, quais hooks bloqueiam mais
- **Esforço**: 1 dia
- **Tipo**: feature
- **LGPD/GDPR**: opt-in explícito; sem dados de conteúdo (só counters); local-first com sync opcional

### F49 — Documentar processo de SemVer breaking
- **Nome**: Adicionar seção em CONTRIBUTING.md sobre como tratar MAJOR bumps em consumidores ativos
- **Esforço**: 2h
- **Tipo**: doc

### F50 — `foundry upgrade` command
- **Nome**: Wrapper sobre `foundry sync` que orquestra upgrade incluindo migração de schemas
- **Esforço**: 1.5 dias (depende de F32)
- **Tipo**: feature

### F51 — Internacionalização do master-prompt
- **Nome**: Versões `master-prompt.{en,es}.md` (hoje só PT)
- **Esforço**: 1 dia (revisão tradução + manter sincronia entre versões)
- **Tipo**: feature (futuro)

### F52 — Foundry dashboard
- **Nome**: Página HTML estática que renderiza manifest.json como UI navegável
- **Esforço**: 1-2 dias
- **Tipo**: feature (futuro)

---

# Seção 2 — Auditoria de qualidade dos artefatos existentes

## Skills L0/L1/L2 (9 skills)

| Categoria | Status | Observações |
|---|---|---|
| L0 (3) | ✅ Sólidas | `company-dna`, `icp-loader`, `offerings-loader` — sem duplicação |
| L1 (3) | ✅ Sólidas | Cadeia explícita diagnostic→baseline→mapper validada |
| L2 (3) | ✅ Sólidas com nota | `shadow-mode-runner` assume `ai_enabled=true` (correto via `applies_when`, mas operador platform pode tentar invocar e receber erro confuso) |
| Coverage Tier 1 reduction | ⏳ Não medida | Helper pattern declara meta de ≥70% redução de tokens. Sem Langfuse integrado em uso real, não há medição. |

**Gap**: Nenhuma skill para o ciclo *platform*-puro (sem AIOS). L1 `baseline-cost-builder` v0.2.0 cobre `platform_margin` mas não há equivalente platform para `eval-case-author` (porque platform usa E2E, não LLM evals — talvez não precise, mas vale documentar explicitamente).

**Performance**: As L2 são longas (>500 linhas cada). Em sessão real do consumidor, isso consome ~15-20% do context window logo no boot — observar se vira problema com context-heavy SKUs.

## Slash commands (15 commands)

| Command | Versão | Status |
|---|---|---|
| diagnose, spec, plan, tasks, implement, eval, promote | 0.2.0-0.3.0 | ✅ Maduros, ramificados delivery-type |
| unit-economics, sla-threshold, pre-merge-check, audit-monthly, playbook-extract | 0.1.0-0.2.0 | ✅ OK |
| aios-init, aios-run, aios-status | 0.1.0-0.2.0 | ✅ OK |

**Comando faltando**: `/novais-digital:sync` (alias para script F32) — para CEO/dev poder sincronizar Foundry do consumidor sem sair do Claude Code. **Esforço estimado**: 1h se F32 já existir.

**Comando faltando candidato**: `/novais-digital:status` — overview rápido (qual versão Foundry, project_type, subscriptions ativas, gates pendentes). Hoje precisa rodar 3-4 comandos para ter essa visão. **Esforço**: 4-6h.

## Guardians (10 subagents)

Cobertura por princípio:

| Princípio | Guardian responsável | Cobertura |
|---|---|---|
| C1 | po-guardian | ✅ |
| C2 | po-guardian | ✅ |
| C3 | unit-economist | ✅ |
| C4 | eval-engineer, promotion-officer | ✅ |
| C5 | artifact-architect | ✅ |
| C6 | observability-guardian | ✅ |
| C7 | tenant-context-curator, artifact-architect | ✅ |
| C8 | tenant-context-curator | ✅ |
| LGPD/PII | security-privacy-guardian | ✅ |
| Code review | code-reviewer-claude, code-reviewer-cross | ✅ |

**Gap**: Nenhum Guardian dedicado a *platform/automation*. Hoje todos os Guardians foram desenhados para `agentic_saas` e respondem para `platform` via `applies_when`. Funciona, mas falta um `platform-guardian` que valida `audit_log_provider`, `acceptance-report`, `delivery-economics` com mesmo rigor que `unit-economist` valida `cost_per_outcome`.
- **Estimado**: 1 dia para criar
- **Decisão pendente**: vale criar ou expandir Guardians existentes?

**Redundância**: `artifact-architect` e `tenant-context-curator` ambos checam C7. Não é problema (defesa em profundidade) mas vale documentar quem é canônico para "first opinion".

## Hooks (11 .sh files = 10 hooks runtime + 1 standalone script)

| Tipo | Count | Status |
|---|---|---|
| PreToolUse | 4 | ✅ outcome-clause-guard, adr-approval-gate, secret-scan, any-type-guard |
| PostToolUse | 4 | ✅ manifest-sync, langfuse-trace-check, unit-economics-recalc, friendly-errors |
| Stop | 2 | ✅ 5-gates-summary, eval-suite-fresh |
| Scripts | 1 | ✅ skill-security-scan.sh |

**Falsos positivos prováveis**: `secret-scan` provavelmente flagga URLs com tokens em walkthroughs do PLAYGROUND. Verificar em F41.

**Cobertura faltando**:
- Hook para AIOS pipeline (validar que `tests/{module}/` tem RED phase antes de build) — hoje é check no workflow CI, não hook local. Considerar `pre-tool-use/tdd-red-check.sh`.
- Hook para detectar tentativa de editar PLAYGROUND/walkthrough sem atualizar version (drift).

## Templates (19 templates)

| Tipo | Cobertura |
|---|---|
| Specs agentic (sku, product, diagnostic) | ✅ |
| Specs platform (module, pilot-state, acceptance) | ✅ |
| Economics (unit, delivery) | ✅ |
| Governance (ADR, retrospective, playbook) | ✅ |
| AIOS (6 agentes + orchestrator + config) | ✅ |
| CI/CD (5 templates) | ✅ |
| Master prompt (universal) | ✅ |
| Outras (eval-case, lifecycle, clickup-blueprint, monthly-audit) | ✅ |

**Faltando**:
- `automation-job-spec.template.md` declarado em F26 mas não consta nos arquivos templates/ (verificar — o `platform-module-spec` é citado como cobertura para `automation`?) — **investigar e formalizar**
- Template `adr-tenant-onboarding.template.md` (não-bloqueador, recorrente em consumidores)
- Template `master-prompt.{en,es}.md` (P2 F51)

## Reviewer DeepAgent

| Asset | Versão | Sincronia com framework |
|---|---|---|
| prompt.template.md | 0.3.0 | ✅ Cobre F26 (Foundry-9), mas **NÃO menciona Foundry-10 TDD-first nem Foundry-11/12** explicitamente |
| output-schema.json | 0.2.0 | ✅ |
| validation-rules.json | 0.3.0 | ✅ |
| 10 SKILL.md convertidas | varia | ✅ Foundry-9.12 atualizou applies_when |

**Gap crítico**: prompt v0.3.0 não foi atualizado para Foundry-10/11/12. Auditoria mensal real pode não checar:
- TDD red phase (Foundry-10) — coverage por tier
- Master prompt instalado no consumidor (Foundry-11)
- friendly-errors hook ativo (Foundry-12 Fase 2)

**Esforço para atualizar**: 0.5 dia (bump para 0.5.0 cobrindo F26-bis + F27 + F29). **P0 oculto** — vou propor como F33-bis (anexar a F33).

## CI/CD

5 workflows entregues (validate, eval, audit, test, checklist). Cobertura:

| Check foundry-doctor | Workflow CI cobre? |
|---|---|
| C1 JSON parse | ✅ validate |
| C2 manifest↔fs | ✅ validate |
| C3 versão coerente | ✅ validate |
| C4 constitution | ✅ validate |
| C5 hooks sintaxe | ✅ validate |
| C6 órfãos | ✅ validate |
| C7 permissions | ✅ validate |
| C8 AIOS TDD-ready | ✅ validate |

**Gap**: Workflow `foundry-validate` é template — consumidor precisa copiar. **Não há equivalente rodando no próprio repo agent-governance-framework**. Reviewer não verifica que o repo canônico passa nos seus próprios gates. **Recomendação**: copiar template para `.github/workflows/foundry-validate.yml` no próprio repo Foundry (dogfooding).

---

# Seção 3 — Pendências documentadas no roadmap

Itens marcados ⏳ em `docs/foundry/roadmap.md`, classificados:

## ✅ Manter (ainda fazem sentido)

| ID | Item | Por que manter |
|---|---|---|
| F1.6 | 4 skills Novais-específicas em `examples/novais-digital/skills/` | Não-bloqueador, mas útil quando Novais Digital SaaS² for migrado |
| F3.6 | ADR-002 do consumidor | **Bloqueador real** — vira P1 F39 acima |
| F3.7 | Primeira auditoria mensal de teste | **Bloqueador real** — F40 acima |
| F5.1 (playbook real) | Playbook vertical real do primeiro cliente | Depende de AUTONOMOUS — F38 |
| F5.3 (retro real) | Retrospectiva do primeiro SKU | Depende de AUTONOMOUS |
| F8 critério ⏳ | Projeto consumidor implementando Wave 6 com Gate 6 | Depende de SKU em ASSISTED |
| F9.13 | Primeira auditoria mensal real de `edu-platform` | **Bloqueador real** — F40 |
| F11.6, F11.7 | Adoção Aicfo/EduPlatform + foundry-router | Renomeados para F34 (router) e dependência de Foundry-15 |
| F12.13-F12.16 | Fase 3 completa | Renomeados F34, F35, F36, F45 |

## 🗑️ Pode ser deletado (não mais relevante)

| ID | Item | Por quê |
|---|---|---|
| Nenhum identificado | — | Tudo no roadmap ainda tem racional |

## 🔄 Mudou de escopo

| ID | Item | Mudança |
|---|---|---|
| F11.6 | "Adoção pelos 3 consumidores" | Hoje 1/3 adotou (Novais Digital Social). Escopo reduz para Aicfo + EduPlatform apenas. |
| F12.16 | "PLAYGROUND 04 automation" | Continua válido mas agora urgência maior — F36 |

---

# Seção 4 — Pendências de adoção (consumidores)

## Novais Digital Social — ✅ Adotou hoje (2026-05-13)

Status: master-prompt referenciado, framework operacional. Pendências:
- ⏳ Primeiro SKU em SHADOW
- ⏳ Primeiro Gate 6 (Wave 6 CI/CD) validado
- ⏳ Primeira retrospectiva real (F5.3)

## Aicfo — ⏳ Não adotou

**Esforço para adotar**: ~0.5-1 dia
- Copiar `templates/master-prompt.md` → `MASTER_PROMPT.md` no Aicfo
- Criar `docs/foundry/project.json` (Aicfo é provavelmente `hybrid` — plataforma com módulos IA)
- Adaptar `CLAUDE.md` local
- Rodar `foundry-doctor` no consumidor (**vai falhar com problemas conhecidos** — exige F30 antes)

**Bloqueado por**: F30 (foundry-doctor --consumer), F32 (sync) preferível mas não obrigatório

## EduPlatform — ⏳ Não adotou

**Esforço para adotar**: ~1 dia
- Copiar artefatos canônicos
- Criar `project.json` (`platform`, `ai_enabled=false`)
- Migrar specs existentes para `platform-module-spec.template.md`
- Validar reviewer cobre branch platform corretamente

**Bloqueado por**: F30 + F40 (primeira auditoria platform real)

## Primeira auditoria mensal real

**Esforço**: 1-2 dias (assumindo EduPlatform ou Novais Digital Social adotaram)
**Bloqueado por**: F39 (ADR-002 reviewer runtime) + adoção formal

---

# Seção 5 — Bugs e dívidas técnicas

## Identificados

| Bug | Severidade | Fix proposto |
|---|---|---|
| **F26 duplicado** em `decisions.md` (linha 10 — Foundry-9; linha 527 — Foundry-10) | 🔴 Alto | F31 |
| **7+ entries com `version` obsoleto no manifest** (foundry-decisions 0.8.0, foundry-roadmap 0.6.0, foundry-manifest 0.9.0, changelog 0.9.0, install 0.9.0, claude-md-meta 0.9.0) vs `manifest_version: 0.12.0` | 🟡 Médio | F33 |
| **Descrição `foundry-decisions` desatualizada** ("F1-F26" mas chega em F29) | 🟡 Médio | F33 |
| **Descrição `foundry-roadmap` desatualizada** ("7 ondas" mas são 12) | 🟡 Médio | F33 |
| **Reviewer prompt v0.3.0** não cita Foundry-10/11/12 → auditoria não vai validar TDD/master-prompt/friendly-errors | 🔴 Alto | F33-bis (anexar a F33) |
| **AIOS templates só `test_agent` validado** em foundry-doctor C8 — outros 5 templates podem driftar | 🟡 Médio | F43 |
| **foundry-doctor.sh fala "C1-C8"** mas são checks internos do doctor, não C1-C8 da Constitution — nomenclatura colide e confunde leitor | 🟢 Baixo | Renomear como D1-D8 |
| **Repo Foundry não roda seus próprios workflows** (templates/cicd/* nunca foi copiado para .github/workflows do agent-governance-framework) | 🟡 Médio | Dogfooding |

## Não identificados ainda (suspeitos)

- Quando `friendly-errors.sh` falha em parse JSON, comportamento exato? (declarado "fallback graceful" — não testado)
- `secret-scan` em PLAYGROUND/walkthrough com sk-fake-... pode flag falso
- `manifest-sync` PostToolUse roda em TODA edição — performance OK em sessão longa?

---

# Seção 6 — Roadmap proposto

## Foundry-13 — Consumer-mode hardening (~3-4 dias)

**Objetivo**: tornar o framework efetivamente consumível por projetos externos sem fricção de mantenedor. Resolve P0 reais.

**Entregáveis**:
- F30 — `foundry-doctor.sh --consumer` (auto-detect ou flag) — 0.5d
- F31 — F26 duplicado resolvido (decisão de nomenclatura + emenda) — 0.25d
- F32 — `foundry sync` script + `manifest_consumer.json` schema — 1.5d
- F33 — Limpeza de metadados obsoletos + descrições + reviewer prompt v0.5.0 — 0.5d
- F37 — Drift detector standalone (depende de fonte de verdade publicada) — 0.5d
- F42 — INSTALL.md atualizado para Surface layer — 0.25d
- Dogfooding: copiar `templates/cicd/*` para `.github/workflows/` do repo Foundry — 0.25d

**Bump**: MINOR (v0.12.0 → v0.13.0)

**Dependências**: nenhuma

**Trade-off aceito**: foco zero em novas capabilities. Vai parecer "release sem novidade" para quem não opera consumidor.

---

## Foundry-14 — Surface Layer Fase 3 (~3-4 dias)

**Objetivo**: cumprir promessas de Foundry-11/12 sobre porta de entrada `vibe`/`agent`.

**Entregáveis**:
- F34 — `foundry-router` subagent (6-8 intents, fallback explícito) — 1.5d
- F35 — Persona auto-detect (heurística sem coletar conteúdo — LGPD) — 1d
- F36 — PLAYGROUND/04-automation — 0.5d
- F45 — GLOSSARY_PLAIN.md standalone — 0.25d
- F44 — Hook friendly-errors expandido com padrões emergentes pós-Novais Digital Social — 0.5d
- F41 — CI workflow valida walkthroughs (com LLM mock) — 1d

**Bump**: MINOR (v0.13.0 → v0.14.0)

**Dependências**: Foundry-13 (sem ele foundry-router cai em sync drift)

**Risco scope creep**: foundry-router precisa ter contrato claro "quando me rendo". Limitar v1 a 6-8 intents.

---

## Foundry-15 — Real-world validation onda 1 (~5-7 dias)

**Objetivo**: validar framework em produção com >1 consumidor + primeira auditoria real platform.

**Entregáveis**:
- F39 — ADR-002 assinada (responsabilidade EduPlatform ou Novais Digital Social) — 1d
- F40 — Primeira auditoria mensal real do `edu-platform` (F9.13) — 0.5d
- Aicfo adoção formal (master-prompt + project.json) — 0.5d (no Aicfo)
- EduPlatform adoção formal — 1d (no EduPlatform)
- F38 — Primeiro playbook vertical real (depende de cliente 1 em AUTONOMOUS) — 2-3d
- Retrospectiva real — 1d
- F43 — Schema validation para templates/aios/*/config.json — 0.5d

**Bump**: PATCH (v0.14.x — sem nova capability no framework, é validação)

**Dependências**: Foundry-13 + Foundry-14

**Trade-off aceito**: maior parte do esforço é em consumidores, não no framework canônico. Pode atrasar se consumidores priorizarem outras coisas.

---

## Foundry-16+ longer-term (escopo aberto)

Candidatos sem onda definida ainda:
- F46 — Plugin marketplace (gatilho: ≥3 AUTONOMOUS)
- F47 — Multi-provider reviewer (Gemini, Anthropic)
- F48 — Telemetria interna opt-in (LGPD-compliant)
- F49 — Doc SemVer breaking
- F50 — `foundry upgrade` orquestrador
- F51 — i18n master-prompt (EN/ES)
- F52 — Foundry dashboard HTML
- Reavaliar F5.5/F5.6 (global install + plugin publicação)

---

# Sumário executivo

| Categoria | Count | % |
|---|---|---|
| 🔴 P0 bloqueadores | 6 | 26% |
| 🟡 P1 importantes | 9 | 39% |
| 🟢 P2 nice-to-have | 8 | 35% |
| **Total** | **23** | **100%** |

**Caminho crítico recomendado**: Foundry-13 (consumer hardening) → Foundry-14 (surface Fase 3) → Foundry-15 (real-world validation). Total estimado: **11-15 dias úteis**.

**Decisão imediata pendente** (mantenedor):
1. Aprovar agrupamento Foundry-13/14/15 ou propor alternativo
2. Decidir tratamento de F26 duplicado (F26-bis vs renomear)
3. Priorizar Foundry-13 antes de Foundry-14 (recomendado pelo auditor)

---

**Fim do documento.** Para implementar pendências aprovadas, abrir issues GitHub por ID (F30, F31, etc.) e seguir CLAUDE.md → "Como adicionar um novo componente".
