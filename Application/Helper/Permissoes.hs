module Application.Helper.Permissoes where
import Prelude
import Data.Text (Text)

data Papel = Administrador | Professor | Aluno deriving (Show, Eq)
data Acao
    = CadastrarEstudante | ConsultarEstudantes | EditarEstudante | ExcluirEstudante
    | CadastrarCurso | ConsultarCursos | EditarCurso | ExcluirCurso
    | ConsultarProprioCadastro | ConsultarDashboard | GerenciarNotasSigilosas
    deriving (Show, Eq)

papelDoBanco :: Text -> Maybe Papel
papelDoBanco "admin" = Just Administrador
papelDoBanco "professor" = Just Professor
papelDoBanco "aluno" = Just Aluno
papelDoBanco _ = Nothing

podeExecutar :: Papel -> Acao -> Bool
podeExecutar Administrador _ = True
podeExecutar Professor ConsultarEstudantes = True
podeExecutar Professor ConsultarCursos = True
podeExecutar Professor ConsultarDashboard = True
podeExecutar Aluno ConsultarCursos = True
podeExecutar Aluno ConsultarProprioCadastro = True
podeExecutar _ _ = False

podeConsultarCadastro :: Papel -> String -> String -> Bool
podeConsultarCadastro Administrador _ _ = True
podeConsultarCadastro Professor _ _ = True
podeConsultarCadastro Aluno idAlunoLogado idAlunoSolicitado =
    idAlunoLogado == idAlunoSolicitado

podeAcessarCadastro :: Papel -> Bool -> Bool
podeAcessarCadastro Administrador _ = True
podeAcessarCadastro Professor _ = True
podeAcessarCadastro Aluno mesmoCadastro = mesmoCadastro
