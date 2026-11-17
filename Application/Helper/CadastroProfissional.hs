{-# LANGUAGE OverloadedStrings #-}

module Application.Helper.CadastroProfissional where

import Prelude
import Data.Text (Text)
import qualified Data.Text as T

-- Erros tipados do cadastro de profissionais
data ErroCadastro
    = NomeObrigatorio
    | EmailInvalido
    | PerfilInvalido
    | DisciplinasInvalidas
    | ProfessorSemDisciplinas
    | CoordenadorComDisciplinas
    | SenhaCurta
    | EmailJaCadastrado
    deriving (Eq, Show)

-- Valida as informacoes usando a monada Either
validarCadastroProfissional
    :: Text -> Text -> Text -> Text -> Int -> Int
    -> Either ErroCadastro ()

validarCadastroProfissional nome email perfil senha selecionadas encontradas = do
    exigir (not (T.null (T.strip nome))) NomeObrigatorio
    exigir (emailValido email) EmailInvalido
    exigir (perfil == "professor" || perfil == "coordenador") PerfilInvalido
    exigir (selecionadas == encontradas) DisciplinasInvalidas
    exigir (perfil /= "professor" || encontradas > 0) ProfessorSemDisciplinas
    exigir (perfil /= "coordenador" || encontradas == 0) CoordenadorComDisciplinas
    exigir (T.length (T.strip senha) >= 8) SenhaCurta

-- Retorna Left quando uma validacao falha
exigir :: Bool -> ErroCadastro -> Either ErroCadastro ()
exigir True _ = Right ()
exigir False erro = Left erro

emailValido :: Text -> Bool
emailValido email =
    case T.splitOn "@" email of
        [local, dominio] ->
            not (T.null local)
            && not (T.null dominio)
            && not (T.any (== ' ') email)
        _ -> False

-- Converte erros tipados em mensagens para o usuario
mensagemErroCadastro :: ErroCadastro -> Text
mensagemErroCadastro erro =
    case erro of
        NomeObrigatorio -> "Informe o nome do profissional."
        EmailInvalido -> "Informe um e-mail válido."
        PerfilInvalido -> "Selecione um perfil válido."
        DisciplinasInvalidas -> "Selecione apenas disciplinas válidas, sem duplicações."
        ProfessorSemDisciplinas -> "Selecione pelo menos uma disciplina para o professor."
        CoordenadorComDisciplinas -> "O vínculo de disciplinas é exclusivo de professores."
        SenhaCurta -> "A senha deve ter pelo menos 8 caracteres."
        EmailJaCadastrado -> "Já existe uma conta com este e-mail."
