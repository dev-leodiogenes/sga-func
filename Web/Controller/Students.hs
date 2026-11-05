module Web.Controller.Students where

import Web.Controller.Prelude
import qualified Data.List as List
import IHP.AuthSupport.Authentication (hashPassword)
import IHP.TypedSql (typedSql, sqlQueryTyped)
import qualified Data.Text as T
import Web.View.Students.Index
import Web.View.Students.New
import Web.View.Students.Show
import Web.View.Students.ReportCard
import Web.View.Students.Edit
import Application.Helper.Validacoes (textoObrigatorioValido)
import Data.Coerce (coerce)
import Application.Helper.Permissoes
import Application.Helper.Criptografia (savePrivateNote, readPrivateNote)

instance Controller StudentsController where
    beforeAction = do
        ensureIsUser
        requirePasswordChange
        let papel = papelDoBanco currentUser.role_
        case ?theAction of
            MyReportCardAction ->
                accessDeniedUnless
                    (papel == Just Aluno && isJust currentUser.studentId)
            StudentsAction -> accessDeniedUnless (papel == Just Administrador || papel == Just Professor)
            ShowStudentAction { studentId } ->
                accessDeniedUnless (case papel of
                    Just role -> podeAcessarCadastro role (currentUser.studentId == Just (coerce studentId))
                    Nothing -> False)
            _ -> accessDeniedUnless (papel == Just Administrador)

    action StudentsAction = do
        students <- query @Student
            |> orderByAsc #name
            |> fetch
        render IndexView { .. }

    action MyReportCardAction = do
        case currentUser.studentId of
            Nothing -> redirectTo CoursesAction
            Just uuid -> do
                let studentId = coerce uuid :: Id Student

                enrollments <- query @Enrollment
                    |> filterWhere (#studentId, studentId)
                    |> orderByDesc #academicPeriod
                    |> fetch

                courses <- mapM
                    (\enrollment -> fetch enrollment.courseId)
                    enrollments

                gradeGroups <- mapM
                    (\enrollment ->
                        query @Grade
                            |> filterWhere (#enrollmentId, enrollment.id)
                            |> fetch)
                    enrollments

                let grades = concatMap
                        (List.sortOn (\grade -> grade.assessmentName))
                        gradeGroups
                render ReportCardView { .. }

    action NewStudentAction = do
        let student = newRecord @Student
        render NewView { .. }

    action ShowStudentAction { studentId } = do
        student <- fetch studentId
        privateNote <- if currentUser.role_ == "admin" then readPrivateNote studentId else pure Nothing
        render ShowView { .. }

    action EditStudentAction { studentId } = do
        student <- fetch studentId
        render EditView { .. }

    action CreateStudentAction = do
        let initialPassword = param @Text "initialPassword"
        let student = newRecord @Student

        student
            |> buildStudent
            |> validateIsUnique #registrationNumber
            >>= ifValid \case
                Left student -> render NewView { .. }

                Right student -> do
                    let email = student.email

                    existingUsers <- sqlQueryTyped [typedSql|
                        SELECT id FROM users
                        WHERE lower(email) = lower(${email})
                        LIMIT 1
                    |]

                    if T.length (T.strip initialPassword) < 8
                        then do
                            setErrorMessage "A senha deve ter pelo menos 8 caracteres."
                            render NewView { .. }
                        else if not (null existingUsers)
                            then do
                                setErrorMessage "Ja existe uma conta com este e-mail."
                                render NewView { .. }
                            else do
                                passwordHash <- hashPassword initialPassword

                                student <- withTransaction do
                                    student <- createRecord student

                                    let user = newRecord @User
                                            |> set #email student.email
                                            |> set #passwordHash passwordHash
                                            |> set #role_ "aluno"
                                            |> set #studentId (Just (coerce student.id))
                                            |> set #mustChangePassword True

                                    _ <- createRecord user
                                    pure student

                                setSuccessMessage "Estudante e conta criados com sucesso."
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

    action CreateStudentNoteAction { studentId } = do
        let note = param @Text "note"
        savePrivateNote studentId note
        setSuccessMessage "Anotacao privada atualizada."
        redirectTo ShowStudentAction { studentId }

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
    | textoObrigatorioValido value = Success
    | otherwise = Failure "Este campo e obrigatorio."

-- Validacoes em memoria; o IHP acrescenta erros ao record.
-- A unicidade da matricula e validada com consulta no controller.
buildStudent student = student
    |> fill @'["registrationNumber", "name", "email"]
    |> validateField #registrationNumber nonBlank
    |> validateField #name nonBlank
    |> validateField #email nonBlank
    |> validateField #email isEmail
