module Calculos where

notaValida :: Double -> Bool
notaValida nota = nota >= 0 && nota <= 10

pesoValido :: Double -> Bool
pesoValido peso = peso > 0

mediaPonderada :: Double -> Double -> Double -> Double -> Maybe Double
mediaPonderada nota1 peso1 nota2 peso2 =
    if notaValida nota1 && notaValida nota2 &&
       pesoValido peso1 && pesoValido peso2
    then Just ((nota1 * peso1 + nota2 * peso2) / (peso1 + peso2))
    else Nothing