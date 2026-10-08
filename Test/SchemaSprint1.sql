-- Sprint 1: run ONLY against a disposable empty database with Schema.sql loaded.
-- psql -v ON_ERROR_STOP=1 -d <test_database> -f Test/SchemaSprint1.sql
-- Test blocks only; no application functions are created. Data is rolled back.
BEGIN;

INSERT INTO students (id,registration_number,name,email) VALUES ('10000000-0000-0000-0000-000000000001','001A','Ana','ana@example.test');
INSERT INTO courses (id,code,name,workload_hours) VALUES ('20000000-0000-0000-0000-000000000001','FP01','Programação Funcional',60);
INSERT INTO enrollments (id,student_id,course_id,academic_period) VALUES ('30000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','2026.2');
INSERT INTO grades (enrollment_id,assessment_name,value) VALUES ('30000000-0000-0000-0000-000000000001','Avaliação 1',0),('30000000-0000-0000-0000-000000000001','Avaliação 2',10),('30000000-0000-0000-0000-000000000001','Avaliação 3',7.125);
DO $$ BEGIN
  IF (SELECT status FROM enrollments WHERE id = '30000000-0000-0000-0000-000000000001') <> 'Active' THEN RAISE EXCEPTION 'default status'; END IF;
  IF (SELECT count(*) FROM grades WHERE enrollment_id = '30000000-0000-0000-0000-000000000001') <> 3 THEN RAISE EXCEPTION 'multiple grades'; END IF;
  IF NOT EXISTS (SELECT 1 FROM grades WHERE value = 7.125) THEN RAISE EXCEPTION 'exact decimal'; END IF;
END $$;
UPDATE enrollments SET status = 'Cancelled';
UPDATE enrollments SET status = 'Completed';
INSERT INTO enrollments (student_id,course_id,academic_period) VALUES ('10000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','2027.1');

-- students.registration_number: vazio
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE students SET registration_number = '';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'students_registration_number_not_blank' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- students.registration_number: espaços
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE students SET registration_number = '   ';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'students_registration_number_not_blank' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- students.registration_number: nulo
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE students SET registration_number = NULL;
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23502' THEN
    NULL;
  END;
END $$;

-- students.name: vazio
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE students SET name = '';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'students_name_not_blank' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- students.name: espaços
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE students SET name = '   ';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'students_name_not_blank' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- students.name: nulo
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE students SET name = NULL;
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23502' THEN
    NULL;
  END;
END $$;

-- students.email: vazio
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE students SET email = '';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'students_email_not_blank' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- students.email: espaços
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE students SET email = '   ';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'students_email_not_blank' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- students.email: nulo
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE students SET email = NULL;
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23502' THEN
    NULL;
  END;
END $$;

-- courses.code: vazio
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE courses SET code = '';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'courses_code_not_blank' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- courses.code: espaços
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE courses SET code = '   ';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'courses_code_not_blank' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- courses.code: nulo
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE courses SET code = NULL;
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23502' THEN
    NULL;
  END;
END $$;

-- courses.name: vazio
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE courses SET name = '';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'courses_name_not_blank' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- courses.name: espaços
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE courses SET name = '   ';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'courses_name_not_blank' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- courses.name: nulo
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE courses SET name = NULL;
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23502' THEN
    NULL;
  END;
END $$;

-- enrollments.academic_period: vazio
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE enrollments SET academic_period = '';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'enrollments_academic_period_not_blank' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- enrollments.academic_period: espaços
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE enrollments SET academic_period = '   ';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'enrollments_academic_period_not_blank' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- enrollments.academic_period: nulo
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE enrollments SET academic_period = NULL;
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23502' THEN
    NULL;
  END;
END $$;

-- grades.assessment_name: vazio
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE grades SET assessment_name = '';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'grades_assessment_name_not_blank' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- grades.assessment_name: espaços
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE grades SET assessment_name = '   ';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'grades_assessment_name_not_blank' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- grades.assessment_name: nulo
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE grades SET assessment_name = NULL;
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23502' THEN
    NULL;
  END;
END $$;

-- matrícula institucional duplicada
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    INSERT INTO students (registration_number,name,email) VALUES ('001A','Outro','other@example.test');
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23505' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'students_registration_number_unique' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- código de disciplina duplicado
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    INSERT INTO courses (code,name,workload_hours) VALUES ('FP01','Outra',30);
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23505' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'courses_code_unique' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- vínculo duplicado
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    INSERT INTO enrollments (student_id,course_id,academic_period) VALUES ('10000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','2026.2');
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23505' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'enrollments_student_course_period_unique' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- carga horária 0
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE courses SET workload_hours = 0;
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'courses_workload_hours_positive' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- carga horária -1
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE courses SET workload_hours = -1;
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'courses_workload_hours_positive' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- nota -0.01
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE grades SET value = -0.01;
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'grades_value_range' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- nota 10.01
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE grades SET value = 10.01;
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'grades_value_range' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- nota 'NaN'
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE grades SET value = 'NaN';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'grades_value_range' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- nota 'Infinity'
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE grades SET value = 'Infinity';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'grades_value_range' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- nota '-Infinity'
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE grades SET value = '-Infinity';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'grades_value_range' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- courses.workload_hours: nulo
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE courses SET workload_hours = NULL;
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23502' THEN
    NULL;
  END;
END $$;

-- enrollments.student_id: nulo
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE enrollments SET student_id = NULL;
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23502' THEN
    NULL;
  END;
END $$;

-- enrollments.course_id: nulo
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE enrollments SET course_id = NULL;
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23502' THEN
    NULL;
  END;
END $$;

-- enrollments.status: nulo
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE enrollments SET status = NULL;
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23502' THEN
    NULL;
  END;
END $$;

-- grades.enrollment_id: nulo
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE grades SET enrollment_id = NULL;
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23502' THEN
    NULL;
  END;
END $$;

-- grades.value: nulo
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE grades SET value = NULL;
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23502' THEN
    NULL;
  END;
END $$;

-- enrollments.student_id: órfão
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE enrollments SET student_id = 'ffffffff-ffff-ffff-ffff-ffffffffffff';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23503' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'enrollments_ref_student_id' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- enrollments.course_id: órfão
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE enrollments SET course_id = 'ffffffff-ffff-ffff-ffff-ffffffffffff';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23503' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'enrollments_ref_course_id' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- grades.enrollment_id: órfão
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE grades SET enrollment_id = 'ffffffff-ffff-ffff-ffff-ffffffffffff';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23503' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'grades_ref_enrollment_id' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- status inválido
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    UPDATE enrollments SET status = 'Pending';
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '22P02' THEN
    NULL;
  END;
END $$;

-- exclusão de students referenciado
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    DELETE FROM students;
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23503' OR SQLSTATE '23001' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'enrollments_ref_student_id' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- exclusão de courses referenciado
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    DELETE FROM courses;
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23503' OR SQLSTATE '23001' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'enrollments_ref_course_id' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;

-- exclusão de enrollments referenciado
DO $$ DECLARE actual_constraint TEXT; BEGIN
  BEGIN
    DELETE FROM enrollments;
    RAISE EXCEPTION 'Expected constraint violation';
  EXCEPTION WHEN SQLSTATE '23503' OR SQLSTATE '23001' THEN
    GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
    IF actual_constraint <> 'grades_ref_enrollment_id' THEN RAISE EXCEPTION 'Unexpected constraint: %', actual_constraint; END IF;
  END;
END $$;
ROLLBACK;
