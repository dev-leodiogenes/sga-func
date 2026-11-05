module Web.View.Layout where

import Web.View.Prelude

defaultLayout :: Html -> Html
defaultLayout inner = [hsx|
    <!DOCTYPE html>
    <html lang="pt-BR">
        <head>
            <meta charset="UTF-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <title>SGA - Sistema de Gestao Academica</title>
            <link rel="stylesheet" href="/static/prod.css" />
        </head>
        <body>
            <nav class="navbar navbar-dark bg-dark mb-4">
                <div class="container">
                    <a class="navbar-brand" href={CoursesAction}>SGA</a>
                    <div class="d-flex gap-3">
                        {studentsNavigation}
                        {coursesNavigation}
                        {dashboardNavigation}
                        {authNavigation}
                    </div>
                </div>
            </nav>
            <main class="container pb-5">
                {renderFlashMessages}
                {inner}
            </main>
        </body>
    </html>
|]

authNavigation :: (?context :: ControllerContext) => Html
authNavigation =
    case currentUserOrNothing of
        Nothing -> [hsx|<a class="text-white" href={NewSessionAction}>Entrar</a>|]
        Just _ -> [hsx|
            <form method="POST" action={DeleteSessionAction}>
                <button class="btn btn-sm btn-outline-light" type="submit">Sair</button>
            </form>
        |]

mayListStudents :: (?context :: ControllerContext) => Bool
mayListStudents = case currentUserOrNothing of
    Just user -> user.role_ == "admin" || user.role_ == "professor"
    Nothing -> False

maySeeDashboard :: (?context :: ControllerContext) => Bool
maySeeDashboard = mayListStudents

studentsNavigation :: (?context :: ControllerContext) => Html
studentsNavigation =
    if mayListStudents then [hsx|<a class="text-white" href={StudentsAction}>Estudantes</a>|] else mempty

coursesNavigation :: (?context :: ControllerContext) => Html
coursesNavigation =
    if isJust currentUserOrNothing then [hsx|<a class="text-white" href={CoursesAction}>Cursos</a>|] else mempty

dashboardNavigation :: (?context :: ControllerContext) => Html
dashboardNavigation =
    if maySeeDashboard then [hsx|<a class="text-white" href={DashboardAction}>Dashboard</a>|] else mempty
