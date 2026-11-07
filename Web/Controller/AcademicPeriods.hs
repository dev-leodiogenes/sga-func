module Web.Controller.AcademicPeriods where

import Web.Controller.Prelude
import Web.View.AcademicPeriods.Index
import Application.Helper.Permissoes
import IHP.TypedSql (typedSql, sqlExecTyped)

instance Controller AcademicPeriodsController where
    beforeAction = do
        ensureIsUser
        requirePasswordChange
        accessDeniedUnless
            (papelDoBanco currentUser.role_ == Just Administrador)

    action AcademicPeriodsAction = do
        periods <- query @AcademicPeriod
            |> orderByAsc #code
            |> fetch

        render IndexView { .. }

    action CreateActiveAcademicPeriodAction { academicPeriodId } = do
        -- Confirma que o periodo selecionado existe.
        _ <- fetch academicPeriodId :: IO AcademicPeriod

        -- As duas alteracoes acontecem na mesma transacao.
        withTransaction do
            _ <- sqlExecTyped [typedSql|
                UPDATE academic_periods
                SET is_active = FALSE
                WHERE is_active = TRUE
            |]

            _ <- sqlExecTyped [typedSql|
                UPDATE academic_periods
                SET is_active = TRUE
                WHERE id = ${academicPeriodId}
            |]

            pure ()

        setSuccessMessage "Período ativo alterado com sucesso."
        redirectTo AcademicPeriodsAction
