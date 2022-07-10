data "aws_availability_zones" "available" {}

locals {
  list_of_azs = data.aws_availability_zones.available.names

  total_azs = length(data.aws_availability_zones.available.names)
  used_azs  = local.total_azs > 3 ? 3 : local.total_azs
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

resource "aws_subnet" "inspection_vpc_public_subnet" {
  count = length(data.aws_availability_zones.available.names)

  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.inspection_vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(var.cidr_block, 8, 10 + count.index)

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/${data.aws_availability_zones.available.names[count.index]}/public-subnet" }))
}

//
//resource "aws_subnet" "inspection_vpc_firewall_subnet" {
//  count                   = length(data.aws_availability_zones.available.names)
//  map_public_ip_on_launch = false
//  vpc_id                  = aws_vpc.inspection_vpc.id
//  availability_zone       = data.aws_availability_zones.available.names[count.index]
//  cidr_block              = cidrsubnet(local.inspection_vpc_cidr, 8, 20 + count.index)
//  tags = {
//    Name = "inspection-vpc/${data.aws_availability_zones.available.names[count.index]}/firewall-subnet"
//  }
//}
//

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

  count = var.enable_nat_gateway == "true" ? 1 : 0
  vpc   = true
  tags = {
    Name = "eip-${var.environment}-${aws_vpc.inspection_vpc.id}-${count.index}"
  }
}

#################################################
#       Create NatGateway and allocate EIP      #
#################################################
resource "aws_nat_gateway" "inspection_vpc_nat_gw" {
  depends_on = [aws_internet_gateway.inspection_vpc_igw, aws_subnet.inspection_vpc_public_subnet]

  count = length(data.aws_availability_zones.available.names)

  allocation_id = aws_eip.inspection_vpc_nat_eip.*.id[count.index]
  subnet_id     = aws_subnet.inspection_vpc_public_subnet[count.index].id

  tags = {
    Name = "inspection-vpc/${data.aws_availability_zones.available.names[count.index]}/nat-gateway"
  }
}


