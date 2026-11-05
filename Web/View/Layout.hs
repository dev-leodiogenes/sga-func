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
                    <a class="navbar-brand" href={StudentsAction}>SGA</a>
                    <div class="d-flex gap-3">
                        {when (isJust currentUserOrNothing) [hsx|<a class="text-white" href={StudentsAction}>Estudantes</a>|]}
                        {when (isJust currentUserOrNothing) [hsx|<a class="text-white" href={CoursesAction}>Cursos</a>|]}
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

authNavigation :: Html
authNavigation =
    case currentUserOrNothing of
        Nothing -> [hsx|<a class="text-white" href={NewSessionAction}>Entrar</a>|]
        Just _ -> [hsx|
            <form method="POST" action={DeleteSessionAction}>
                <button class="btn btn-sm btn-outline-light" type="submit">Sair</button>
            </form>
        |]
