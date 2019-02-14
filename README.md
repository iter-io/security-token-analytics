
# security-token-analytics

### Overview

This project uses blockchain data to provide a platform for financial analysis 
of crypto assets.  In particular we are researching in 
emerging standards for [security tokens](https://github.com/ethereum/EIPs/issues/1411) 
and potential methods of fundamental analysis.

Our system will has the following capabilities:

1. Scalability to handle exponential growth in blockchain data size.
2. Fault-tolerance to maintain data recency.
3. Security features suitable for protecting proprietary data.

It will serve as an example for how to build a data pipeline for analyzing
public blockchains.

## Documentation

### Table of Contents
1.  [Getting Started](/docs/getting_started.md)
2.  [Setting up Kubernetes / EKS](/k8s/README.md)
3.  [Airflow DAGs](/airflow/README.md)
4.  [Tech Stack](/docs/tech_stack.md)
5.  [Engineering Challenges](/docs/challenges.md)


### High-level Architecture
![alt text](docs/img/tech_stack.png)


Potential use cases include:
* Platform for blockchain analytics and machine learning
* Data pipeline component for algorithmic trading engines
* Reproducible analysis / CoC for criminal investigations
