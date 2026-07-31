variable "aws_region" {
  description = "AWS region to deploy into"
  default     = "us-east-1"
}

variable "github_org" {
  description = "GitHub username or org"
  default     = "R3X0N05"
}

variable "be_repo" {
  description = "Backend GitHub repo name"
  default     = "caa900-BE-grp04"
}

variable "fp_repo" {
  description = "Frontend GitHub repo name"
  default     = "caa900-fp-grp04"
}

variable "iac_repo" {
  description = "IAC GitHub repo name"
  default     = "caa900-IAC-grp04"
}

variable "from_email" {
  description = "SES verified sender email"
  default     = "azure.allure99@gmail.com"
}

variable "github_token" {
  description = "GitHub PAT for Amplify to pull the FP repo (repo scope)"
  sensitive   = true
}