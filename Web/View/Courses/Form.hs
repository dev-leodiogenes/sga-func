module Web.View.Courses.Form where

import Web.View.Prelude

renderForm :: Course -> Html
renderForm course = formFor course [hsx|
    <div class="mb-3">
        {textField #code}
    </div>
    <div class="mb-3">
        {textField #name}
    </div>
    <div class="mb-3">
        {numberField #workloadHours}
    </div>
    {submitButton}
|]
