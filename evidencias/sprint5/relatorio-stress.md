# Sprint 5 - Relatorio de Testes de Stress

## Sistema
SGA-Func - Sistema de Gestao Academica

## Ambiente
Servidor IHP em ambiente local de desenvolvimento.
Ferramenta: wrk.
Endpoint: http://localhost:8000/NewSession

## Configuracao
- 2 threads
- 15 segundos por teste
- 10, 50 e 100 conexoes simultaneas
- Requisicoes HTTP GET

## Resultados

| Metrica | 10 conexoes | 50 conexoes | 100 conexoes |
|---|---:|---:|---:|
| Requisicoes totais | 56334 | 68561 | 56024 |
| Requisicoes/s | 3740.67 | 4547.26 | 3722.76 |
| Latencia media | 5.52 ms | 28.89 ms | 104.34 ms |
| P99 | 52.65 ms | 271.68 ms | 704.67 ms |
| Latencia maxima | 161.80 ms | 459.46 ms | 1.79 s |
| Timeouts | 0 | 0 | 50 |

## Analise

O melhor throughput observado ocorreu com 50 conexoes
simultaneas, atingindo 4547.26 requisicoes por segundo.

Com 100 conexoes, o throughput diminuiu e a latencia
aumentou significativamente, com 50 timeouts registrados.

Os resultados indicam degradacao de desempenho sob
concorrencia elevada nesse ambiente de desenvolvimento.

## Limitacoes

Os testes foram realizados na pagina publica de login.

Os resultados nao representam necessariamente o desempenho
de funcionalidades autenticadas, como matriculas e notas.

O teste nao registrou uma contagem detalhada dos codigos
HTTP retornados.

O limite maximo de usuarios reais nao pode ser determinado
somente por esses resultados.

## Evidencias

- wrk-login-10conexoes.txt
- wrk-login-50conexoes.txt
- wrk-login-100conexoes.txt

## Conclusao

O sistema respondeu aos tres cenarios de carga, mas
apresentou degradacao significativa e timeouts no
cenario de 100 conexoes simultaneas.

Recomenda-se complementar os testes com endpoints
autenticados e verificacao dos codigos de resposta HTTP.
