#!/usr/bin/env bash

echo ECS_CLUSTER=${health_monitoring_cluster} >> /etc/ecs/ecs.config
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config

# To enable IAM roles for tasks in containers with bridge and default network modes, set ECS_ENABLE_TASK_IAM_ROLE to true. See the following example:
echo ECS_ENABLE_TASK_IAM_ROLE=true >> /etc/ecs/ecs.config

# To enable IAM roles for tasks in containers with the host network mode, set ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST to true. See the following example:
echo ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true >> /etc/ecs/ecs.config

ECS_IMAGE_PULL_BEHAVIOR=always >> /etc/ecs/ecs.config
