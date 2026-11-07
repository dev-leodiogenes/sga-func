module Web.Controller.Dashboard where

import Web.Controller.Prelude
import Web.View.Dashboard.Index
import Application.Helper.Permissoes
import IHP.TypedSql (typedSql, sqlQueryTyped)

instance Controller DashboardController where
    beforeAction = do
        ensureIsUser
        requirePasswordChange
        accessDeniedUnless (case papelDoBanco currentUser.role_ of
            Just role -> podeExecutar role ConsultarDashboard
            Nothing -> False)

    action DashboardAction = do
        let period = fromMaybe "" (paramOrNothing @Text "period")
        let courseFilter = fromMaybe "" (paramOrNothing @Text "course")
        periodRecords <- query @AcademicPeriod
            |> orderByAsc #code
            |> fetch
        let periods = map (\item -> item.code) periodRecords
        totals <- sqlQueryTyped [typedSql|
            SELECT
                (SELECT count(*)::int4 FROM students),
                (SELECT count(*)::int4 FROM courses),
                (SELECT count(*)::int4 FROM enrollments e
                 JOIN courses c ON c.id = e.course_id
                 WHERE (${period} = '' OR e.academic_period = ${period})
                   AND (${courseFilter} = '' OR c.code = ${courseFilter})),
                (SELECT avg(g.value)::float8
                 FROM grades g
                 JOIN enrollments e ON e.id = g.enrollment_id
                 JOIN courses c ON c.id = e.course_id
                 WHERE (${period} = '' OR e.academic_period = ${period})
                   AND (${courseFilter} = '' OR c.code = ${courseFilter}))
        |]
        let (totalStudents, totalCourses, totalEnrollments, averageGrade) =
                case totals of
                    (row : _) ->
                        (fromMaybe 0 row.count, fromMaybe 0 row.count_1,
                         fromMaybe 0 row.count_2, row.avg)
                    _ -> (0, 0, 0, Nothing)
        rankingRows <- sqlQueryTyped [typedSql|
            SELECT c.name, avg(g.value)::float8, count(g.id)::int4
            FROM courses c
            JOIN enrollments e ON e.course_id = c.id
            JOIN grades g ON g.enrollment_id = e.id
            WHERE (${period} = '' OR e.academic_period = ${period})
              AND (${courseFilter} = '' OR c.code = ${courseFilter})
            GROUP BY c.id, c.name
            ORDER BY avg(g.value) DESC, c.name ASC
            LIMIT 20
        |]
        let ranking = map (\row -> (row.name, row.avg, row.count)) rankingRows
        -- Dados para o boletim por estudante e avaliacao
        courses <- query @Course |> orderByAsc #name |> fetch
        students <- query @Student |> orderByAsc #name |> fetch
        allEnrollments <- query @Enrollment |> fetch
        allGrades <- query @Grade |> fetch

        let filteredEnrollments = filter (\enrollment ->
                (period == "" || enrollment.academicPeriod == period)
                && (courseFilter == "" || any (\course ->
                    course.id == enrollment.courseId
                    && course.code == courseFilter
                ) courses)
                ) allEnrollments

        let filteredGrades = filter (\grade ->
                any (\enrollment ->
                    enrollment.id == grade.enrollmentId
                ) filteredEnrollments
                ) allGrades

        render IndexView { .. }
