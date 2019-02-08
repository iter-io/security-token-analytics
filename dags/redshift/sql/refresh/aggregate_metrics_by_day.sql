
--
--  Join at the block level and aggregate by day.
--

DROP TABLE IF EXISTS ethereum.aggregate_metrics_by_day_tmp;

CREATE TABLE ethereum.aggregate_metrics_by_day_tmp
(LIKE ethereum.aggregate_metrics_by_day);

INSERT INTO ethereum.aggregate_metrics_by_day_tmp
SELECT
  DATE_TRUNC('day', TIMESTAMP 'epoch' + blocks.timestamp * INTERVAL '1 second')
                                AS day,

  COUNT(DISTINCT blocks.hash)   AS blocks_cnt,
  COUNT(DISTINCT blocks.miner)  AS unique_miners,
  AVG(blocks.difficulty)        AS median_difficulty,
  MAX(blocks.total_difficulty)  AS cumulative_difficulty,
  SUM(blocks.size)              AS total_blocksize_bytes,
  SUM(blocks.gas_used)          AS gas_used,
  SUM(transaction_count)        AS transactions_cnt_from_blocks,
  SUM(transactions_cnt)         AS transactions_cnt,
  SUM(new_addresses)            AS new_addresses,
  SUM(unique_senders)           AS unique_senders,
  SUM(unique_receivers)         AS unique_receivers,
  SUM(value_transferred_wei)    AS value_transferred_wei,
  SUM(value_transferred_eth)    AS value_transferred_eth,
  SUM(total_gas_provided)       AS total_gas_provided
FROM
  ethereum.blocks AS blocks
INNER JOIN
  ethereum.aggregate_transaction_metrics_by_block AS transactions
ON
  blocks.number = transactions.block_number
GROUP BY
  day
ORDER BY
  day DESC;

BEGIN;
DROP TABLE ethereum.aggregate_metrics_by_day;
ALTER TABLE ethereum.aggregate_metrics_by_day_tmp RENAME TO aggregate_metrics_by_day;
COMMIT;