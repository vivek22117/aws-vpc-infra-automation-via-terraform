resource "aws_networkfirewall_firewall_policy" "firewall_policy" {
  name = "network-firewall-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.alert_icmp_rule.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.allow_domains.arn
    }
  }
}

resource "aws_networkfirewall_rule_group" "alert_icmp_rule" {
  capacity = 100
  name     = "icmp-alert"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      stateful_rule {
        action = "ALERT"
        header {
          destination      = "ANY"
          destination_port = "ANY"
          direction        = "ANY"
          protocol         = "ICMP"
          source           = "ANY"
          source_port      = "ANY"
        }
        rule_option {
          keyword = "sid:1"
        }
      }
    }
  }

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/${aws_vpc.inspection_vpc.id}/icmp-alert"}))

}

resource "aws_networkfirewall_rule_group" "allow_domains" {
  capacity = 100
  name     = "domain-allow"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = ["10.0.0.0/16"]
        }
      }
    }
    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              =
        [
          ".wikipedia.org",
          ".google.com",
          ".amazonaws.com",
          ".microsoft.com",
          ".windowsupdate.com",
          ".windows.com",
          ".viventium.com"
        ]
      }
    }
  }

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/${aws_vpc.inspection_vpc.id}/domain-allow"}))
}


resource "aws_networkfirewall_firewall" "inspection_vpc_nt_firewall" {
  name        = "Network-Firewall"
  description = "AWS Network Firewall for VPC environment"

  vpc_id                            = aws_vpc.inspection_vpc.id
  delete_protection                 = var.delete_protection
  firewall_policy_change_protection = var.firewall_policy_change_protection
  subnet_change_protection          = var.subnet_change_protection
  firewall_policy_arn               = aws_networkfirewall_firewall_policy.firewall_policy.arn

  subnet_mapping {
    subnet_id = aws_subnet.firewall_internal_subnet.id
  }

  tags = merge(local.common_tags, tomap({ "Name" = "inspection-vpc/${data.aws_availability_zones.available.names[count.index]}/firewall" }))

}

resource "aws_cloudwatch_log_group" "firewall_alert_log_group" {
  name = "/aws/network-firewall/anfw-external/alert"
}

resource "aws_cloudwatch_log_group" "firewall_flow_log_group" {
  name = "/aws/network-firewall/anfw-external/flow"
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
        logGroup = aws_cloudwatch_log_group.firewall_flow_log_group.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
  }
}

