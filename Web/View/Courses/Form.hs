module Web.View.Courses.Form where

import Web.View.Prelude

renderForm :: Course -> Html
renderForm course = formFor course [hsx|
    <div class="mb-3">
        {(textField #code) { fieldLabel = "Código" }}
    </div>
    <div class="mb-3">
        {(textField #name) { fieldLabel = "Nome da disciplina" }}
    </div>
    <div class="mb-3">
        {(numberField #workloadHours) { fieldLabel = "Carga horária (h)" }}
    </div>
    {submitButton { label = "Salvar" }}
|]
