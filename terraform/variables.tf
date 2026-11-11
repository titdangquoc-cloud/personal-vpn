variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "syd1"
}

variable "admin_ip" {
  description = "Your public IP in CIDR form, e.g. 203.0.113.10/32"
  type        = string
}