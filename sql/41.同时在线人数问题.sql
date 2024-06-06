-- user_id, live_id, in_datetime, out_datetime
WITH t1 AS (
    SELECT
        live_id,
        in_datetime AS `date_time`,
        1 AS `flag`
    FROM
        live_events
    UNION
    ALL
    SELECT
        live_id,
        out_datetime AS `date_time` -1 AS `flag`
    FROM
        live_events
),
t2 AS (
    SELECT
        live_id,
        date_time,
        sum(flag) over(
            PARTITION by live_id
            ORDER BY
                date_time
        ) AS `amount`
    FROM
        t1
),
t3 AS (
    SELECT
        live_id,
        cast(max(amount) AS int) AS `max_cnt`,
        cast(min(amount) AS int) AS `min_cnt`
    FROM
        t2
    GROUP BY
        live_id
)
SELECT
    t2.live_id,
    t2.date_time,
    t3.max_cnt,
    t3.min_cnt
FROM
    t2
    JOIN t3 ON t2.amount int (t3.max_cnt, min_cnt);