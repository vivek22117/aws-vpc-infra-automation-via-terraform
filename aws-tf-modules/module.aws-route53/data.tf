###################################################
# Fetch remote state for S3 deployment bucket     #
###################################################
data "terraform_remote_state" "cognito_userpool" {
  backend = "s3"

  config = {
    bucket = "${var.environment}-tfstate-${data.aws_caller_identity.current.account_id}-${var.default_region}"
    key    = "state/${var.environment}/cognito-userpool/terraform.tfstate"
    region = var.default_region
  }
}

# used for accessing Account ID and ARN
data "aws_caller_identity" "current" {}
