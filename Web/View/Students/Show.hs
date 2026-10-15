module Web.View.Students.Show where

import Web.View.Prelude

data ShowView = ShowView { student :: Student }

instance View ShowView where
    html ShowView { .. } = [hsx|
        <h1>{student.name}</h1>
        <dl class="row mt-4">
            <dt class="col-sm-3">Matricula</dt>
            <dd class="col-sm-9">{student.registrationNumber}</dd>
            <dt class="col-sm-3">E-mail</dt>
            <dd class="col-sm-9">{student.email}</dd>
        </dl>
        <div class="d-flex gap-2 mt-4">
            <a href={StudentsAction} class="btn btn-outline-secondary">Voltar</a>
            <a href={EditStudentAction student.id} class="btn btn-primary">Editar</a>
            <form method="POST" action={DeleteStudentAction student.id}>
                <input type="hidden" name="_method" value="DELETE" />
                <button type="submit" class="btn btn-outline-danger">Excluir estudante</button>
            </form>
        </div>
        <p class="text-muted mt-2">A exclusao e bloqueada quando existem matriculas vinculadas.</p>
    |]
