-- Cadastro de periodos academicos
CREATE TABLE academic_periods (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY NOT NULL,
    code TEXT NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT academic_periods_code_valid
        CHECK (code ~ '^[0-9]{4}[.][12]$')
);

-- Permite no maximo um periodo ativo
CREATE UNIQUE INDEX academic_periods_one_active
    ON academic_periods (is_active)
    WHERE is_active;

-- Preserva os periodos ja utilizados no sistema
INSERT INTO academic_periods (code, is_active)
SELECT academic_period, academic_period = '2026.2'
FROM (
    SELECT academic_period FROM enrollments
    UNION
    SELECT academic_period FROM assessments
) AS existing_periods;

-- Matriculas devem utilizar periodos cadastrados
ALTER TABLE enrollments
    ADD CONSTRAINT enrollments_academic_period_fk
    FOREIGN KEY (academic_period)
    REFERENCES academic_periods(code)
    ON UPDATE CASCADE
    ON DELETE RESTRICT;

-- Avaliacoes tambem devem utilizar periodos cadastrados
ALTER TABLE assessments
    ADD CONSTRAINT assessments_academic_period_fk
    FOREIGN KEY (academic_period)
    REFERENCES academic_periods(code)
    ON UPDATE CASCADE
    ON DELETE RESTRICT;
