variable "application" { }
variable "environment" { }
variable "project"     { }
variable "region"      { }


variable "airflow_conn_aws_default"               { }
variable "airflow_conn_redshift"                  { }
variable "airflow_core_encrypt_s3_logs"           { }
variable "airflow_core_fernet_key"                { }
variable "airflow_core_home"                      { default = "/usr/local/airflow"}
variable "airflow_core_remote_base_log_folder"    { }
variable "airflow_core_remote_log_conn_id"        { }
variable "airflow_core_sql_alchemy_conn"          { }
variable "airflow_webserver_rbac"                 { }
variable "aws_access_key_id"                      { }
variable "aws_secret_access_key"                  { }