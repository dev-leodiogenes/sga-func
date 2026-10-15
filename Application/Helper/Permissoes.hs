module Application.Helper.Permissoes where

-- Perfis de usuario
data Papel
    = Administrador
    | Professor
    | Aluno
    deriving (Show, Eq)

-- Operacoes do sistema
data Acao
    = CadastrarEstudante
    | ConsultarEstudantes
    | EditarEstudante
    | ExcluirEstudante
    | CadastrarCurso
    | ConsultarCursos
    | EditarCurso
    | ExcluirCurso
    | ConsultarProprioCadastro
    deriving (Show, Eq)

-- Verifica as permissoes
podeExecutar :: Papel -> Acao -> Bool

podeExecutar Administrador _ = True

podeExecutar Professor ConsultarEstudantes = True
podeExecutar Professor ConsultarCursos = True

podeExecutar Aluno ConsultarProprioCadastro = True

podeExecutar _ _ = False

podeConsultarCadastro :: Papel -> String -> String -> Bool

podeConsultarCadastro Administrador _ _ = True
podeConsultarCadastro Professor _ _ = True

podeConsultarCadastro Aluno idAlunoLogado idAlunoSolicitado =
    idAlunoLogado == idAlunoSolicitado