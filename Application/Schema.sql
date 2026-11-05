-- Sprint 1: academic data model. See docs/SPRINT-1-MODELAGEM.md.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TYPE enrollment_statuses AS ENUM ('Active', 'Cancelled', 'Completed');

CREATE TABLE students (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY NOT NULL,
    registration_number TEXT NOT NULL,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    confidential_note BYTEA DEFAULT NULL
);

CREATE TABLE courses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY NOT NULL,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    workload_hours INT NOT NULL
);

CREATE TABLE enrollments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY NOT NULL,
    student_id UUID NOT NULL,
    course_id UUID NOT NULL,
    academic_period TEXT NOT NULL,
    status enrollment_statuses DEFAULT 'Active' NOT NULL
);

CREATE TABLE grades (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY NOT NULL,
    enrollment_id UUID NOT NULL,
    assessment_name TEXT NOT NULL,
    value NUMERIC NOT NULL,
    assessment_id UUID DEFAULT NULL
);

ALTER TABLE students ADD CONSTRAINT students_registration_number_unique UNIQUE (registration_number);
ALTER TABLE students ADD CONSTRAINT students_registration_number_not_blank CHECK (length(replace(registration_number, ' ', '')) > 0);
ALTER TABLE students ADD CONSTRAINT students_name_not_blank CHECK (length(replace(name, ' ', '')) > 0);
ALTER TABLE students ADD CONSTRAINT students_email_not_blank CHECK (length(replace(email, ' ', '')) > 0);

ALTER TABLE courses ADD CONSTRAINT courses_code_unique UNIQUE (code);
ALTER TABLE courses ADD CONSTRAINT courses_code_not_blank CHECK (length(replace(code, ' ', '')) > 0);
ALTER TABLE courses ADD CONSTRAINT courses_name_not_blank CHECK (length(replace(name, ' ', '')) > 0);
ALTER TABLE courses ADD CONSTRAINT courses_workload_hours_positive CHECK (workload_hours > 0);

ALTER TABLE enrollments ADD CONSTRAINT enrollments_ref_student_id FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE RESTRICT;
ALTER TABLE enrollments ADD CONSTRAINT enrollments_ref_course_id FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE RESTRICT;
ALTER TABLE enrollments ADD CONSTRAINT enrollments_student_course_period_unique UNIQUE (student_id, course_id, academic_period);
ALTER TABLE enrollments ADD CONSTRAINT enrollments_academic_period_not_blank CHECK (length(replace(academic_period, ' ', '')) > 0);

ALTER TABLE grades ADD CONSTRAINT grades_ref_enrollment_id FOREIGN KEY (enrollment_id) REFERENCES enrollments (id) ON DELETE RESTRICT;
ALTER TABLE grades ADD CONSTRAINT grades_assessment_name_not_blank CHECK (length(replace(assessment_name, ' ', '')) > 0);
ALTER TABLE grades ADD CONSTRAINT grades_value_range CHECK ((value >= 0) AND (value <= 10));

-- The enrollment UNIQUE index already starts with student_id.
CREATE INDEX enrollments_course_id_index ON enrollments (course_id);
CREATE INDEX grades_enrollment_id_index ON grades (enrollment_id);

-- Users are provisioned by administrators, never through an open signup endpoint.
-- Password hashes are created with IHP's salted hashPassword function.
CREATE TABLE users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY NOT NULL,
    email TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    locked_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    failed_login_attempts INT DEFAULT 0 NOT NULL,
    role TEXT DEFAULT 'aluno' NOT NULL,
    must_change_password BOOLEAN DEFAULT FALSE NOT NULL,
    student_id UUID DEFAULT NULL,
    CONSTRAINT users_email_not_blank CHECK (length(replace(email, ' ', '')) > 0),
    CONSTRAINT users_role_valid CHECK (role IN ('admin', 'professor', 'aluno')),
    CONSTRAINT users_ref_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE SET NULL
);
CREATE UNIQUE INDEX users_email_case_insensitive_unique ON users (lower(email));

-- Avaliacoes compartilhadas por disciplina e periodo
CREATE TABLE assessments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY NOT NULL,
    course_id UUID NOT NULL,
    academic_period TEXT NOT NULL,
    name TEXT NOT NULL
);

ALTER TABLE assessments ADD CONSTRAINT assessments_ref_course_id
    FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE RESTRICT;

ALTER TABLE assessments ADD CONSTRAINT assessments_period_not_blank
    CHECK (length(replace(academic_period, ' ', '')) > 0);

ALTER TABLE assessments ADD CONSTRAINT assessments_name_not_blank
    CHECK (length(replace(name, ' ', '')) > 0);

ALTER TABLE assessments ADD CONSTRAINT assessments_course_period_name_unique
    UNIQUE (course_id, academic_period, name);

CREATE INDEX assessments_course_id_index ON assessments (course_id);


ALTER TABLE grades ADD CONSTRAINT grades_ref_assessment_id
    FOREIGN KEY (assessment_id) REFERENCES assessments (id) ON DELETE RESTRICT;

CREATE UNIQUE INDEX grades_enrollment_assessment_unique
    ON grades (enrollment_id, assessment_id);
