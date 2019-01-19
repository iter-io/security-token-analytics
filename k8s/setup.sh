#!/bin/bash


eks apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
eks apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml
eks apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml
eks apply -f eks-admin-service-account.yaml

# TODO: Figure out how we can parse the token from this command
#EKS_ADMIN_AUTH_TOKEN=$()
eks -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')
