###################################################
#          Fetch TF remote state of VPC           #
###################################################
data "terraform_remote_state" "s3" {
  backend = "s3"

  config = {
    bucket = "${var.environment}-tfstate-${data.aws_caller_identity.current.account_id}-${var.default_region}"
    key    = "state/${var.environment}/s3-buckets/terraform.tfstate"
    region = var.default_region
  }
}

data "aws_caller_identity" "current" {}
