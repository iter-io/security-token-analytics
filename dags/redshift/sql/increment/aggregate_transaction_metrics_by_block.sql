
--
-- Rollup our transactions to the block level.
--

DROP TABLE IF EXISTS ethereum.aggregate_transaction_metrics_by_block_incr_tmp;

CREATE TABLE ethereum.aggregate_transaction_metrics_by_block_incr_tmp
(LIKE ethereum.aggregate_transaction_metrics_by_block);

INSERT INTO ethereum.aggregate_transaction_metrics_by_block_incr_tmp
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
WHERE
  transactions.block_number BETWEEN
    (SELECT MIN(number) FROM ethereum.blocks WHERE timestamp >= {start_timestamp})
    AND
    (SELECT MAX(number) FROM ethereum.blocks WHERE timestamp <= {end_timestamp})
GROUP BY
  transactions.block_number
ORDER BY
  transactions.block_number ASC;


BEGIN TRANSACTION;

DELETE FROM ethereum.aggregate_transaction_metrics_by_block
USING ethereum.aggregate_transaction_metrics_by_block_incr_tmp
WHERE
  ethereum.aggregate_transaction_metrics_by_block.block_number =
    ethereum.aggregate_transaction_metrics_by_block_incr_tmp.block_number;

INSERT INTO ethereum.aggregate_transaction_metrics_by_block
SELECT * FROM ethereum.aggregate_transaction_metrics_by_block_incr_tmp;

END TRANSACTION;

DROP TABLE ethereum.aggregate_transaction_metrics_by_block_incr_tmp;
