module Web.View.Students.New where

import Web.View.Prelude
import Web.View.Students.Form (renderForm)

data NewView = NewView { student :: Student }

instance View NewView where
    html NewView { .. } = [hsx|
        <h1>Novo estudante</h1>
        {renderForm student}
        <a class="btn btn-link mt-3" href={StudentsAction}>Voltar</a>
    |]
