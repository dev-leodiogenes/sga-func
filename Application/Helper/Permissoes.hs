module Application.Helper.Permissoes where
import Prelude
import Data.Text (Text)

data Papel = Administrador | Coordenador | Professor | Aluno deriving (Show, Eq)
data Acao
    = CadastrarEstudante | ConsultarEstudantes | EditarEstudante | ExcluirEstudante
    | CadastrarCurso | ConsultarCursos | EditarCurso | ExcluirCurso
    | ConsultarProprioCadastro | ConsultarDashboard | GerenciarNotasSigilosas
    deriving (Show, Eq)

papelDoBanco :: Text -> Maybe Papel
papelDoBanco "admin" = Just Administrador
papelDoBanco "coordenador" = Just Coordenador
papelDoBanco "professor" = Just Professor
papelDoBanco "aluno" = Just Aluno
papelDoBanco _ = Nothing

podeExecutar :: Papel -> Acao -> Bool
podeExecutar Administrador _ = True
podeExecutar Coordenador CadastrarEstudante = True
podeExecutar Coordenador ConsultarEstudantes = True
podeExecutar Coordenador EditarEstudante = True
podeExecutar Coordenador CadastrarCurso = True
podeExecutar Coordenador ConsultarCursos = True
podeExecutar Coordenador EditarCurso = True
podeExecutar Coordenador ConsultarDashboard = True
podeExecutar Professor ConsultarEstudantes = True
podeExecutar Professor ConsultarCursos = True
podeExecutar Professor ConsultarDashboard = True
podeExecutar Aluno ConsultarCursos = True
podeExecutar Aluno ConsultarProprioCadastro = True
podeExecutar _ _ = False

podeConsultarCadastro :: Papel -> String -> String -> Bool
podeConsultarCadastro Administrador _ _ = True
podeConsultarCadastro Coordenador _ _ = True
podeConsultarCadastro Professor _ _ = True
podeConsultarCadastro Aluno idAlunoLogado idAlunoSolicitado =
    idAlunoLogado == idAlunoSolicitado

podeAcessarCadastro :: Papel -> Bool -> Bool
podeAcessarCadastro Administrador _ = True
podeAcessarCadastro Coordenador _ = True
podeAcessarCadastro Professor _ = True
podeAcessarCadastro Aluno mesmoCadastro = mesmoCadastro
