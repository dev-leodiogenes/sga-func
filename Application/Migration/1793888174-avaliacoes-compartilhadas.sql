-- Avaliacoes compartilhadas por disciplina e periodo academico

CREATE TABLE IF NOT EXISTS assessments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY NOT NULL,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE RESTRICT,
    academic_period TEXT NOT NULL,
    name TEXT NOT NULL,

    CONSTRAINT assessments_period_not_blank
        CHECK (length(replace(academic_period, ' ', '')) > 0),

    CONSTRAINT assessments_name_not_blank
        CHECK (length(replace(name, ' ', '')) > 0),

    CONSTRAINT assessments_course_period_name_unique
        UNIQUE (course_id, academic_period, name)
);

CREATE INDEX IF NOT EXISTS assessments_course_id_index
    ON assessments (course_id);

-- Ligacao entre cada nota individual e a avaliacao compartilhada
ALTER TABLE grades
    ADD COLUMN IF NOT EXISTS assessment_id UUID
    REFERENCES assessments(id) ON DELETE RESTRICT;

-- Um estudante so pode receber uma nota por avaliacao
CREATE UNIQUE INDEX IF NOT EXISTS grades_enrollment_assessment_unique
    ON grades (enrollment_id, assessment_id)
    WHERE assessment_id IS NOT NULL;
