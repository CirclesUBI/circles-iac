variable "do_token" {
  type = string
}

variable "environment" {
  type = string
  default = "stg"
}

variable "nginx_ingress_helm_timeout_seconds" { 
  type        = number                          
  default     = 600                             
}              