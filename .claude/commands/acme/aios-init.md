---
name: acme:aios-init
description: "Scaffolda a estrutura aios/agents/{module}/ para um novo artefato ou módulo"
allowed-tools: [Write, Bash, Read]
arguments:
  required:
    - module
  optional:
    - tier
    - project_root
forge_command_version: 0.1.0
linked_principles: [C5, C6, C7, C8]
invokes_skills: []
output_artifact: aios/agents/{module}_spec_agent/ + aios/agents/{module}_backend_agent/ + aios/agents/{module}_frontend_agent/
trace_required: false
---

# /acme:aios-init

## Propósito

Cria a estrutura de agentes AIOS para um módulo/artefato que ainda não tem agentes configurados.
Deve ser executado após `/acme:spec` e antes de `/acme:implement --via aios`.

> Os SYSTEM_PROMPTs gerados funcionam como **prompts standalone em Claude Code** — sem dependência do kernel AIOS (C7 obrigatório).

## Inputs

```yaml
module: <kebab-case>           # nome do módulo
# opcionais
tier: A | B | C                # A=autônomo, B=iterativo, C=Rafael-dirige (default B)
project_root: <path>           # raiz do projeto consumidor (default: cwd)
```

## Validation gate (pré-criação)

Antes de criar qualquer arquivo, verificar:

```
1. docs/specs/{module}.md existe (spec gerada via /acme:spec)
2. aios/config.yaml existe (kernel configurado no projeto consumidor)
3. Python 3.10/3.11 disponível: python --version
4. ANTHROPIC_API_KEY definida no .env
```

Se qualquer check falhar: **parar e orientar o usuário** com instrução específica de correção. Não criar nenhum arquivo até todos os checks passarem.

## Estrutura criada

```
aios/agents/{module}_spec_agent/
├── entry.py      # SpecAgent com SYSTEM_PROMPT específico do módulo
└── config.json   # { "name": "{module}-spec-agent", "tier": "{A|B|C}" }

aios/agents/{module}_backend_agent/
├── entry.py
└── config.json

aios/agents/{module}_frontend_agent/
├── entry.py
└── config.json
```

> Os agentes `test_agent` e `review_agent` são **compartilhados** — não específicos por módulo.

## Boilerplate entry.py gerado

Cada agente recebe SYSTEM_PROMPT que:
- Referencia `docs/specs/{module}.md` como **única fonte de verdade**
- Declara explicitamente o que o agente **NÃO lê** (isolamento de contexto C5)
- Funciona como prompt standalone sem o kernel (C7)
- Nunca tem `tenantId` hardcoded (C8) — `tenantId` vai em `task_input`

### Template spec_agent/entry.py

```python
# AUTO-GERADO POR /acme:aios-init
# Tier: {A|B|C} — {descricao do tier}
# C7: este SYSTEM_PROMPT funciona como prompt standalone sem o kernel AIOS.
# C8: tenantId é passado em task_input, nunca hardcoded aqui.

import os
from langfuse import Langfuse

langfuse = Langfuse(
    public_key=os.environ.get("LANGFUSE_PUBLIC_KEY"),
    secret_key=os.environ.get("LANGFUSE_SECRET_KEY"),
    host=os.environ.get("LANGFUSE_HOST", "https://cloud.langfuse.com"),
)

SYSTEM_PROMPT = """
Você é o Spec Agent do módulo {module}.

Sua única fonte de verdade é docs/specs/{module}.md.

LEIA APENAS:
- docs/specs/{module}.md (spec do módulo)

NÃO LEIA (isolamento de contexto C5):
- Specs de outros módulos
- Código de implementação
- Dados de outros tenants

Tarefa: converter a spec em especificação executável para os agentes backend e frontend.
Declare explicitamente: funcionalidades, endpoints esperados, schema de dados, regras de negócio.

tenantId disponível em task_input — nunca hardcode aqui (C8).
"""

class SpecAgent:
    agent_name = "{module}-spec-agent"

    def run(self, task_input: dict) -> dict:
        # Telemetria C6 — ver docs/forge/aios-telemetry-pattern.md
        langfuse_available = bool(os.environ.get("LANGFUSE_PUBLIC_KEY"))
        trace = langfuse.trace(
            name=f"{self.agent_name}-{task_input.get('module', '{module}')}",
            metadata={
                "agent": self.agent_name,
                "module": task_input.get("module"),
                "tier": task_input.get("tier", "{tier}"),
                "aios_version": "0.2.2",
            }
        ) if langfuse_available else _MockTrace()

        generation = trace.generation(
            name="send_request",
            model="claude-sonnet-4-6",
            input=[{"role": "system", "content": SYSTEM_PROMPT}],
        )

        # TODO: integrar com aios.client.send_request
        # response = self.send_request(
        #     agent_name=self.agent_name,
        #     messages=[{"role": "system", "content": SYSTEM_PROMPT},
        #               {"role": "user", "content": task_input.get("task", "")}],
        #     base_url="http://localhost:8000",
        #     model="claude-sonnet-4-6"
        # )
        response = ""  # stub — substituir pela chamada real

        generation.end(output=response)
        trace.update(status_message="completed")

        return {
            "module": task_input.get("module"),
            "trace_id": trace.id,
            "status": "generated",
            "chars": len(response),
        }

class _MockTrace:
    id = "local-dev-no-trace"
    def generation(self, **kwargs): return self
    def end(self, **kwargs): pass
    def update(self, **kwargs): pass
```

## Output structured

```yaml
command: /acme:aios-init
status: ok | error
module: <>
tier: A | B | C
agents_created:
  - aios/agents/{module}_spec_agent/
  - aios/agents/{module}_backend_agent/
  - aios/agents/{module}_frontend_agent/
checks_passed:
  spec_exists: true
  config_exists: true
  python_ok: true
  api_key_ok: true
next_step: "/acme:aios-run --module {module} --step spec"
```

## Verification gate

- [x] `docs/specs/{module}.md` existe antes de criar qualquer arquivo
- [x] `aios/config.yaml` existe no projeto consumidor
- [x] Python 3.10/3.11 disponível no PATH
- [x] `ANTHROPIC_API_KEY` definida no ambiente
- [x] Cada `entry.py` gerado tem SYSTEM_PROMPT com seção "LEIA APENAS" e "NÃO LEIA"
- [x] Nenhum `tenantId` hardcoded nos arquivos gerados (C8)
- [x] SYSTEM_PROMPT funciona standalone sem kernel (C7) — declarado nos comentários

## Tabela anti-rationalization

| Tentação | Por que não | Resposta correta |
|---|---|---|
| Criar agentes genéricos sem especificidade do módulo | Contexto genérico gera código genérico — spec-específico é o ponto | SYSTEM_PROMPT referencia `docs/specs/{module}.md` explicitamente |
| Pular o gate de spec existente | Agentes sem spec geram lixo irrecuperável | Check 1 é hard gate — parar se spec não existe |
| Hardcodar tenantId no SYSTEM_PROMPT | Viola C8 — tenantId vai em task_input | `task_input.get("tenant_id")` sempre; nunca literal |
| Criar test_agent e review_agent por módulo | Esses agentes são compartilhados — redundância sem benefício | Apenas spec, backend e frontend são específicos por módulo |
| Pular instrumentação Langfuse no boilerplate | Sem trace = outcome não auditável (C6) | Mock fallback incluso; trace obrigatório em prod |

## Saída de erro estruturada

```yaml
command: /acme:aios-init
status: error
error: <enum>
hint: <ação específica>
```

`error` ∈ `spec_not_found` (criar spec via /acme:spec) | `aios_config_not_found` (criar aios/config.yaml) | `python_not_available` (instalar Python 3.10+) | `api_key_missing` (definir ANTHROPIC_API_KEY no .env) | `module_dir_already_exists` (usar --force para sobrescrever).

## Histórico

| Versão | Data | Mudança |
|---|---|---|
| 0.1.0 | 2026-05-06 | Versão inicial — Forge-6 AIOS init |
