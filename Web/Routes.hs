module Web.Routes where

import IHP.RouterPrelude
import Generated.Types
import Web.Types

-- Mantem as rotas padrao do IHP 1.6 (GET/POST/DELETE).
instance AutoRoute StudentsController
