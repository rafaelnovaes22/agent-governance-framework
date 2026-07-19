# AIOS Agents — Padrão de Telemetria (C6)

> **Foundry-6** — Padrão oficial para projetos consumidores que adotam AIOS Server como camada de implementação.
> Vinculado a: C6 (Telemetry-by-default), C7 (Portability), C8 (Anti-heroic customization)

---

## Obrigação

Toda chamada `send_request()` em agente AIOS de produção deve ter trace LangSmith correspondente.
**Sem trace: chamada não conta como outcome auditável (C6).**

O `trace_id` deve ser propagado no retorno de `run()` para que o orquestrador possa correlacionar
steps de pipeline com traces individuais.

---

## Implementação padrão

```python
# Em cada entry.py de agente AIOS
import os
import langsmith as ls

LANGSMITH_ENABLED = (
    os.environ.get("LANGSMITH_TRACING", "").lower() in {"true", "1", "yes"}
    and bool(os.environ.get("LANGSMITH_API_KEY"))
)

def run(self, task_input: dict) -> dict:
    with ls.trace(
        name=f"{self.agent_name}-{task_input.get('module', 'unknown')}",
        run_type="llm",
        inputs={"messages": self.messages},
        metadata={
            "agent": self.agent_name,
            "module": task_input.get("module"),
            "tier": task_input.get("tier", "B"),
            "aios_version": "0.2.2",
        }
    ) as trace:
        response = self.send_request(
            agent_name=self.agent_name,
            messages=self.messages,
            base_url="http://localhost:8000",
            model="claude-sonnet-4-6"
        )
        trace.end(outputs={"response": response})

    return {
        "module": task_input.get("module"),
        "trace_id": str(trace.id),
        "status": "generated",
        "chars": len(response),
    }
```

---

## Campos obrigatórios no trace

| Campo | Onde | Descrição |
|---|---|---|
| `name` | `trace.name` | `{agent_name}-{module}` — padrão rastreável |
| `agent` | `trace.metadata` | nome do agente (ex: `cadastros-spec-agent`) |
| `module` | `trace.metadata` | módulo processado (ex: `cadastros`) |
| `tier` | `trace.metadata` | A/B/C — para correlacionar com autonomia esperada |
| `aios_version` | `trace.metadata` | versão do kernel em uso |
| `trace_id` | retorno do `run()` | propagado ao orquestrador para correlação de pipeline |

---

## Verificação pelo hook `langfuse-trace-check`

O hook legado em `hooks/post-tool-use/langfuse-trace-check.sh` deve ser tratado como `llm-trace-check`: ele detecta chamadas LLM sem trace em `src/agents/**`.
Para agentes AIOS, o hook deve também verificar que `trace_id` está presente no retorno do `run()`:

```bash
# Extensão do hook para AIOS (adicionar ao llm-trace-check/langfuse-trace-check no projeto consumidor)
if grep -r "send_request" aios/agents/ | grep -v "ls.trace\|traceable"; then
  echo "[WARN] send_request sem trace LangSmith em agente AIOS"
fi
```

---

## Fallback sem LangSmith (desenvolvimento local)

Durante desenvolvimento local (sem `LANGSMITH_API_KEY` ou com `LANGSMITH_TRACING=false`), use o mock abaixo.
**Nunca commitar código que remove o trace em produção** — use o mock como fallback, não substituto.

```python
class _MockTrace:
    """Fallback local sem LangSmith — nunca usar em produção."""
    id = "local-dev-no-trace"
    def generation(self, **kwargs): return self
    def end(self, **kwargs): pass
    def update(self, **kwargs): pass

langsmith_available = bool(os.environ.get("LANGSMITH_API_KEY"))
trace = telemetry.trace(
    name=f"{self.agent_name}-{task_input.get('module', 'unknown')}",
    metadata={...}
) if langsmith_available else _MockTrace()
```

O boilerplate gerado por `/novais-digital:aios-init` já inclui este mock — não é necessário adicionar manualmente.

---

## Aviso em `/novais-digital:aios-run`

O comando `/novais-digital:aios-run` exibe automaticamente no console:

```
[AIOS-RUN] Trace LangSmith: AVISO — LANGSMITH_API_KEY/LANGSMITH_TRACING não configurados
           Chamadas desta execução não serão auditáveis (C6).
           Configurar em .env: LANGSMITH_TRACING=true e LANGSMITH_API_KEY=...
```

Este aviso é **não-bloqueante** em desenvolvimento mas **deve ser resolvido antes de SHADOW**.

---

## Integração com `/novais-digital:promote`

Antes de promover de SHADOW para ASSISTED, o gate de telemetria (C6) verifica:
- `trace_id` presente em ≥ 99% dos runs registrados
- `trace.metadata.module` preenchido em todos os traces de agentes AIOS
- Nenhum run com `trace_id = "local-dev-no-trace"` em ambiente de produção

---

## Mapeamento com a Constitution

| Princípio | Como este padrão aplica |
|---|---|
| C6 (Telemetry-by-default) | `send_request()` envolto por LangSmith (`ls.trace`/`traceable`) em todo agente |
| C7 (Portability) | SYSTEM_PROMPTs funcionam standalone; trace via LangSmith é opcional em dev (mock) |
| C8 (Anti-heroic) | `tenantId` em `task_input`, nunca em `trace.name` ou SYSTEM_PROMPT hardcoded |

---

## Histórico

| Versão | Data | Mudança |
|---|---|---|
| 0.1.0 | 2026-05-06 | Versão inicial — Foundry-6 padrão de telemetria AIOS |
| 0.2.0 | 2026-05-26 | Provedor default atualizado de LANGSMITH para LangSmith |
