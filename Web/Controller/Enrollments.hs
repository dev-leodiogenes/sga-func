module Web.Controller.Enrollments where

import Web.Controller.Prelude
import Web.View.Enrollments.Index
import Web.View.Enrollments.New
import Web.View.Enrollments.Show
import Web.View.Enrollments.Edit
import Application.Helper.Permissoes
import Application.Helper.Validacoes (textoObrigatorioValido)

instance Controller EnrollmentsController where
    beforeAction = do
        ensureIsUser
        requirePasswordChange
        let papel = papelDoBanco currentUser.role_
        case ?theAction of
            StudentEnrollmentsAction {} ->
                accessDeniedUnless
                    (papel == Just Administrador
                     || papel == Just Coordenador
                     || papel == Just Professor)

            EnrollmentsAction ->
                accessDeniedUnless
                    (papel == Just Administrador
                     || papel == Just Coordenador
                     || papel == Just Professor)

            ShowEnrollmentAction {} ->
                accessDeniedUnless
                    (papel == Just Administrador
                     || papel == Just Coordenador
                     || papel == Just Professor)

            NewEnrollmentAction ->
                accessDeniedUnless
                    (papel == Just Administrador
                     || papel == Just Coordenador)

            CreateEnrollmentAction ->
                accessDeniedUnless
                    (papel == Just Administrador
                     || papel == Just Coordenador)

            EditEnrollmentAction {} ->
                accessDeniedUnless
                    (papel == Just Administrador
                     || papel == Just Coordenador)

            UpdateEnrollmentAction {} ->
                accessDeniedUnless
                    (papel == Just Administrador
                     || papel == Just Coordenador)

            _ ->
                accessDeniedUnless (papel == Just Administrador)

    action EnrollmentsAction = do
        let selectedStudent = Nothing
        enrollments <- query @Enrollment |> orderByDesc #academicPeriod |> fetch
        students <- query @Student |> fetch
        courses <- query @Course |> fetch
        render IndexView { .. }

    action StudentEnrollmentsAction { studentId } = do
        student <- fetch studentId
        let selectedStudent = Just student
        enrollments <- query @Enrollment
            |> filterWhere (#studentId, studentId)
            |> orderByDesc #academicPeriod
            |> fetch
        students <- query @Student |> fetch
        courses <- query @Course |> fetch
        render IndexView { .. }

    action NewEnrollmentAction = do
        let enrollment = newRecord @Enrollment
        students <- query @Student |> orderByAsc #name |> fetch
        courses <- query @Course |> orderByAsc #name |> fetch
        periods <- query @AcademicPeriod |> orderByAsc #code |> fetch
        render NewView { .. }

    action CreateEnrollmentAction = do
        let enrollment = newRecord @Enrollment
        periods <- query @AcademicPeriod |> orderByAsc #code |> fetch

        enrollment
            |> fill @'["studentId", "courseId", "academicPeriod"]
            |> validateField #academicPeriod nonBlank
            |> validateField #academicPeriod (\valor ->
                if any (\period -> period.code == valor) periods
                    then Success
                    else Failure "Selecione um período acadêmico válido.")
            |> ifValid \case
                Left enrollment -> do
                    students <- query @Student |> orderByAsc #name |> fetch
                    courses <- query @Course |> orderByAsc #name |> fetch
                    render NewView { .. }

                Right enrollment -> do
                    exists <- query @Enrollment
                        |> filterWhere (#studentId, enrollment.studentId)
                        |> filterWhere (#courseId, enrollment.courseId)
                        |> filterWhere (#academicPeriod, enrollment.academicPeriod)
                        |> fetchExists

                    if exists
                        then do
                            setErrorMessage "Este estudante ja esta matriculado nessa disciplina e periodo."
                            redirectTo NewEnrollmentAction
                        else do
                            enrollment <- createRecord enrollment
                            setSuccessMessage "Matricula realizada com sucesso."
                            redirectTo ShowEnrollmentAction { enrollmentId = enrollment.id }

    action ShowEnrollmentAction { enrollmentId } = do
        enrollment <- fetch enrollmentId
        student <- fetch enrollment.studentId
        course <- fetch enrollment.courseId

        assessments <- query @Assessment
            |> filterWhere (#courseId, enrollment.courseId)
            |> filterWhere (#academicPeriod, enrollment.academicPeriod)
            |> orderByAsc #name
            |> fetch

        grades <- query @Grade
            |> filterWhere (#enrollmentId, enrollmentId)
            |> orderByAsc #assessmentName
            |> fetch

        let newGrade = newRecord @Grade
                |> set #enrollmentId enrollment.id

        render ShowView { .. }

    action EditEnrollmentAction { enrollmentId } = do
        enrollment <- fetch enrollmentId

        hasGrades <- query @Grade
            |> filterWhere (#enrollmentId, enrollmentId)
            |> fetchExists

        if hasGrades
            then do
                setErrorMessage "Não é possível alterar o período de uma matrícula com notas."
                redirectTo ShowEnrollmentAction { enrollmentId }
            else do
                student <- fetch enrollment.studentId
                course <- fetch enrollment.courseId
                periods <- query @AcademicPeriod
                    |> orderByAsc #code
                    |> fetch

                render EditView { .. }

    action UpdateEnrollmentAction { enrollmentId } = do
        enrollment <- fetch enrollmentId
        let novoPeriodo = param @Text "academicPeriod"

        periods <- query @AcademicPeriod |> fetch

        hasGrades <- query @Grade
            |> filterWhere (#enrollmentId, enrollmentId)
            |> fetchExists

        duplicate <- query @Enrollment
            |> filterWhere (#studentId, enrollment.studentId)
            |> filterWhere (#courseId, enrollment.courseId)
            |> filterWhere (#academicPeriod, novoPeriodo)
            |> fetchExists

        if hasGrades
            then do
                setErrorMessage "Não é possível alterar o período de uma matrícula com notas."
                redirectTo ShowEnrollmentAction { enrollmentId }

            else if not (any (\period -> period.code == novoPeriodo) periods)
                then do
                    setErrorMessage "Selecione um período acadêmico válido."
                    redirectTo EditEnrollmentAction { enrollmentId }

            else if novoPeriodo /= enrollment.academicPeriod && duplicate
                then do
                    setErrorMessage "Este estudante já está matriculado nessa disciplina e período."
                    redirectTo EditEnrollmentAction { enrollmentId }

            else do
                let updatedEnrollment = enrollment
                        |> set #academicPeriod novoPeriodo

                _ <- updateRecord updatedEnrollment

                setSuccessMessage "Período da matrícula atualizado com sucesso."
                redirectTo ShowEnrollmentAction { enrollmentId }

    action CreateEnrollmentDeletionAction { enrollmentId } = do
        enrollment <- fetch enrollmentId
        hasGrades <- query @Grade
            |> filterWhere (#enrollmentId, enrollmentId)
            |> fetchExists

        if hasGrades
            then do
                setErrorMessage "Nao e possivel excluir uma matricula com notas."
                redirectTo ShowEnrollmentAction { enrollmentId }
            else do
                let studentId = enrollment.studentId
                deleteRecord enrollment
                setSuccessMessage "Matricula excluida com sucesso."
                redirectTo StudentEnrollmentsAction { studentId }

nonBlank :: Text -> ValidatorResult
nonBlank value
    | textoObrigatorioValido value = Success
    | otherwise = Failure "O periodo academico e obrigatorio."
