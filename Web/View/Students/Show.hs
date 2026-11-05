module Web.View.Students.Show where

import Web.View.Prelude

data ShowView = ShowView { student :: Student, privateNote :: Maybe Text }

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
            {when (currentUser.role == "admin") (adminActions student)}

        </div>
        {when (currentUser.role == "admin") (privateNoteForm student privateNote)}
    |]

adminActions :: Student -> Html
adminActions student = [hsx|
    <a href={EditStudentAction student.id} class="btn btn-primary">Editar</a>
    <form method="POST" action={DeleteStudentAction student.id}>
        <input type="hidden" name="_method" value="DELETE" />
        <button type="submit" class="btn btn-outline-danger">Excluir estudante</button>
    </form>
|]

privateNoteForm :: Student -> Maybe Text -> Html
privateNoteForm student privateNote = [hsx|
    <section class="card mt-4">
        <div class="card-body">
            <h2 class="h5">Anotacao confidencial (AES-256)</h2>
            <p class="text-muted">Visivel apenas para administradores. Criptografada no banco.</p>
            <form method="POST" action={CreateStudentNoteAction student.id}>
                <textarea class="form-control mb-2" name="note" rows="3">{fromMaybe "" privateNote}</textarea>
                <button type="submit" class="btn btn-secondary">Salvar anotacao</button>
            </form>
        </div>
    </section>
|]
