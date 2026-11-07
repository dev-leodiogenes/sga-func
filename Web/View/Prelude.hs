module Web.View.Prelude
    ( module IHP.ViewPrelude
    , module Generated.Types
    , module Web.Types
    , situacaoMatricula
    ) where

import IHP.ViewPrelude
import Generated.Types
import Web.Types
import Web.Routes ()


-- Traducao dos status exibidos na interface.
situacaoMatricula :: Text -> Text
situacaoMatricula "Active" = "Ativa"
situacaoMatricula "Cancelled" = "Cancelada"
situacaoMatricula "Completed" = "Concluída"
situacaoMatricula outro = outro
