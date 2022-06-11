###############################################################
#         SNS Topic for user registration                     #
###############################################################
resource "aws_sns_topic" "user_registration_topic" {
  name = "Auth_Service_New_User_Notification_Topic"
}

# ------------------------------------------------------------------------------
# SNS IAM Policy
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "new_user_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.user_registration_topic.arn,
    ]
  }
}

# ------------------------------------------------------------------------------
# SNS Topic policy resource
# ------------------------------------------------------------------------------
resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.user_registration_topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

# ------------------------------------------------------------------------------
# SNS Topic subscribers resource
# ------------------------------------------------------------------------------
resource "aws_sns_topic_subscription" "sns_subscribers" {
  count = length(var.sns_email_list)

  topic_arn = aws_sns_topic.user_registration_topic.arn
  protocol  = "email"
  endpoint  = var.sns_email_list[count.index]
}
