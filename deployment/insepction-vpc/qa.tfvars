default_region = "us-east-1"

owner        = "DD-Team"
project      = "inspection-vpc"
isMonitoring = true
team         = "DD-Team"

cidr_block       = "10.0.0.0/16"
instance_tenancy = "default"
enable_dns       = true
support_dns      = true

enable_nat_gateway = true
log_retention      = 90

delete_protection                 = false
firewall_policy_change_protection = false
subnet_change_protection          = false
create_network_firewall           = true

