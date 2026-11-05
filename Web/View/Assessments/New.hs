module Web.View.Assessments.New where

import Web.View.Prelude
import Web.View.Enrollments.New ()

data NewView = NewView
    { assessment :: Assessment
    , courses :: [Course]
    }

instance View NewView where
    html NewView { .. } = [hsx|
        <h1>Nova avaliacao</h1>

        <p class="text-muted">
            Crie uma avaliacao para todos os estudantes
            de uma disciplina e periodo.
        </p>

        {renderContent assessment courses}

        <a href={AssessmentsAction}
           class="btn btn-outline-secondary mt-3">
            Voltar
        </a>
    |]

renderContent :: Assessment -> [Course] -> Html
renderContent assessment courses =
    if null courses
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
                {(textField #academicPeriod)
                    { fieldLabel = "Periodo academico"
                    , placeholder = "Ex.: 2026.2" }}
            </div>

            <div class="mb-3">
                {(textField #name)
                    { fieldLabel = "Nome da avaliacao"
                    , placeholder = "Ex.: AV1" }}
            </div>

            {submitButton { label = "Criar avaliacao" }}
        |]
