module Web.View.Enrollments.Edit where

import Web.View.Prelude

data EditView = EditView
    { enrollment :: Enrollment
    , student :: Student
    , course :: Course
    , periods :: [AcademicPeriod]
    }

instance View EditView where
    html EditView { .. } = [hsx|
        <h1>Editar período da matrícula</h1>

        <p class="text-muted">
            Corrija o período acadêmico desta matrícula.
            O estudante e a disciplina serão mantidos.
        </p>

        <div class="card mb-4">
            <div class="card-body">
                <p><strong>Estudante:</strong> {student.name}</p>
                <p><strong>Disciplina:</strong> {course.name}</p>
                <p><strong>Período atual:</strong> {enrollment.academicPeriod}</p>
            </div>
        </div>

        {renderEditForm enrollment periods}

        <a href={ShowEnrollmentAction enrollment.id}
           class="btn btn-outline-secondary mt-3">
            Cancelar
        </a>
    |]

renderEditForm :: Enrollment -> [AcademicPeriod] -> Html
renderEditForm enrollment periods =
    formFor' enrollment (pathTo (UpdateEnrollmentAction enrollment.id)) [hsx|
        <div class="mb-3">
            <label for="academicPeriod" class="form-label">
                Novo período acadêmico
            </label>

            <select id="academicPeriod"
                    name="academicPeriod"
                    class="form-select"
                    required>
                {forEach periods (renderPeriodOption enrollment.academicPeriod)}
            </select>
        </div>

        {submitButton { label = "Salvar alteração" }}
    |]

renderPeriodOption :: Text -> AcademicPeriod -> Html
renderPeriodOption selectedPeriod period = [hsx|
    <option value={period.code}
            selected={period.code == selectedPeriod}>
        {period.code}
    </option>
|]
