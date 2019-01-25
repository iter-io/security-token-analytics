
output "s3_bucket_arn_ethereum_etl_output" {
  value = "${aws_s3_bucket.ethereum_etl_output.arn}"
}

output "s3_bucket_arn_airflow_logs" {
  value = "${aws_s3_bucket.airflow_logs.arn}"
}
