-- Sprint 1: academic data model. See docs/SPRINT-1-MODELAGEM.md.
CREATE TYPE enrollment_statuses AS ENUM ('Active', 'Cancelled', 'Completed');

CREATE TABLE students (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY NOT NULL,
    registration_number TEXT NOT NULL,
    name TEXT NOT NULL,
    email TEXT NOT NULL
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
    value NUMERIC NOT NULL
);

ALTER TABLE students ADD CONSTRAINT students_registration_number_unique UNIQUE (registration_number);
ALTER TABLE students ADD CONSTRAINT students_registration_number_not_blank CHECK (length(trim(registration_number)) > 0);
ALTER TABLE students ADD CONSTRAINT students_name_not_blank CHECK (length(trim(name)) > 0);
ALTER TABLE students ADD CONSTRAINT students_email_not_blank CHECK (length(trim(email)) > 0);

ALTER TABLE courses ADD CONSTRAINT courses_code_unique UNIQUE (code);
ALTER TABLE courses ADD CONSTRAINT courses_code_not_blank CHECK (length(trim(code)) > 0);
ALTER TABLE courses ADD CONSTRAINT courses_name_not_blank CHECK (length(trim(name)) > 0);
ALTER TABLE courses ADD CONSTRAINT courses_workload_hours_positive CHECK (workload_hours > 0);

ALTER TABLE enrollments ADD CONSTRAINT enrollments_ref_student_id FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE RESTRICT;
ALTER TABLE enrollments ADD CONSTRAINT enrollments_ref_course_id FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE RESTRICT;
ALTER TABLE enrollments ADD CONSTRAINT enrollments_student_course_period_unique UNIQUE (student_id, course_id, academic_period);
ALTER TABLE enrollments ADD CONSTRAINT enrollments_academic_period_not_blank CHECK (length(trim(academic_period)) > 0);

ALTER TABLE grades ADD CONSTRAINT grades_ref_enrollment_id FOREIGN KEY (enrollment_id) REFERENCES enrollments (id) ON DELETE RESTRICT;
ALTER TABLE grades ADD CONSTRAINT grades_assessment_name_not_blank CHECK (length(trim(assessment_name)) > 0);
ALTER TABLE grades ADD CONSTRAINT grades_value_range CHECK ((value >= 0) AND (value <= 10));

-- The enrollment UNIQUE index already starts with student_id.
CREATE INDEX enrollments_course_id_index ON enrollments (course_id);
CREATE INDEX grades_enrollment_id_index ON grades (enrollment_id);
