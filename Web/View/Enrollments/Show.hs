module Web.View.Enrollments.Show where

import Web.View.Prelude

data ShowView = ShowView
    { enrollment :: Enrollment
    , student :: Student
    , course :: Course
    , grades :: [Grade]
    , newGrade :: Grade
    }

instance View ShowView where
    html ShowView { .. } = [hsx|
        <h1>Detalhes da matricula</h1>

        <div class="card mb-4">
            <div class="card-body">
                <h2 class="h5">Informacoes da matricula</h2>
                <p><strong>Estudante:</strong> {student.name}</p>
                <p><strong>Matricula:</strong> {student.registrationNumber}</p>
                <p><strong>Disciplina:</strong> {course.name}</p>
                <p><strong>Periodo:</strong> {enrollment.academicPeriod}</p>
                <p><strong>Situacao:</strong> {tshow enrollment.status}</p>
            </div>
        </div>

        <h2>Avaliacoes e notas</h2>

        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Avaliacao</th>
                    <th>Nota</th>
                    <th>Acoes</th>
                </tr>
            </thead>
            <tbody>
                {forEach grades renderGrade}
            </tbody>
        </table>

        {renderAverage grades}

        <h3 class="mt-4">Lancamento de nota</h3>
        {renderGradeForm enrollment newGrade}

        <a href={EnrollmentsAction}
           class="btn btn-outline-secondary mt-4">
            Voltar para matriculas
        </a>
    |]

renderGrade :: Grade -> Html
renderGrade grade = [hsx|
    <tr>
        <td>{grade.assessmentName}</td>
        <td>{tshow grade.value}</td>
        <td>
            <form method="POST" action={DeleteGradeAction grade.id}>
                <input type="hidden" name="_method" value="DELETE" />
                <button type="submit" class="btn btn-sm btn-outline-danger">
                    Excluir
                </button>
            </form>
        </td>
    </tr>
|]

renderAverage :: [Grade] -> Html
renderAverage [] = [hsx|
    <p class="text-muted">Nenhuma nota cadastrada.</p>
|]
renderAverage grades = [hsx|
    <p class="fw-bold">
        Media das avaliacoes:
        {tshow (sum (map (\grade -> realToFrac (grade.value) :: Double) grades)
            / fromIntegral (length grades))}
    </p>
|]

renderGradeForm :: Enrollment -> Grade -> Html
renderGradeForm enrollment grade =
    formFor' grade (pathTo (CreateGradeAction enrollment.id)) [hsx|
        <div class="mb-3">
            {(textField #assessmentName) { fieldLabel = "Avaliacao" }}
        </div>

        <div class="mb-3">
            {(numberField #value) { fieldLabel = "Nota (0 a 10)", additionalAttributes = [("step", "0.01"), ("min", "0"), ("max", "10")] }}
        </div>

        {submitButton { label = "Salvar nota" }}
    |]
