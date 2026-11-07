module Web.Controller.Grades where

import Web.Controller.Prelude
import Control.Monad.Reader (Reader, ask, runReader)
import Application.Helper.Permissoes
import Application.Helper.Validacoes (textoObrigatorioValido)

instance Controller GradesController where
    beforeAction = do
        ensureIsUser
        requirePasswordChange
        let papel = papelDoBanco currentUser.role_
        case ?theAction of
            CreateGradeAction {} ->
                accessDeniedUnless
                    (papel == Just Administrador
                     || papel == Just Coordenador
                     || papel == Just Professor)

            DeleteGradeAction {} ->
                accessDeniedUnless
                    (papel == Just Administrador
                     || papel == Just Professor)

    action CreateGradeAction { enrollmentId } = do
        enrollment <- fetch enrollmentId

        let grade = newRecord @Grade
                |> set #enrollmentId enrollment.id

        grade
            |> fill @'["value"]
            |> validateField #value (\nota ->
                runReader (validarNotaComReader (realToFrac nota)) limitesDeNota)
            |> ifValid \case
                Left _ -> do
                    setErrorMessage "Informe uma nota valida entre 0 e 10."
                    redirectTo ShowEnrollmentAction { enrollmentId }

                Right submitted -> case paramOrNothing @(Id Assessment) "assessmentId" of
                    Nothing -> do
                        setErrorMessage "Selecione uma avaliacao."
                        redirectTo ShowEnrollmentAction { enrollmentId }

                    Just assessmentId -> do
                        assessment <- fetch assessmentId

                        accessDeniedUnless
                            (assessment.courseId == enrollment.courseId
                             && assessment.academicPeriod == enrollment.academicPeriod)

                        exists <- query @Grade
                            |> filterWhere (#enrollmentId, enrollmentId)
                            |> filterWhere (#assessmentId, Just assessmentId)
                            |> fetchExists

                        if exists
                            then do
                                setErrorMessage
                                    "Ja existe uma nota para esta avaliacao."
                                redirectTo ShowEnrollmentAction { enrollmentId }
                            else do
                                let validGrade = submitted
                                        |> set #assessmentId (Just assessmentId)
                                        |> set #assessmentName assessment.name
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


-- Configuracao utilizada na validacao das notas.
limitesDeNota :: (Double, Double)
limitesDeNota = (0, 10)

-- Reader: consulta os limites e valida a nota.
validarNotaComReader :: Double -> Reader (Double, Double) ValidatorResult
validarNotaComReader nota = do
    (minimo, maximo) <- ask
    pure (
        if nota >= minimo && nota <= maximo
            then Success
            else Failure "A nota deve estar entre 0 e 10."
        )
