module Web.View.Layout where

import Web.View.Prelude

defaultLayout :: (?context :: Request, ?request :: Request) => Html -> Html
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
                        {dashboardNavigation}
                        {studentsNavigation}
                        {reportCardNavigation}
                        {coursesNavigation}
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

authNavigation :: (?context :: Request, ?request :: Request) => Html
authNavigation =
    case currentUserOrNothing of
        Nothing -> [hsx|<a class="text-white" href={NewSessionAction}>Entrar</a>|]
        Just _ -> [hsx|
            <form method="POST" action={CreateLogoutAction}>
                <button class="btn btn-sm btn-outline-light" type="submit">Sair</button>
            </form>
        |]

mayListStudents :: (?context :: Request, ?request :: Request) => Bool
mayListStudents = case currentUserOrNothing of
    Just user -> user.role_ == "admin" || user.role_ == "professor"
    Nothing -> False

maySeeDashboard :: (?context :: Request, ?request :: Request) => Bool
maySeeDashboard = mayListStudents

studentsNavigation :: (?context :: Request, ?request :: Request) => Html
studentsNavigation =
    if mayListStudents then [hsx|<a class="text-white" href={StudentsAction}>Estudantes</a>|] else mempty

coursesNavigation :: (?context :: Request, ?request :: Request) => Html
coursesNavigation =
    if isJust currentUserOrNothing then [hsx|<a class="text-white" href={CoursesAction}>Disciplinas</a>|] else mempty

dashboardNavigation :: (?context :: Request, ?request :: Request) => Html
dashboardNavigation =
    if maySeeDashboard then [hsx|<a class="text-white" href={DashboardAction}>Painel</a>|] else mempty


enrollmentsNavigation :: (?context :: Request, ?request :: Request) => Html
enrollmentsNavigation =
    if mayListStudents
        then [hsx|<a class="text-white" href={EnrollmentsAction}>Matriculas</a>|]
        else mempty


-- Administradores e professores podem consultar avaliacoes.
assessmentsNavigation :: (?context :: Request, ?request :: Request) => Html
assessmentsNavigation =
    if mayListStudents
        then [hsx|
            <a class="text-white" href={AssessmentsAction}>
                Avaliacoes
            </a>
        |]
        else mempty


reportCardNavigation :: (?context :: Request, ?request :: Request) => Html
reportCardNavigation =
    case currentUserOrNothing of
        Just user | user.role_ == "aluno" ->
            [hsx|
                <a class="text-white" href={MyReportCardAction}>
                    Meu boletim
                </a>
            |]
        _ -> mempty
