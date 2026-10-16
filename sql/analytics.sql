

SELECT
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount)::numeric, 2) AS total_transaction_value,
    ROUND(AVG(amount)::numeric, 2) AS average_transaction_amount,
    SUM("isFraud") AS fraud_cases,
    ROUND(
        100.0 * SUM("isFraud") / NULLIF(COUNT(*), 0),
        2
    ) AS fraud_rate_pct
FROM transactions_etl;


SELECT
    type,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount)::numeric, 2) AS total_value,
    ROUND(AVG(amount)::numeric, 2) AS average_amount,
    SUM("isFraud") AS fraud_count,
    ROUND(
        100.0 * SUM("isFraud") / NULLIF(COUNT(*), 0),
        2
    ) AS fraud_rate_pct
FROM transactions_etl
GROUP BY type
ORDER BY total_value DESC;



SELECT
    "isFraud" AS fraud_label,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount)::numeric, 2) AS total_value,
    ROUND(AVG(amount)::numeric, 2) AS average_amount
FROM transactions_etl
GROUP BY "isFraud"
ORDER BY fraud_label;



SELECT
    type,
    COUNT(*) AS transaction_count,
    SUM("isFraud") AS fraud_count,
    ROUND(
        100.0 * SUM("isFraud") / NULLIF(COUNT(*), 0),
        2
    ) AS fraud_rate_pct
FROM transactions_etl
GROUP BY type
ORDER BY fraud_rate_pct DESC, fraud_count DESC;




SELECT
    step,
    COUNT(*) AS transaction_count,
    SUM("isFraud") AS fraud_count,
    ROUND(
        100.0 * SUM("isFraud") / NULLIF(COUNT(*), 0),
        2
    ) AS fraud_rate_pct,
    ROUND(SUM(amount)::numeric, 2) AS total_value
FROM transactions_etl
GROUP BY step
ORDER BY step;



SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE step IS NULL) AS missing_step,
    COUNT(*) FILTER (WHERE type IS NULL) AS missing_type,
    COUNT(*) FILTER (WHERE amount IS NULL) AS missing_amount,
    COUNT(*) FILTER (WHERE "isFraud" IS NULL) AS missing_fraud_label
FROM transactions_etl;




SELECT
    COUNT(*) FILTER (WHERE amount < 0) AS negative_amounts,
    COUNT(*) FILTER (
        WHERE "isFraud" NOT IN (0, 1)
    ) AS invalid_fraud_labels,
    COUNT(*) FILTER (
        WHERE "isFlaggedFraud" NOT IN (0, 1)
    ) AS invalid_flag_labels
FROM transactions_etl;



SELECT
    COALESCE(SUM(duplicate_count - 1), 0) AS extra_duplicate_rows
FROM (
    SELECT COUNT(*) AS duplicate_count
    FROM transactions_etl
    GROUP BY
        step,
        type,
        amount,
        "nameOrig",
        "oldbalanceOrg",
        "newbalanceOrig",
        "nameDest",
        "oldbalanceDest",
        "newbalanceDest",
        "isFraud",
        "isFlaggedFraud"
    HAVING COUNT(*) > 1
) AS duplicate_groups;