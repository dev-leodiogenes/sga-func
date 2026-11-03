module MonadsFunctorsCPS where

import Control.Monad.Reader (Reader, ask, runReader)

-- ============================================================
-- 1. MONADS: MAYBE / EITHER PARA VALIDACAO
-- ============================================================

primeiraNota :: [Double] -> Maybe Double
primeiraNota [] = Nothing
primeiraNota (nota:_) = Just nota

validarNota :: Double -> Either String Double
validarNota nota
    | nota < 0 = Left "A nota nao pode ser menor que 0."
    | nota > 10 = Left "A nota nao pode ser maior que 10."
    | otherwise = Right nota

validarMatricula :: String -> Either String String
validarMatricula matricula
    | null matricula = Left "A matricula nao pode ser vazia."
    | otherwise = Right matricula

-- ============================================================
-- 2. IO ISOLADO / EFEITOS COLATERAIS CONTROLADOS
-- ============================================================

mensagemDeMatricula :: String -> String
mensagemDeMatricula matricula =
    "Matricula processada: " ++ matricula

registrarMatriculaNoConsole :: String -> IO ()
registrarMatriculaNoConsole matricula =
    putStrLn (mensagemDeMatricula matricula)

-- ============================================================
-- 3. READER PARA CONFIGURACAO
-- ============================================================

data Configuracao = Configuracao
    { notaMinimaAprovacao :: Double
    , periodoAtual :: String
    }
    deriving (Show, Eq)

estaAprovado :: Double -> Reader Configuracao Bool
estaAprovado nota = do
    config <- ask
    pure (nota >= notaMinimaAprovacao config)

periodoConfigurado :: Reader Configuracao String
periodoConfigurado = do
    config <- ask
    pure (periodoAtual config)

executarEstaAprovado :: Configuracao -> Double -> Bool
executarEstaAprovado config nota =
    runReader (estaAprovado nota) config

-- ============================================================
-- 4. FUNCTORS APLICADOS A COLECOES
-- ============================================================

aumentarNotas :: Double -> [Double] -> [Double]
aumentarNotas bonus notas =
    fmap (+ bonus) notas

dobrarPrimeiraNota :: [Double] -> Maybe Double
dobrarPrimeiraNota notas =
    fmap (* 2) (primeiraNota notas)

-- ============================================================
-- 5. CONTINUATION PASSING STYLE (CPS)
-- ============================================================

processarMatriculaCPS :: String -> (String -> resultado) -> resultado
processarMatriculaCPS matricula continuacao =
    continuacao ("Matricula " ++ matricula ++ " processada com sucesso.")

pipelineMatriculaCPS :: String -> String
pipelineMatriculaCPS matricula =
    processarMatriculaCPS matricula
        (\mensagem -> mensagem ++ " Proxima etapa: vincular disciplina.")

-- ============================================================
-- 6. LAZY EVALUATION
-- ============================================================

numerosNaturais :: [Integer]
numerosNaturais = [1..]

primeirosNaturais :: Int -> [Integer]
primeirosNaturais quantidade =
    take quantidade numerosNaturais

numerosPares :: [Integer]
numerosPares = [2,4..]

primeirosPares :: Int -> [Integer]
primeirosPares quantidade =
    take quantidade numerosPares
