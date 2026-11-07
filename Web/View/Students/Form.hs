module Web.View.Students.Form where

import Web.View.Prelude

renderForm :: Student -> Html
renderForm = renderStudentForm False

renderNewForm :: Student -> Html
renderNewForm = renderStudentForm True

renderStudentForm :: Bool -> Student -> Html
renderStudentForm isNew student = formFor student [hsx|
    <div class="mb-3">
        {(textField #registrationNumber) { fieldLabel = "Número de matrícula" }}
    </div>
    <div class="mb-3">
        {(textField #name) { fieldLabel = "Nome completo" }}
    </div>
    <div class="mb-3">
        {(textField #email) { fieldLabel = "E-mail" }}
    </div>
    {initialPasswordField isNew}
    {submitButton { label = "Salvar" }}
|]

initialPasswordField :: Bool -> Html
initialPasswordField False = mempty
initialPasswordField True = [hsx|
    <div class="mb-3">
        <label for="initialPassword" class="form-label">
            Senha inicial do estudante
        </label>
        <input type="password"
               id="initialPassword"
               name="initialPassword"
               class="form-control"
               minlength="8"
               autocomplete="new-password"
               required />
        <div class="form-text">
            O estudante deverá alterar essa senha no primeiro acesso.
        </div>
    </div>
|]
