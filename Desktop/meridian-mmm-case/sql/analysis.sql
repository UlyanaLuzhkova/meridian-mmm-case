--1.А ЕЖЕМЕСЯЧНЫЕ КОЭФФИЕНТЫ СЕЗОННОСТИ ПРОДАЖ ЗА ВСЕ ВРЕМЯ

WITH monthly_stats AS (
    SELECT 
        strftime('%m', DATE) AS month,
        AVG("DEMAND") AS avg_demand
    FROM MMM_data_fixed
    GROUP BY strftime('%m', DATE)
),
overall_stats AS (
    SELECT AVG("DEMAND") AS overall_avg
    FROM MMM_data_fixed
)
SELECT 
    m.month,
    ROUND(m.avg_demand, 2) AS avg_demand,
    ROUND(o.overall_avg, 2) AS overall_avg,
    ROUND(m.avg_demand / o.overall_avg, 3) AS seasonality
FROM monthly_stats m
CROSS JOIN overall_stats o
ORDER BY m.month;

--1.Б ЕЖЕМЕСЯЧНЫЕ КОЭФФИЕНТЫ СЕЗОННОСТИ ПРОДАЖ ЗА КАЖДЫЙ ГОД

WITH monthly_stats2 AS (
    SELECT 
        strftime('%Y', DATE) AS year,
        strftime('%m', DATE) AS month,
        AVG("DEMAND") AS avg_demand
    FROM MMM_data_fixed
    GROUP BY strftime('%Y', DATE), strftime('%m', DATE)  -- добавили год!
),
yearly_avg AS (
    SELECT 
        strftime('%Y', DATE) AS year,
        AVG("DEMAND") AS year_avg
    FROM MMM_data_fixed
    GROUP BY strftime('%Y', DATE)
)
SELECT 
    m2.year,
    m2.month,
    ROUND(m2.avg_demand, 2) AS avg_demand,
    ROUND(y.year_avg, 2) AS year_avg,
    ROUND(m2.avg_demand / y.year_avg, 3) AS seasonality
FROM monthly_stats2 m2
JOIN yearly_avg y ON m2.year = y.year
ORDER BY m2.year, m2.month;

--ЕЖЕМЕСЯЧНЫЙ ВОЗВРАТ НА РЕКЛАМНЫЕ ИНВЕСТИЦИИ ЗА ВСЕ ВРЕМЯ

WITH monthly_data AS (
    SELECT 
        strftime('%m', DATE) AS month,
        SUM("SALES ($)") AS total_sales,
        SUM(
            "Advertising Expenses (SMS)" +
            "Advertising Expenses(Newspaper ads)" +
            "Advertising Expenses(Radio)" +
            "Advertising Expenses(TV)" +
            "Advertising Expenses(Internet)"
        ) AS total_spend
    FROM MMM_data_fixed
    GROUP BY strftime('%m', DATE)
)
SELECT 
    month,
    ROUND(total_sales, 2) AS sales,
    ROUND(total_spend, 2) AS spend,
    ROUND(total_sales / total_spend, 2) AS roas
FROM monthly_data
WHERE total_spend > 0
ORDER BY month;

--ЕЖЕМЕСЯЧНЫЙ ВОЗВРАТ НА РЕКЛАМНЫЕ ИНВЕСТИЦИИ ЗА КАЖДЫЙ ГОД

WITH monthly_data2 AS (
    SELECT 
        strftime('%Y', DATE) AS year,
        strftime('%m', DATE) AS month,
        SUM("SALES ($)") AS total_sales,
        SUM(
            "Advertising Expenses (SMS)" +
            "Advertising Expenses(Newspaper ads)" +
            "Advertising Expenses(Radio)" +
            "Advertising Expenses(TV)" +
            "Advertising Expenses(Internet)"
        ) AS total_spend
    FROM MMM_data_fixed
    GROUP BY strftime('%Y', DATE), strftime('%m', DATE)
)
SELECT 
    year,
    month,
    ROUND(total_sales, 2) AS sales,
    ROUND(total_spend, 2) AS spend,
    ROUND(total_sales /total_spend, 2) AS roas
FROM monthly_data2
WHERE total_spend > 0
ORDER BY year, month;