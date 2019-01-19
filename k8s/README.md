Setup the AWS IAM authenticator:

https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html

Create a kubeconfig:

https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html

Download and edit the aws-auth config map template:

`curl -O https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-01-09/aws-auth-cm.yaml`

Then run our shell script k8s setup script:

`source k8s/setup.sh`
