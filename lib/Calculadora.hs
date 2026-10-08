
module Calculadora where

criarCalculadora :: Double -> Double -> Double -> Double -> Double
criarCalculadora peso1 peso2 nota1 nota2 =
    nota1 * peso1 + nota2 * peso2

calculadora6040 :: Double -> Double -> Double
calculadora6040 = criarCalculadora 0.6 0.4
