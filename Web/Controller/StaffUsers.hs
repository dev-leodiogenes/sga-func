module Web.Controller.StaffUsers where

import Web.Controller.Prelude
import Web.View.StaffUsers.Index
import Web.View.StaffUsers.New
import Application.Helper.Permissoes
import IHP.AuthSupport.Authentication (hashPassword)
import IHP.TypedSql (typedSql, sqlQueryTyped, sqlExecTyped)
import qualified Data.Text as T

instance Controller StaffUsersController where
    beforeAction = do
        ensureIsUser
        requirePasswordChange
        accessDeniedUnless
            (papelDoBanco currentUser.role_ == Just Administrador)

    action StaffUsersAction = do
        users <- query @User |> fetch

        let staffUsers = filter
                (\usuario ->
                    usuario.role_ == "professor"
                    || usuario.role_ == "coordenador")
                users

        render IndexView { .. }

    action NewStaffUserAction = do
        let user = newRecord @User
        courses <- query @Course |> orderByAsc #name |> fetch
        render NewView { .. }

    action CreateStaffUserAction = do
        let name = T.strip (param @Text "name")
        let email = T.toLower (T.strip (param @Text "email"))
        let role = param @Text "role"
        let initialPassword = param @Text "initialPassword"
        let user = newRecord @User
        courses <- query @Course |> orderByAsc #name |> fetch

        let courseIds = paramList @(Id Course) "courseIds"
        let selectedCourses = filter
                (\course -> course.id `elem` courseIds)
                courses

        existingUsers <- sqlQueryTyped [typedSql|
            SELECT id FROM users
            WHERE lower(email) = lower(${email})
            LIMIT 1
        |]

        if T.null name
            then do
                setErrorMessage "Informe o nome do profissional."
                render NewView { .. }

            else if not (emailValido email)
                then do
                    setErrorMessage "Informe um e-mail válido."
                    render NewView { .. }

            else if role /= "professor" && role /= "coordenador"
                then do
                    setErrorMessage "Selecione um perfil válido."
                    render NewView { .. }

            else if length courseIds /= length selectedCourses
                then do
                    setErrorMessage "Selecione apenas disciplinas válidas, sem duplicações."
                    render NewView { .. }

            else if role == "professor" && null selectedCourses
                then do
                    setErrorMessage "Selecione pelo menos uma disciplina para o professor."
                    render NewView { .. }

            else if role == "coordenador" && not (null selectedCourses)
                then do
                    setErrorMessage "O vínculo de disciplinas é exclusivo de professores."
                    render NewView { .. }

            else if T.length (T.strip initialPassword) < 8
                then do
                    setErrorMessage "A senha deve ter pelo menos 8 caracteres."
                    render NewView { .. }

            else if not (null existingUsers)
                then do
                    setErrorMessage "Já existe uma conta com este e-mail."
                    render NewView { .. }

            else do
                passwordHash <- hashPassword initialPassword

                let newUser = newRecord @User
                        |> set #name (Just name)
                        |> set #email email
                        |> set #passwordHash passwordHash
                        |> set #role_ role
                        |> set #mustChangePassword True

                _ <- withTransaction do
                    createdUser <- createRecord newUser

                    forM_ selectedCourses \course -> do
                        let professorId :: Id User
                            professorId = createdUser.id

                        let courseId :: Id Course
                            courseId = course.id

                        _ <- sqlExecTyped [typedSql|
                            INSERT INTO professor_courses
                                (professor_id, course_id)
                            VALUES
                                (${professorId}, ${courseId})
                        |]
                        pure ()

                    pure createdUser

                setSuccessMessage "Profissional cadastrado com sucesso."
                redirectTo StaffUsersAction


emailValido :: Text -> Bool
emailValido email =
    case T.splitOn "@" email of
        [local, dominio] ->
            not (T.null local)
            && not (T.null dominio)
            && not (T.any (== ' ') email)
        _ -> False
