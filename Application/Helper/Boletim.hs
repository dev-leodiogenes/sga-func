module Application.Helper.Boletim where

import IHP.Prelude
import Generated.Types

-- Funcao pura: seleciona notas de uma matricula.
notasDaMatricula :: Enrollment -> [Grade] -> [Grade]
notasDaMatricula enrollment grades =
    [grade | grade <- grades, grade.enrollmentId == enrollment.id]

-- Funcao pura: calcula a media das notas cadastradas.
mediaDasNotas :: [Grade] -> Maybe Double
mediaDasNotas [] = Nothing
mediaDasNotas grades =
    let values = map (\grade -> realToFrac grade.value :: Double) grades
        total = foldl (+) 0 values
    in Just (total / fromIntegral (quantidadeNotas grades))


-- Recursao em cauda: conta as notas usando um acumulador.
quantidadeNotas :: [Grade] -> Int
quantidadeNotas = contar 0
    where
        contar acumulador [] = acumulador
        contar acumulador (_:resto) =
            contar (acumulador + 1) resto
