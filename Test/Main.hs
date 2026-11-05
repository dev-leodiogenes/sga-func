module Main where

import Test.Hspec
import IHP.Prelude
import Application.Helper.Permissoes

main :: IO ()
main = hspec do
    describe "Papéis e permissões" do
        it "rejeita perfil desconhecido (fail closed)" do
            papelDoBanco "hacker" `shouldBe` Nothing
        it "não permite que aluno edite ou exclua dados" do
            podeExecutar Aluno EditarEstudante `shouldBe` False
            podeExecutar Aluno ExcluirCurso `shouldBe` False
        it "permite professor consultar, mas não modificar" do
            podeExecutar Professor ConsultarEstudantes `shouldBe` True
            podeExecutar Professor ConsultarDashboard `shouldBe` True
            podeExecutar Professor CadastrarCurso `shouldBe` False
        it "permite ao administrador gerenciar o SGA" do
            podeExecutar Administrador GerenciarNotasSigilosas `shouldBe` True
        it "impede o aluno de consultar outro cadastro" do
            podeAcessarCadastro Aluno False `shouldBe` False
            podeAcessarCadastro Aluno True `shouldBe` True
        it "não limita a leitura do cadastro para professor" do
            podeAcessarCadastro Professor False `shouldBe` True
