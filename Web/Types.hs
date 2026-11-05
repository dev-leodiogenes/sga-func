module Web.Types where

import IHP.Prelude
import IHP.ModelSupport
import Generated.Types
import IHP.LoginSupport.Types (HasNewSessionUrl (..), CurrentUserRecord)

data WebApplication = WebApplication deriving (Eq, Show, Data)

data StudentsController
    = StudentsAction
    | NewStudentAction
    | ShowStudentAction { studentId :: !(Id Student) }
    | CreateStudentAction
    | EditStudentAction { studentId :: !(Id Student) }
    | UpdateStudentAction { studentId :: !(Id Student) }
    | DeleteStudentAction { studentId :: !(Id Student) }
    | CreateStudentNoteAction { studentId :: !(Id Student) }
    deriving (Eq, Show, Data)

-- Sprint 2: CRUD de disciplinas (Course).
data CoursesController
    = CoursesAction
    | NewCourseAction
    | ShowCourseAction { courseId :: !(Id Course) }
    | CreateCourseAction
    | EditCourseAction { courseId :: !(Id Course) }
    | UpdateCourseAction { courseId :: !(Id Course) }
    | DeleteCourseAction { courseId :: !(Id Course) }
    deriving (Eq, Show, Data)

data SessionsController
    = NewSessionAction
    | CreateSessionAction
    | DeleteSessionAction
    | CreateLogoutAction
    deriving (Eq, Show, Data)

instance HasNewSessionUrl User where
    newSessionUrl _ = "/NewSession"

type instance CurrentUserRecord = User

data DashboardController
    = DashboardAction
    deriving (Eq, Show, Data)

-- Matriculas: vinculo entre estudante e disciplina
data EnrollmentsController
    = EnrollmentsAction
    | NewEnrollmentAction
    | CreateEnrollmentAction
    | ShowEnrollmentAction { enrollmentId :: !(Id Enrollment) }
    deriving (Eq, Show, Data)

-- Notas vinculadas a uma matricula
data GradesController
    = CreateGradeAction { enrollmentId :: !(Id Enrollment) }
    | DeleteGradeAction { gradeId :: !(Id Grade) }
    deriving (Eq, Show, Data)
