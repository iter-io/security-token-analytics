application                         = "airflow"
project                             = "insight"
environment                         = "prod"
region                              = "us-east-1"

allocated_storage                   = "20"
allow_major_version_upgrade         = "false"
apply_immediately                   = "true"
auto_minor_version_upgrade          = "true"
backup_retention_period             = "14"
backup_window                       = "03:00-06:00"
create_db_instance                  = "true"
create_db_option_group              = false
create_db_parameter_group           = false
create_db_subnet_group              = false
create_monitoring_role              = "true"
deletion_protection                 = "false"
engine                              = "postgres"
engine_version                      = "10.6"
family                              = "postgres10"
iam_database_authentication_enabled = "false"
instance_class                      = "db.t3.micro"
iops                                = "0"
maintenance_window                  = "Mon:00:00-Mon:03:00"
major_engine_version                = "10.6"
monitoring_interval                 = "5"
multi_az                            = "false"
port                                = "5432"
publicly_accessible                 = "false"
skip_final_snapshot                 = "false"
storage_encrypted                   = "false"
storage_type                        = "gp2"