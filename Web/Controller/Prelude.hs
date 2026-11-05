module Web.Controller.Prelude
    ( module IHP.ControllerPrelude
    , module Generated.Types
    , module Web.Types
    , requirePasswordChange
    ) where

import IHP.ControllerPrelude
import Generated.Types
import Web.Types
import Web.Routes ()


-- Exige a troca da senha inicial antes de acessar o SGA.
requirePasswordChange :: (?request :: Request, ?respond :: Respond) => IO ()
requirePasswordChange = do
    let user = currentUser @User
    when (user.mustChangePassword) $
        earlyReturn (redirectTo NewPasswordAction)
