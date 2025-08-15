WITH
-- Pre-reg per date
PreRegCount AS (
    SELECT
        CAST([date] AS DATE) AS [Date],
        'Pre-reg' AS Stage,
        COUNT(DISTINCT description) AS NumUsers
    FROM tblAuth0LogData
    WHERE description NOT IN (SELECT Email FROM AspNetUsers)
      AND description NOT LIKE '%boringmoney.co.uk%'
      AND description LIKE '%@%'
    GROUP BY CAST([date] AS DATE)
),

-- Registered users per date by level
RegisteredCounts AS (
    SELECT
        CAST(DateRegistered AS DATE) AS [Date],
        CASE CAST(ProfileComplete AS NVARCHAR)
            WHEN 'COMPLETE' THEN 'Registration Completed'
            WHEN '2' THEN 'Level 2'
            WHEN '1' THEN 'Level 1'
            ELSE 'Other'
        END AS Stage,
        COUNT(*) AS NumUsers
    FROM AspNetUsers
    WHERE Email NOT LIKE '%boringmoney.co.uk%'
      AND Email NOT LIKE '%test%'
    GROUP BY
        CAST(DateRegistered AS DATE),
        CASE CAST(ProfileComplete AS NVARCHAR)
            WHEN 'COMPLETE' THEN 'Registration Completed'
            WHEN '2' THEN 'Level 2'
            WHEN '1' THEN 'Level 1'
            ELSE 'Other'
        END
)

-- Combine both datasets
SELECT * FROM RegisteredCounts
UNION ALL
SELECT * FROM PreRegCount
ORDER BY [Date], Stage;