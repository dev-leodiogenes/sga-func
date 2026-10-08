# Sprint 1 — Modelagem acadêmica

Entrega baseada no ZIP `sga-func-main.zip` e no relatório `Markdown colado.md`. O relatório é uma proposta, não o enunciado completo da disciplina. Implementação limitada ao schema e à documentação de Student, Course, Enrollment e Grade, com um roteiro SQL de verificação. Não foram implementados funções puras de negócio, currying, controllers, telas, cálculo de média ou aprovação.

## Decisões confirmadas e premissas

Confirmado pelo pedido: **Course é disciplina**, **Grade é uma avaliação individual**, a escala é **0 a 10, inclusive**, e os estados são **Active / Cancelled / Completed**.

Premissas adotadas:

- Matrícula institucional e código da disciplina são textos únicos. A matrícula preserva zeros à esquerda e pode conter letras.
- Todos os atributos são obrigatórios. Os textos rejeitam string vazia e conteúdo composto apenas por espaços comuns (`trim`). Normalização de caixa, tabs e outros espaços Unicode fica para uma validação de entrada futura; não há normalização automática no banco.
- E-mail é obrigatório, mas não é identificador único e não recebe uma regex de validação nesta modelagem.
- Carga horária é um inteiro estritamente positivo.
- Período letivo é texto, por exemplo `2026.2`. Não se impõe calendário semestral, formato ou limite de períodos.
- Há no máximo uma matrícula por estudante, disciplina e período, inclusive quando cancelada. Reativação usa o mesmo vínculo; nova tentativa em outro período é permitida. Turmas e múltiplas tentativas no mesmo período não são modeladas.
- `Active` é o estado inicial. `Cancelled` indica cancelamento; `Completed` indica conclusão do vínculo, sem significar aprovação. O enum limita os valores, mas não impõe transições entre eles.
- Uma matrícula pode ter zero ou várias avaliações. Avaliação ainda não lançada é ausência de registro, não nota zero. Não há limite de quantidade nem unicidade do nome da avaliação.
- Nota usa `NUMERIC` sem precisão/escala fixa: aceita decimais exatos sem arredondamento prévio à constraint. Não foram presumidos pesos, média final, recuperação ou frequência.
- As FKs bloqueiam a exclusão de estudante/disciplina com matrículas e de matrícula com avaliações. Isso preserva referências; não é auditoria nem proibição de apagar registros sem dependentes. A atualização das chaves usa a política padrão `NO ACTION`.
- O schema permite notas em qualquer estado. Proibir lançamento em matrícula cancelada, definir transições e critérios de aprovação exige decisão posterior da equipe; nenhuma dessas regras foi inventada aqui.

## Dicionário de dados

Todos os campos abaixo têm `NOT NULL`. Os quatro `id` são chaves primárias UUID com `DEFAULT gen_random_uuid()` (PostgreSQL 13+).

| Tabela → modelo | Coluna SQL → campo Haskell | PostgreSQL | Tipo Haskell esperado | Significado/regra |
| --- | --- | --- | --- | --- |
| students → Student | id → id | UUID | Id Student | Identificador interno |
| students | registration_number → registrationNumber | TEXT | Text | Matrícula institucional única |
| students | name → name | TEXT | Text | Nome do estudante |
| students | email → email | TEXT | Text | Contato |
| courses → Course | id → id | UUID | Id Course | Identificador interno |
| courses | code → code | TEXT | Text | Código único da disciplina |
| courses | name → name | TEXT | Text | Nome da disciplina |
| courses | workload_hours → workloadHours | INT | Int | Carga horária positiva |
| enrollments → Enrollment | id → id | UUID | Id Enrollment | Identificador do vínculo |
| enrollments | student_id → studentId | UUID | Id Student | FK obrigatória para students.id |
| enrollments | course_id → courseId | UUID | Id Course | FK obrigatória para courses.id |
| enrollments | academic_period → academicPeriod | TEXT | Text | Período do vínculo |
| enrollments | status → status | enrollment_statuses | EnrollmentStatus | Active por padrão |
| grades → Grade | id → id | UUID | Id Grade | Identificador da avaliação individual |
| grades | enrollment_id → enrollmentId | UUID | Id Enrollment | FK obrigatória para enrollments.id |
| grades | assessment_name → assessmentName | TEXT | Text | Rótulo da avaliação |
| grades | value → value | NUMERIC | Scientific | Valor decimal entre 0 e 10 |

`Id Model` é a notação pública dos identificadores tipados do IHP; o gerador pode expressar os campos como `Id' "students"`, por exemplo. `Scientific` é o mapeamento de `NUMERIC` confirmado no código do IHP v1.6. Tipos Haskell comuns não codificam sozinhos a escala 0–10 ou a positividade: essas garantias estão nas constraints do banco.

## Relações e constraints

```text
Student (1) ── (0..N) Enrollment (0..N) ── (1) Course
                           (1)
                            │
                         (0..N)
                          Grade
```

Cada Enrollment exige exatamente um Student e um Course. Cada Grade exige exatamente um Enrollment; estudante, disciplina e período são obtidos por essa relação, sem duplicar FKs na nota. Enrollment resolve a relação muitos-para-muitos entre estudantes e disciplinas.

`Application/Schema.sql` contém as quatro PKs, três FKs com `ON DELETE RESTRICT`, unicidade da matrícula institucional, do código de disciplina e da combinação `(student_id, course_id, academic_period)`, além de verificações de textos, carga horária e nota. O enum rejeita qualquer estado diferente dos três declarados. A comparação `value >= 0 AND value <= 10` também rejeita `NaN` e infinitos do PostgreSQL.

Há índices para `enrollments.course_id` e `grades.enrollment_id`. O índice da unicidade composta já começa por `student_id`, atendendo à busca dos vínculos de um estudante.

## Records e tipos algébricos

Um **record** é um tipo produto: reúne simultaneamente os atributos de uma entidade. O IHP gera os records e seus aliases a partir das tabelas. O enum é um **tipo soma**: seu valor escolhe uma das alternativas possíveis.

Modelo didático das quatro entidades, não um módulo para adicionar ao projeto:

```haskell
data EnrollmentStatus = Active | Cancelled | Completed
    deriving (Eq, Show)

data Student = Student
    { id :: Id Student, registrationNumber :: Text
    , name :: Text, email :: Text }

data Course = Course
    { id :: Id Course, code :: Text
    , name :: Text, workloadHours :: Int }

data Enrollment = Enrollment
    { id :: Id Enrollment, studentId :: Id Student
    , courseId :: Id Course, academicPeriod :: Text
    , status :: EnrollmentStatus }

data Grade = Grade
    { id :: Id Grade, enrollmentId :: Id Enrollment
    , assessmentName :: Text, value :: Scientific }
```

Esse trecho omite imports, extensões, metadados e instâncias geradas pelo IHP. Não criar definições paralelas com esses nomes: `Application/Schema.sql` é a fonte da modelagem e `Generated.Types` expõe os tipos reais. O gerador usa estruturas internas como `Grade'` e aliases, portanto o exemplo não promete uma reprodução literal do arquivo gerado.

O `flake.nix` original usa `relationSupport = false`. Isso mantém as FKs e os identificadores tipados, mas desativa a infraestrutura gerada de `Include`/`fetchRelated`. A configuração foi preservada. Caso a equipe decida usar esses recursos futuramente, deverá habilitar a opção e regenerar os tipos.

## Integração no IHP 1.6

1. Use o projeto entregue ou copie `Application/Schema.sql`, `Test/SchemaSprint1.sql` e `docs/` para a mesma base do ZIP. O README recebeu apenas um link para esta entrega. Nenhum repositório remoto foi alterado.
2. No ambiente Linux/WSL2 com Nix e as dependências do projeto, entre na pasta e ative seu ambiente habitual (`direnv allow`, conforme `.envrc`). Execute `./start` para iniciar os serviços do projeto.
3. Gere os tipos no ambiente IHP: `make build/Generated/Types.hs`. Confira `Student`, `Course`, `Enrollment`, `Grade` e `EnrollmentStatus` em `build/Generated/Types.hs` e nos módulos que ele reexporta. Não editar arquivos gerados manualmente.
4. **Apenas para um banco de desenvolvimento descartável**, rode `make db`. Esse comando apaga e recria o schema `public`, importa a infraestrutura do IHP, `Application/Schema.sql` e `Application/Fixtures.sql`. Não o execute em um banco com dados a preservar.
5. Se já existir um banco em uso, gere/revise uma migração pelo fluxo de migrações do IHP a partir do estado real desse banco; não execute `make db`. Não foi adicionada migração a esta base inicial vazia, evitando assumir o estado de um ambiente externo ou aplicar a criação das tabelas duas vezes. Siga a regra de timestamp de `AGENTS.md` ao criar a migração.
6. Execute `nix flake check --impure`, conforme exigido por `AGENTS.md`. A geração e compilação real dos tipos ainda precisam dessa verificação no ambiente IHP.

Para repetir somente a validação SQL, em um PostgreSQL 13+ com uma base **vazia e descartável**, execute da raiz do projeto (substitua o nome da base):

```sh
psql -v ON_ERROR_STOP=1 -d sprint1_test -f Application/Schema.sql
psql -v ON_ERROR_STOP=1 -d sprint1_test -f Test/SchemaSprint1.sql
```

O segundo arquivo executa os casos dentro de uma transação e termina com `ROLLBACK`; não instala funções de aplicação nem dados de demonstração permanentes. Não integra automaticamente a suíte Haskell. Consulte [VALIDACAO.md](VALIDACAO.md) para os resultados e limites da validação efetuada.

## Referências técnicas

- [Gerador oficial do IHP v1.6](https://github.com/digitallyinduced/ihp/blob/v1.6/ihp-schema-compiler/IHP/SchemaCompiler.hs): mapeamentos de tipos, records, enums e opção de relações.
- [Parser PostgreSQL do IHP v1.6](https://github.com/digitallyinduced/ihp/blob/v1.6/ihp-postgres-parser/IHP/Postgres/Parser.hs): sintaxe das constraints e expressões.
- [Makefile oficial do IHP v1.6](https://github.com/digitallyinduced/ihp/blob/v1.6/ihp-ide/data/lib/IHP/Makefile.dist): geração e importação do schema.
- [Guia de migrações](https://ihp.digitallyinduced.com/Guide/database-migrations.html): integração com bancos existentes.

## Relação com a Aula 9 e fechamento da parte de Pedro

A Aula 9 de Ildo Ramos Vieira apresenta um sistema acadêmico (p. 4), separação entre funções puras e efeitos externos (pp. 7-10), composição de média e situação (pp. 11-16) e a sequência requisitos, dados, funções e aplicação (p. 22). O modelo aqui fornece os dados para essas funções; persistência é efeito externo, isolado do cálculo puro. Um record Haskell é um valor imutável; atualizar o banco é uma operação distinta.

O slide não determina Student/Course/Enrollment/Grade nem as cardinalidades e regras desta entrega. A página 24 anuncia uma aula seguinte sobre artefatos e modelo de tipos. Portanto, esta documentação atende ao escopo solicitado, sem afirmar conformidade com um enunciado completo não fornecido. O exemplo de aprovação da aula não foi convertido em regra do banco; Completed não significa aprovado. A calculadora e as partes dos colegas não foram alteradas.

O CHECK da nota foi corrigido para `CHECK ((value >= 0) AND (value <= 10))`, conforme a auditoria. Consulte `VALIDACAO.md`, `INTEGRACAO-PEDRO.md` e `MODELAGEM-PEDRO.pdf`.
