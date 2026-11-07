-- Adiciona o perfil de coordenador academico
ALTER TABLE users
    DROP CONSTRAINT users_role_valid;

ALTER TABLE users
    ADD CONSTRAINT users_role_valid
    CHECK (role IN ('admin', 'coordenador', 'professor', 'aluno'));
