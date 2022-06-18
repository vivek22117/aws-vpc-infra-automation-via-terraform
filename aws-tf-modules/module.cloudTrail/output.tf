output "cloudtrail_id" {
  value       = join("", aws_cloudtrail.vpc_cloudTrail.*.id)
  description = "The name of the Cloud-trail"
}

output "cloudtrail_region" {
  value       = join("", aws_cloudtrail.vpc_cloudTrail.*.home_region)
  description = "The region in which the cloud-trail was deployed"
}

output "cloudtrail_arn" {
  value       = join("", aws_cloudtrail.vpc_cloudTrail.*.arn)
  description = "The ARN of the cloud-trail"
}

output "cloutrail_sqs_alarm_events_arn" {
  value = aws_sqs_queue.security_alerts_sqs.arn
}

output "cloutrail_sqs_alarm_events_name" {
  value = aws_sqs_queue.security_alerts_sqs.name
}