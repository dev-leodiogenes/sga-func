module Web.View.Enrollments.Show where

import Web.View.Prelude
import qualified Data.Text as T
import Numeric (showFFloat)
import Application.Helper.Boletim (mediaDasNotas)

data ShowView = ShowView
    { enrollment :: Enrollment
    , student :: Student
    , course :: Course
    , grades :: [Grade]
    , newGrade :: Grade
    , assessments :: [Assessment]
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
                <p><strong>Situacao:</strong> {situacaoMatricula (tshow enrollment.status)}</p>
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
        {renderGradeForm enrollment newGrade assessments}

        {when (currentUser.role_ == "admin" || currentUser.role_ == "coordenador") (editPeriodButton enrollment)}

        {when (currentUser.role_ == "admin") (deleteEnrollmentButton enrollment)}

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
            {when (currentUser.role_ == "admin" || currentUser.role_ == "professor") (deleteGradeButton grade)}
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
        {maybe "Sem notas" formatarMediaMatricula (mediaDasNotas grades)}
    </p>
|]

formatarMediaMatricula :: Double -> Text
formatarMediaMatricula numero =
    T.replace "." "," (T.pack (showFFloat (Just 2) numero ""))

renderGradeForm :: Enrollment -> Grade -> [Assessment] -> Html
renderGradeForm enrollment grade assessments =
    if null assessments
        then [hsx|
            <div class="alert alert-info">
                Nenhuma avaliacao cadastrada para esta disciplina
                e periodo.
                <a href={AssessmentsAction}>
                    Consultar avaliacoes
                </a>
            </div>
        |]
        else formFor' grade
            (pathTo (CreateGradeAction enrollment.id)) [hsx|
            <div class="mb-3">
                <label class="form-label">
                    Selecione a avaliacao
                </label>
                <select name="assessmentId"
                        class="form-select" required>
                    <option value="">Selecione...</option>
                    {forEach assessments renderAssessmentOption}
                </select>
            </div>

            <div class="mb-3">
                {(numberField #value)
                    { fieldLabel = "Nota (0 a 10)"
                    , additionalAttributes =
                        [("step", "0.01"), ("min", "0"), ("max", "10")]
                    }}
            </div>

            {submitButton { label = "Salvar nota" }}
        |]

renderAssessmentOption :: Assessment -> Html
renderAssessmentOption assessment = [hsx|
    <option value={tshow assessment.id}>
        {assessment.name}
    </option>
|]

deleteEnrollmentButton :: Enrollment -> Html
deleteEnrollmentButton enrollment = [hsx|
    <form method="POST"
          action={CreateEnrollmentDeletionAction enrollment.id}
          onsubmit="return confirm('Excluir esta matricula?');">
        <button type="submit" class="btn btn-outline-danger">
            Excluir matricula
        </button>
    </form>
|]


deleteGradeButton :: Grade -> Html
deleteGradeButton grade = [hsx|
    <form method="POST" action={DeleteGradeAction grade.id}>
        <input type="hidden" name="_method" value="DELETE" />
        <button type="submit" class="btn btn-sm btn-outline-danger">
            Excluir
        </button>
    </form>
|]


editPeriodButton :: Enrollment -> Html
editPeriodButton enrollment = [hsx|
    <a href={EditEnrollmentAction enrollment.id}
       class="btn btn-outline-primary mt-3 mb-2">
        Editar período
    </a>
|]
