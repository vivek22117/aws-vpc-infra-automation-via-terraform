############################################
#       CloudTrail Configuration           #
############################################
resource "aws_cloudtrail" "vpc_cloudTrail" {

  depends_on = [
    aws_cloudwatch_log_group.cloudtrail_logGroup,
    aws_s3_bucket_policy.s3_bucket_trail_policy
  ]

  name                          = "${var.environment}-CloudTrail"
  enable_logging                = var.enable_trail_logging
  is_multi_region_trail         = var.is_multi_region_trail
  include_global_service_events = var.include_global_service_events
  is_organization_trail         = var.is_organization_trail

  s3_bucket_name             = data.terraform_remote_state.s3.outputs.cloudtrail_s3_name
  s3_key_prefix              = var.s3_key_prefix
  enable_log_file_validation = var.enable_log_file_validation

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail_logGroup.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrial_logs_access_role.arn

  tags = merge(local.common_tags, map("Name", "${var.environment}-CloudTrail"))

  dynamic "event_selector" {
    for_each = var.event_selector
    content {
      include_management_events = lookup(event_selector.value, "include_management_events", null)
      read_write_type           = lookup(event_selector.value, "read_write_type", null)

      dynamic "data_resource" {
        for_each = lookup(event_selector.value, "data_resource", [])
        content {
          type   = data_resource.value.type
          values = data_resource.value.values
        }
      }
    }
  }
}


####################################################################################
# Setup cloudwatch logs to receive cloudtrail events and audit filter for alarms   #
####################################################################################
resource "aws_cloudwatch_log_group" "cloudtrail_logGroup" {
  name = "dd-cloudtrail"

  retention_in_days = var.log_retention
  tags              = local.common_tags
}

####=========watch for use of the root account============#####
resource "aws_cloudwatch_log_metric_filter" "root_login" {
  name = "root-access"

  pattern        = "{$.userIdentity.type = Root}"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_logGroup.name

  metric_transformation {
    name      = "RootAccessCount"
    namespace = var.metric_name_space
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_login_alarm" {
  alarm_name          = "root-access-${var.default_region}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "RootAccessCount"
  namespace           = var.metric_name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Use of the root account has been detected"
  alarm_actions       = [aws_sns_topic.security_alerts_sns.arn]
}


#####==========Watch for use of the console without MFA===========#####
resource "aws_cloudwatch_log_metric_filter" "console_without_mfa" {
  name = "console-without-mfa"

  pattern        = "{$.eventName = ConsoleLogin && $.additionalEventData.MFAUsed = No}"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_logGroup.name

  metric_transformation {
    name      = "ConsoleWithoutMFACount"
    namespace = var.metric_name_space
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "console_without_mfa" {
  alarm_name          = "console-without-mfa-${var.default_region}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ConsoleWithoutMFACount"
  namespace           = var.metric_name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Use of the console by an account without MFA has been detected"
  alarm_actions       = [aws_sns_topic.security_alerts_sns.arn]
}


#####===========look for key alias changes or key deletions========#####
resource "aws_cloudwatch_log_metric_filter" "illegal_key_use" {
  name = "key-changes"

  pattern        = "{$.eventSource = kms.amazonaws.com && ($.eventName = DeleteAlias || $.eventName = DisableKey)}"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_logGroup.name

  metric_transformation {
    name      = "KeyChangeOrDelete"
    namespace = var.metric_name_space
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "illegal_key_use" {
  alarm_name          = "key-changes-${var.default_region}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "KeyChangeOrDelete"
  namespace           = var.metric_name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "A key alias has been changed or a key has been deleted"
  alarm_actions       = [aws_sns_topic.security_alerts_sns.arn]
}


#####============look for changes to security groups================#####
resource "aws_cloudwatch_log_metric_filter" "security_group_change" {
  name = "security-group-changes"

  pattern        = "{ $.eventName = AuthorizeSecurityGroup* || $.eventName = RevokeSecurityGroup* || $.eventName = CreateSecurityGroup || $.eventName = DeleteSecurityGroup }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_logGroup.name

  metric_transformation {
    name      = "SecurityGroupChanges"
    namespace = var.metric_name_space
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "security_group_change" {
  alarm_name          = "security-group-changes-${var.default_region}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "SecurityGroupChanges"
  namespace           = var.metric_name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Security groups have been changed"
  alarm_actions       = [aws_sns_topic.security_alerts_sns.arn]
}


#####========look for changes to IAM resources================#####
resource "aws_cloudwatch_log_metric_filter" "iam_change" {
  name = "iam-changes"

  pattern        = "{$.eventSource = iam.* && $.eventName != Get* && $.eventName != List*}"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_logGroup.name

  metric_transformation {
    name      = "IamChanges"
    namespace = var.metric_name_space
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "iam_change" {
  alarm_name          = "iam-changes-${var.default_region}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "IamChanges"
  namespace           = var.metric_name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "IAM Resources have been changed"
  alarm_actions       = [aws_sns_topic.security_alerts_sns.arn]
}


#####=============look for changes to route table resources================#####
resource "aws_cloudwatch_log_metric_filter" "routetable_change" {
  name = "route-table-changes"

  pattern        = "{$.eventSource = ec2.* && ($.eventName = AssociateRouteTable || $.eventName = CreateRoute* || $.eventName = CreateVpnConnectionRoute || $.eventName = DeleteRoute* || $.eventName = DeleteVpnConnectionRoute || $.eventName = DisableVgwRoutePropagation || $.eventName = DisassociateRouteTable || $.eventName = EnableVgwRoutePropagation || $.eventName = ReplaceRoute*)}"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_logGroup.name

  metric_transformation {
    name      = "RouteTableChanges"
    namespace = var.metric_name_space
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "routetable_change" {
  alarm_name          = "route-table-changes-${var.default_region}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "RouteTableChanges"
  namespace           = var.metric_name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Route Table Resources have been changed"
  alarm_actions       = [aws_sns_topic.security_alerts_sns.arn]
}


#####========look for changes to NACL===================#####
resource "aws_cloudwatch_log_metric_filter" "nacl_change" {
  name = "nacl-changes"

  pattern        = "{$.eventSource = ec2.* && ($.eventName = CreateNetworkAcl* || $.eventName = DeleteNetworkAcl* || $.eventName = ReplaceNetworkAcl*)}"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_logGroup.name

  metric_transformation {
    name      = "NaclChanges"
    namespace = var.metric_name_space
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "nacl_change" {
  alarm_name          = "nacl-changes-${var.default_region}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "NaclChanges"
  namespace           = var.metric_name_space
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "NACL have been changed"
  alarm_actions       = [aws_sns_topic.security_alerts_sns.arn]
}


#######################################################
# SetUp SNS for notification and alarm configuration  #
#######################################################
resource "aws_sns_topic" "security_alerts_sns" {
  name            = "security_alerts_topic_${var.environment}_${var.default_region}"
  delivery_policy = <<JSON
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget"    : 20,
      "maxDelayTarget"    : 600,
      "numRetries"        : 5,
      "backoffFunction"   : "exponential"
    },
    "disableSubscriptionOverrides": false
  }
}
JSON
}

resource "aws_sns_topic_subscription" "security_alerts_to_sqs" {
  depends_on = [aws_sqs_queue.security_alerts_sqs]

  topic_arn            = aws_sns_topic.security_alerts_sns.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.security_alerts_sqs.arn
  raw_message_delivery = true
}

resource "aws_sqs_queue" "security_alerts_sqs" {
  name = "security_alerts_${var.environment}_${var.default_region}"

  redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.security_alerts_dlq.arn}\",\"maxReceiveCount\":5}"
  visibility_timeout_seconds = 300
}

resource "aws_sqs_queue" "security_alerts_dlq" {
  name = "security_alerts_dlq_${var.environment}_${var.default_region}"
}

resource "aws_sqs_queue_policy" "security_alerts_queue_policy" {
  queue_url = aws_sqs_queue.security_alerts_sqs.id

  policy = templatefile("${path.module}/scripts/sqs-access-policy.json", {
    security_sqs_arn = aws_sqs_queue.security_alerts_sqs.arn
    security_sns_arn = aws_sns_topic.security_alerts_sns.arn
  })
}
