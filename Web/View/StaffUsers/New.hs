module Web.View.StaffUsers.New where

import Web.View.Prelude

data NewView = NewView
    { user :: User
    , courses :: [Course]
    }

instance View NewView where
    html NewView { .. } = [hsx|
        <h1>Cadastrar profissional</h1>

        <p class="text-muted mb-4">
            Cadastre um professor ou coordenador.
            O profissional deverá alterar a senha
            no primeiro acesso ao sistema.
        </p>

        <div class="card">
            <div class="card-body">
                {renderStaffForm user courses}
            </div>
        </div>

        <a href={StaffUsersAction}
           class="btn btn-outline-secondary mt-3">
            Voltar
        </a>
    |]

renderStaffForm :: User -> [Course] -> Html
renderStaffForm user courses =
    formFor' user (pathTo CreateStaffUserAction) [hsx|

        <div class="mb-3">
            <label for="name" class="form-label">
                Nome completo
            </label>
            <input type="text"
                   id="name"
                   name="name"
                   class="form-control"
                   placeholder="Nome do profissional"
                   required />
        </div>

        <div class="mb-3">
            <label for="email" class="form-label">
                E-mail
            </label>
            <input type="email"
                   id="email"
                   name="email"
                   class="form-control"
                   placeholder="exemplo@email.com"
                   required />
        </div>

        <div class="mb-3">
            <label for="role" class="form-label">
                Perfil de acesso
            </label>
            <select id="role"
                    name="role"
                    class="form-select"
                    required>
                <option value="">Selecione o perfil</option>
                <option value="professor">Professor</option>
                <option value="coordenador">Coordenador</option>
            </select>
        </div>

        <div class="mb-3">
            <label for="initialPassword" class="form-label">
                Senha inicial
            </label>
            <input type="password"
                   id="initialPassword"
                   name="initialPassword"
                   class="form-control"
                   minlength="8"
                   autocomplete="new-password"
                   required />

            <div class="form-text">
                A senha deve ter pelo menos 8 caracteres.
                A troca será obrigatória no primeiro acesso.
            </div>
        </div>

        <div class="mb-3">
            <label for="courseIds" class="form-label">
                Disciplinas ministradas
            </label>

            <select id="courseIds"
                    name="courseIds"
                    class="form-select"
                    multiple="multiple"
                    size="6">
                {forEach courses renderCourseOption}
            </select>

            <div class="form-text">
                Para professores, selecione uma ou mais disciplinas.
                Use Ctrl para selecionar várias opções.
                Para coordenadores, deixe em branco.
            </div>
        </div>

        {submitButton { label = "Cadastrar profissional" }}
    |]


renderCourseOption :: Course -> Html
renderCourseOption course = [hsx|
    <option value={course.id}>
        {course.code} - {course.name}
    </option>
|]
