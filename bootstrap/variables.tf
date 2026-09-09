variable "aws_region" {
  description = "AWS region where the Terraform state bucket will be created"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket used to store Terraform state"
  type        = string
}