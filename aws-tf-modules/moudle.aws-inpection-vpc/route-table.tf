##############################################################################
#               Inspection VPC TGW RouteTable & its Association              #
##############################################################################
resource "aws_route_table" "inspection_vpc_tgw_subnet_route_table" {
  count = local.used_azs

  vpc_id = aws_vpc.inspection_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    # https://github.com/hashicorp/terraform-provider-aws/issues/16759
    vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.inspection_vpc_nt_firewall.firewall_status.sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.inspection_vpc_firewall_subnet[count.index].id], 0)
  }
  tags = {
    Name = "inspection-vpc/${data.aws_availability_zones.available.names[count.index]}/tgw-subnet-route-table"
  }
}

resource "aws_route_table_association" "inspection_vpc_tgw_subnet_route_table_association" {
  count = local.used_azs

  route_table_id = aws_route_table.inspection_vpc_tgw_subnet_route_table[count.index].id
  subnet_id      = aws_subnet.inspection_vpc_tgw_subnet[count.index].id
}

###################################################################################
#               Inspection VPC Firewall RouteTable & its Association              #
###################################################################################
resource "aws_route_table" "inspection_vpc_firewall_subnet_route_table" {
  count = local.used_azs

  vpc_id = aws_vpc.inspection_vpc.id
  route {
    cidr_block         = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.inspection_vpc_nat_gw[count.index].id
  }
  tags = {
    Name = "inspection-vpc/${data.aws_availability_zones.available.names[count.index]}/firewall-subnet-route-table"
  }
}

resource "aws_route_table_association" "inspection_vpc_firewall_subnet_route_table_association" {
  count = local.used_azs

  route_table_id = aws_route_table.inspection_vpc_firewall_subnet_route_table[count.index].id
  subnet_id      = aws_subnet.inspection_vpc_firewall_subnet[count.index].id
}

#################################################################################
#               Inspection VPC Public RouteTable & its Association              #
#################################################################################
resource "aws_route_table" "inspection_vpc_public_subnet_route_table" {
  count = local.used_azs

  vpc_id = aws_vpc.inspection_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.inspection_vpc_igw.id
  }
  route {
    cidr_block      = "10.0.0.0/8"
    vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.inspection_vpc_nt_firewall.firewall_status.sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.inspection_vpc_firewall_subnet[count.index].id], 0)
  }
  tags = {
    Name = "inspection-vpc/${data.aws_availability_zones.available.names[count.index]}/public-subnet-route-table"
  }
}

resource "aws_route_table_association" "inspection_vpc_public_subnet_route_table_association" {
  count = local.used_azs

  route_table_id = aws_route_table.inspection_vpc_public_subnet_route_table[count.index].id
  subnet_id      = aws_subnet.inspection_vpc_public_subnet[count.index].id
}
