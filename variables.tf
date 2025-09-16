variable "region" {
  default = "us-east-1"
}

# Ubuntu 22.04 AMI for us-east-1 (check & update if region is different)
variable "ami" {
  default = "ami-0360c520857e3138f"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "key_name" {
  default = "mahi" # Replace with your AWS key pair
}
