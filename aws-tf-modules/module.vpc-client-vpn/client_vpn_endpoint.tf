##########################################################
#               AWS cloudwatch log group                 #
##########################################################
resource "aws_cloudwatch_log_group" "vpn_logs" {
  name              = "${var.project}/${terraform.workspace}-vpn/logs/"
  retention_in_days = var.logs_retention_in_days
}

resource "aws_cloudwatch_log_stream" "vpn_logs_stream" {
  name           = "connection_logs"
  log_group_name = aws_cloudwatch_log_group.vpn_logs.name
}

#######################################################
#              AWS VPN client security group          #
#######################################################
resource "aws_security_group" "vpn" {
  name        = "${var.project}-${terraform.workspace}-vpn-security-group"
  description = "${var.project}-${var.environment}-vpn-security-group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, tomap({ "Name" = "${var.project}-${var.environment}-vpn-security-group" }))

}
#############################################################
#                 AWS vpn client endpoint                   #
#############################################################
resource "aws_ec2_client_vpn_endpoint" "vpn_client" {
  description            = "${var.project}-${var.environment}-vpn-client"
  server_certificate_arn = aws_acm_certificate.server_cert.arn
  vpc_id                 = data.terraform_remote_state.vpc.outputs.vpc_id
  security_group_ids     = [aws_security_group.vpn.id]
  client_cidr_block      = var.client_cidr_block
  session_timeout_hours  = var.session_timeout_hours

  split_tunnel = var.split_tunnel
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.client[0].arn
  }
  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.vpn_logs.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.vpn_logs_stream.name
  }

  tags = merge(local.common_tags, tomap({ "Name" = "${var.project}-${var.environment}-vpn-client" }))

}
resource "aws_ec2_client_vpn_network_association" "vpn_client" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_client.id
  subnet_id              = data.terraform_remote_state.vpc.outputs.private_subnets[0]
}

resource "aws_ec2_client_vpn_authorization_rule" "vpn-client" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_client.id
  target_network_cidr    = "0.0.0.0/0"
  authorize_all_groups   = true
  depends_on = [
    aws_ec2_client_vpn_endpoint.vpn_client,
    aws_ec2_client_vpn_network_association.vpn_client
  ]
}
