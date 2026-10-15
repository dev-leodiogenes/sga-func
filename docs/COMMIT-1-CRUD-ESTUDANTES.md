# Sprint 2 — Commit 1: CRUD de estudantes

Implementacao baseada na branch `main` do repositorio `dev-leodiogenes/sga-func`, inspecionada em 14/10/2026.

## O que foi entregue

- `StudentsAction`: lista todos os estudantes ordenados por nome.
- `NewStudentAction` e `CreateStudentAction`: formulario e inclusao no PostgreSQL.
- `ShowStudentAction`: consulta individual.
- `EditStudentAction` e `UpdateStudentAction`: edicao de matricula, nome e e-mail.
- `DeleteStudentAction`: exclusao somente quando nao ha matriculas (`enrollments`) vinculadas.
- Validacao de campos em branco, formato de e-mail e matricula institucional duplicada.
- Estrutura de application/controller/view/rotas em IHP 1.6; a raiz `/` abre a listagem.

## Aplicacao no seu clone (Windows/VS Code)

1. Abra seu clone local do repositorio no VS Code.
2. Confira se a branch `main` nao tem alteracoes locais que voce queira preservar. Opcional: use uma branch `feature/crud-estudantes`.
3. Execute `git apply --check commit-1-crud-estudantes.patch` (patch disponibilizado separadamente), depois `git apply commit-1-crud-estudantes.patch`. **Nao execute tambem a copia do ZIP**, pois sao duas maneiras de aplicar a mesma mudanca.
4. No ambiente IHP configurado, rode `./start` e, se necessario, `make build/Generated/Types.hs` para gerar `Student` e `Enrollment` a partir do schema ja versionado.
5. Confirme que seu PostgreSQL de desenvolvimento ja tem as tabelas da Sprint 1. `make db` recria o schema; rode apenas se o banco for descartavel.
6. Acesse `http://localhost:8000/` e teste o roteiro abaixo.
7. Execute `nix flake check --impure`; somente apos o build passar faca o commit.

## Checklist de teste manual

- [ ] Tela inicial lista estudantes (`/`).
- [ ] Cadastrar matricula `PF-0001`, nome `Ana Teste`, e-mail `ana@example.com`.
- [ ] Verificar que o estudante aparece na listagem e na pagina individual.
- [ ] Editar o nome e confirmar persistencia apos recarregar.
- [ ] Tentar criar outro estudante com matricula `PF-0001`: deve aparecer erro de unicidade.
- [ ] Tentar nome vazio, matricula composta so de espacos e e-mail invalido: deve falhar a validacao.
- [ ] Excluir um estudante sem matriculas: deve desaparecer da listagem.
- [ ] Vincular um estudante a uma disciplina e tentar exclui-lo: deve aparecer mensagem de bloqueio sem apagar o registro.

## Integracao com o commit 2

O segundo commit pode acrescentar `CoursesController`, suas views e a rota `parseRoute @CoursesController`, alem de um link de Cursos no layout. Nao modifique `Web.Types` e `Web.Routes` inteiros sem incorporar o codigo ja existente: **acrescente** `CoursesController` e suas rotas, preservando Students.

## Limites e observacoes

- Sem alteracoes no schema ou migracoes: reaproveita as tabelas existentes.
- `ON DELETE RESTRICT` continua sendo a protecao final. A checagem previa torna o erro legivel, mas uma corrida concorrente rara ainda pode ser barrada pelo banco.
- Roles/autenticacao nao estao modeladas no schema existente. Estes endpoints sao adequados somente a um ambiente de desenvolvimento confiavel, ate que a equipe implemente autorizacao.
- Nao ha testes compilados por esta entrega: Nix/GHC/IHP nao estavam disponiveis no ambiente de preparacao. O roteiro acima e o check oficial sao obrigatorios para validar o funcionamento real.
