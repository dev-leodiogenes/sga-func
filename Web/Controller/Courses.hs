module Web.Controller.Courses where

import Web.Controller.Prelude
import Web.View.Courses.Index
import Web.View.Courses.New
import Web.View.Courses.Show
import Web.View.Courses.Edit
import Application.Helper.Validacoes (textoObrigatorioValido, cargaHorariaValida)

instance Controller CoursesController where
    action CoursesAction = do
        courses <- query @Course
            |> orderByAsc #name
            |> fetch
        render IndexView { .. }

    action NewCourseAction = do
        let course = newRecord @Course
        render NewView { .. }

    action ShowCourseAction { courseId } = do
        course <- fetch courseId
        render ShowView { .. }

    action EditCourseAction { courseId } = do
        course <- fetch courseId
        render EditView { .. }

    action CreateCourseAction = do
        let course = newRecord @Course
        course
            |> buildCourse
            |> validateIsUnique #code
            >>= ifValid \case
                Left course -> render NewView { .. }
                Right course -> do
                    course <- createRecord course
                    setSuccessMessage "Disciplina cadastrada com sucesso."
                    redirectTo ShowCourseAction { courseId = course.id }

    action UpdateCourseAction { courseId } = do
        course <- fetch courseId
        course
            |> buildCourse
            |> validateIsUnique #code
            >>= ifValid \case
                Left course -> render EditView { .. }
                Right course -> do
                    course <- updateRecord course
                    setSuccessMessage "Disciplina atualizada com sucesso."
                    redirectTo ShowCourseAction { courseId = course.id }

    action DeleteCourseAction { courseId } = do
        -- O banco impede excluir disciplinas com matriculas vinculadas.
        hasEnrollments <- query @Enrollment
            |> filterWhere (#courseId, courseId)
            |> fetchExists
        if hasEnrollments
            then do
                setErrorMessage "Nao e possivel excluir: existem matriculas vinculadas."
                redirectTo ShowCourseAction { courseId }
            else do
                course <- fetch courseId
                deleteRecord course
                setSuccessMessage "Disciplina excluida com sucesso."
                redirectTo CoursesAction

-- Funcao pura usada na validacao do codigo e do nome.
nonBlank :: Text -> ValidatorResult
nonBlank value
    | textoObrigatorioValido value = Success
    | otherwise = Failure "Este campo e obrigatorio."

-- Funcao pura: carga horaria precisa ser maior que zero.
positiveWorkload :: Int -> ValidatorResult
positiveWorkload hours
    | cargaHorariaValida hours = Success
    | otherwise = Failure "A carga horaria deve ser maior que zero."

-- As validacoes adicionam erros aos campos do record.
-- O codigo tambem e verificado como unico no banco (validateIsUnique).
buildCourse course = course
    |> fill @'["code", "name", "workloadHours"]
    |> validateField #code nonBlank
    |> validateField #name nonBlank
    |> validateField #workloadHours positiveWorkload
