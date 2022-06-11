sg_name  = "auth-service-sg"
username = "doubledigit"
password = "password"

enabled = true

sub_group_name    = "auth-service-subnet-group"
cluster_prefix    = "auth-service"
azs               = ["us-east-1a", "us-east-1b", "us-east-1c"]
db_engine         = "aurora-postgresql"
db_engine_version = "10.14"
db_engine_mode    = "serverless"
database_name     = "auth_service"
secret_version    = "v1"

skip_final_snapshot          = true
backup_retention_period      = "1"
preferred_backup_window      = "02:00-03:00"
preferred_maintenance_window = "sun:05:00-sun:06:00"
apply_immediately            = false
scaling_auto_pause           = true
max_capacity                 = 4
min_capacity                 = 2
auto_pause_secs              = 900

sns_email_list = ["vivekmishra22117@gmail.com"]
