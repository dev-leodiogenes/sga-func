module Application.Helper.Validacoes where

import Data.Text (Text)
import qualified Data.Text as T

textoObrigatorioValido :: Text -> Bool
textoObrigatorioValido texto =
    not (T.null (T.strip texto))

cargaHorariaValida :: Int -> Bool
cargaHorariaValida horas =
    horas > 0    

dadosCursoValidos :: Text -> Text -> Int -> Bool
dadosCursoValidos codigo nome horas =
    textoObrigatorioValido codigo &&
    textoObrigatorioValido nome &&
    cargaHorariaValida horas

dadosEstudanteValidos :: Text -> Text -> Text -> Bool
dadosEstudanteValidos matricula nome email =
    textoObrigatorioValido matricula &&
    textoObrigatorioValido nome &&
    textoObrigatorioValido email