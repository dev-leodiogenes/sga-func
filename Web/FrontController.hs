module Web.FrontController where

import IHP.ControllerPrelude
import IHP.FrameworkConfig
import IHP.RouterSupport
import Web.Types
import Web.Routes ()
import Web.Controller.Students ()
import Web.Controller.Courses ()
import Web.View.Layout (defaultLayout)

instance FrontController WebApplication where
    controllers =
        [ startPage StudentsAction
        , parseRoute @StudentsController
        , parseRoute @CoursesController
        ]

instance InitControllerContext WebApplication where
    initContext = setLayout defaultLayout
