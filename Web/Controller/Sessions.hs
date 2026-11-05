module Web.Controller.Sessions where

import Web.Controller.Prelude
import Web.View.Sessions.ChangePassword
import IHP.AuthSupport.Authentication
    (hashPassword, VerifiyPassword (verifyPassword'))
import qualified Data.Text as T
import Web.View.Sessions.New ()
import qualified IHP.AuthSupport.Controller.Sessions as Sessions

instance Controller SessionsController where
    action NewSessionAction = Sessions.newSessionAction @User
    action CreateSessionAction = Sessions.createSessionAction @User
    action DeleteSessionAction = Sessions.deleteSessionAction @User
    action CreateLogoutAction = Sessions.deleteSessionAction @User
    action NewPasswordAction = do
        ensureIsUser
        render ChangePasswordView

    action CreatePasswordChangeAction = do
        ensureIsUser

        let newPassword = param @Text "newPassword"
        let confirmation = param @Text "confirmPassword"

        if T.length newPassword < 8
            || T.null (T.strip newPassword)
            || newPassword /= confirmation
            || verifyPassword' currentUser.passwordHash newPassword
            then do
                setErrorMessage
                    "Use uma senha diferente da inicial, com pelo menos 8 caracteres, e confirme corretamente."
                redirectTo NewPasswordAction
            else do
                passwordHash <- hashPassword newPassword
                _ <- currentUser
                    |> set #passwordHash passwordHash
                    |> set #mustChangePassword False
                    |> updateRecord

                setSuccessMessage "Senha alterada com sucesso."
                redirectTo CoursesAction


instance Sessions.SessionsControllerConfig User
