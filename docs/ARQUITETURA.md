# SGA-Func — Arquitetura e Decisões Técnicas

## 1. Visão geral

O SGA-Func é um sistema web de gestão acadêmica desenvolvido em Haskell, utilizando IHP e PostgreSQL.

Seu objetivo é organizar estudantes, disciplinas, matrículas, períodos acadêmicos, avaliações, notas e usuários com diferentes níveis de permissão.

O projeto combina programação funcional, persistência de dados e uma arquitetura MVC.

## 2. Organização da arquitetura

A aplicação utiliza a estrutura Model-View-Controller (MVC) do IHP.

### Model

Os modelos representam os dados acadêmicos armazenados no PostgreSQL.

As principais entidades são:

- User: contas e perfis de acesso.
- Student: informações dos estudantes.
- Course: disciplinas.
- Enrollment: vínculos entre estudantes e disciplinas.
- Assessment: avaliações acadêmicas.
- Grade: notas associadas às matrículas.
- AcademicPeriod: períodos acadêmicos.
- ProfessorCourse: vínculos entre professores e disciplinas.

O esquema do banco está em Application/Schema.sql.

### View

A camada View apresenta as páginas HTML.

Está organizada principalmente no diretório Web/View.

As views exibem formulários, tabelas e informações recuperadas pelos controladores.

### Controller

A camada Controller recebe requisições, verifica permissões, executa operações e seleciona as views.

Está localizada em Web/Controller.

Exemplos:

- Courses.hs: disciplinas.
- Enrollments.hs: matrículas.
- Assessments.hs: avaliações.
- Grades.hs: notas.
- StaffUsers.hs: professores e coordenadores.

### Helpers

O diretório Application/Helper contém regras de negócio e funções auxiliares.

Essa separação facilita testar a lógica sem precisar executar uma aplicação web completa.

## 3. Fluxo de uma requisição

1. O navegador envia uma requisição HTTP.
2. O roteador do IHP identifica a ação correspondente.
3. O controlador verifica a autenticação e a autorização.
4. O controlador consulta ou altera dados quando necessário.
5. As regras de negócio são aplicadas.
6. Uma view apresenta o resultado ou ocorre um redirecionamento.

As rotas são declaradas em Web/Routes.hs.

## 4. Decisões de Programação Funcional

### Funções puras

As regras de cálculo e validação foram separadas das operações de entrada e saída.

Exemplos:

- Validação de informações acadêmicas.
- Validação dos dados de cadastro profissional.
- Seleção de notas de uma matrícula.
- Cálculo da média.
- Verificação de regras de permissão.

Essa separação torna a lógica mais previsível e facilita os testes unitários.

### Maybe

O tipo Maybe representa resultados que podem estar ausentes.

Um exemplo é o cálculo de média de uma matrícula.

Quando não existem notas, a função pode retornar Nothing, evitando representar uma média inexistente como se fosse um resultado válido.

### Either

O tipo Either representa operações que podem resultar em erro ou sucesso.

No cadastro profissional, erros específicos são representados por um tipo algébrico.

Isso permite diferenciar problemas como e-mail inválido, senha curta e disciplinas incompatíveis com o perfil informado.

### ExceptT

O transformador ExceptT é utilizado para organizar validações que podem interromper uma operação.

No cadastro profissional, ele permite combinar verificações de entrada com consultas ao banco.

Caso uma validação falhe, o controlador pode apresentar a mensagem correspondente sem prosseguir com a criação do usuário.

### Reader

O Reader é utilizado na validação de notas.

Os limites permitidos são fornecidos como ambiente de configuração.

Dessa forma, a função de validação consulta esses limites sem precisar recebê-los individualmente em cada etapa.

### Transformações de listas

O sistema utiliza operações como:

- map
- filter
- foldl
- any

Essas funções permitem transformar, selecionar e agregar dados de maneira declarativa.

## 5. Tratamento de efeitos

Os controladores executam operações que dependem de efeitos, incluindo consultas ao PostgreSQL, gravação de registros e respostas HTTP.

Sempre que possível, as regras de negócio são mantidas separadas dessas operações.

Essa abordagem combina um núcleo de lógica funcional com uma camada responsável pelos efeitos necessários ao funcionamento da aplicação.

## 6. Persistência e integridade

O PostgreSQL armazena os registros acadêmicos e mantém relacionamentos entre as entidades.

A tabela professor_courses representa a associação entre professores e disciplinas.

Foram verificados comportamentos de integridade como:

- Bloqueio de vínculo duplicado.
- Bloqueio de referência a professor inexistente.
- Rejeição de perfil inválido.

Operações de cadastro que envolvem múltiplos registros utilizam transações em pontos específicos do sistema.

## 7. Autenticação e autorização

O sistema possui os perfis:

- Administrador.
- Coordenador.
- Professor.
- Aluno.

O acesso às ações é controlado nos servidores por meio dos controladores.

O professor possui acesso restrito às disciplinas com as quais mantém vínculo.

Essa restrição também é aplicada às matrículas, avaliações e operações de notas.

A autorização não depende somente de esconder botões ou informações na interface.

Foram realizados testes de acesso direto por URL e requisições HTTP que retornaram 403 Forbidden quando o professor tentou acessar recursos não autorizados.

## 8. Estratégia de testes

### Testes unitários

Utilizam Hspec para verificar regras funcionais isoladas.

Resultado registrado: 41 testes aprovados.

### Testes de integração com banco de dados

Executam operações temporárias no PostgreSQL.

Resultado registrado: 4 testes aprovados.

Os registros temporários são descartados utilizando ROLLBACK.

### Testes de segurança HTTP

Foram verificadas restrições de autenticação, acesso direto e lançamento indevido de notas.

Os testes manuais confirmaram bloqueios em rotas protegidas.

### Testes de carga

Executados com wrk na página pública de login.

Foram utilizados cenários com 10, 50 e 100 conexões simultâneas.

O cenário de 100 conexões apresentou aumento de latência e timeouts.

Os resultados completos estão em evidencias/sprint5/relatorio-stress.md.

## 9. Decisões e justificativas

| Decisão | Justificativa |
|---|---|
| Haskell | Aplicar programação funcional com tipos explícitos |
| IHP | Integrar aplicação web, modelos e rotas |
| PostgreSQL | Persistir dados relacionais |
| MVC | Separar interface, controle e dados |
| Helpers | Isolar regras de negócio para facilitar testes |
| Maybe | Representar ausência de informação |
| Either e ExceptT | Representar e propagar erros explicitamente |
| Reader | Compartilhar configurações em validações |
| Hspec | Automatizar testes de regras funcionais |
| wrk | Avaliar comportamento sob requisições concorrentes |
| Controle por perfil | Restringir operações conforme as responsabilidades |

## 10. Limitações conhecidas

Os testes de carga foram executados em ambiente local e não representam o limite de usuários reais.

Ainda existem verificações complementares de autorização a realizar em outras funcionalidades.

O bloqueio de exclusão indevida de notas foi implementado, mas ainda precisa de um teste HTTP específico.

As verificações manuais de segurança devem ser complementadas por testes automatizados de autorização.

## 11. Conclusão

A arquitetura do SGA-Func demonstra a aplicação de conceitos de programação funcional em um sistema web acadêmico.

A separação entre regras de negócio, controladores e persistência facilita a manutenção, os testes e a evolução da aplicação.

Os resultados da Sprint 5 fornecem evidências de validações funcionais, integridade de dados, segurança de acesso e desempenho sob carga.
