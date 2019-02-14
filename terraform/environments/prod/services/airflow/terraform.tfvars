application   = "airflow"
environment   = "prod"
project       = "insight"
region        = "us-east-1"

airflow_core_remote_base_log_folder = "s3://insight-prod-airflow-logs/"
airflow_core_encrypt_s3_logs        = "False"
airflow_webserver_rbac              = "False"