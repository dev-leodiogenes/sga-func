module Web.View.Courses.Show where

import Web.View.Prelude

data ShowView = ShowView { course :: Course }

instance View ShowView where
    html ShowView { .. } = [hsx|
        <h1>{course.name}</h1>
        <dl class="row mt-4">
            <dt class="col-sm-3">Codigo</dt>
            <dd class="col-sm-9">{course.code}</dd>
            <dt class="col-sm-3">Carga horaria (h)</dt>
            <dd class="col-sm-9">{course.workloadHours}</dd>
        </dl>
        <div class="d-flex gap-2 mt-4">
            <a href={CoursesAction} class="btn btn-outline-secondary">Voltar</a>
            <a href={EditCourseAction course.id} class="btn btn-primary">Editar</a>
            <form method="POST" action={DeleteCourseAction course.id}>
                <input type="hidden" name="_method" value="DELETE" />
                <button type="submit" class="btn btn-outline-danger">Excluir disciplina</button>
            </form>
        </div>
        <p class="text-muted mt-2">A exclusao e bloqueada quando existem matriculas vinculadas.</p>
    |]
