# Playbooks Verticais — Novais Digital Foundry

> **Gerados via** `/novais-digital:playbook-extract` após o primeiro SKU de um vertical atingir `AUTONOMOUS`.
> **Template**: `templates/playbook.template.md`

---

## O que é um playbook

Um playbook vertical documenta os **blocos reutilizáveis** extraídos de um ou mais SKUs em produção, permitindo que o próximo cliente do mesmo vertical seja implementado com **≤ 30% do esforço do primeiro** (meta Foundry-5).

Um playbook **não é** um tutorial genérico. É uma referência direta com paths, métricas reais e lições do projeto de origem.

---

## Estrutura esperada

```
docs/playbooks/
  {vertical}/
    playbook.md         ← gerado por /novais-digital:playbook-extract
    blocks/             ← links simbólicos ou cópias de artefatos de alta confiança
      tier1/
      tier2/
      tier3/
```

---

## Quando criar

1. Primeiro SKU do vertical atinge `AUTONOMOUS`
2. Pelo menos 30 dias de dados de produção disponíveis
3. Retrospectiva do SKU criada em `docs/retrospectives/{sku_id}/`

---

## Métricas de sucesso

| Métrica | Meta |
|---|---|
| Esforço cliente 2 / cliente 1 (mesmo vertical) | ≤ 30% |
| Blocos com alta confiança de reutilização | ≥ 60% do total |
| Playbook atualizado após cliente 2 | sim (validação real) |

---

## Playbooks existentes

_Nenhum ainda — aguardando primeiro SKU em AUTONOMOUS no projeto consumidor._
