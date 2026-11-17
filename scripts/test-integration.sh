#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "====================================="
echo " SGA-Func - Testes de Integracao SQL"
echo "====================================="

psql "$DATABASE_URL" -X -v ON_ERROR_STOP=1 <<'SQL'
BEGIN;

DO $test$
DECLARE
    professor UUID := gen_random_uuid();
    disciplina UUID := gen_random_uuid();
    email_teste TEXT := 'teste-' || gen_random_uuid()::TEXT || '@sga.local';
    codigo_teste TEXT := 'TEST-' || gen_random_uuid()::TEXT;
    total INTEGER;
BEGIN

    -- Teste 1: cadastrar professor e disciplina
    INSERT INTO users
        (id, name, email, password_hash, role, must_change_password)
    VALUES
        (professor, 'Professor Integracao',
         email_teste, 'hash-temporario', 'professor', TRUE);

    INSERT INTO courses
        (id, code, name, workload_hours)
    VALUES
        (disciplina, codigo_teste, 'Disciplina Integracao', 60);

    INSERT INTO professor_courses
        (professor_id, course_id)
    VALUES (professor, disciplina);

    SELECT COUNT(*) INTO total
    FROM professor_courses
    WHERE professor_id = professor
      AND course_id = disciplina;

    IF total <> 1 THEN
        RAISE EXCEPTION 'Falha: vinculo nao criado';
    END IF;

    RAISE NOTICE 'TESTE 1 APROVADO: professor e disciplina vinculados';

    -- Teste 2: impedir vinculo duplicado
    BEGIN
        INSERT INTO professor_courses
            (professor_id, course_id)
        VALUES (professor, disciplina);

        RAISE EXCEPTION 'Falha: duplicacao permitida';
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'TESTE 2 APROVADO: duplicacao bloqueada';
    END;

    -- Teste 3: impedir professor inexistente
    BEGIN
        INSERT INTO professor_courses
            (professor_id, course_id)
        VALUES (gen_random_uuid(), disciplina);

        RAISE EXCEPTION 'Falha: vinculo invalido permitido';
    EXCEPTION
        WHEN foreign_key_violation THEN
            RAISE NOTICE 'TESTE 3 APROVADO: vinculo inexistente bloqueado';
    END;

    -- Teste 4: impedir perfil invalido
    BEGIN
        INSERT INTO users
            (email, password_hash, role)
        VALUES
            (email_teste || '.invalido', 'hash-temporario', 'invalido');

        RAISE EXCEPTION 'Falha: perfil invalido permitido';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'TESTE 4 APROVADO: perfil invalido rejeitado';
    END;

END;
$test$;

ROLLBACK;
SQL

echo "Testes SQL concluidos com sucesso!"
echo "Dados temporarios descartados por ROLLBACK."
