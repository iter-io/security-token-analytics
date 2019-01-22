
resource "aws_s3_bucket" "ethereum_etl_output" {
  bucket = "${var.project}-${var.environment}-ethereum-etl-output"
}

resource "aws_s3_bucket" "airflow_logs" {
  bucket = "${var.project}-${var.environment}-airflow-logs"
}
