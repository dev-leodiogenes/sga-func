# Sprint 2 — Commit 2: CRUD de cursos (disciplinas)

Implementacao incremental sobre a branch `main` de `dev-leodiogenes/sga-func`, commit base `40950ab`.

## O que foi entregue

- `CoursesAction`: listagem de disciplinas ordenada por nome.
- `NewCourseAction` e `CreateCourseAction`: formulario e cadastro no PostgreSQL.
- `ShowCourseAction`: consulta individual.
- `EditCourseAction` e `UpdateCourseAction`: edicao de codigo, nome e carga horaria.
- `DeleteCourseAction`: exclusao somente de disciplinas sem matriculas associadas.
- Validacao de codigo e nome nao vazios; carga horaria positiva; codigo unico.
- Navegacao entre Estudantes e Cursos, preservando o CRUD anterior.

Nao ha alteracoes no banco nem na modelagem existente, porque `courses` ja esta em `Application/Schema.sql`.

## Como aplicar o patch e fazer o commit

1. Na pasta `sga-func`, execute `git status` e `git fetch origin` antes de alterar arquivos.
2. Sem alteracoes locais pendentes e com a main atualizada, copie `commit-2-crud-cursos.patch` para a raiz do projeto.
3. Execute `git apply --check commit-2-crud-cursos.patch`, depois `git apply commit-2-crud-cursos.patch`.
4. Confira `git diff --check` e `git status`.
5. Teste no IHP e com `nix flake check --impure` quando possivel; o codigo nao foi compilado no ambiente que gerou este patch.
6. Faca `git add Web/Controller/Courses.hs Web/FrontController.hs Web/Routes.hs Web/Types.hs Web/View/Layout.hs Web/View/Courses/ docs/COMMIT-2-CRUD-CURSOS.md` (nao adicione o .patch).
7. Configure a autoria para sua segunda conta do GitHub, crie o commit e envie com `git push origin main`. Certifique-se de que a conta autenticada possui acesso de escrita.

## Checklist manual (pendente)

- [ ] Listar disciplinas e acessar a nova pagina pelo menu.
- [ ] Cadastrar codigo `PF001`, nome `Programacao Funcional`, carga horaria `60`.
- [ ] Visualizar a disciplina criada.
- [ ] Editar o nome/carga horaria e confirmar persistencia.
- [ ] Bloquear codigo vazio, nome em branco, carga horaria 0/negativa e codigo repetido.
- [ ] Excluir disciplina sem matriculas.
- [ ] Bloquear exclusao de disciplina que tenha matriculas vinculadas.
- [ ] Executar `nix flake check --impure` no ambiente IHP.

## Limites

Este patch ainda precisa ser compilado e testado no ambiente da equipe. Como o sistema nao possui autenticacao/roles implementados no banco, a aplicacao deve ser usada somente em ambiente de desenvolvimento confiavel. O CHECK e o FK `ON DELETE RESTRICT` existentes no banco continuam responsaveis pela integridade final das operacoes. Uma alteracao concorrente rara pode ser recusada pela constraint mesmo apos a consulta previa do controller.
