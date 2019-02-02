
--
-- Data Source:  https://coinmetrics.io/data-downloads/
--

CREATE SCHEMA IF NOT EXISTS coinmetrics;

DROP TABLE IF EXISTS coinmetrics.ethereum_usd_price_history;

CREATE TABLE coinmetrics.ethereum_usd_price_history (
  day                    TIMESTAMP      NOT NULL,
  tx_volume_usd          NUMERIC(38, 6) NOT NULL,
  adjusted_tx_volume_usd NUMERIC(38, 6) NOT NULL,
  tx_count               BIGINT         NOT NULL,
  marketcap_usd          NUMERIC(38, 6) NOT NULL,
  price_usd              NUMERIC(38, 6) NOT NULL,
  exchange_volume_usd    NUMERIC(38, 6) NOT NULL,
  generated_coins        NUMERIC(38, 6) NOT NULL,
  fees                   NUMERIC(38, 6) NOT NULL,
  active_addresses       BIGINT         NOT NULL,
  median_tx_value_usd    NUMERIC(38, 6) NOT NULL,
  median_fee             NUMERIC(38, 6) NOT NULL,
  average_difficulty     NUMERIC(38, 6) NOT NULL,
  payment_count          BIGINT         NOT NULL,
  block_size             BIGINT         NOT NULL,
  block_count            BIGINT         NOT NULL,
  nvt                    NUMERIC(38, 6) NOT NULL,
  PRIMARY KEY (day)
)
DISTSTYLE ALL
SORTKEY (day);