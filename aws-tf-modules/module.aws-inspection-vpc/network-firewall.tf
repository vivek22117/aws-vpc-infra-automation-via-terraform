resource "aws_cloudwatch_log_group" "firewall_alert_log_group" {
  name              = "/aws/network-firewall/alert"
  retention_in_days = var.log_retention
}

resource "random_string" "bucket_random_id" {
  length  = 5
  special = false
  upper   = false
}

resource "aws_s3_bucket" "firewall_flow_bucket" {
  bucket        = "network-firewall-flow-bucket-${random_string.bucket_random_id.id}"
  acl           = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "firewall_flow_bucket_public_access_block" {
  bucket = aws_s3_bucket.firewall_flow_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_networkfirewall_logging_configuration" "firewall_alert_logging_configuration" {
  firewall_arn = aws_networkfirewall_firewall.inspection_vpc_nt_firewall.arn

  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_alert_log_group.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
    log_destination_config {
      log_destination = {
        bucketName = aws_s3_bucket.firewall_flow_bucket.bucket
      }
      log_destination_type = "S3"
      log_type             = "FLOW"
    }
  }
}

resource "aws_networkfirewall_firewall_policy" "firewall_policy" {
  name = "network-firewall-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateless_rule_group_reference = {
      priority     = 20
      resource_arn = aws_networkfirewall_rule_group.drop_icmp.arn
    }

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.block_domains.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.block_public_dns_resolvers.arn
    }
  }
}

resource "aws_networkfirewall_rule_group" "drop_icmp" {
  capacity = 1
  name     = "drop-icmp"
  type     = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              protocols = [1]
              source {
                address_definition = "0.0.0.0/0"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_networkfirewall_rule_group" "block_public_dns_resolvers" {
  capacity = 1
  name     = "block-public-dns"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      stateful_rule {
        action = "DROP"
        header {
          destination      = "ANY"
          destination_port = "ANY"
          direction        = "ANY"
          protocol         = "DNS"
          source           = "ANY"
          source_port      = "ANY"
        }
        rule_option {
          keyword = "sid:50"
        }
      }
    }
  }
}

resource "aws_networkfirewall_rule_group" "block_domains" {
  capacity = 100
  name     = "block-domains"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = ["10.0.0.0/16", "10.1.0.0/16", "192.0.2.0/24"]
        }
      }
    }
    rules_source {
      rules_source_list {
        generated_rules_type = "DENYLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = [".facebook.com", ".twitter.com", ".bad-omain.org", ".evil-domain.com"]
      }
    }
  }
}

resource "aws_networkfirewall_rule_group" "allow_domains" {
  capacity = 100
  name     = "allow-domains"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "WEBSERVERS_HOSTS"
        ip_set {
          definition = ["10.0.1.0/24", "192.168.0.0/16"]
        }
      }
      port_sets {
        key = "HTTP_PORTS"
        port_set {
          definition = ["443", "80"]
        }
      }
    }
    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = [".wikipedia.org"]
      }
    }
  }
}

resource "aws_networkfirewall_firewall" "inspection_vpc_nt_firewall" {
  name        = "DD-Inspection-Network-Firewall"
  description = "AWS Network Firewall for DD environment"

  vpc_id                            = aws_vpc.inspection_vpc.id
  delete_protection                 = var.delete_protection
  firewall_policy_change_protection = var.firewall_policy_change_protection
  subnet_change_protection          = var.subnet_change_protection
  firewall_policy_arn               = aws_networkfirewall_firewall_policy.firewall_policy.arn

  dynamic "subnet_mapping" {
    for_each = aws_subnet.inspection_vpc_firewall_subnet[*].id

    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/${data.aws_availability_zones.available.names[count.index]}/nt-firewall" }))
}
