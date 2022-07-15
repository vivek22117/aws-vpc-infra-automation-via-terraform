data "aws_availability_zones" "available" {}

locals {
  list_of_azs = ["us-east-1a", "us-east-1b"]
  total_azs   = length(local.list_of_azs)
}

#################################################
#       VPC Configuration                       #
#################################################
resource "aws_vpc" "inspection_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.support_dns


  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc-${var.environment}-${var.cidr_block}" }))
}

resource "aws_subnet" "public_admin_subnet" {
  vpc_id                  = aws_vpc.inspection_vpc.id
  availability_zone       = local.list_of_azs[0]
  map_public_ip_on_launch = true
  cidr_block              = "10.0.32.0/22"

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/${aws_vpc.inspection_vpc.id}/public-admin-subnet" }))
}

resource "aws_subnet" "private_admin_subnet" {
  vpc_id                  = aws_vpc.inspection_vpc.id
  availability_zone       = local.list_of_azs[0]
  map_public_ip_on_launch = false
  cidr_block              = "10.0.0.48/28"

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/${aws_vpc.inspection_vpc.id}/private-admin-subnet" }))
}


#######################################################
# Enable access to or from the Internet for instances #
# in public subnets using IGW                         #
#######################################################
resource "aws_internet_gateway" "inspection_vpc_igw" {
  vpc_id = aws_vpc.inspection_vpc.id

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/igw" }))
}

######################################################
# NAT gateways  enable instances in a private subnet #
# to connect to the Internet or other AWS services,  #
# but prevent the internet from initiating           #
# a connection with those instances.                 #
#                                                    #
# Each NAT gateway requires an Elastic IP.           #
######################################################
resource "aws_eip" "inspection_vpc_nat_eip" {
  depends_on = [aws_internet_gateway.inspection_vpc_igw]

  vpc = true
  tags = {
    Name = "eip-${var.environment}-${aws_vpc.inspection_vpc.id}-${count.index}"
  }
}


#################################################
#       Create NatGateway and allocate EIP      #
#################################################
resource "aws_nat_gateway" "inspection_vpc_nat_gw" {
  depends_on = [aws_internet_gateway.inspection_vpc_igw, aws_subnet.public_admin_subnet]

  allocation_id = aws_eip.inspection_vpc_nat_eip.id
  subnet_id     = aws_subnet.public_admin_subnet.id

  tags = {
    Name = "inspection-vpc/${aws_vpc.inspection_vpc.id}/nat-gateway"
  }
}

######################################################
#       Create private subnets for DB, AD, Apps      #
######################################################
resource "aws_subnet" "private_db_subnet" {
  vpc_id                  = aws_vpc.inspection_vpc.id
  map_public_ip_on_launch = false
  availability_zone       = local.list_of_azs[0]
  cidr_block              = "10.0.8.0/22"

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/${aws_vpc.inspection_vpc.id}/private-db-subnet" }))
}

resource "aws_subnet" "private_ad_subnet" {
  vpc_id                  = aws_vpc.inspection_vpc.id
  map_public_ip_on_launch = false
  availability_zone       = local.list_of_azs[0]
  cidr_block              = "10.0.12.0/22"

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/${aws_vpc.inspection_vpc.id}/private-ad-subnet-1" }))
}

resource "aws_subnet" "private_ad_subnet_2" {
  vpc_id                  = aws_vpc.inspection_vpc.id
  map_public_ip_on_launch = false
  availability_zone       = local.list_of_azs[1]
  cidr_block              = "10.0.36.0/22"

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/${aws_vpc.inspection_vpc.id}/private-ad-subnet-2" }))
}

resource "aws_subnet" "private_apps_subnet" {
  vpc_id                  = aws_vpc.inspection_vpc.id
  map_public_ip_on_launch = false
  availability_zone       = local.list_of_azs[0]
  cidr_block              = "10.0.16.0/22"

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/${aws_vpc.inspection_vpc.id}/private-apps-subnet" }))
}

resource "aws_subnet" "private_outbound_subnet" {
  vpc_id                  = aws_vpc.inspection_vpc.id
  map_public_ip_on_launch = false
  availability_zone       = local.list_of_azs[0]
  cidr_block              = "10.0.4.0/22"

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/${aws_vpc.inspection_vpc.id}/private-outbound-subnet" }))
}

resource "aws_subnet" "private_cloudEndure_subnet" {
  vpc_id                  = aws_vpc.inspection_vpc.id
  map_public_ip_on_launch = false
  availability_zone       = local.list_of_azs[0]
  cidr_block              = "10.0.28.0/22"

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/${aws_vpc.inspection_vpc.id}/private-cloudendure-subnet" }))
}

######################################################
#       Create public subnets for webapps            #
######################################################
resource "aws_subnet" "public_web_subnet" {
  vpc_id                  = aws_vpc.inspection_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = local.list_of_azs[0]
  cidr_block              = "10.0.20.0/22"

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/${aws_vpc.inspection_vpc.id}/public-web-subnet" }))
}

resource "aws_subnet" "public_brist_subnet" {
  vpc_id                  = aws_vpc.inspection_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = local.list_of_azs[0]
  cidr_block              = "10.0.24.0/22"

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/${aws_vpc.inspection_vpc.id}/public-brist-subnet" }))
}

######################################################
#         Firewall Internal Subnets                  #
######################################################
resource "aws_subnet" "firewall_internal_subnet" {
  vpc_id                  = aws_vpc.inspection_vpc.id
  map_public_ip_on_launch = false
  availability_zone       = local.list_of_azs[0]
  cidr_block              = "10.0.0.16/28"

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/${aws_vpc.inspection_vpc.id}/internal-firewall-subnet" }))
}


resource "aws_subnet" "inspection_vpc_tgw_subnet" {
  count = length(data.aws_availability_zones.available.names)

  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.inspection_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(var.cidr_block, 8, 30 + count.index)

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/${data.aws_availability_zones.available.names[count.index]}/tgw-subnet" }))
}
