WITH t1 AS (
    -- 每个日期，每个用户的下单总额
    SELECT
        user_id,
        create_date,
        sum(total_amount) AS `total_amount`
    FROM
        order_info
    GROUP BY
        user_id,
        create_date
),
t2 AS (
    -- 截止日期，消费总额明细表明细表
    SELECT
        user_id,
        create_date,
        sum(total_amount) over(
            PARTITION by user_id
            ORDER BY
                create_date
        ) AS `sum_so_far`
    FROM
        t1
)
SELECT
    *,
    CASE
        WHEN sum_so_far >= 100000 THEN '钻石会员'
        WHEN sum_so_far >= 80000 THEN '白金会员'
        WHEN sum_so_far >= 50000 THEN '黄金会员'
        WHEN sum_so_far >= 30000 THEN '白银会员'
        WHEN sum_so_far >= 10000 THEN '青铜会员'
        WHEN sum_so_far >= 0 THEN '普通会员'
    END AS `vip_level`
FROM
    t2
ORDER BY
    user_id,
    create_date;