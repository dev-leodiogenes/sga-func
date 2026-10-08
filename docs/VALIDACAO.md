# Validação final da parte de Pedro - 08/10/2026

## Executado nesta entrega

O Application/Schema.sql corrigido foi carregado integralmente em PostgreSQL 18.3 via PGlite 0.5.8 (WebAssembly), em memória. Test/SchemaSprint1.sql passou: 44 casos negativos e os cenários positivos existentes, incluindo 0, 10, 7.125, defaults e estados. O rollback deixou zero linhas nas quatro tabelas. Evidência: RESULTADOS-SQL.json. A suíte SQL original foi preservada byte a byte.

Isso é execução real de PostgreSQL em WebAssembly, não execução de um servidor PostgreSQL nativo nem prova da integração IHP/Haskell. Para reproduzir em PostgreSQL nativo, use os dois comandos psql documentados em SPRINT-1-MODELAGEM.md, em banco vazio e descartável.

## Revisão estática IHP v1.6

flake.lock fixa 71b7bb685d2a60b20cd19c8a810c8931369e5efb. Foram revistos o parser e o SchemaCompiler dessa revisão, recuperados na auditoria. Literais numéricos não consomem o espaço necessário antes de AND na expressão original. Os parênteses das duas comparações consomem esse espaço. Aplicada a correção mínima CHECK ((value >= 0) AND (value <= 10)), sem alterar a regra de negócio.

A revisão sustenta o uso de enum, tabelas, defaults, FKs, UNIQUE, CHECK e índices e os mapeamentos TEXT -> Text, INT -> Int, NUMERIC -> Scientific, UUID/FK -> Id do modelo. Não é execução do parser. relationSupport = false foi preservado: não elimina FKs, mas desativa a infraestrutura de Include/fetchRelated. Os exemplos de records são didáticos, não arquivos gerados.

## Não comprovado

Nix e GHC não estão disponíveis no ambiente. A tentativa de nix flake check --impure falhou por comando ausente. Parser, geração de tipos, compilação, testes Haskell e aplicação IHP não foram executados. Os testes Haskell existentes só cobrem soma e SELECT 1; não validam as quatro entidades. A referência a CI no README não corresponde a workflow presente no ZIP; o README geral foi preservado por estar fora da correção de Pedro.

Antes de afirmar funcionamento IHP, gerar tipos, compilar e testar criação/leitura das quatro entidades pelos modelos reais, enum e decimal, além de rodar nix flake check --impure. Não foram criados testes Haskell não executáveis como se constituíssem evidência.

Conclusão: schema corrigido e aprovado nos testes SQL executados; compatibilidade IHP revisada estaticamente, funcionamento completo não comprovado.

Fontes: https://github.com/digitallyinduced/ihp/blob/71b7bb685d2a60b20cd19c8a810c8931369e5efb/ihp-postgres-parser/IHP/Postgres/Parser.hs
https://github.com/digitallyinduced/ihp/blob/71b7bb685d2a60b20cd19c8a810c8931369e5efb/ihp-schema-compiler/IHP/SchemaCompiler.hs
