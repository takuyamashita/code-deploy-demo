variable "availability_zones" {
  type = list(string)
}

variable "server_spec" {

  type = object({
    next_server = object({
      desired_capacity = number
      max_size         = number
      min_size         = number
    }),
    echo_server = object({
      desired_capacity = number
      max_size         = number
      min_size         = number
    })
  })

  default = {
    next_server = {
      desired_capacity = 1
      max_size         = 1
      min_size         = 1
    },
    echo_server = {
      desired_capacity = 1
      max_size         = 1
      min_size         = 1
    }
  }
}

variable "next_server_subnet_ids" {
  type = list(string)
}

variable "echo_server_subnet_ids" {
  type = list(string)
}

variable "next_server_sg_id" {
  type = string
}

variable "echo_server_sg_id" {
  type = string
}

variable "next_server_instance_profile_arn" {
  type = string
}

variable "echo_server_instance_profile_arn" {
  type = string
}

variable "code_deploy_service_role_arn" {
  type = string
}

variable "alb_next_target_group_arn" {
  type = string
}

variable "nlb_echo_target_group_arn" {
  type = string
}

variable "target_group_names" {
  type = object({
    next_server = string
    echo_server = string
  })
}
