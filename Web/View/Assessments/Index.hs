module Web.View.Assessments.Index where

import Web.View.Prelude

data IndexView = IndexView
    { assessments :: [Assessment]
    , courses :: [Course]
    }

instance View IndexView where
    html IndexView { .. } = [hsx|
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h1>Avaliacoes</h1>
            <a href={NewAssessmentAction} class="btn btn-primary">
                Nova avaliacao
            </a>
        </div>

        <p class="text-muted">
            Avaliacoes compartilhadas por disciplina e periodo.
        </p>

        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Avaliacao</th>
                    <th>Disciplina</th>
                    <th>Periodo</th>
                    <th>Acoes</th>
                </tr>
            </thead>
            <tbody>
                {forEach assessments (renderAssessment courses)}
            </tbody>
        </table>
    |]

renderAssessment :: [Course] -> Assessment -> Html
renderAssessment courses assessment = [hsx|
    <tr>
        <td>{assessment.name}</td>
        <td>{courseName assessment.courseId courses}</td>
        <td>{assessment.academicPeriod}</td>
        <td>
            <a href={ShowAssessmentAction assessment.id}
               class="btn btn-sm btn-outline-primary">
                Ver
            </a>
        </td>
    </tr>
|]

courseName :: Id Course -> [Course] -> Text
courseName courseId courses =
    case find (\course -> course.id == courseId) courses of
        Just course -> course.name
        Nothing -> "Disciplina nao encontrada"
