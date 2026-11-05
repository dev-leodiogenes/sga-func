module Web.Controller.Grades where

import Web.Controller.Prelude
import Application.Helper.Permissoes
import Application.Helper.Validacoes (textoObrigatorioValido)

instance Controller GradesController where
    beforeAction = do
        ensureIsUser
        let papel = papelDoBanco currentUser.role_
        accessDeniedUnless
            (papel == Just Administrador || papel == Just Professor)

    action CreateGradeAction { enrollmentId } = do
        enrollment <- fetch enrollmentId

        let grade = newRecord @Grade
                |> set #enrollmentId enrollment.id

        grade
            |> fill @'["assessmentName", "value"]
            |> validateField #assessmentName nonBlank
            |> validateField #value (isInRange (0, 10))
            |> ifValid \case
                Left _ -> do
                    setErrorMessage "Verifique a avaliacao e informe uma nota entre 0 e 10."
                    redirectTo ShowEnrollmentAction { enrollmentId }

                Right validGrade -> do
                    _ <- createRecord validGrade
                    setSuccessMessage "Nota cadastrada com sucesso."
                    redirectTo ShowEnrollmentAction { enrollmentId }

    action DeleteGradeAction { gradeId } = do
        grade <- fetch gradeId
        let enrollmentId = grade.enrollmentId

        deleteRecord grade
        setSuccessMessage "Nota excluida com sucesso."
        redirectTo ShowEnrollmentAction { enrollmentId }

nonBlank :: Text -> ValidatorResult
nonBlank value
    | textoObrigatorioValido value = Success
    | otherwise = Failure "O nome da avaliacao e obrigatorio."
