module Web.View.Dashboard.Index where
import Web.View.Prelude

data IndexView = IndexView
    { period :: Text
    , periods :: [Text]
    , totalStudents :: Int
    , totalCourses :: Int
    , totalEnrollments :: Int
    , averageGrade :: Maybe Double
    , ranking :: [(Text, Maybe Double, Maybe Int)]
    }

instance View IndexView where
    html IndexView { .. } = [hsx|
        <h1>Painel academico</h1>
        <p class="text-muted">Indicadores e notas por disciplina, calculados no PostgreSQL.</p>
        <form method="GET" action={DashboardAction} class="mb-4">
            <label class="form-label" for="period">Periodo academico</label>
            <select id="period" name="period" class="form-select" onchange="this.form.submit()">
                <option value="">Todos os periodos</option>
                {forEach periods (renderPeriodOption period)}
            </select>
            <noscript><button type="submit" class="btn btn-primary mt-2">Filtrar</button></noscript>
        </form>
        <div class="row g-3 mb-4">
            {metricCard "Estudantes" totalStudents}
            {metricCard "Disciplinas" totalCourses}
            {metricCard "Matriculas" totalEnrollments}
        </div>
        <section class="card mb-4">
            <div class="card-body">
                <h2 class="h5">Media geral de notas</h2>
                <p class="display-6 mb-0">{maybe "Sem notas" show averageGrade}</p>
            </div>
        </section>
        <h2 class="h4">Ranking de disciplinas por media</h2>
        <table class="table table-striped">
            <thead>
                <tr><th>Disciplina</th><th>Media</th><th>Avaliacoes</th></tr>
            </thead>
            <tbody>{forEach ranking renderRank}</tbody>
        </table>
    |]

metricCard :: Text -> Int -> Html
metricCard title value = [hsx|
    <div class="col-md-4">
        <div class="card h-100"><div class="card-body">
            <h2 class="h6 text-muted">{title}</h2>
            <p class="display-6 mb-0">{value}</p>
        </div></div>
    </div>
|]

renderPeriodOption :: Text -> Text -> Html
renderPeriodOption selected value = [hsx|
    <option value={value} selected={selected == value}>{value}</option>
|]

renderRank :: (Text, Maybe Double, Maybe Int) -> Html
renderRank (name, mean, quantity) = [hsx|
    <tr>
        <td>{name}</td>
        <td>{maybe "-" show mean}</td>
        <td>{fromMaybe 0 quantity}</td>
    </tr>
|]
