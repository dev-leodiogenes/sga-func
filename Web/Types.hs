module Web.Types where

import IHP.Prelude
import IHP.ModelSupport
import Generated.Types

data WebApplication = WebApplication deriving (Eq, Show, Data)

data StudentsController
    = StudentsAction
    | NewStudentAction
    | ShowStudentAction { studentId :: !(Id Student) }
    | CreateStudentAction
    | EditStudentAction { studentId :: !(Id Student) }
    | UpdateStudentAction { studentId :: !(Id Student) }
    | DeleteStudentAction { studentId :: !(Id Student) }
    deriving (Eq, Show, Data)
