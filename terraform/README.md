
### Terraform

The terraform configs are split into separate directories for each environment 
and resource type. [Modules](https://www.terraform.io/docs/modules/index.html) 
are reusable components that can be deployed to multiple environments. Most of 
our config files leverage modules from the [Terraform Module Registry](https://registry.terraform.io/) instead 
of custom modules.  The goal of this approach was to minimize time to market.

* environments
    * base
        * ops
            * [ecr](https://github.com/iter-io/security-token-analytics/blob/master/terraform/environments/base/ops/ecr/ecr.tf)
    * prod
        * compute
            * [eks](https://github.com/iter-io/security-token-analytics/blob/master/terraform/environments/prod/compute/eks/eks.tf)
        * data
            * [rds-airflow](https://github.com/iter-io/security-token-analytics/blob/master/terraform/environments/prod/data/rds-airflow/rds-airflow.tf)
            * [rds-grafana](https://github.com/iter-io/security-token-analytics/blob/master/terraform/environments/prod/data/rds-grafana/rds-grafana.tf)
            * [rds-superset](https://github.com/iter-io/security-token-analytics/blob/master/terraform/environments/prod/data/rds-superset/rds-superset.tf)
            * [redshift](https://github.com/iter-io/security-token-analytics/blob/master/terraform/environments/prod/data/redshift/redshift.tf)
        * network
            * [bastion](https://github.com/iter-io/security-token-analytics/blob/master/terraform/environments/prod/network/bastion/bastion.tf)
            * [vpc](https://github.com/iter-io/security-token-analytics/blob/master/terraform/environments/prod/network/vpc/vpc.tf)
        * services
            * [airflow](https://github.com/iter-io/security-token-analytics/blob/master/terraform/environments/prod/services/airflow/airflow.tf)
            * [grafana](https://github.com/iter-io/security-token-analytics/blob/master/terraform/environments/prod/services/grafana/grafana.tf)
* modules
    * services
        * [airflow](https://github.com/iter-io/security-token-analytics/blob/master/terraform/modules/services/airflow/main.tf)
