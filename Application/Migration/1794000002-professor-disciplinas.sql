-- Disciplinas vinculadas aos professores
CREATE TABLE professor_courses (
    professor_id UUID NOT NULL,
    course_id UUID NOT NULL,

    PRIMARY KEY (professor_id, course_id),

    CONSTRAINT professor_courses_ref_professor
        FOREIGN KEY (professor_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT professor_courses_ref_course
        FOREIGN KEY (course_id)
        REFERENCES courses(id)
        ON DELETE CASCADE
);
