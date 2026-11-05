module Web.Controller.Assessments where

import Web.Controller.Prelude
import Web.View.Assessments.Index
import Web.View.Assessments.New
import Web.View.Assessments.Show
import Application.Helper.Permissoes
import Application.Helper.Validacoes (textoObrigatorioValido)

instance Controller AssessmentsController where
    beforeAction = do
        ensureIsUser
        requirePasswordChange
        let papel = papelDoBanco currentUser.role_
        accessDeniedUnless
            (papel == Just Administrador || papel == Just Professor)

    action AssessmentsAction = do
        assessments <- query @Assessment
            |> orderByAsc #name
            |> fetch
        courses <- query @Course |> fetch
        render IndexView { .. }

    action NewAssessmentAction = do
        let assessment = newRecord @Assessment
        courses <- query @Course
            |> orderByAsc #name
            |> fetch
        render NewView { .. }

    action CreateAssessmentAction = do
        let assessment = newRecord @Assessment

        assessment
            |> fill @'["courseId", "academicPeriod", "name"]
            |> validateField #academicPeriod nonBlank
            |> validateField #name nonBlank
            |> ifValid \case
                Left assessment -> do
                    courses <- query @Course |> fetch
                    render NewView { .. }

                Right assessment -> do
                    exists <- query @Assessment
                        |> filterWhere (#courseId, assessment.courseId)
                        |> filterWhere (#academicPeriod, assessment.academicPeriod)
                        |> filterWhere (#name, assessment.name)
                        |> fetchExists

                    if exists
                        then do
                            setErrorMessage
                                "Esta avaliacao ja existe nessa disciplina e periodo."
                            redirectTo NewAssessmentAction
                        else do
                            assessment <- createRecord assessment
                            setSuccessMessage
                                "Avaliacao criada com sucesso."
                            redirectTo ShowAssessmentAction
                                { assessmentId = assessment.id }

    action ShowAssessmentAction { assessmentId } = do
        assessment <- fetch assessmentId
        course <- fetch assessment.courseId

        enrollments <- query @Enrollment
            |> filterWhere (#courseId, assessment.courseId)
            |> filterWhere (#academicPeriod, assessment.academicPeriod)
            |> fetch

        students <- query @Student |> fetch

        render ShowView { .. }

    action CreateAssessmentGradeAction { assessmentId, enrollmentId } = do
        assessment <- fetch assessmentId
        enrollment <- fetch enrollmentId

        -- Impede lancar nota em uma disciplina ou periodo diferente.
        accessDeniedUnless
            (enrollment.courseId == assessment.courseId
             && enrollment.academicPeriod == assessment.academicPeriod)

        alreadyExists <- query @Grade
            |> filterWhere (#enrollmentId, enrollmentId)
            |> filterWhere (#assessmentId, Just assessmentId)
            |> fetchExists

        if alreadyExists
            then do
                setErrorMessage "Este estudante ja tem nota nessa avaliacao."
                redirectTo ShowAssessmentAction { assessmentId }
            else do
                let grade = newRecord @Grade
                        |> set #enrollmentId enrollmentId
                        |> set #assessmentId (Just assessmentId)
                        |> set #assessmentName assessment.name

                grade
                    |> fill @'["value"]
                    |> validateField #value (isInRange (0, 10))
                    |> ifValid \case
                        Left _ -> do
                            setErrorMessage "Informe uma nota entre 0 e 10."
                            redirectTo ShowAssessmentAction { assessmentId }
                        Right validGrade -> do
                            _ <- createRecord validGrade
                            setSuccessMessage "Nota cadastrada com sucesso."
                            redirectTo ShowAssessmentAction { assessmentId }

nonBlank :: Text -> ValidatorResult
nonBlank value
    | textoObrigatorioValido value = Success
    | otherwise = Failure "Este campo e obrigatorio."
