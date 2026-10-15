module Main where
import IHP.Prelude

import Config
import qualified IHP.Server
import IHP.RouterSupport
import IHP.FrameworkConfig
import Web.Types (WebApplication (..))
import Web.FrontController ()

instance FrontController RootApplication where
    controllers = [mountFrontController WebApplication]

main :: IO ()
main = IHP.Server.run config
