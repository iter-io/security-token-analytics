#!/bin/bash

# Update the local kube config
aws eks update-kubeconfig --name insight-prod-cluster

# Apply the auth config map so EC2 instances can join our cluster as worker nodes
eks apply -f aws-auth-cm.yaml

# Kubernetes Dashboard
eks apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

# Heapster
eks apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml

# InfluxDB
eks apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml

# Admin service account
eks apply -f eks-admin-service-account.yaml

# TODO: Figure out how we can parse the token from this command
#EKS_ADMIN_AUTH_TOKEN=$()
eks -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')

