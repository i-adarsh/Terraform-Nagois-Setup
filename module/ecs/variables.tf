variable "create_ecs" {
  description = "Controls if ECS should be created"
  type        = bool
  default     = true
}

variable "vpc_id" {
  type = string
  description = "description"
}

variable "name" {
  description = "Name to be used on all the resources as identifier, also the name of the ECS cluster"
  type        = string
  default     = "zqms-ecs"
}

variable "capacity_providers" {
  description = "List of short names of one or more capacity providers to associate with the cluster. Valid values also include FARGATE and FARGATE_SPOT."
  type        = list(string)
  default     = []
}

variable "default_capacity_provider_strategy" {
  description = "The capacity provider strategy to use by default for the cluster. Can be one or more."
  type        = list(map(any))
  default     = []
}

variable "container_insights" {
  description = "Controls if ECS Cluster has container insights enabled"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to ECS Cluster"
  type        = map(string)
  default     = {}
}

variable "associate_alb" {
  description = "Whether to associate an Application Load Balancer (ALB) with the ECS service."
  default     = false
  type        = bool
}

variable "associate_nlb" {
  description = "Whether to associate a Network Load Balancer (NLB) with the ECS service."
  default     = false
  type        = bool
}


variable "lb_target_groups" {
  description = "List of load balancer target group objects containing the lb_target_group_arn, container_port and container_health_check_port. The container_port is the port on which the container will receive traffic. The container_health_check_port is an additional port on which the container can receive a health check. The lb_target_group_arn is either Application Load Balancer (ALB) or Network Load Balancer (NLB) target group ARN tasks will register with."
  default     = []
  type = list(
  object({
    container_port              = number
    container_health_check_port = number
    lb_target_group_arn         = string
  }
  )
  )
}


variable "protocol_version" {
  description = "The protocol (HTTP) version."
  default     = "HTTP1"
  type        = string
}

variable "task_container_protocol" {
  description = "Protocol that the container exposes."
  default     = "HTTP"
  type        = string
}
