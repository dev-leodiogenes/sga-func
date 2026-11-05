module Web.View.Dashboard.Index where
import Web.View.Prelude
import Numeric (showFFloat)
import qualified Data.Text as T

data IndexView = IndexView
    { period :: Text
    , periods :: [Text]
    , totalStudents :: Int
    , totalCourses :: Int
    , totalEnrollments :: Int
    , averageGrade :: Maybe Double
    , ranking :: [(Text, Maybe Double, Int)]
    , courseFilter :: Text
    , courses :: [Course]
    , students :: [Student]
    , filteredEnrollments :: [Enrollment]
    , filteredGrades :: [Grade]
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

            <label class="form-label mt-3" for="course">
                Disciplina do boletim
            </label>
            <select id="course" name="course"
                    class="form-select"
                    onchange="this.form.submit()">
                <option value="">Todas as disciplinas</option>
                {forEach courses (renderCourseOption courseFilter)}
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
                <p class="display-6 mb-0">{formatAverage averageGrade}</p>
            </div>
        </section>
        <h2 class="h4">Ranking de disciplinas por media</h2>
        <table class="table table-striped">
            <thead>
                <tr><th>Disciplina</th><th>Media</th><th>Avaliacoes</th></tr>
            </thead>
            <tbody>{forEach ranking renderRank}</tbody>
        </table>

        <section class="card mt-4 mb-4">
            <div class="card-body">
                <h2 class="h4">Boletim por estudante</h2>
                <p class="text-muted">
                    Notas por avaliacao e media aritmetica
                    das notas cadastradas.
                </p>

                <div class="table-responsive">
                    <table class="table table-striped table-hover">
                        <thead>
                            <tr>
                                <th>Estudante</th>
                                <th>Disciplina</th>
                                <th>Periodo</th>
                                {forEach (assessmentNames filteredGrades)
                                    renderAssessmentHeader}
                                <th>Media</th>
                            </tr>
                        </thead>
                        <tbody>
                            {forEach filteredEnrollments
                                (renderBoletimRow students courses
                                    filteredGrades
                                    (assessmentNames filteredGrades))}
                        </tbody>
                    </table>
                </div>
            </div>
        </section>
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

renderRank :: (Text, Maybe Double, Int) -> Html
renderRank (name, mean, quantity) = [hsx|
    <tr>
        <td>{name}</td>
        <td>{formatAverage mean}</td>
        <td>{quantity}</td>
    </tr>
|]


formatAverage :: Maybe Double -> Text
formatAverage Nothing = "Sem notas"
formatAverage (Just value) =
    T.replace "." "," (T.pack (showFFloat (Just 2) value ""))


renderCourseOption :: Text -> Course -> Html
renderCourseOption selected course = [hsx|
    <option value={course.code} selected={selected == course.code}>
        {course.name}
    </option>
|]

assessmentNames :: [Grade] -> [Text]
assessmentNames grades =
    foldl addName [] grades
    where
        addName names grade =
            if grade.assessmentName `elem` names
                then names
                else names ++ [grade.assessmentName]

renderAssessmentHeader :: Text -> Html
renderAssessmentHeader name = [hsx|
    <th>{name}</th>
|]

renderBoletimRow
    :: [Student] -> [Course] -> [Grade] -> [Text]
    -> Enrollment -> Html
renderBoletimRow students courses grades assessments enrollment = [hsx|
    <tr>
        <td>{studentName enrollment.studentId students}</td>
        <td>{courseName enrollment.courseId courses}</td>
        <td>{enrollment.academicPeriod}</td>
        {forEach assessments (renderGradeCell enrollment grades)}
        <td><strong>{enrollmentMean enrollment grades}</strong></td>
    </tr>
|]

renderGradeCell :: Enrollment -> [Grade] -> Text -> Html
renderGradeCell enrollment grades assessment = [hsx|
    <td>{gradeText enrollment grades assessment}</td>
|]

gradeText :: Enrollment -> [Grade] -> Text -> Text
gradeText enrollment grades assessment =
    case find (\grade ->
        grade.enrollmentId == enrollment.id
        && grade.assessmentName == assessment) grades of
        Nothing -> "-"
        Just grade ->
            formatAverage (Just (realToFrac grade.value :: Double))

enrollmentMean :: Enrollment -> [Grade] -> Text
enrollmentMean enrollment grades =
    let values =
            map (\grade -> realToFrac grade.value :: Double)
                (filter (\grade ->
                    grade.enrollmentId == enrollment.id) grades)
    in if null values
        then "-"
        else formatAverage
            (Just (sum values / fromIntegral (length values)))

studentName :: Id Student -> [Student] -> Text
studentName studentId students =
    case find (\student -> student.id == studentId) students of
        Just student -> student.name
        Nothing -> "Estudante nao encontrado"

courseName :: Id Course -> [Course] -> Text
courseName courseId courses =
    case find (\course -> course.id == courseId) courses of
        Just course -> course.name
        Nothing -> "Disciplina nao encontrada"
