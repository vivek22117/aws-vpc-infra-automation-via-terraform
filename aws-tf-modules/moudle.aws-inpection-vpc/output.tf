output "inspection_vpc_id" {
  value = aws_vpc.inspection_vpc.id
}

output "tgw_id" {
  value = aws_ec2_transit_gateway.dd_tgw.id
}
