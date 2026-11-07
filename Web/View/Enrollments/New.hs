module Web.View.Enrollments.New where

import Web.View.Prelude
import IHP.View.Form.Select (CanSelect (..))

data NewView = NewView
    { enrollment :: Enrollment
    , students :: [Student]
    , courses :: [Course]
    , periods :: [AcademicPeriod]
    }

instance CanSelect Student where
    type SelectValue Student = Id Student
    selectLabel student = student.name

instance CanSelect Course where
    type SelectValue Course = Id Course
    selectLabel course = course.name

instance View NewView where
    html NewView { .. } = [hsx|
        <h1>Nova matricula</h1>

        <p class="text-muted">
            Vincule um estudante a uma disciplina.
        </p>

        {enrollmentContent enrollment students courses periods}

        <a href={EnrollmentsAction}
           class="btn btn-outline-secondary mt-3">
            Voltar
        </a>
    |]

renderEnrollmentForm :: Enrollment -> [Student] -> [Course] -> [AcademicPeriod] -> Html
renderEnrollmentForm enrollment students courses periods =
    formFor enrollment [hsx|
        <div class="mb-3">
            {(selectField #studentId students) { fieldLabel = "Estudante" }}
        </div>

        <div class="mb-3">
            {(selectField #courseId courses) { fieldLabel = "Disciplina" }}
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

        {submitButton { label = "Matricular estudante" }}
    |]


enrollmentContent :: Enrollment -> [Student] -> [Course] -> [AcademicPeriod] -> Html
enrollmentContent enrollment students courses periods =
    if null students || null courses || null periods
        then [hsx|
            <div class="alert alert-warning">
                Cadastre pelo menos um estudante e uma disciplina
                antes de criar uma matricula.
            </div>
        |]
        else renderEnrollmentForm enrollment students courses periods


renderPeriodOption :: AcademicPeriod -> Html
renderPeriodOption period = [hsx|
    <option value={period.code} selected={period.isActive}>
        {period.code}
    </option>
|]
