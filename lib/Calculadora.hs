
module Calculadora where

criarCalculadora :: Double -> Double -> Double -> Double -> Double
criarCalculadora peso1 peso2 nota1 nota2 =
    nota1 * peso1 + nota2 * peso2

calculadora6040 :: Double -> Double -> Double
calculadora6040 = criarCalculadora 0.6 0.4

data Resultado
    = MediaCalculada Double
    | SemNotas
    | DadosInvalidos
    deriving (Show, Eq)

mostrarResultado :: Resultado -> String

mostrarResultado (MediaCalculada media) =
    "A media do aluno foi: " ++ show media

mostrarResultado SemNotas =
    "O aluno ainda nao possui notas"

mostrarResultado DadosInvalidos =
    "Os dados informados sao invalidos"
