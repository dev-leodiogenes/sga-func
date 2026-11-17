module Web.Controller.StaffUsers where

import Web.Controller.Prelude
import Web.View.StaffUsers.Index
import Web.View.StaffUsers.New
import Application.Helper.Permissoes
import IHP.AuthSupport.Authentication (hashPassword)
import IHP.TypedSql (typedSql, sqlQueryTyped, sqlExecTyped)
import qualified Data.Text as T
import Application.Helper.CadastroProfissional
    ( ErroCadastro (EmailJaCadastrado)
    , validarCadastroProfissional
    , mensagemErroCadastro
    )
import Control.Monad.Except (runExceptT, throwError)
import Control.Monad.IO.Class (liftIO)

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

        resultado <- runExceptT $ do
            either throwError pure $
                validarCadastroProfissional
                    name email role initialPassword
                    (length courseIds)
                    (length selectedCourses)

            existingUsers <- liftIO $ sqlQueryTyped [typedSql|
                SELECT id FROM users
                WHERE lower(email) = lower(${email})
                LIMIT 1
            |]

            when (not (null existingUsers)) $
                throwError EmailJaCadastrado

        case resultado of
            Left erro -> do
                setErrorMessage (mensagemErroCadastro erro)
                render NewView { .. }

            Right () -> do
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
