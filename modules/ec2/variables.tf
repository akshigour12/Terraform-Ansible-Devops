variable "project_name" {
  type = string
}

variable "name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "iam_instance_profile" {
  type = string
}

variable "key_name" {
  type = string
}

variable "role" {
  type = string
}

variable "os" {
  type = string
}

variable "user_data" {
  type    = string
  default = null
}