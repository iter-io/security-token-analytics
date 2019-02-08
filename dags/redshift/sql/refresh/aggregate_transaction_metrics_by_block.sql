
--
-- Rollup our transactions to the block level.
--

DROP TABLE IF EXISTS ethereum.aggregate_transaction_metrics_by_block_tmp;

CREATE TABLE ethereum.aggregate_transaction_metrics_by_block_tmp
(LIKE ethereum.aggregate_transaction_metrics_by_block);

INSERT INTO ethereum.aggregate_transaction_metrics_by_block_tmp
SELECT
  transactions.block_number                 AS block_number,
  COUNT(DISTINCT transactions.hash)         AS transactions_cnt,

  COUNT(DISTINCT
    CASE
      WHEN transactions.nonce = 0 THEN from_address
      ELSE NULL
    END
  )                                         AS new_addresses,

  COUNT(DISTINCT transactions.from_address) AS unique_senders,
  COUNT(DISTINCT transactions.to_address)   AS unique_receivers,
  SUM(transactions.value)                   AS value_transferred_wei,

  SUM(transactions.value)::NUMERIC(32, 6) / POWER(10, 18)::NUMERIC(32, 6)
                                            AS value_transferred_eth,

  SUM(transactions.gas)                     AS total_gas_provided,
  AVG(transactions.gas_price)               AS avg_gas_price
FROM
  ethereum.transactions AS transactions
GROUP BY
  transactions.block_number
ORDER BY
  transactions.block_number ASC;

BEGIN;
DROP TABLE ethereum.aggregate_transaction_metrics_by_block;
ALTER TABLE ethereum.aggregate_transaction_metrics_by_block_tmp RENAME TO aggregate_transaction_metrics_by_block;
COMMIT;
