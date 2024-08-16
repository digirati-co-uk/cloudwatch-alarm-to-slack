variable "s3_bucket" {
  description = "S3 bucket containing cloudwatch-to-slack Lambda function"
  type        = string
}

variable "s3_key" {
  description = "S3 key for cloudwatch-to-slack Lambda function"
  type        = string
}

variable "slack_webhook_url" {
  description = "Slack webhook URL to call"
  type        = string
  default     = ""
}

variable "slack_webhook_secret" {
  description = "SecretsManager secret containing slack webhook URL to call"
  type        = string
  default     = ""
}

variable "runtime" {
  description = "Python runtime to use for lambda"
  type        = string
  default     = "python3.11"

  validation {
    condition     = substr(var.runtime, 0, 6) == "python"
    error_message = "The runtime must start with \"python\"."
  }
}

variable "prefix" {
  description = "Prefix for services"
  type        = string
}

variable "account_id" {
  description = "AWS account id"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

locals {
  env_candidates = {
    SLACK_WEBHOOK_URL    = var.slack_webhook_url
    SLACK_WEBHOOK_SECRET = var.slack_webhook_secret
  }

  env_vars = { for k, v in local.env_candidates : k => v if v != "" }
}
