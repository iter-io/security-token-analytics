## Getting Started


#### Step #1 - Install Docker

Mac OS X:
  1. `brew install docker`

Ubuntu Linux:
  1.  Install [Docker CE](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/)

  2.  To use docker without root credentials, create a docker group:

      ```bash
        sudo groupadd docker
      ```

      Then add your user to this group:
      ```bash
        sudo usermod -aG docker $USER
      ```

      You can read more in the [official docker documentation](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user).

  3.  Log out and then log in again to re-evaluate your groups.


#### Step #2 - Install the aws-cli


1.  Install the [AWS-CLI](http://docs.aws.amazon.com/cli/latest/userguide/awscli-install-linux.html).

2.  Download your AWS login and keypair from the IAM console.

3.  Run `aws configure` and input your credentials.

4.  Now you can use your Docker client authenticate with [AWS ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html):  

  ```bash
    eval $(aws ecr get-login --no-include-email)
  ```

  You should also add this alias to your bash profile:
  ```bash
    alias ecrlogin='eval $(aws ecr get-login --no-include-email)'
  ```

  In the future you can authenticate yourself with ECR using this command:
  ```bash
  ecrlogin
  ```


#### Step #3 - Install Terraform

Follow the [getting started guide](https://learn.hashicorp.com/terraform/getting-started/install.html#installing-terraform) 
from Hashicorp.


#### Step #4 - Install kube-ctl

Follow the [task doc](https://kubernetes.io/docs/tasks/tools/install-kubectl/) 
on kubernetes.io.
   

#### Step #5 - Use Terraform to provision the base environment and prod network

Apply the following Terraform configs:

* environments
    * base
        * ops
            * [ecr](https://github.com/iter-io/security-token-analytics/blob/master/terraform/environments/base/ops/ecr/ecr.tf)
    * prod
        * compute
            * [eks](https://github.com/iter-io/security-token-analytics/blob/master/terraform/environments/prod/compute/eks/eks.tf)
        * network
            * [bastion](https://github.com/iter-io/security-token-analytics/blob/master/terraform/environments/prod/network/bastion/bastion.tf)
            * [vpc](https://github.com/iter-io/security-token-analytics/blob/master/terraform/environments/prod/network/vpc/vpc.tf)

Here's the example commands for the EKS config:

```
cd terraform/environments/prod/compute/eks
terraform init
terraform apply
```

Repeat this for each of the configs above.


#### Step #6 - Setup EKS / Kubernetes

Follow the [setup guide](https://github.com/iter-io/security-token-analytics/blob/master/k8s/README.md) 
in this repo.


#### Step #7 - Build and deploy the Airflow container

Run `make build_docker` in the project root.


#### Step #8 - Use Terraform to provision the prod databases and services

* environments
    * prod
        * data
            * [rds-airflow](https://github.com/iter-io/security-token-analytics/blob/master/terraform/environments/prod/data/rds-airflow/rds-airflow.tf)
            * [rds-grafana](https://github.com/iter-io/security-token-analytics/blob/master/terraform/environments/prod/data/rds-grafana/rds-grafana.tf)
            * [rds-superset](https://github.com/iter-io/security-token-analytics/blob/master/terraform/environments/prod/data/rds-superset/rds-superset.tf)
            * [redshift](https://github.com/iter-io/security-token-analytics/blob/master/terraform/environments/prod/data/redshift/redshift.tf)
        * services
            * [airflow](https://github.com/iter-io/security-token-analytics/blob/master/terraform/environments/prod/services/airflow/airflow.tf)
            * [grafana](https://github.com/iter-io/security-token-analytics/blob/master/terraform/environments/prod/services/grafana/grafana.tf)


#### Step #9 - Create the schema and users in Redshift

1.  Use psql to create the Redshift schemas:
 
    * [ethereum schema](https://github.com/iter-io/ethereum-etl-airflow/blob/feature-aws/dags/resources/stages/raw/schemas_redshift/schema.sql)
    * [3rd party schemas](https://github.com/iter-io/security-token-analytics/tree/master/redshift/schema)
   
2.  Use psql to run [users.sql](https://github.com/iter-io/security-token-analytics/blob/master/redshift/users.sql) 
    for setting up the Redshift user accounts.