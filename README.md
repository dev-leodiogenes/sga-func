# SGA-Func — Sistema de Gestão Acadêmica

Projeto acadêmico desenvolvido para a disciplina de Programação Funcional da Universidade de Fortaleza (UNIFOR).

O SGA-Func é uma aplicação web para gerenciamento de estudantes, disciplinas, matrículas, avaliações, notas e usuários, utilizando Haskell e o framework IHP.

## Tecnologias

- Haskell
- IHP (Integrated Haskell Platform)
- PostgreSQL
- Nix / devenv
- HTML e Bootstrap
- Git e GitHub

## Funcionalidades

O sistema possui:

- Autenticação de usuários e encerramento de sessão
- Perfis de administrador, coordenador, professor e aluno
- Troca obrigatória de senha no primeiro acesso
- Cadastro e gerenciamento de estudantes
- Cadastro e gerenciamento de disciplinas
- Matrículas de estudantes em disciplinas
- Gerenciamento de períodos acadêmicos
- Cadastro de avaliações
- Lançamento e exclusão de notas
- Cálculo da média das avaliações
- Dashboard acadêmico
- Cadastro de professores e coordenadores
- Vinculação de professores às disciplinas

## Arquitetura

A aplicação utiliza a estrutura MVC do IHP:

- `Web/Controller/`: controladores, regras de acesso e operações
- `Web/View/`: interfaces e formulários
- `Web/Types.hs`: ações e tipos dos controladores
- `Web/Routes.hs`: definição das rotas
- `Application/Helper/`: regras de negócio e funções auxiliares
- `Application/Schema.sql`: estrutura do banco de dados
- `Test/Spec.hs`: testes unitários
- `scripts/`: scripts de testes automatizados
- `evidencias/sprint5/`: resultados dos testes de carga

O PostgreSQL armazena os usuários, estudantes, disciplinas, matrículas, avaliações, notas e vínculos entre professores e disciplinas.

## Conceitos de programação funcional

O projeto aplica conceitos de programação funcional como:

- Funções puras para validação e cálculo de médias
- Tipos algébricos para representar permissões e erros
- `Maybe` para representar ausência de dados
- `Either` para representar sucesso ou falha
- `ExceptT` para organizar validações com erros
- `Reader` para consultar configurações durante validações
- Operações com listas usando `map`, `filter` e `foldl`
- Separação entre regras de negócio e efeitos de banco de dados

## Segurança e controle de acesso

O sistema diferencia permissões por perfil.

Administradores e coordenadores possuem acesso às funcionalidades administrativas previstas para seus perfis.

Professores podem consultar somente disciplinas, matrículas e avaliações vinculadas a eles.

O servidor também verifica esses vínculos no acesso direto aos detalhes e nas operações de lançamento e exclusão de notas.

Alunos possuem restrições específicas de acesso às próprias informações acadêmicas.

As regras são verificadas nos controladores, não apenas na interface.

## Execução local

Com o ambiente de desenvolvimento configurado, execute:

```bash
devenv up
```

Aplicação:

http://localhost:8000

O projeto depende de PostgreSQL e do ambiente de desenvolvimento do IHP.

## Testes unitários

Executar:

```bash
./scripts/test-unit.sh
```

Resultado registrado durante a Sprint 5:

- 41 testes aprovados
- 0 falhas

Os testes contemplam permissões, validações acadêmicas, cálculos de médias, filtragem de notas e validação de cadastro profissional.

## Testes de integração com PostgreSQL

Executar:

```bash
./scripts/test-integration.sh
```

Foram aprovados quatro cenários:

1. Criação de professor e vínculo com disciplina
2. Bloqueio de vínculo duplicado
3. Bloqueio de vínculo com professor inexistente
4. Rejeição de perfil inválido

Os testes utilizam transações e `ROLLBACK` para descartar os registros temporários.

## Testes de carga

Ferramenta: wrk

Ambiente: servidor local de desenvolvimento

Endpoint: `/NewSession`

Configuração: 2 threads e 15 segundos por cenário.

| Conexões | Requisições/s | Latência média | Timeouts |
|---|---:|---:|---:|
| 10 | 3740,67 | 5,52 ms | 0 |
| 50 | 4547,26 | 28,89 ms | 0 |
| 100 | 3722,76 | 104,34 ms | 50 |

O maior throughput observado ocorreu com 50 conexões.

Com 100 conexões houve aumento de latência, redução de throughput e ocorrência de timeouts.

Esses resultados representam a página pública de login no ambiente local, não o limite de usuários reais do sistema.

Relatório completo: `evidencias/sprint5/relatorio-stress.md`.

## Testes de segurança

Foram realizadas verificações manuais de:

- Redirecionamento de visitantes não autenticados
- Bloqueio de professores na administração de usuários
- Filtragem das disciplinas vinculadas ao professor
- Bloqueio de acesso direto a disciplinas não vinculadas
- Filtragem e proteção de matrículas
- Filtragem e proteção de avaliações
- Bloqueio de lançamento indevido de notas pelas duas rotas HTTP

As tentativas de lançamento de notas em disciplinas não autorizadas retornaram HTTP 403.

Essas verificações não substituem uma auditoria completa de segurança.

## Limitações e próximos testes

Ainda devem ser realizados testes complementares de exclusão indevida de notas, autorização em outras rotas e operações autenticadas sob carga.

Os testes de carga realizados não incluem a contagem detalhada dos códigos HTTP.

## Repositório

https://github.com/dev-leodiogenes/sga-func

## Finalidade

Projeto desenvolvido para fins acadêmicos, demonstrando a aplicação de conceitos de programação funcional em um sistema web com persistência de dados, autenticação, validações, controle de acesso e testes.

## Demonstrações complementares de programação funcional

O projeto possui módulos didáticos executáveis:

- `lib/AcademicUtils.hs`: list comprehension, pattern matching, map, filter, foldl, concatMap e Maybe.
- `lib/MonadsFunctorsCPS.hs`: Maybe, Either, IO, Reader, fmap, CPS, currying e lazy evaluation.

Exemplo de execução:

```bash
ghci -v0 lib/AcademicUtils.hs -e 'print (notasAprovadas [InformacaoNota "AV1" 8, InformacaoNota "AV2" 5], mediaNotas [InformacaoNota "AV1" 8, InformacaoNota "AV2" 6])'
```

Resultado verificado:

```text
([InformacaoNota {nomeAvaliacao = "AV1", valorNota = 8.0}],Just 7.0)
```

## Demonstração complementar com MongoDB

O PostgreSQL continua sendo o banco principal do SGA-Func.

O arquivo `examples/mongodb-courses.js` demonstra operações CRUD em MongoDB, utilizando um banco separado chamado `sga_func_demo`.

Para executar com MongoDB Server e mongosh disponíveis:

```bash
mongosh --quiet examples/mongodb-courses.js
```

A demonstração foi executada com sucesso, incluindo:

- CREATE: cadastro de disciplina.
- READ: consulta da disciplina.
- UPDATE: alteração da carga horária de 60 para 80.
- DELETE: exclusão do registro temporário.

O exemplo é independente da aplicação IHP e não representa uma integração operacional do SGA-Func com MongoDB.
