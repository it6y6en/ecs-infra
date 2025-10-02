variable "vpc_cidr" {
  type        = string
  default     = ""
  description = "description"
}

variable "num_subnets" {
  type = number
  validation {
    condition     = var.num_subnets <= length(data.aws_availability_zones.available.names)
    error_message = "num_subnets must not be greater than the number of available AZs in this region."
  }
}

variable "allowed_ips" {
  type = set(string)
}

variable "region" {
  type    = string
}