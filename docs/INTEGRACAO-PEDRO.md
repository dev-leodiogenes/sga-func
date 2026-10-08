# Integrar a parte de Pedro em feature/modelagem

1. Extraia o ZIP em uma pasta separada. No clone da equipe, confira `git status` e preserve alterações locais antes de trocar de branch.
2. Use `git switch feature/modelagem` se a branch já existir; se ainda não existir, a partir da base combinada pela equipe use `git switch -c feature/modelagem`.
3. Compare o schema atual com o do pacote. Na mesma base da Sprint 1, substitua somente Application/Schema.sql e os documentos da modelagem. Se a branch já evoluiu, aplique apenas a alteração do CHECK e incorpore a documentação sem sobrescrever novas tabelas ou trabalho dos colegas. Test/SchemaSprint1.sql veio intacto; copie-o apenas se ainda faltar na branch.
4. No ambiente Linux/Nix/IHP do projeto, ative o ambiente habitual e execute `make build/Generated/Types.hs`. Inicie `./start`. Somente em banco de desenvolvimento descartável, `make db` importa o schema e apaga o schema public anterior. Em banco com dados, use migração revisada conforme o estado real; siga o timestamp exigido por AGENTS.md. A mudança de parênteses é semanticamente equivalente no PostgreSQL e não exige, por si, alterar a constraint já instalada.
5. Rode a suíte SQL em banco descartável e `nix flake check --impure`. Valide criação e leitura de Student, Course, Enrollment e Grade pelos modelos gerados, incluindo enum e nota decimal. Esses passos IHP continuam pendentes.
6. Revise `git diff` e selecione apenas Application/Schema.sql, docs/SPRINT-1-MODELAGEM.md, docs/VALIDACAO.md, docs/INTEGRACAO-PEDRO.md, docs/RESULTADOS-SQL.json e docs/MODELAGEM-PEDRO.pdf. Faça o commit local após a revisão. Não é necessário copiar o projeto inteiro sobre o clone nem editar arquivos Generated manualmente.

Nada foi publicado no GitHub. Nenhuma branch de colegas foi alterada. O pacote conserva os demais arquivos do ZIP original, inclusive arquivos ocultos. O manifesto externo lista a comparação byte a byte.
