module Web.View.StaffUsers.Index where

import Web.View.Prelude

data IndexView = IndexView
    { staffUsers :: [User]
    }

instance View IndexView where
    html IndexView { .. } = [hsx|
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1>Gerenciar usuários</h1>
                <p class="text-muted">
                    Professores e coordenadores cadastrados no sistema.
                </p>
            </div>

            <a href={NewStaffUserAction}
               class="btn btn-primary">
                Cadastrar profissional
            </a>
        </div>

        {if null staffUsers
            then emptyMessage
            else renderStaffTable staffUsers}
    |]

emptyMessage :: Html
emptyMessage = [hsx|
    <div class="alert alert-info">
        Nenhum professor ou coordenador cadastrado.
    </div>
|]

renderStaffTable :: [User] -> Html
renderStaffTable users = [hsx|
    <table class="table table-striped">
        <thead>
            <tr>
                <th>Nome</th>
                <th>E-mail</th>
                <th>Perfil</th>
            </tr>
        </thead>
        <tbody>
            {forEach users renderStaffUser}
        </tbody>
    </table>
|]

renderStaffUser :: User -> Html
renderStaffUser user = [hsx|
    <tr>
        <td>{nomeUsuario user}</td>
        <td>{user.email}</td>
        <td>{nomePerfil user.role_}</td>
    </tr>
|]

nomeUsuario :: User -> Text
nomeUsuario user =
    case user.name of
        Just name -> name
        Nothing -> "Não informado"

nomePerfil :: Text -> Text
nomePerfil role =
    case role of
        "professor" -> "Professor"
        "coordenador" -> "Coordenador"
        _ -> "Outro"
