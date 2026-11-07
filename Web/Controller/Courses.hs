module Web.Controller.Courses where

import Web.Controller.Prelude
import Data.Coerce (coerce)
import Web.View.Courses.Index
import Web.View.Courses.New
import Web.View.Courses.Show
import Web.View.Courses.Edit
import Application.Helper.Validacoes (textoObrigatorioValido, cargaHorariaValida)
import Application.Helper.Permissoes

instance Controller CoursesController where
    beforeAction = do
        ensureIsUser
        requirePasswordChange
        let papel = papelDoBanco currentUser.role_
        case ?theAction of
            CoursesAction -> accessDeniedUnless (papel /= Nothing)
            ShowCourseAction {} ->
                accessDeniedUnless (papel /= Nothing)

            NewCourseAction ->
                accessDeniedUnless
                    (papel == Just Administrador || papel == Just Coordenador)

            CreateCourseAction ->
                accessDeniedUnless
                    (papel == Just Administrador || papel == Just Coordenador)

            EditCourseAction {} ->
                accessDeniedUnless
                    (papel == Just Administrador || papel == Just Coordenador)

            UpdateCourseAction {} ->
                accessDeniedUnless
                    (papel == Just Administrador || papel == Just Coordenador)

            _ ->
                accessDeniedUnless (papel == Just Administrador)

    action CoursesAction = do
        allCourses <- query @Course
            |> orderByAsc #name
            |> fetch

        courses <- if currentUser.role_ == "aluno"
            then case currentUser.studentId of
                Nothing -> pure []
                Just studentUuid -> do
                    enrollments <- query @Enrollment
                        |> filterWhere (#studentId, coerce studentUuid :: Id Student)
                        |> fetch
                    pure (filter
                        (\course -> any
                            (\enrollment -> enrollment.courseId == course.id)
                            enrollments)
                        allCourses)
            else pure allCourses

        render IndexView { .. }

    action NewCourseAction = do
        let course = newRecord @Course
        render NewView { .. }

    action ShowCourseAction { courseId } = do
        when (currentUser.role_ == "aluno") do
            case currentUser.studentId of
                Nothing -> accessDeniedUnless False
                Just studentUuid -> do
                    enrolled <- query @Enrollment
                        |> filterWhere (#studentId, coerce studentUuid :: Id Student)
                        |> filterWhere (#courseId, courseId)
                        |> fetchExists
                    accessDeniedUnless enrolled

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
