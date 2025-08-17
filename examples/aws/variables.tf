variable "instance_name" {
  description = "EC2 instance name"
  type        = string
  default     = "learn-terraform"
}

variable "instance_type" {
  description = "EC2 type"
  type        = string
  default     = "t2.micro"
}