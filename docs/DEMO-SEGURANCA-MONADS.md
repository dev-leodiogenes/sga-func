# SGA-Func — apresentação e demonstração

## Preparação antes da apresentação

1. Atualize o código: `git pull` na branch de trabalho ou faça merge do PR após o CI.
2. Entre no ambiente do projeto, execute `devenv up` e confirme que as migrations foram aplicadas. Rode `nix flake check --impure`.
3. Exporte uma chave no servidor (nunca no repositório): `export SGA_ENCRYPTION_KEY="$(openssl rand -hex 32)"`. Guarde a mesma chave com segurança entre reinicializações, ou perderá acesso às anotações criptografadas.
4. Crie usuários manualmente com a ferramenta `hash-password` do IHP, que produz um hash com salt. **Não use texto puro no campo `password_hash`.** Execute o comando em um terminal interativo e não compartilhe a senha nos slides.
5. No PostgreSQL, cadastre os perfis: `INSERT INTO users (email, password_hash, role) VALUES ('admin@exemplo.local', '<hash gerado>', 'admin');` (substitua o hash e o email).
6. Para vincular um aluno, primeiro crie um estudante, depois `INSERT INTO users (email, password_hash, role, student_id) VALUES ('aluno@exemplo.local', '<hash gerado>', 'aluno', '<uuid estudante>');`. Crie um perfil `professor` da mesma forma, sem student_id. Estes endereços são apenas exemplos.
7. Os usuários são provisionados por administrador no banco nesta versão: **não existe cadastro público de usuários, recuperação de senha por email ou MFA**. Não apresente essas funcionalidades como implementadas.

## Roteiro sugerido (7–10 min)

### 1. Arquitetura funcional (1 min)
Explique: rotas/controller recebem requisições; funções puras validam campos e decidem permissões; a camada de banco persiste dados; HSX transforma o estado em HTML no servidor (SSR).

### 2. Autenticação (2 min)
Abra `/NewSession` sem estar logado. Demonstre:
- Login com senha correta e redirecionamento.
- Logout.
- Tentativa de acesso direto a uma rota protegida enquanto deslogado.
- Login com senha errada sem mostrar o hash.
- Bloqueio após tentativas incorretas (o módulo de sessão do IHP controla a proteção).

### 3. Autorização por papel (2 min)
- `admin`: cria/edita/remove estudantes e disciplinas e edita anotação confidencial.
- `professor`: lê estudantes, disciplinas e dashboard; não altera cadastros.
- `aluno`: lê disciplinas e **apenas seu próprio cadastro** pelo link direto `/ShowStudent?studentId=<uuid>`.
- Tente abrir manualmente uma ação proibida; explique que o controller retorna 403 independentemente da visibilidade do botão.

### 4. Segurança de dados (1 min)
- Hash de senha com salt usando `hashPassword` / `hash-password` do IHP (pwstore-fast). Hash **não é criptografia reversível**.
- Salve uma anotação privada como administrador; consulte o campo `students.confidential_note` no PostgreSQL: seu conteúdo binário não corresponde ao texto original.
- Abra a tela como professor: a anotação não é lida nem exibida.
- Explique a chave `SGA_ENCRYPTION_KEY` via variável de ambiente e a necessidade de backup. Não mostre a chave.

### 5. Funções, functors e monads (2 min)
No `lib/MonadsFunctorsCPS.hs`:
- `primeiraNota [] == Nothing` — modela ausência com `Maybe`.
- `validarNota 11 == Left ...`, `validarNota 8 == Right 8` — `Either` representa erro ou sucesso.
- `dobrarPrimeiraNota [7]` — `fmap` transforma o valor dentro de `Maybe`.
- `executarEstaAprovado (Configuracao 7 "2026.2") 8` — `Reader` lê configuração, sem variável global.
- `registrarMatriculaNoConsole` e controladores IHP — `IO` isola efeitos colaterais; validações são funções puras.
- `processarMatriculaCPS` e `primeirosPares 5` mostram CPS e lazy evaluation.

### 6. Dashboard (1 min)
Mostre filtros por período, total de matrículas, média geral e ranking de disciplinas calculados pelo PostgreSQL. Alterne entre um período com notas e um período sem notas; o painel não inventa média em amostras vazias.

## Limites e observações
- O hash padrão do IHP é salgado via `pwstore-fast`, não bcrypt. A exigência "bcrypt ou similar" é cumprida por algoritmo de derivação com salt, mas o grupo deve saber explicar a diferença.
- A criptografia da anotação usa `pgcrypto` com AES-256 no PostgreSQL. Matrícula, nome e e-mail continuam pesquisáveis em texto claro; não afirmar que toda a tabela está cifrada.
- O projeto utiliza SSR com HSX; `onchange` no filtro é melhoria progressiva, não Miso/Obelisk.
- Antes de demo pública, valide HTTPS e cookies de sessão, proteção CSRF e migrações no ambiente de execução.
