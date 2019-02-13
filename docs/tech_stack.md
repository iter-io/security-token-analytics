
## Tech Stack

#### Kubernetes / EKS

Kubernetes provides cluster orchestration services for running the apps in our
data pipeline. This allows us to scale out ETL workloads and maintain availability
of services such as the Airflow scheduler and webserver.

We utilize [Amazon's EKS service](https://aws.amazon.com/eks/) for a managed 
Kubernetes control plane. The Kubernetes cluster is scaled using an [EC2 
Autoscaling Group](https://docs.aws.amazon.com/autoscaling/ec2/userguide/AutoScalingGroup.html) 
in conjunction with a [scaling policy](https://docs.aws.amazon.com/autoscaling/ec2/userguide/scaling_plan.html).
Our cluster scales in response high CPU usage and attempts to maintain a target
utilization of 70% by adding and removing nodes from the cluster.


#### Airflow

Airflow serves as a scheduler for coordinating the following pipeline tasks:

1. Running tasks to export data from Ethereum nodes using the JSON RPC API. Then 
   upload it to S3.
2. Loading output data from S3 into Redshift using the COPY command.
3. Executing SQL in Redshift to update our data models.

The Dockerfile in the root of this repository is used to build a Docker image
for Airflow that contains all dependencies and DAGs. This same image is used for 
the scheduler, webserver, and workers.

The Airflow scheduler and webserver are deployed on Kubernetes to make them 
highly available.  In the event one of these processes fails, Kubernetes will 
launch new pods in an attempt to keep them running.  This setup could also be 
used to scale out the webserver service if necessary in a large organization.  

A Postgres RDS instance is used as the backend database for Airflow.  So our 
scheduler and webserver containers are stateless and can be redeployed as 
needed.

Airflow workers are each launched in their own pod using the [Kubernetes 
Executor](https://airflow.readthedocs.io/en/stable/kubernetes.html).  Due to 
the experimental status of Airflow's Kubernetes functionality, we are building 
our image directly from the Airflow master branch (instead of a tagged release).


#### go-ethereum

[go-ethereum](https://github.com/ethereum/go-ethereum/wiki/Geth) is an ethereum 
implementation written in Go.  We run a "full archive node" containing a complete 
history of blockchain transactions. Then we export data via the 
[JSON RPC API](https://github.com/ethereum/wiki/wiki/JSON-RPC).  The goal of 
using Kubernetes to run go-ethereum is to scale the data export process by storing 
multiple copies of the blockchain and load balancing the JSON RPC API.


#### blockchain-etl

We utilize code from the [ethereum-etl project](https://github.com/blockchain-etl)
to export raw data from the blockchain.  We [forked](https://github.com/iter-io/ethereum-etl-airflow) 
the project's Airflow DAGs for GCP and added support for using them with S3 and 
Redshift on AWS.   This minimized time to market by leveraging an existing 
high-quality codebase (credit goes to [Evgeny Medvedev](https://github.com/medvedev1088) 
and [Allen Day](https://github.com/allenday)).


#### S3
S3 serves as a ["data lake"](https://aws.amazon.com/big-data/datalakes-and-analytics/what-is-a-data-lake/)
for storing exported blockchain data.  Data is loaded from S3 into Redshift using
the [COPY command](https://docs.aws.amazon.com/redshift/latest/dg/r_COPY.html)


#### Redshift

Redshift is used as a [data warehouse](https://aws.amazon.com/data-warehouse/). 
This allows us to build useful data models and run interactive queries on 
them.  Redshift was chosen because the columnar storage format is well-suited 
for aggregate queries on the historical data.  We expect this will be an 
important access pattern.


#### Grafana

Grafana is used for data visualization and presentation.  We expect our end 
users will be familiar with SQL. So using our examples they should be able to 
combine simple SQL queries into shareable dashboards.  The goal is to build a 
"self-service" system where end-users can assist us in identifying important 
metrics and improving the Redshift data models. 


#### Terraform

Terraform modules are used to provision the following AWS resources:

1.  VPC components
2.  Bastion server
3.  EKS cluster
4.  S3 buckets
5.  RDS instances
6.  Redshift cluster


#### Security

AWS IAM, VPC security groups, and Kubernetes RBAC Authorization are used to 
protect AWS resources.  The [AWS Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-paramstore.html) 
and [Kubernetes secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
are used to protect credentials and provide them to containers as environment 
variables at runtime.