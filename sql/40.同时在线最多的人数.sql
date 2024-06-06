-- user_id, ip_address, login_ts, logout_ts
WITH t1 AS (
    SELECT
        login_ts AS `time`,
        1 AS `mark` -- 登记操作记为 1
    FROM
        user_login_detail
    UNION
    ALL
    SELECT
        login_out AS `time`,
        -1 AS `mark` -- 登出操作记为 -1
    FROM
        user_login_detail
),
t2 AS (
    SELECT
        sum(mark) over(
            ORDER BY
                `time`
        ) AS `count_people` -- 开窗统计在线人数
    FROM
        t1
),
SELECT
    max(count_people) AS `max_cnt` -- 筛选出最大同时在线人数
FROM
    t2;