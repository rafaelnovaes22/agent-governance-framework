# Novais Digital Foundry

> Read this in [Portuguese](README.pt-BR.md).

> A governance framework for projects that deliver a **billable outcome**: AI agents, SaaS and operational platforms, or automations.
> Reproducible by **human devs (Claude Code)**, by **autonomous reviewers (DeepAgents / GPT-5.5)** and by other agent harnesses.

[![Version](https://img.shields.io/badge/version-0.24.0-blue)](./CHANGELOG.md)
[![License](https://img.shields.io/badge/license-PolyForm%20Noncommercial%201.0.0-red)](./LICENSE.md)
[![Phase](https://img.shields.io/badge/phase-Foundry--21-orange)](./docs/foundry/roadmap.md)
[![Reviewer](https://img.shields.io/badge/reviewer-DeepAgent%20%2F%20GPT--5.5-purple)](./reviewer/)
[![Project Types](https://img.shields.io/badge/project__types-agentic__saas%20%7C%20platform%20%7C%20automation%20%7C%20hybrid-success)](./templates/project.template.json)

---

## The problem it solves

Building AI agents that deliver a **billable outcome** (a qualified lead, a resolved ticket, a generated analysis) has failure modes that kill projects quietly:

- A spec with no contractual clause, which turns into an endless dispute about what counts as delivered
- Inference cost above the price of the outcome, which means negative margin at volume
- Promotion from demo to production with no evals, so quality drift goes undetected
- Heroic per-customer customization, which does not scale and turns the company into an agency
- No telemetry, so nothing can be audited

Foundry answers that with:

1. A **versioned constitution** (8 principles, [`.claude/CONSTITUTION.md`](./.claude/CONSTITUTION.md))
2. **Core templates** (spec, ADR, eval case, unit economics, lifecycle, audit) in [`templates/`](./templates/)
3. A machine-readable **auditable manifest**, [`docs/foundry/manifest.json`](./docs/foundry/manifest.json)
4. An **independent external reviewer** (DeepAgent / GPT-5.5) with a formal contract, [`reviewer/`](./reviewer/)
5. **9 active runtime hooks** with audited bypass (PreToolUse x4, PostToolUse x3, Stop x2), [`hooks/`](./hooks/)
6. **12 slash commands** covering the diagnose → promote → audit pipeline, [`.claude/commands/`](./.claude/commands/)
7. **10 Guardian subagents** (4 Opus + 4 Sonnet + 2 cross-LLM), [`.claude/agents/`](./.claude/agents/)
8. **9 skills** in 3 tiers (L0/L1/L2) using the BMAD helper pattern, [`.claude/skills/`](./.claude/skills/)

---

## Three kinds of consumer

Foundry is designed for three audiences, each with its own entry point:

| Consumer | Entry point | What they do |
|---|---|---|
| 👤 **Human dev** using Claude Code | [`QUICKSTART.md`](./QUICKSTART.md) then [`INSTALL.md`](./INSTALL.md) | Installs it in a new or existing project; uses skills and commands in the editor |
| 🤖 **DeepAgent / GPT-5.5** (autonomous reviewer) | [`DEEPAGENT_GUIDE.md`](./DEEPAGENT_GUIDE.md) then [`reviewer/prompt.template.md`](./reviewer/prompt.template.md) | Reads the manifest, validates the principles, emits the monthly report |
| 🛠️ **Foundry maintainer** | [`CONTRIBUTING.md`](./CONTRIBUTING.md) then [`CLAUDE.md`](./CLAUDE.md) | Adds skills, commands and templates to the framework |

---

## What it is not

- Not a generic Claude Code starter kit (there are dozens)
- Not a process methodology (the methodology lives with whoever operates the Foundry, see `examples/novais-digital/`)
- Not an agent SDK (LangGraph, CrewAI and AutoGen already fill that role)
- Not a platform. It is a set of **conventions plus automations** on top of Claude Code

Details in [`docs/foundry/out-of-scope.md`](./docs/foundry/out-of-scope.md).

---

## The 8 constitutional principles

Versioned in [`.claude/CONSTITUTION.md`](./.claude/CONSTITUTION.md):

1. **C1** Diagnose before design
2. **C2** Outcome first, never tech first
3. **C3** Cost at or below 25% of price
4. **C4** SHADOW mode before billing
5. **C5** Three-tier context (strategic / tactical / operational)
6. **C6** Telemetry by default (split in v0.22.0 into `llm_trace_provider` LangSmith and `analytics_provider` WireLog)
7. **C7** Portability over lock-in
8. **C8** No heroic customization

These are generic. Domain-specific extensions live in `examples/{domain}/constitution-extension.md`.

---

## Current status

| Wave | Status | Delivered |
|---|---|---|
| **Foundry-0** Foundation | ✅ Done | Constitution, settings, manifest, 12 templates, multi-consumer docs, reviewer enablement, examples/novais-digital |
| **Foundry-1** L0/L1/L2 skills | ✅ Done | 9 generic skills (3 L0 + 3 L1 + 3 L2) with the BMAD helper pattern documented |
| **Foundry-2** Slash commands | ✅ Done | 12 commands covering diagnose → promote → audit → playbook-extract |
| **Foundry-3** Guardian subagents + reviewer | ✅ Done | 10 agents (8 Guardians + 2 cross-LLM) plus the DeepAgent reviewer infrastructure |
| **Foundry-4** Runtime hooks | ✅ Done (v0.3.0) | 9 active hooks, audited bypass, standalone skill security scan |
| **Foundry-5** Vertical playbooks (infrastructure) | ✅ Delivered (v0.4.0) | Playbook and retrospective templates, `/novais-digital:playbook-extract`; real content waits for the first AUTONOMOUS SKU |

**Open items on the consumer side:** reviewer ADR-002, the first trial monthly audit, and the first SKU reaching AUTONOMOUS so a real playbook can be extracted.

Full roadmap in [`docs/foundry/roadmap.md`](./docs/foundry/roadmap.md).

---

## Repository layout

```
agent-governance-framework/
├── README.md                        ← this file
├── QUICKSTART.md                    ← install in 5 minutes
├── ARCHITECTURE.md                  ← structure and flows
├── INSTALL.md                       ← detailed manual install
├── CONTRIBUTING.md                  ← how to evolve the framework
├── DEEPAGENT_GUIDE.md               ← how an autonomous agent navigates the Foundry
├── GLOSSARY.md                      ← shared vocabulary
├── CLAUDE.md                        ← meta-doc for framework devs
├── CLAUDE.md.template               ← template for a consumer project
├── CHANGELOG.md                     ← version history
│
├── .claude/
│   ├── CONSTITUTION.md              ← the 8 generic principles
│   ├── settings.json                ← permissions and hooks (Foundry layer)
│   ├── skills/                      ← 9 generic skills in 3 tiers
│   │   ├── L0/  (company-dna, icp-loader, offerings-loader)
│   │   ├── L1/  (baseline-cost-builder, diagnostic-runner, process-mapper)
│   │   └── L2/  (artifact-prompt-builder, eval-case-author, shadow-mode-runner)
│   ├── agents/                      ← 10 Guardian and cross-LLM subagents
│   │   ├── po-guardian.md, artifact-architect.md, unit-economist.md
│   │   ├── promotion-officer.md, eval-engineer.md, tenant-context-curator.md
│   │   ├── observability-guardian.md, security-privacy-guardian.md
│   │   └── code-reviewer-claude.md, code-reviewer-cross.md
│   └── commands/novais-digital/     ← the 12 pipeline slash commands
│       ├── diagnose.md, spec.md, unit-economics.md, sla-threshold.md
│       ├── plan.md, tasks.md, implement.md
│       ├── eval.md, promote.md, audit-monthly.md
│       ├── pre-merge-check.md, playbook-extract.md
│
├── hooks/                           ← 9 runtime hooks plus the CI script
│   ├── pre-tool-use/   (outcome-clause-guard, adr-approval-gate, secret-scan, any-type-guard)
│   ├── post-tool-use/  (llm-trace-check/langfuse-trace-check legacy, unit-economics-recalc, manifest-sync)
│   ├── stop/           (5-gates-summary, eval-suite-fresh)
│   └── scripts/        (skill-security-scan.sh, standalone CI)
│
├── docs/foundry/                    ← internal framework documentation
│   ├── README.md                    ← overview
│   ├── decisions.md                 ← F1 to F21 plus extensions
│   ├── roadmap.md                   ← the 5 waves
│   ├── reviewer-contract.md         ← contract with the reviewer
│   ├── manifest.json                ← machine-readable inventory
│   ├── out-of-scope.md              ← what stays out
│   ├── helper-pattern.md            ← BMAD helper pattern (L0, cache)
│   ├── bypass-log/                  ← record of hook bypasses
│   └── session-gate-reports/        ← automatic end-of-session reports
│
├── templates/                       ← 12 core generic templates
│   ├── adr.template.md
│   ├── adr-reviewer-runtime.template.md  ← ADR-002 for the consumer
│   ├── platform-sku-spec.template.md
│   ├── product-spec.template.md
│   ├── diagnostic-spec.template.md
│   ├── eval-case.template.md
│   ├── unit-economics.template.md
│   ├── lifecycle-stage.template.md
│   ├── monthly-audit.template.md
│   ├── clickup-blueprint.template.md
│   ├── playbook.template.md         ← reusable vertical blocks (Foundry-5)
│   └── retrospective.template.md    ← per-SKU retrospective after AUTONOMOUS
│
├── reviewer/                        ← DeepAgent reviewer enablement
│   ├── README.md                    ← index and reading order
│   ├── prompt.template.md           ← system prompt
│   ├── output-schema.json           ← JSON schema of the report
│   ├── validation-rules.json        ← machine-readable checks
│   ├── example-audit.md             ← sample report
│   └── deepagents/                  ← 10 SKILL.md files converted for the DeepAgents CLI
│       ├── README.md
│       ├── conversion-log.md
│       └── skills/
│
├── docs/playbooks/                  ← vertical playbooks (after the first AUTONOMOUS customer)
├── docs/retrospectives/             ← per-SKU retrospectives
│
└── examples/                        ← real use cases used as reference
    └── novais-digital/              ← the Novais Digital case (the Foundry's own operator)
        ├── README.md
        ├── methodology/
        ├── portfolio.md
        ├── constitution-extension.md
        ├── clickup-blueprint.md
        └── products/
            ├── novais-fin.md
            └── novais-educacional.md
```

---

## Getting started

### I am a dev and want to use Foundry in a new project

```bash
git clone https://github.com/rafaelnovaes22/agent-governance-framework.git
cd /path/to/your/project
# follow the steps in INSTALL.md

# after installing, validate framework consistency:
bash scripts/foundry-doctor.sh
```

See also [`QUICKSTART.md`](./QUICKSTART.md) and [`ARCHITECTURE.md`](./ARCHITECTURE.md).

### I am a DeepAgent and want to audit a project that uses Foundry

1. Read [`reviewer/prompt.template.md`](./reviewer/prompt.template.md) and load it as the system prompt
2. Take the consumer project's `manifest.json` as input
3. Run the checks defined in [`reviewer/validation-rules.json`](./reviewer/validation-rules.json)
4. Emit the report following [`reviewer/output-schema.json`](./reviewer/output-schema.json)
5. Full detail in [`DEEPAGENT_GUIDE.md`](./DEEPAGENT_GUIDE.md)

### I am a maintainer and want to evolve Foundry

[`CONTRIBUTING.md`](./CONTRIBUTING.md) describes the process (issue → branch → PR → versioning).

---

## Versioning

Strict SemVer:

- **MAJOR**: a constitutional break (a principle removed or reworded)
- **MINOR**: a completed Foundry wave (a new capability)
- **PATCH**: a template, doc or hook fix that does not change a contract

Current version in [`docs/foundry/manifest.json`](./docs/foundry/manifest.json) under `framework.version`.

---

## The philosophy in one sentence

> Every new AI agent in production automatically inherits a structured diagnosis, a contractual outcome spec, a unit economics gate, an SLA threshold and SHADOW to AUTONOMOUS promotion, with an independent external audit performed by a DeepAgent.

---

## License

Copyright (c) 2026 Rafael Novaes.

Licensed under the [PolyForm Noncommercial License 1.0.0](./LICENSE.md): reading, study and non-commercial use are allowed; commercial use requires express authorization from the author.
