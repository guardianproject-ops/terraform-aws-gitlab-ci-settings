variable "region" {
  type        = string
  description = "region to create the test environment in"
}

variable "vpc_cidr_block" {
  default     = "172.17.0.0/16"
  description = "internal ip block the VPC should use"
}

variable "vpc_subnet_cidr_block" {
  type        = string
  default    = "172.17.1.0/24"
  description = "internal ip block the VPC subnet should use. Must be contained in `vpc_cidr_block`"
}
variable "vpc_subnet_az" {
  description = "the availability zone to place the CI subnet in"
  type        = string
}

variable "gitlab_project_ids" {
  type        = list
  description = "list of gitlab project ids to configure"
  default     = []
}

variable "gitlab_schedule_daily_rebuild_cron" {
  type        = string
  default     = "42 7 * * *"
  description = "cron expression for the daily rebuild pipeline schedule"
}

variable "gitlab_docker_image_project_ids" {
  type        = list
  description = "a subset of gitlab_project_ids that are projects that produce docker images and should have a uniform pipeline configuration applied."
  default     = []
}
