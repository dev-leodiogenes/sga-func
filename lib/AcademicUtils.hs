module AcademicUtils where

-- Representa uma nota de forma temporária para desenvolver
-- as funções enquanto os modelos IHP são gerados.
data GradeInfo = GradeInfo
    { assessmentName :: String
    , gradeValue :: Double
    }
    deriving (Show, Eq)

-- LIST COMPREHENSION

-- Retorna apenas as notas de aprovação (>= 7)
approvedGrades :: [GradeInfo] -> [GradeInfo]
approvedGrades grades =
    [grade | grade <- grades, gradeValue grade >= 7]


-- Retorna apenas as notas abaixo da média (< 7)
failedGrades :: [GradeInfo] -> [GradeInfo]
failedGrades grades =
    [grade | grade <- grades, gradeValue grade < 7]

-- Retorna somente os valores das notas
gradeValues :: [GradeInfo] -> [Double]
gradeValues grades =
    [gradeValue grade | grade <- grades]


-- PATTERN MATCHING

-- Retorna a primeira nota da lista.
-- Se a lista estiver vazia, retorna Nothing.
firstGrade :: [GradeInfo] -> Maybe GradeInfo
firstGrade [] = Nothing
firstGrade (grade:_) = Just grade