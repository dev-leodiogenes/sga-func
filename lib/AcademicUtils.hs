module AcademicUtils where

-- Representa uma nota de forma temporária para desenvolver
-- as funções enquanto os modelos IHP são gerados.
data InformacaoNota = InformacaoNota
    { nomeAvaliacao :: String
    , valorNota :: Double
    }
    deriving (Show, Eq)

-- LIST COMPREHENSION

-- Retorna apenas as notas de aprovação (>= 7)
notasAprovadas :: [InformacaoNota] -> [InformacaoNota]
notasAprovadas notas =
    [nota | nota <- notas, valorNota nota >= 7]

-- Retorna apenas as notas abaixo da média (< 7)
notasReprovadas :: [InformacaoNota] -> [InformacaoNota]
notasReprovadas notas =
    [nota | nota <- notas, valorNota nota < 7]

-- Retorna somente os valores das notas
valoresNotas :: [InformacaoNota] -> [Double]
valoresNotas notas =
    [valorNota nota | nota <- notas]

-- PATTERN MATCHING

-- Retorna a primeira nota da lista.
-- Se a lista estiver vazia, retorna Nothing.
primeiraNota :: [InformacaoNota] -> Maybe InformacaoNota
primeiraNota [] = Nothing
primeiraNota (nota:_) = Just nota

-- MAP

-- Percorre todas as notas e retorna somente os valores.
valoresNotasMap :: [InformacaoNota] -> [Double]
valoresNotasMap notas =
    map valorNota notas

-- FILTER

-- Retorna somente as notas aprovadas usando filter.
notasAprovadasFilter :: [InformacaoNota] -> [InformacaoNota]
notasAprovadasFilter notas =
    filter (\nota -> valorNota nota >= 7) notas

-- Retorna somente as notas reprovadas usando filter.
notasReprovadasFilter :: [InformacaoNota] -> [InformacaoNota]
notasReprovadasFilter notas =
    filter (\nota -> valorNota nota < 7) notas