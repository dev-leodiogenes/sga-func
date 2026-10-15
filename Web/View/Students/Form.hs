module Web.View.Students.Form where

import Web.View.Prelude

renderForm :: Student -> Html
renderForm student = formFor student [hsx|
    <div class="mb-3">
        {textField #registrationNumber}
    </div>
    <div class="mb-3">
        {textField #name}
    </div>
    <div class="mb-3">
        {textField #email}
    </div>
    {submitButton}
|]
