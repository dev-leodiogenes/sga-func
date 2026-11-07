module Web.View.Assessments.New where

import Web.View.Prelude
import Web.View.Enrollments.New ()

data NewView = NewView
    { assessment :: Assessment
    , courses :: [Course]
    , periods :: [AcademicPeriod]
    }

instance View NewView where
    html NewView { .. } = [hsx|
        <h1>Nova avaliacao</h1>

        <p class="text-muted">
            Crie uma avaliacao para todos os estudantes
            de uma disciplina e periodo.
        </p>

        {renderContent assessment courses periods}

        <a href={AssessmentsAction}
           class="btn btn-outline-secondary mt-3">
            Voltar
        </a>
    |]

renderContent :: Assessment -> [Course] -> [AcademicPeriod] -> Html
renderContent assessment courses periods =
    if null courses || null periods
        then [hsx|
            <div class="alert alert-warning">
                Cadastre uma disciplina antes de criar avaliacoes.
            </div>
        |]
        else formFor assessment [hsx|
            <div class="mb-3">
                {(selectField #courseId courses)
                    { fieldLabel = "Disciplina" }}
            </div>

            <div class="mb-3">
                <label class="form-label" for="academicPeriod">
                    Período acadêmico
                </label>
                <select id="academicPeriod" name="academicPeriod"
                        class="form-select" required>
                    {forEach periods renderPeriodOption}
                </select>
            </div>

            <div class="mb-3">
                {(textField #name)
                    { fieldLabel = "Nome da avaliacao"
                    , placeholder = "Ex.: AV1" }}
            </div>

            {submitButton { label = "Criar avaliacao" }}
        |]


renderPeriodOption :: AcademicPeriod -> Html
renderPeriodOption period = [hsx|
    <option value={period.code} selected={period.isActive}>
        {period.code}
    </option>
|]
