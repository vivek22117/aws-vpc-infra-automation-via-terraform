#!/usr/bin/env bash

echo ECS_CLUSTER=${health_monitoring_cluster} >> /etc/ecs/ecs.config
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config

# To enable IAM roles for tasks in containers with bridge and default network modes, set ECS_ENABLE_TASK_IAM_ROLE to true. See the following example:
echo ECS_ENABLE_TASK_IAM_ROLE=true >> /etc/ecs/ecs.config

# To enable IAM roles for tasks in containers with the host network mode, set ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST to true. See the following example:
echo ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true >> /etc/ecs/ecs.config

ECS_IMAGE_PULL_BEHAVIOR=always >> /etc/ecs/ecs.config


USED_MEMORY=$(free -m | awk 'NR==2{printf "%.2f\t", $3*100/$2 }')
TCP_CONN=$(netstat -an | wc -l)
TCP_CONN_PORT_80=$(netstat -an | grep 80 | wc -l)
TCP_CONN_PORT_443=$(netstat -an | grep 443 | wc -l)
USERS=$(uptime | awk '{ print $6 }')
IO_WAIT=$(iostat | awk 'NR==4 {print $5}')
INSTANCE_ID=$(wget -q -O- http://169.254.169.254/latest/meta-data/instance-id)

aws cloudwatch put-metric-data --metric-name memory-usage --dimensions Instance=$INSTANCE_ID \
--namespace "Custom" --value $USED_MEMORY

aws cloudwatch put-metric-data --metric-name TCP_Connections --dimensions Instance=$INSTANCE_ID \
--namespace "Custom" --value $TCP_CONN

aws cloudwatch put-metric-data --metric-name TCP_Connections_Port_80 --dimensions Instance=$INSTANCE_ID \
--namespace "Custom" --value $TCP_CONN_PORT_80

aws cloudwatch put-metric-data --metric-name TCP_Connections_Port_443 --dimensions Instance=$INSTANCE_ID \
--namespace "Custom" --value $TCP_Connections_Port_443

aws cloudwatch put-metric-data --metric-name No_Of_Users --dimensions Instance=$INSTANCE_ID \
--namespace "Custom" --value $USERS

aws cloudwatch put-metric-data --metric-name IO_Wait --dimensions Instance=$INSTANCE_ID \
--namespace "Custom" --value $IO_WAIT
