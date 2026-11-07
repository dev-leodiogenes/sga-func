module Web.View.AcademicPeriods.Index where

import Web.View.Prelude

data IndexView = IndexView
    { periods :: [AcademicPeriod]
    }

instance View IndexView where
    html IndexView { .. } = [hsx|
        <h1>Períodos acadêmicos</h1>

        <p class="text-muted">
            Selecione o período letivo atual.
            Matrículas e avaliações de outros períodos
            continuarão disponíveis para consulta.
        </p>

        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Período</th>
                    <th>Situação</th>
                    <th>Ação</th>
                </tr>
            </thead>
            <tbody>
                {forEach periods renderPeriod}
            </tbody>
        </table>
    |]

renderPeriod :: AcademicPeriod -> Html
renderPeriod period = [hsx|
    <tr>
        <td>{period.code}</td>
        <td>
            {situacaoPeriodo period}
        </td>
        <td>
            {if period.isActive
                then activeLabel
                else activateButton period}
        </td>
    </tr>
|]

activeLabel :: Html
activeLabel = [hsx|
    <span class="badge bg-success">Período atual</span>
|]

activateButton :: AcademicPeriod -> Html
activateButton period = [hsx|
    <form method="POST"
          action={CreateActiveAcademicPeriodAction period.id}>
        <button type="submit"
                class="btn btn-sm btn-primary">
            Definir como ativo
        </button>
    </form>
|]


-- Retorna a situação do período como Text.
situacaoPeriodo :: AcademicPeriod -> Text
situacaoPeriodo period =
    if period.isActive
        then "Ativo"
        else "Inativo"
