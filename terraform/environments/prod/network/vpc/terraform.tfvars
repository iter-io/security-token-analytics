#--------------------------------------------------------------
# Networking-related variables for "prod" environment
#--------------------------------------------------------------

project                      = "insight"
environment                  = "prod"
region                       = "us-east-1"
cidr                         = "10.0.0.0/16"
azs                          = "us-east-1a,us-east-1b"
public_subnets               = "10.0.101.0/24,10.0.102.0/24"
private_subnets              = "10.0.1.0/24,10.0.2.0/24"
enable_dns_hostnames         = true
enable_dns_support           = true
enable_nat_gateway           = false
enable_vpn_gateway           = false
create_database_subnet_group = true
