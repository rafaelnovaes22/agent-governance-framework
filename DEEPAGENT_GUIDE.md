# DeepAgent Guide — Como auditar projetos Forge autonomamente

> Para agentes autônomos (DeepAgent / GPT-5.5 / equivalente) que vão validar projetos consumidores do Acme Forge contra a Constitution.

---

## 1. O que você (agente) está fazendo aqui

Você é o **reviewer externo independente** do Acme Forge. Sua função é auditar mensalmente projetos que adotaram o framework, validando que:

- Os 8 princípios da [`Constitution`](./.claude/CONSTITUTION.md) estão sendo respeitados
- Há coerência entre artefatos (spec, código, eval, manifest)
- Não há drift de qualidade ou custo
- Issues encontradas são acionáveis

Você **não é o produtor** do código. Você é o auditor independente — um modelo distinto do que opera em produção (princípio da separação de modelos).

---

## 2. Pré-requisitos

Para rodar como reviewer, você precisa de:

| Recurso | Onde |
|---|---|
| **System prompt** | [`reviewer/prompt.template.md`](./reviewer/prompt.template.md) |
| **JSON schema do output** | [`reviewer/output-schema.json`](./reviewer/output-schema.json) |
| **Validation rules machine-readable** | [`reviewer/validation-rules.json`](./reviewer/validation-rules.json) |
| **Exemplo de relatório bem-feito** | [`reviewer/example-audit.md`](./reviewer/example-audit.md) |
| **Constitution vigente** | `.claude/CONSTITUTION.md` do projeto auditado |
| **Manifest do projeto auditado** | `docs/forge/manifest.json` do projeto auditado |
| **Acesso read-only ao DB do projeto** | (para amostrar outcomes em produção) |
| **Acesso read-only ao provedor de telemetria** | (Langfuse, Helicone, ou equivalente) |

---

## 3. Sequência de execução padrão

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│  1. Carregar system prompt (reviewer/prompt.template.md)            │
│     ↓                                                               │
│  2. Receber URL/path do projeto consumidor                          │
│     ↓                                                               │
│  3. Ler manifest.json do projeto                                    │
│     ↓                                                               │
│  4. Verificar versão de Constitution declarada                      │
│     ↓                                                               │
│  5. Carregar Constitution e parsear C1-C8                           │
│     ↓                                                               │
│  6. Executar checks de validation-rules.json em ordem               │
│     ↓                                                               │
│  7. Para cada check: ler artefatos referenciados, comparar com regra│
│     ↓                                                               │
│  8. Amostrar 5-10% outcomes do mês via DB read-only                 │
│     ↓                                                               │
│  9. Re-classificar amostra independentemente                        │
│     ↓                                                               │
│  10. Comparar com gabarito humano (se disponível) e com agente prod │
│     ↓                                                               │
│  11. Detectar drift (acurácia, custo, volume) vs auditoria anterior │
│     ↓                                                               │
│  12. Gerar relatório seguindo output-schema.json                    │
│     ↓                                                               │
│  13. Emitir markdown legível seguindo monthly-audit.template.md     │
│     ↓                                                               │
│  14. Para cada FAIL: abrir issue (dependendo do canal disponível)   │
│     ↓                                                               │
│  15. Commit relatório em docs/forge/audits/YYYY-MM-DD.md            │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 4. Como ler o `manifest.json`

O manifest é **input primário**. Estrutura mínima esperada:

```json
{
  "manifest_version": "X.Y.Z",
  "framework": {
    "name": "Acme Forge",
    "version": "X.Y.Z",
    "constitution_version": "X.Y.Z",
    "constitution_path": ".claude/CONSTITUTION.md",
    "constitution_sha256": "...",
    "reviewer": { ... }
  },
  "principles": [
    {"id": "C1", "name": "Diagnose-before-design", ...},
    ...
  ],
  "artifacts": {
    "documentation": [...],
    "constitution": {...},
    "settings": {...},
    "templates": [...],
    "skills": {...},
    "agents": {...},
    "commands": {...}
  },
  "checks_for_reviewer": {
    "C1_diagnose_before_design": "instrução de validação",
    ...
  },
  "linked_methodology_docs": [...],
  "linked_onda_artifacts": [...]
}
```

**Comportamento esperado**:
1. Se `manifest_version` não corresponde a uma versão suportada por você, **abortar** com FAIL crítico
2. Se `constitution_sha256` não bate com o hash real do arquivo `.claude/CONSTITUTION.md`, **WARN** (manifest desatualizado)
3. Para cada artefato em `artifacts.*`, verificar que o path existe no projeto e o sha256 confere
4. Cross-reference `principles[]` com `checks_for_reviewer{}` — toda principle deve ter check correspondente

---

## 5. Como validar cada princípio (resumo)

Detalhe completo em [`reviewer/validation-rules.json`](./reviewer/validation-rules.json). Resumo:

| Princípio | Como validar |
|---|---|
| **C1 — Diagnose** | Para cada agente em produção, há `diagnostic.md` referenciado no manifest? |
| **C2 — Outcome-first** | Toda spec tem seção "Cláusula de outcome" com 3 exemplos positivos + 3 negativos? |
| **C3 — Cost ≤ 25%** | `unit-economics.md` declara razão ≤ 25% E traces 30d confirmam? |
| **C4 — SHADOW** | Toda promoção SHADOW→ASSISTED ou ASSISTED→AUTONOMOUS no período tem gates passing registrados? |
| **C5 — Three-tier** | Toda skill em `.claude/skills/` declara `tier: 1\|2\|3` no frontmatter? |
| **C6 — Telemetry** | Outcomes no DB ↔ traces no Langfuse com desvio ≤ 1%? |
| **C7 — Portability** | Imports de SDK LLM proibidos fora da camada de abstração? |
| **C8 — Anti-custom** | Sem `if (tenantId === ...)` em código de produção? |

---

## 6. Como amostrar outcomes para auditoria de qualidade

Procedimento padrão:

1. Query DB: `SELECT * FROM outcomes WHERE created_at >= NOW() - INTERVAL '30 days' AND status IN ('DELIVERED', 'BILLED')`
2. Agrupar por categoria (`payload.category` ou equivalente)
3. Para cada categoria, amostrar 5-10% (mínimo 3 por categoria)
4. Para cada outcome amostrado, fetch trace correspondente em Langfuse
5. Re-classificar **você (reviewer)** o outcome a partir do input bruto (`payload.input` ou equivalente)
6. Comparar:
   - Decisão do agente em produção
   - Decisão do humano (se houver gabarito de auditoria humana)
   - **Sua** decisão como reviewer independente
7. Concordância >= threshold do SLA = ✅; abaixo = ⚠️

---

## 7. Drift detection

Compare auditoria atual com auditoria anterior:

| Drift | Trigger |
|---|---|
| **Drift de qualidade** | Acurácia mês N − mês N-1 < −5pp |
| **Drift de custo** | Custo médio outcome mês N / mês N-1 > 1.15 |
| **Drift de volume** | Volume mês N / mês N-1 > 1.30 ou < 0.70 |
| **Drift de latência** | p95 latency mês N / mês N-1 > 1.25 |

Drift detectado = **WARN automático**, mesmo que princípio individual passe.

---

## 8. Formato do output

### Output 1 — Markdown legível para humanos

Use [`templates/monthly-audit.template.md`](./templates/monthly-audit.template.md) como estrutura.

Salve em `docs/forge/audits/YYYY-MM-DD-monthly.md` no projeto consumidor (commit via PR, não direto na main).

### Output 2 — JSON machine-readable

Schema em [`reviewer/output-schema.json`](./reviewer/output-schema.json). Salve em `docs/forge/audits/YYYY-MM-DD-monthly.json`.

Estrutura mínima:

```json
{
  "audit_date": "2026-05-31",
  "audit_period": "2026-05",
  "reviewer": "deepagent-gpt-5.5",
  "constitution_version": "0.2.0",
  "manifest_version": "0.2.0",
  "project": "...",
  "checks": [
    {"id": "C1", "status": "PASS|WARN|FAIL", "evidence": "...", "issues": []},
    ...
  ],
  "drift_detected": {
    "quality": false,
    "cost": false,
    "volume": false
  },
  "outcomes_sampled": 47,
  "agreement_rate": 0.91,
  "issues_opened": [
    {"id": "AUD-2026-05-001", "principle": "C3", "severity": "P1", "title": "..."}
  ],
  "overall_status": "pass|warn|fail",
  "execution_time_seconds": 234,
  "audit_cost_usd": 1.23
}
```

### Output 3 — Issues em sistema externo (opcional)

Se o projeto consumidor tem ClickUp, Linear, GitHub Issues, ou similar configurado, abra issue para cada FAIL com:
- Título conciso
- Princípio violado
- Evidência (path + linha)
- Severidade (P0/P1/P2)
- Owner sugerido

---

## 9. O que você NÃO faz

- ❌ **Não edita** arquivos do projeto consumidor (apenas lê e gera novos arquivos em `docs/forge/audits/`)
- ❌ **Não toma decisões automáticas** (não promove subscription, não muda pricing)
- ❌ **Não bloqueia merges** (isso é trabalho dos hooks Claude Code)
- ❌ **Não substitui code review humano** de PRs
- ❌ **Não acessa dados sensíveis** além do necessário para sample auditing
- ❌ **Não executa código do projeto** (só lê estado e logs)

---

## 10. Idempotência

Rodar você 2x no mesmo dia com os mesmos inputs **deve produzir** output idêntico (a menos que dados de produção mudem entre execuções).

Implicações:
- Suas decisões devem ser baseadas em regras explícitas em validation-rules.json
- Quando há ambiguidade, prefira WARN a tomar decisão arbitrária
- Documente toda heurística usada em "evidence" do output

---

## 11. Tratamento de erros

| Situação | Ação |
|---|---|
| Manifest não encontrado | FAIL crítico, abortar |
| Constitution não encontrada | FAIL crítico, abortar |
| Versão do manifest incompatível | FAIL crítico, abortar |
| Acesso ao DB negado | WARN, prosseguir sem amostragem (registrar limitação) |
| Acesso a Langfuse negado | WARN, prosseguir sem cross-check de traces |
| Princípio individual: dados insuficientes | WARN com `evidence: "dados insuficientes para validar — recomendar revisão na próxima auditoria"` |

---

## 12. Frequência e cadência

| Cadência | Quando |
|---|---|
| **Mensal** (padrão) | Último dia útil do mês |
| **Pós-deploy crítico** (opcional) | Após mudança em prompt/modelo de SKU em produção |
| **On-demand** | Quando humano solicitar via comando explícito |

Manifest do projeto pode declarar cadência customizada em `framework.reviewer.frequency`.

---

## 13. Stack de implementação recomendada

Você (reviewer) pode ser implementado como:

| Stack | Vantagens |
|---|---|
| **Python + `deepagents` (LangChain)** | Filesystem virtual, planejamento explícito, subagentes |
| **Node/TS + `@langchain/langgraph`** | Stack alinhado a projetos JS típicos do Forge |
| **OpenAI Assistants API** | Setup mais simples; menos controle |
| **Custom (qualquer SDK GPT-5.5)** | Para casos específicos |

Default sugerido pelo Forge: **Python + `deepagents`** (auditoria autônoma e planejamento robusto).

---

## 14. Versionamento do reviewer

Você precisa declarar:
- Versão do prompt.template.md que está usando
- Versão do GPT-5.5 (snapshot, se aplicável)
- Versão da Constitution lida

Mudança de qualquer uma dessas versões pode mudar veredito → registrar em `audit_metadata`.

---

## 15. Onboarding rápido — execução de teste

Antes de auditar projetos reais:

1. Use [`examples/acme/`](./examples/acme/) como projeto-fixture
2. Rode auditoria contra ele
3. Compare seu output com [`reviewer/example-audit.md`](./reviewer/example-audit.md) (gabarito esperado)
4. Diferenças significativas indicam configuração incorreta

---

## 16. FAQ

**Q: Posso rodar Constitution v0.1.x no Forge v0.2.0?**
A: Sim, mas declare downgrade explicitamente em `audit_metadata.compatibility_mode`. Recomende migração no relatório.

**Q: Cliente do projeto consumidor pode ler meu relatório?**
A: Depende da política do projeto consumidor. Por padrão, relatório é interno. Se cliente vai ver, sanitize PII e dados sensíveis em §5 (outcomes amostrados).

**Q: Posso recomendar mudanças à Constitution?**
A: Não diretamente. Mas pode escrever em §8 (recomendações) que "recomenda nova ADR para C3 ajustar limite". Mantenedor decide.

**Q: O que faço se vejo violação que não cabe em C1-C8?**
A: Registre em §8 (recomendações) sob "achados fora dos princípios". Não force enquadramento.

**Q: Posso pausar auditoria mid-execução?**
A: Sim. Salve estado em `docs/forge/audits/YYYY-MM-DD-partial.json` e retome.
