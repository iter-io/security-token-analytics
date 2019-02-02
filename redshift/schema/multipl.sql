
--
-- Data Source:  http://www.multpl.com/shiller-pe/
--
-- Stock Market Data Used in "Irrational Exuberance" Princeton University Press, 2000, 2005, 2015, updated
-- Robert J. Shiller
--

CREATE SCHEMA IF NOT EXISTS multpl;

DROP TABLE IF EXISTS multpl.shiller_pe;

CREATE TABLE multpl.shiller_pe (
  month TIMESTAMP     NOT NULL,
  value NUMERIC(8, 2) NOT NULL,
  PRIMARY KEY (month)
)
DISTSTYLE ALL
SORTKEY (month);
