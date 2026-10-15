module Web.View.Courses.Edit where

import Web.View.Prelude
import Web.View.Courses.Form (renderForm)

data EditView = EditView { course :: Course }

instance View EditView where
    html EditView { .. } = [hsx|
        <h1>Editar disciplina</h1>
        {renderForm course}
        <a class="btn btn-link mt-3" href={ShowCourseAction course.id}>Voltar</a>
    |]
