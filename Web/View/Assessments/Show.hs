module Web.View.Assessments.Show where

import Web.View.Prelude

data ShowView = ShowView
    { assessment :: Assessment
    , course :: Course
    , enrollments :: [Enrollment]
    , students :: [Student]
    }

instance View ShowView where
    html ShowView { .. } = [hsx|
        <h1>{assessment.name}</h1>

        <div class="card mb-4">
            <div class="card-body">
                <p><strong>Disciplina:</strong> {course.name}</p>
                <p><strong>Periodo:</strong> {assessment.academicPeriod}</p>
            </div>
        </div>

        <h2 class="h4">Estudantes matriculados</h2>

        {renderStudents enrollments students}

        <a href={AssessmentsAction}
           class="btn btn-outline-secondary mt-3">
            Voltar para avaliacoes
        </a>
    |]

renderStudents :: [Enrollment] -> [Student] -> Html
renderStudents enrollments students =
    if null enrollments
        then [hsx|
            <div class="alert alert-info">
                Nenhum estudante matriculado nessa disciplina e periodo.
            </div>
        |]
        else [hsx|
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Estudante</th>
                        <th>Situacao</th>
                    </tr>
                </thead>
                <tbody>
                    {forEach enrollments (renderEnrollment students)}
                </tbody>
            </table>
        |]

renderEnrollment :: [Student] -> Enrollment -> Html
renderEnrollment students enrollment = [hsx|
    <tr>
        <td>{studentName enrollment.studentId students}</td>
        <td>{situacaoMatricula (tshow enrollment.status)}</td>
    </tr>
|]

studentName :: Id Student -> [Student] -> Text
studentName studentId students =
    case find (\student -> student.id == studentId) students of
        Just student -> student.name
        Nothing -> "Estudante nao encontrado"
