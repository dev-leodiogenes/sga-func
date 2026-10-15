module Web.View.Courses.New where

import Web.View.Prelude
import Web.View.Courses.Form (renderForm)

data NewView = NewView { course :: Course }

instance View NewView where
    html NewView { .. } = [hsx|
        <h1>Nova disciplina</h1>
        {renderForm course}
        <a class="btn btn-link mt-3" href={CoursesAction}>Voltar</a>
    |]
