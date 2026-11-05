module Application.Helper.Criptografia where

import IHP.Prelude
import IHP.ModelSupport
import IHP.TypedSql (typedSql, sqlExecTyped, sqlQueryTyped)
import Generated.Types
import System.Environment (lookupEnv)
import qualified Data.Text as T

-- A passphrase is supplied by the server, not stored in source control.
-- pgcrypto uses OpenPGP symmetric encryption (AES-256) and randomized salts.
encryptionKey :: IO Text
encryptionKey = do
    configured <- lookupEnv "SGA_ENCRYPTION_KEY"
    case configured of
        Nothing -> fail "SGA_ENCRYPTION_KEY nao configurada"
        Just value
            | T.length (T.pack value) < 32 -> fail "SGA_ENCRYPTION_KEY deve ter pelo menos 32 caracteres"
            | otherwise -> pure (T.pack value)

savePrivateNote studentId note
    | T.null (T.strip note) = do
        _ <- sqlExecTyped [typedSql|
            UPDATE students SET confidential_note = NULL
            WHERE id = ${studentId}
        |]
        pure ()
    | otherwise = do
        key <- encryptionKey
        _ <- sqlExecTyped [typedSql|
            UPDATE students
            SET confidential_note = pgp_sym_encrypt(${note}, ${key}, 'cipher-algo=aes256')
            WHERE id = ${studentId}
        |]
        pure ()

readPrivateNote studentId = do
    key <- encryptionKey
    notes <- sqlQueryTyped [typedSql|
        SELECT pgp_sym_decrypt(confidential_note, ${key})
        FROM students
        WHERE id = ${studentId}
    |]
    case notes of
        (Just note : _) -> pure (Just note)
        _ -> pure Nothing
