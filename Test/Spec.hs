{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE OverloadedLabels #-}

module Main where

import Test.Hspec
import Application.Helper.Permissoes
import Application.Helper.Validacoes
import Application.Helper.CadastroProfissional
import Application.Helper.Boletim
import Generated.Types (Grade, Enrollment)
import qualified Generated.ActualTypes.Grade as Grade
import qualified Generated.ActualTypes.Enrollment as Enrollment
import IHP.ModelSupport.Types (Id'(Id))
import qualified Data.UUID as UUID
import IHP.ModelSupport (newRecord)
import IHP.Prelude (set, (|>))

main :: IO ()
main = hspec $ do

    describe "Permissoes de usuarios" $ do

        it "reconhece o administrador" $
            papelDoBanco "admin" `shouldBe` Just Administrador

        it "reconhece o coordenador" $
            papelDoBanco "coordenador" `shouldBe` Just Coordenador

        it "reconhece o professor" $
            papelDoBanco "professor" `shouldBe` Just Professor

        it "reconhece o aluno" $
            papelDoBanco "aluno" `shouldBe` Just Aluno

        it "rejeita perfis desconhecidos" $
            papelDoBanco "invalido" `shouldBe` Nothing

        it "administrador pode excluir estudantes" $
            podeExecutar Administrador ExcluirEstudante
                `shouldBe` True

        it "coordenador pode cadastrar estudantes" $
            podeExecutar Coordenador CadastrarEstudante
                `shouldBe` True

        it "coordenador nao pode excluir estudantes" $
            podeExecutar Coordenador ExcluirEstudante
                `shouldBe` False

        it "professor pode consultar disciplinas" $
            podeExecutar Professor ConsultarCursos
                `shouldBe` True

        it "professor nao pode excluir disciplinas" $
            podeExecutar Professor ExcluirCurso
                `shouldBe` False

        it "aluno pode consultar seu cadastro" $
            podeAcessarCadastro Aluno True
                `shouldBe` True

        it "aluno nao pode acessar cadastro de outro aluno" $
            podeAcessarCadastro Aluno False
                `shouldBe` False

    describe "Validacoes academicas" $ do

        it "aceita texto preenchido" $
            textoObrigatorioValido "Programacao Funcional"
                `shouldBe` True

        it "rejeita texto vazio" $
            textoObrigatorioValido ""
                `shouldBe` False

        it "rejeita texto somente com espacos" $
            textoObrigatorioValido "   "
                `shouldBe` False

        it "aceita carga horaria positiva" $
            cargaHorariaValida 60
                `shouldBe` True

        it "rejeita carga horaria negativa" $
            cargaHorariaValida (-10)
                `shouldBe` False

        it "rejeita carga horaria zero" $
            cargaHorariaValida 0
                `shouldBe` False

        it "aceita disciplina com dados validos" $
            dadosCursoValidos "PF01" "Programacao Funcional" 60
                `shouldBe` True

        it "rejeita disciplina sem nome" $
            dadosCursoValidos "PF01" "" 60
                `shouldBe` False

        it "aceita estudante com dados preenchidos" $
            dadosEstudanteValidos
                "2026001" "Diego" "diego@email.com"
                `shouldBe` True

        it "rejeita estudante sem matricula" $
            dadosEstudanteValidos
                "" "Diego" "diego@email.com"
                `shouldBe` False


    describe "Calculos do boletim" $ do

        it "retorna Nothing quando nao existem notas" $
            mediaDasNotas [] `shouldBe` Nothing

        it "calcula a media de 8, 7 e 9" $
            mediaDasNotas [nota 8, nota 7, nota 9]
                `shouldBe` Just 8.0

        it "mantem a media de uma unica nota" $
            mediaDasNotas [nota 6]
                `shouldBe` Just 6.0

        it "calcula medias com casas decimais" $
            mediaDasNotas [nota 7, nota 8]
                `shouldBe` Just 7.5

        it "calcula media zero" $
            mediaDasNotas [nota 0, nota 0]
                `shouldBe` Just 0.0

        it "conta uma lista vazia" $
            quantidadeNotas [] `shouldBe` 0

        it "conta tres notas corretamente" $
            quantidadeNotas [nota 8, nota 7, nota 9]
                `shouldBe` 3


    describe "Filtragem de notas por matricula" $ do

        it "retorna somente as notas da matricula selecionada" $ do
            let notas =
                    [ notaVinculada matriculaA 8
                    , notaVinculada matriculaB 5
                    , notaVinculada matriculaA 7
                    ]

            map Grade.value
                (notasDaMatricula matriculaA notas)
                `shouldBe` [8, 7]

        it "nao retorna notas de outra matricula" $ do
            let notas = [notaVinculada matriculaB 9]

            notasDaMatricula matriculaA notas
                `shouldBe` []

        it "retorna lista vazia quando nao existem notas" $
            notasDaMatricula matriculaA []
                `shouldBe` []



    describe "Validacao monadica de profissionais" $ do

        it "aceita professor com disciplinas" $
            validarCadastroProfissional "Ana" "ana@sga.com" "professor" "senha1234" 2 2
                `shouldBe` Right ()

        it "aceita coordenador sem disciplinas" $
            validarCadastroProfissional "Carlos" "carlos@sga.com" "coordenador" "senha1234" 0 0
                `shouldBe` Right ()

        it "rejeita nome vazio" $
            validarCadastroProfissional "   " "ana@sga.com" "professor" "senha1234" 1 1
                `shouldBe` Left NomeObrigatorio

        it "rejeita email invalido" $
            validarCadastroProfissional "Ana" "email-invalido" "professor" "senha1234" 1 1
                `shouldBe` Left EmailInvalido

        it "rejeita perfil desconhecido" $
            validarCadastroProfissional "Ana" "ana@sga.com" "admin" "senha1234" 1 1
                `shouldBe` Left PerfilInvalido

        it "exige disciplinas para professores" $
            validarCadastroProfissional "Ana" "ana@sga.com" "professor" "senha1234" 0 0
                `shouldBe` Left ProfessorSemDisciplinas

        it "impede disciplinas em coordenadores" $
            validarCadastroProfissional "Ana" "ana@sga.com" "coordenador" "senha1234" 1 1
                `shouldBe` Left CoordenadorComDisciplinas

        it "rejeita disciplinas inconsistentes" $
            validarCadastroProfissional "Ana" "ana@sga.com" "professor" "senha1234" 2 1
                `shouldBe` Left DisciplinasInvalidas

        it "rejeita senha curta" $
            validarCadastroProfissional "Ana" "ana@sga.com" "professor" "123" 1 1
                `shouldBe` Left SenhaCurta


-- Cria uma nota ficticia sem acessar o banco.
nota :: Integer -> Grade
nota valor =
    newRecord @Grade
        |> set #value (fromIntegral valor)


-- Matriculas ficticias com identificadores distintos.
matriculaA :: Enrollment
matriculaA =
    newRecord @Enrollment
        |> set #id (Id (UUID.fromWords 0 0 0 1))

matriculaB :: Enrollment
matriculaB =
    newRecord @Enrollment
        |> set #id (Id (UUID.fromWords 0 0 0 2))

-- Associa uma nota ficticia a uma matricula.
notaVinculada :: Enrollment -> Integer -> Grade
notaVinculada enrollment valor =
    nota valor
        |> set #enrollmentId (Enrollment.id enrollment)
