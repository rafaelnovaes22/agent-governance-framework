# Template de Pull Request (Foundry)

> Copie para `.github/pull_request_template.md` no projeto consumidor.
> A seção Declaração MI é obrigatória em todo PR: revelar, verificar,
> responsabilizar-se.

## O que muda

<!-- 1 a 3 frases: resultado, não stack -->

## Por que

<!-- problema, evidência, artefato ou issue de origem -->

## Como foi verificado

<!-- comandos rodados + resultado: testes, evals, doctor -->

- [ ] `npm test` (ou comando de verificação do projeto) verde
- [ ] `bash scripts/foundry-doctor.sh` sem FAIL novo
- [ ] Eval suite do módulo afetado passando (se houver)

## Declaração MI (obrigatória)

- [ ] **Revelei**: o que a máquina gerou neste PR (código, testes, texto, plano)
  <!-- liste os arquivos ou trechos gerados com assistência de IA -->
- [ ] **Verifiquei**: revisei de forma independente cada trecho gerado,
  rodei os gates acima e consigo defender o resultado
- [ ] **Responsabilizo-me**: autor humano deste PR (nome + data):
  <!-- nome — YYYY-MM-DD -->

Sem os 3 checkboxes marcados, o PR não entra em review.

## Riscos e rollback

<!-- o que pode quebrar, como voltar atrás -->

## Chave do módulo (sincronia com ClickUp)

<!-- key do módulo alterado, ex: ingest, classification -->
