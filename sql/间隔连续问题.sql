/**
间隔连续问题
某游戏公司记录的用户每日登录数据
1001 2021-12-12
1002 2021-12-12
1001 2021-12-13
1001 2021-12-14
1001 2021-12-16
1002 2021-12-16
1001 2021-12-19
1002 2021-12-17
1001 2021-12-20

计算每个用户最大的连续登录天数，可以间隔一天。解释：如果一个用户在 1,3,5,6 登录游戏，则视为连续 6 天登录。
*/

-- 建表 DuckDB
CREATE TABLE
    user_logins (user_id INTEGER, login_date DATE);

-- 插入数据
INSERT INTO
    user_logins
VALUES
    (1001, '2021-12-12'),
    (1002, '2021-12-12'),
    (1001, '2021-12-13'),
    (1001, '2021-12-14'),
    (1001, '2021-12-16'),
    (1002, '2021-12-16'),
    (1001, '2021-12-19'),
    (1002, '2021-12-17'),
    (1001, '2021-12-20');

-- 查询
WITH
    date_differences AS (
        SELECT
            user_id,
            login_date,
            LAG (login_date, 1) OVER (
                PARTITION BY
                    user_id
                ORDER BY
                    login_date
            ) AS previous_login_date -- 获取每个用户上一次的登录日期
        FROM
            user_logins
    ),
    streak_identifiers AS (
        -- 识别每个新的连续登录周期的开始
        SELECT
            user_id,
            login_date,
            -- 如果与上次登录日期相差超过2天，或者这是第一次登录 (previous_login_date is NULL)，则标记为新的连续登录周期 (is_new_streak = 1)
            CASE
                WHEN login_date - previous_login_date > 2 THEN 1
                WHEN previous_login_date IS NULL THEN 1
                ELSE 0
            END AS is_new_streak
        FROM
            date_differences
    ),
    streak_groups AS (
        -- 为每个连续登录周期分配一个唯一的ID
        SELECT
            user_id,
            login_date,
            -- 对 is_new_streak 标志进行累加求和，为每个连续周期生成一个分组ID (streak_id)
            SUM(is_new_streak) OVER (
                PARTITION BY
                    user_id
                ORDER BY
                    login_date
            ) AS streak_id
        FROM
            streak_identifiers
    ),
    streak_durations AS (
        -- 计算每个连续登录周期的持续时间
        SELECT
            user_id,
            streak_id,
            -- 对于每个连续周期，计算其开始日期和结束日期，然后计算总天数
            MAX(login_date) - MIN(login_date) + 1 AS streak_duration
        FROM
            streak_groups
        GROUP BY
            user_id,
            streak_id
    )
SELECT
    user_id,
    MAX(streak_duration) AS max_continuous_login_days
FROM
    streak_durations
GROUP BY
    user_id
ORDER BY
    user_id;

-- 结果
-- ┌─────────┬───────────────────────────┐
-- │ user_id │ max_continuous_login_days │
-- │  int32  │           int64           │
-- ├─────────┼───────────────────────────┤
-- │    1001 │                         5 │
-- │    1002 │                         2 │
-- └─────────┴───────────────────────────┘
