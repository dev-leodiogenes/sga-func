module Web.View.Sessions.ChangePassword where

import Web.View.Prelude

data ChangePasswordView = ChangePasswordView

instance View ChangePasswordView where
    html ChangePasswordView = [hsx|
        <div class="row justify-content-center">
            <div class="col-md-6">
                <h1>Alterar senha inicial</h1>
                <p class="text-muted">
                    Para continuar, defina uma nova senha.
                </p>
                <form method="POST" action={CreatePasswordChangeAction}>
                    <div class="mb-3">
                        <label class="form-label">Nova senha</label>
                        <input type="password" name="newPassword"
                               class="form-control" minlength="8"
                               autocomplete="new-password" required />
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Confirme a nova senha</label>
                        <input type="password" name="confirmPassword"
                               class="form-control" minlength="8"
                               autocomplete="new-password" required />
                    </div>
                    <button class="btn btn-primary" type="submit">
                        Alterar senha
                    </button>
                </form>
            </div>
        </div>
    |]
