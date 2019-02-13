## Kubernetes setup

1.  Setup the AWS IAM authenticator:

    https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html

2.  Create a kubeconfig:

    https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html

3.  Download the aws-auth config map template:

    `curl -O https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-01-09/aws-auth-cm.yaml`

    Edit the aws-auth-cm.yaml file by adding Role ARN of the EC2 worker instances.

4.  Run our shell script k8s setup script:

    `source k8s/setup.sh`

5.  Run the proxy:

    `kubectl --context=<CLUSTER_ARN> proxy`

6. Open the Kubernetes dashboard login url in your browser:

    http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login

7. Insert the token printed by the setup.sh and click login.

8. To access internal services such as the Airflow web UI, setup a SOCKS proxy 
   using an alias such as the following:

      `alias insocks='ssh -D 8123 -f -C -q -N inprodbastion'`

9. For debugging purposes you can ssh from your local system through the bastion
   server to access any of the k8s nodes:

   `ssh -J inprodbastion ec2-user@ip-10-0-102-76.ec2.internal`

    For ease of use setup an alias such as:

    `function jumpto() { ssh -J inprodbastion ec2-user@$1; }`
