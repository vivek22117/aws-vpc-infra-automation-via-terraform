resource "aws_ec2_transit_gateway" "dd_tgw" {
  description = "AWS VPC transit gateway to site-to-site VPN connectivity"

  amazon_side_asn                 = "64512"
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/tgw" }))

}

resource "aws_ec2_transit_gateway_route_table" "tgw_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.dd_tgw.id

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/tgw-route-table" }))
}

resource "aws_ec2_transit_gateway_route_table" "inspection_route_table" {
  transit_gateway_id = aws_ec2_transit_gateway.dd_tgw.id

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/inspection-route-table" }))
}

resource "aws_ec2_transit_gateway_vpc_attachment" "app_vpc_tgw_attachment" {
  transit_gateway_id                              = aws_ec2_transit_gateway.dd_tgw.id
  subnet_ids                                      = data.terraform_remote_state.vpc.outputs.tgw_subnets
  vpc_id                                          = data.terraform_remote_state.vpc.outputs.vpc_id
  transit_gateway_default_route_table_association = false

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/app_vpc_tgw_attachment" }))
}

resource "aws_ec2_transit_gateway_route_table_association" "app_vpc_tgw_attachment_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app_vpc_tgw_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_route_table.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "inspection_vpc_tgw_attachment" {
  subnet_ids                                      = aws_subnet.inspection_vpc_tgw_subnet[*].id
  transit_gateway_id                              = aws_ec2_transit_gateway.dd_tgw.id
  vpc_id                                          = aws_vpc.inspection_vpc.id
  transit_gateway_default_route_table_association = false

  appliance_mode_support = "enable"

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/tgw_inspection_vpc_attachment" }))
}

//
//resource "aws_ec2_transit_gateway_route" "spoke_route_table_default_route" {
//  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_vpc_tgw_attachment.id
//  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_route_table.id
//  destination_cidr_block         = "0.0.0.0/0"
//
//}
//
//resource "aws_ec2_transit_gateway_route_table_association" "inspection_vpc_tgw_attachment_rt_association" {
//  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_vpc_tgw_attachment.id
//  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_route_table.id
//}
//
//resource "aws_ec2_transit_gateway_route_table_propagation" "inspection_route_table_propagate_spoke_vpc_a" {
//  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_vpc_a_tgw_attachment.id
//  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_route_table.id
//}
//
//resource "aws_ec2_transit_gateway_route_table_propagation" "inspection_route_table_propagate_spoke_vpc_b" {
//  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke_vpc_b_tgw_attachment.id
//  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_route_table.id
//}
//
//resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_route_table_propagate_inspection_vpc" {
//  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_vpc_tgw_attachment.id
//  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_route_table.id
//}
