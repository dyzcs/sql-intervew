WITH t1 AS (
    SELECT
        user_id,
        create_date,
        row_number() over(
            PARTITION by user_id
            ORDER BY
                create_date
        ) AS `rn`
    FROM
        order_info
),
t2 AS (
    SELECT
        user_id,
        create_date,
        rn,
        date_sub(create_date, rn) AS `ds`
    FROM
        t1
),
t3 AS (
    SELECT
        user_id,
        count(*) AS `cnt`
    FROM
        t2
    GROUP BY
        user_id,
        ds
    HAVING
        cnt >= 3
)
SELECT
    user_id
FROM
    t3;