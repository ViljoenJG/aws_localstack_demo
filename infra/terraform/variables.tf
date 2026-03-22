variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "Items"
}

variable "stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "dev"
}
