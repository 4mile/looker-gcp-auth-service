variable "project" { }

variable "credentials_file" { }

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-c"
}

variable "service" {
  default = "looker-gcp-auth-service"
}

variable "app_version" {
  type        = string
  description = "short hash of latest git commit"
}