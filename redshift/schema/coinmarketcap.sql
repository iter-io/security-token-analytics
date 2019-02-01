
--
-- Data Source:  https://coinmarketcap.com/currencies/ethereum/historical-data/
--

CREATE SCHEMA IF NOT EXISTS coinmarketcap;

DROP TABLE IF EXISTS coinmarketcap.ethereum_usd_price_history;

CREATE TABLE coinmarketcap.ethereum_usd_price_history (
  day        TIMESTAMP      NOT NULL,
  "open"     NUMERIC(38, 6) NOT NULL,
  high       NUMERIC(38, 6) NOT NULL,
  low        NUMERIC(38, 6) NOT NULL,
  close      NUMERIC(38, 6) NOT NULL,
  volume     NUMERIC(38, 6) NOT NULL,
  market_cap NUMERIC(38, 6) NOT NULL,
  PRIMARY KEY (day)
)
DISTSTYLE ALL
SORTKEY (day);

