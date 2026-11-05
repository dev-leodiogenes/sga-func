module Web.View.Enrollments.Index where

import Web.View.Prelude

data IndexView = IndexView
    { enrollments :: [Enrollment]
    , students :: [Student]
    , courses :: [Course]
    }

instance View IndexView where
    html IndexView { .. } = [hsx|
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h1>Matriculas</h1>
            {createEnrollmentButton}
        </div>

        <p class="text-muted">
            Estudantes vinculados as disciplinas por periodo academico.
        </p>

        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Estudante</th>
                    <th>Disciplina</th>
                    <th>Periodo</th>
                    <th>Acoes</th>
                </tr>
            </thead>
            <tbody>
                {forEach enrollments (renderEnrollment students courses)}
            </tbody>
        </table>
    |]

renderEnrollment :: [Student] -> [Course] -> Enrollment -> Html
renderEnrollment students courses enrollment = [hsx|
    <tr>
        <td>{studentName enrollment.studentId students}</td>
        <td>{courseName enrollment.courseId courses}</td>
        <td>{enrollment.academicPeriod}</td>
        <td>
            <a href={ShowEnrollmentAction enrollment.id}
               class="btn btn-sm btn-outline-primary">
                Ver
            </a>
        </td>
    </tr>
|]

studentName studentId students =
    case find (\student -> student.id == studentId) students of
        Just student -> student.name
        Nothing -> "Estudante nao encontrado"

courseName courseId courses =
    case find (\course -> course.id == courseId) courses of
        Just course -> course.name
        Nothing -> "Disciplina nao encontrada"


createEnrollmentButton :: Html
createEnrollmentButton =
    if currentUser.role_ == "admin"
        then [hsx|
            <a href={NewEnrollmentAction} class="btn btn-primary">
                Nova matricula
            </a>
        |]
        else mempty
