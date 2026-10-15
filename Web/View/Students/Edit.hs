module Web.View.Students.Edit where

import Web.View.Prelude
import Web.View.Students.Form (renderForm)

data EditView = EditView { student :: Student }

instance View EditView where
    html EditView { .. } = [hsx|
        <h1>Editar estudante</h1>
        {renderForm student}
        <a class="btn btn-link mt-3" href={ShowStudentAction student.id}>Voltar</a>
    |]
