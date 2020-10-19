variable "do_token" {
  type = string
}

variable "environment" {
  type = string
  default = "stg"
}

variable "worker_count" {
  type = number
  default = 3
}
