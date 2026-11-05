module Config where

import IHP.Prelude
import IHP.Environment
import IHP.FrameworkConfig
import IHP.LoginSupport.Middleware
import Generated.Types (User)
import Web.Types () -- make CurrentUserRecord ~ User available in Config

config :: ConfigBuilder
config = do
    -- See https://ihp.digitallyinduced.com/Guide/config.html
    -- for what you can do here
    option $ AuthMiddleware (authMiddleware @User)