default_region = "us-east-1"

team         = "Learning-Team"
owner        = "Vivek"
isMonitoring = true
project      = "CloudTrail-Monitoring"
component    = "CloudTrailManagement"

enable_log_file_validation    = true
is_multi_region_trail         = true
include_global_service_events = true
enable_trail_logging          = true
is_organization_trail         = false

log_retention = 3

s3_key_prefix = "audit"

event_selector = [{ include_management_events : true, read_write_type : "All", data_resource : [{ type : "AWS::S3::Object", values : ["arn:aws:s3:::"] }] },
{ include_management_events : true, read_write_type : "All", data_resource : [{ type : "AWS::Lambda::Function", values : ["arn:aws:lambda"] }] }]

metric_name_space = "dd-cloudtrail"
