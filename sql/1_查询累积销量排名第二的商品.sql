-- http://practice.atguigu.cn/#/question/1/desc?qType=SQL
WITH t1 AS (
    SELECT
        sku_id,
        sum(sku_num) AS `num`
    FROM
        order_detail
    GROUP BY
        sku_id
),
t2 AS (
    SELECT
        sku_id,
        num,
        rank() over(
            ORDER BY
                num DESC
        ) AS `rk`
    FROM
        t1
)
SELECT
    sku_id
FROM
    t2
WHERE
    rk = 2;