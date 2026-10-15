module Web.View.Courses.Index where

import Web.View.Prelude

data IndexView = IndexView { courses :: [Course] }

instance View IndexView where
    html IndexView { .. } = [hsx|
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h1>Disciplinas</h1>
            <a href={NewCourseAction} class="btn btn-primary">Nova disciplina</a>
        </div>
        <p class="text-muted">Cadastro e consulta de disciplinas do SGA.</p>
        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Codigo</th>
                    <th>Nome</th>
                    <th>Carga horaria</th>
                    <th>Acoes</th>
                </tr>
            </thead>
            <tbody>
                {forEach courses renderCourse}
            </tbody>
        </table>
    |]

renderCourse :: Course -> Html
renderCourse course = [hsx|
    <tr>
        <td>{course.code}</td>
        <td>{course.name}</td>
        <td>{course.workloadHours}</td>
        <td>
            <a href={ShowCourseAction course.id} class="btn btn-sm btn-outline-primary">Ver</a>
            <a href={EditCourseAction course.id} class="btn btn-sm btn-outline-secondary">Editar</a>
        </td>
    </tr>
|]
