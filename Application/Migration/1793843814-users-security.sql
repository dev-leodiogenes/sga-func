-- Authentication credentials and encrypted private student notes.
-- Apply through IHP migrations before starting the upgraded application.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

ALTER TABLE students ADD COLUMN IF NOT EXISTS confidential_note BYTEA DEFAULT NULL;

CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY NOT NULL,
    email TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    locked_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    failed_login_attempts INT DEFAULT 0 NOT NULL,
    role TEXT DEFAULT 'aluno' NOT NULL,
    student_id UUID DEFAULT NULL,
    CONSTRAINT users_email_not_blank CHECK (length(trim(email)) > 0),
    CONSTRAINT users_role_valid CHECK (role IN ('admin', 'professor', 'aluno')),
    CONSTRAINT users_ref_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE SET NULL
);
CREATE UNIQUE INDEX IF NOT EXISTS users_email_case_insensitive_unique ON users (lower(email));
