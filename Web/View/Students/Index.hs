module Web.View.Students.Index where

import Web.View.Prelude

data IndexView = IndexView { students :: [Student] }

instance View IndexView where
    html IndexView { .. } = [hsx|
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h1>Estudantes</h1>
            <a href={NewStudentAction} class="btn btn-primary">Novo estudante</a>
        </div>
        <p class="text-muted">Cadastro e consulta de estudantes do SGA.</p>
        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Matricula</th>
                    <th>Nome</th>
                    <th>E-mail</th>
                    <th>Acoes</th>
                </tr>
            </thead>
            <tbody>
                {forEach students renderStudent}
            </tbody>
        </table>
    |]

renderStudent :: Student -> Html
renderStudent student = [hsx|
    <tr>
        <td>{student.registrationNumber}</td>
        <td>{student.name}</td>
        <td>{student.email}</td>
        <td>
            <a href={ShowStudentAction student.id} class="btn btn-sm btn-outline-primary">Ver</a>
            <a href={EditStudentAction student.id} class="btn btn-sm btn-outline-secondary">Editar</a>
        </td>
    </tr>
|]
