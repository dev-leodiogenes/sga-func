module Web.View.Students.ReportCard where

import Web.View.Prelude
import Application.Helper.Boletim
import Numeric (showFFloat)
import qualified Data.Text as T

data ReportCardView = ReportCardView
    { enrollments :: [Enrollment]
    , courses :: [Course]
    , grades :: [Grade]
    }

instance View ReportCardView where
    html ReportCardView { .. } = [hsx|
        <h1>Meu boletim</h1>
        <p class="text-muted">
            Suas disciplinas, avaliacoes e medias.
        </p>
        {renderReportCards enrollments courses grades}
    |]

renderReportCards :: [Enrollment] -> [Course] -> [Grade] -> Html
renderReportCards [] _ _ = [hsx|
    <div class="alert alert-info">
        Voce ainda nao possui matriculas cadastradas.
    </div>
|]
renderReportCards enrollments courses grades =
    [hsx|
        {forEach enrollments (renderEnrollment courses grades)}
    |]

renderEnrollment :: [Course] -> [Grade] -> Enrollment -> Html
renderEnrollment courses grades enrollment = [hsx|
    <section class="card mb-4">
        <div class="card-body">
            <h2 class="h5">{courseName enrollment.courseId courses}</h2>
            <p class="text-muted">
                Periodo: {enrollment.academicPeriod}
            </p>
            {renderGrades studentGrades}
        </div>
    </section>
|]
    where
        studentGrades = notasDaMatricula enrollment grades

courseName :: Id Course -> [Course] -> Text
courseName courseId courses =
    case find (\course -> course.id == courseId) courses of
        Just course -> course.name
        Nothing -> "Disciplina nao encontrada"

renderGrades :: [Grade] -> Html
renderGrades [] = [hsx|
    <p class="text-muted">Nenhuma nota lancada ainda.</p>
|]
renderGrades grades = [hsx|
    <table class="table table-striped">
        <thead>
            <tr><th>Avaliacao</th><th>Nota</th></tr>
        </thead>
        <tbody>
            {forEach grades renderGrade}
        </tbody>
    </table>
    <p class="fw-bold">
        Media parcial: {fromMaybe "Sem notas" (fmap formatNumber (mediaDasNotas grades))}
    </p>
|]

renderGrade :: Grade -> Html
renderGrade grade = [hsx|
    <tr>
        <td>{grade.assessmentName}</td>
        <td>{formatNumber (realToFrac grade.value :: Double)}</td>
    </tr>
|]

formatNumber :: Double -> Text
formatNumber number =
    T.replace "." "," (T.pack (showFFloat (Just 2) number ""))
