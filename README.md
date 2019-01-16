
# security-token-analytics

##### Security token analytics with blockchain ETL on Kubernetes and Airflow.

The objective is to build a batch data pipeline to measure the development of 
security token standards and transaction levels on the Ethereum blockchain 
(e.g. [ERC 1400](https://github.com/ethereum/EIPs/issues/1411)) By combining 
Airflow with Kubernetes we will provide a platform for extracting data from 
blockchain nodes and loading it into an analytical database.  

Our system will have the following capabilities:

1. Scalability to handle exponential growth in block size.
2. Fault-tolerant pipeline to maintain data recency.
3. Reproducible analysis to support legal / regulatory use cases.
4. Security features suitable for protecting proprietary data.

It will serve as an example for how to run rapid and reproducible analyses of 
a public blockchain.  "Blockchain ETL" is a good description of this process 
and the name of the [current open source project](https://github.com/blockchain-etl) 
we utilize.  

## Tech Stack

#### Airflow

Airflow will serve as a scheduler coordinating the following pipeline tasks:

1. Running ethereum-etl commands to extract data from Ethereum nodes.
2. Loading output data into an analytical database.
3. Updating aggregate data models of our joined datasets.

High availability of the Airflow webserver and scheduler process will be 
implemented using Kubernetes deployments and load balancing features.


#### Kubernetes (k8s)

Kubernetes will provide cluster orchestration services. This will allow us to 
implement highly available Airflow webserver and scheduler processes. The 
[KubernetesPodOperator](http://airflow.apache.org/_modules/airflow/contrib/operators/kubernetes_pod_operator.html) 
will be used to scale out the Airflow tasks.  The KubernetesExecutor can also 
be utilized to scale Airflow worker processes if necessary.


#### EKS (or more succinctly the Amazon Elastic Container Service for Kubernetes)

We will utilize Amazon's EKS service for a managed k8s control plane.  The 
cluster will scale by adding additional EC2 instances as nodes in the EKS cluster.
High resource utilization will be achieved using autoscaling policies.


#### geth

[geth](https://github.com/ethereum/go-ethereum/wiki/Geth) is the command line 
interface for running a full ethereum node implemented in Go.  We will run a 
"full archive node" containing a complete history of blockchain transactions. 
Then we will extract data via the [JSON RPC API](https://github.com/ethereum/wiki/wiki/JSON-RPC).  Kubernetes 
with the intention of using it to scale the data extraction process (i.e. multiple 
copies of the blockchain and load balancing in front of the API.


#### ethereum-etl

We intend to utilize code from the 
[blockchain-etl project](https://github.com/blockchain-etl) sponsored by 
Google.  This will minimize our time to market by leveraging an existing
high-quality codebase (credit goes to [Evgeny Medvedev](https://github.com/medvedev1088) 
and [Allen Day](https://github.com/allenday)).


#### S3
S3 will serve as a ["data lake"](https://aws.amazon.com/big-data/datalakes-and-analytics/what-is-a-data-lake/)
for all extracted blockchain data.  The analytical database will either load 
data from S3 or consist of a metastore defining tables on S3.


#### Terraform

Terraform modules will be used to provision the following AWS resources:

1.  Configuring VPC components such as subnets and NAT gateways.
2.  Provisioning EKS clusters
3.  Creating S3 buckets
4.  Provisioning analytical database
5.  Restricting access to proprietary data via IAM roles and access policies


#### Logging

Initially raw log files will be pushed to S3.  Exceptions / errors will be 
logged and analyzed using separate tooling.


#### Security

AWS IAM, VPC security groups, and Kubernetes RBAC Authorization will be used to 
protect resources such as:

* Kubernetes cluster management API 
* Proprietary data on S3
* Access to the analytical database

Role-based authentication controls (RBAC) also open the door for various auth 
backends and functionally to allow admin users to dictate who has access to 
specific elements of the infrastructure.

The Kubernetes secret store will be used to protect secrets and provide them to 
containers as environment variables at runtime.


## Engineering Challenges

#### Scalability / Resource Utilization

Our Kubernetes / Airflow cluster must scale support high concurrency of Airflow 
workers and tasks.  At the same time the Airflow scheduler must backoff if 
spawning additional tasks will exceed the resource capacity.  Running a large 
number of idle nodes will lead to unacceptable costs.  So our goal is to 
maintain high resource utilization.

#### Fault-tolerance

In order to implement a fault-tolerant pipeline we must gracefully handle 
failures of the following components:

* Airflow scheduler process
* Airflow webserver process
* Airflow database
* Ethereum-etl tasks
* Geth nodes

#### Task state / DAG visibility

The current ethereum-etl project runs a sequence of tasks to extract logical
objects from the blockchain. Downstream tasks depend on the output of upstream 
tasks.  This creates a possibility that our tasks could produce different
 results on re-runs.  
 
Our challenge is make Airflow tasks as 
[functional](https://medium.com/@maximebeauchemin/functional-data-engineering-a-modern-paradigm-for-batch-data-processing-2327ec32c42a)
as possible.  Ideally our tasks will run as Kubernetes pods that are 
essentially functions of environment variables. We expect a trade-off between 
implementing "pure tasks" and maintaining the ability to track specific task 
performance and failures.

#### DAG deployments

There are operational trade-offs associated with the DAG deployment process.
The following methodologies are most prevalent:

1. Syncing a shared volume with remote storage such as git or S3
2. "Pre-baked" DAGs deployed w/ the airflow container.

#### Reproducibility 

To support legal and regulatory use cases our analysis must support some degree
of reproducibility.  For example, criminal investigations require 
[chain of custody](https://en.wikipedia.org/wiki/Chain_of_custody).  So we must
be able to repeatedly extract historical data from the blockchain to validate our 
results.  As the size of the blockchain increases, this will require a scalable 
distributed system.

#### Data security

There is a growing growing demand for joining public blockchain data on 
proprietary datasets.  As a result security features must be sufficient 
for protecting proprietary data stored on the platform.  

We specifically expect security issues related to protecting our network 
while receiving data on our blockchain nodes.  Running these nodes will 
announce our endponts to potential adversaries.  In the event one of our
nodes are compromised, we must control access to services such as S3 and
the Kubernetes cluster managemnet API.  These policies will be implemented 
using Kubernetes RBAC and AWS IAM role configuration.


#### Utilizing ethereum-etl code
 
There will be some work related to adapting this code to work on AWS in 
addition to GCP.  We intend to communicate with the core developers to
ensure that we can contribute back to the project and do not unnecessarily
fork their code.  


## Business Value

Potential use cases include:
* Platform for blockchain analytics and machine learning
* Data pipeline component for algorithmic trading engines
* Reproducible analysis / CoC for criminal investigations

## Wanna help?

Fork, improve and PR. ;-)
