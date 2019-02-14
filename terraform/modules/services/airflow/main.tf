
resource "aws_s3_bucket" "ethereum_etl_output" {
  bucket = "${var.project}-${var.environment}-ethereum-etl-output"
}

resource "aws_s3_bucket" "airflow_logs" {
  bucket = "${var.project}-${var.environment}-airflow-logs"
}

resource "kubernetes_secret" "airflow" {
  metadata {
    name = "${var.project}-${var.environment}-airflow"
  }

  data {
    AIRFLOW_CONN_AWS_DEFAULT          = "${var.airflow_conn_aws_default}"
    AIRFLOW_CONN_REDSHIFT             = "${var.airflow_conn_redshift}"
    AIRFLOW__CORE__FERNET_KEY         = "${var.airflow_core_fernet_key}"
    AIRFLOW__CORE__REMOTE_LOG_CONN_ID = "${var.airflow_core_remote_log_conn_id}"
    AIRFLOW__CORE__SQL_ALCHEMY_CONN   = "${var.airflow_core_sql_alchemy_conn}"
    AWS_ACCESS_KEY_ID                 = "${var.aws_access_key_id}"
    AWS_SECRET_ACCESS_KEY             = "${var.aws_secret_access_key}"
  }

  type = "Opaque"
}

resource "kubernetes_deployment" "airflow_webserver" {
  metadata {
    name = "${var.environment}-${var.application}-webserver"
  }

  spec {
    replicas = 3

    selector {
      match_labels {
        app = "${var.environment}-${var.application}-webserver"
      }
    }

    template {
      metadata {
        labels {
          app = "${var.environment}-${var.application}-webserver"
        }
      }

      spec {
        restart_policy = "Always"

        container = [
          {
            name = "${var.environment}-${var.application}-webserver"
            image = "772681551441.dkr.ecr.us-east-1.amazonaws.com/security-token-analytics"
            image_pull_policy = "Always"
            args = ["webserver"]

            port = [
              {
                name = "webserver"
                container_port = 8080
              }
            ]

            liveness_probe = [
              {
                http_get = {
                  path = "/"
                  port = 8080
                }
                initial_delay_seconds = 240
                period_seconds        = 60
              }
            ]

            env = [
              {
                name = "AIRFLOW_HOME"
                value = "${var.airflow_core_home}"
              },
              {
                name = "AIRFLOW__CORE__ENCRYPT_S3_LOGS"
                value = "${var.airflow_core_encrypt_s3_logs}"
              },
              {
                name = "AIRFLOW__CORE__REMOTE_BASE_LOG_FOLDER"
                value = "${var.airflow_core_remote_base_log_folder}"
              },
              {
                name = "AIRFLOW__WEBSERVER__RBAC"
                value = "${var.airflow_webserver_rbac}"
              },
              {
                name = "AIRFLOW_CONN_AWS_DEFAULT"
                value_from = {
                  secret_key_ref = {
                    key = "AIRFLOW_CONN_AWS_DEFAULT"
                    name = "${var.project}-${var.environment}-airflow"
                  }
                }
              },
              {
                name = "AIRFLOW_CONN_REDSHIFT"
                value_from = {
                  secret_key_ref = {
                    key = "AIRFLOW_CONN_REDSHIFT"
                    name = "${var.project}-${var.environment}-airflow"
                  }
                }
              },
              {
                name = "AIRFLOW__CORE__FERNET_KEY"
                value_from = {
                  secret_key_ref = {
                    key = "AIRFLOW__CORE__FERNET_KEY"
                    name = "${var.project}-${var.environment}-airflow"
                  }
                }
              },
              {
                name = "AIRFLOW__CORE__REMOTE_LOG_CONN_ID"
                value_from = {
                  secret_key_ref = {
                    key = "AIRFLOW__CORE__REMOTE_LOG_CONN_ID"
                    name = "${var.project}-${var.environment}-airflow"
                  }
                }
              },
              {
                name = "AIRFLOW__CORE__SQL_ALCHEMY_CONN"
                value_from = {
                  secret_key_ref = {
                    key = "AIRFLOW__CORE__SQL_ALCHEMY_CONN"
                    name = "${var.project}-${var.environment}-airflow"
                  }
                }
              },
              {
                name = "AWS_ACCESS_KEY_ID"
                value_from = {
                  secret_key_ref = {
                    key = "AWS_ACCESS_KEY_ID"
                    name = "${var.project}-${var.environment}-airflow"
                  }
                }
              },
              {
                name = "AWS_SECRET_ACCESS_KEY"
                value_from = {
                  secret_key_ref = {
                    key = "AWS_SECRET_ACCESS_KEY"
                    name = "${var.project}-${var.environment}-airflow"
                  }
                }
              }
            ]

            resources {
              limits {
                cpu    = "2.0"
                memory = "1024Mi"
              }
              requests {
                cpu    = "1.0"
                memory = "512Mi"
              }
            }
          }
        ]
      }
    }
  }
}

#
# Can't add this service using Terraform due to the following:
#
# https://github.com/terraform-providers/terraform-provider-kubernetes/pull/50#issue-251016641
#
# Instead use this command:
#
# eks create -f k8s/services/airflow-webserver.yaml
#

#resource "kubernetes_service" "airflow_webserver" {
#  metadata {
#    name = "${var.environment}-${var.application}-webserver"
#    annotations {
#      "service.beta.kubernetes.io/aws-load-balancer-internal" = "0.0.0.0/0"
#    }
#  }
#
#  spec {
#    selector {
#      app = "airflow"
#    }
#
#    port {
#      name = "webserver"
#      protocol = "TCP"
#      port = 8080
#      targetPort = "webserver"
#      nodePort = 32080
#    }
#
#    type = "LoadBalancer"
#  }
#}
