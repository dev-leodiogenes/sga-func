module Web.Controller.Students where

import Web.Controller.Prelude
import Web.View.Students.Index
import Web.View.Students.New
import Web.View.Students.Show
import Web.View.Students.Edit
import qualified Data.Text as Text

instance Controller StudentsController where
    action StudentsAction = do
        students <- query @Student
            |> orderByAsc #name
            |> fetch
        render IndexView { .. }

    action NewStudentAction = do
        let student = newRecord @Student
        render NewView { .. }

    action ShowStudentAction { studentId } = do
        student <- fetch studentId
        render ShowView { .. }

    action EditStudentAction { studentId } = do
        student <- fetch studentId
        render EditView { .. }

    action CreateStudentAction = do
        let student = newRecord @Student
        student
            |> buildStudent
            |> validateIsUnique #registrationNumber
            >>= ifValid \case
                Left student -> render NewView { .. }
                Right student -> do
                    student <- createRecord student
                    setSuccessMessage "Estudante cadastrado com sucesso."
                    redirectTo ShowStudentAction { studentId = student.id }

    action UpdateStudentAction { studentId } = do
        student <- fetch studentId
        student
            |> buildStudent
            |> validateIsUnique #registrationNumber
            >>= ifValid \case
                Left student -> render EditView { .. }
                Right student -> do
                    student <- updateRecord student
                    setSuccessMessage "Estudante atualizado com sucesso."
                    redirectTo ShowStudentAction { studentId = student.id }

    action DeleteStudentAction { studentId } = do
        -- O esquema ja proibe apagar estudantes com matriculas vinculadas.
        -- Esta consulta permite informar o problema antes de tentar o DELETE.
        hasEnrollments <- query @Enrollment
            |> filterWhere (#studentId, studentId)
            |> fetchExists
        if hasEnrollments
            then do
                setErrorMessage "Nao e possivel excluir: existem matriculas vinculadas."
                redirectTo ShowStudentAction { studentId }
            else do
                student <- fetch studentId
                deleteRecord student
                setSuccessMessage "Estudante excluido com sucesso."
                redirectTo StudentsAction

-- Funcao pura: valida se o campo contem caracteres nao brancos.
nonBlank :: Text -> ValidatorResult
nonBlank value
    | Text.null (Text.strip value) = Failure "Este campo e obrigatorio."
    | otherwise = Success

-- Validacoes em memoria; o IHP acrescenta erros ao record.
-- A unicidade da matricula e validada com consulta no controller.
buildStudent student = student
    |> fill @'["registrationNumber", "name", "email"]
    |> validateField #registrationNumber nonBlank
    |> validateField #name nonBlank
    |> validateField #email nonBlank
    |> validateField #email isEmail
