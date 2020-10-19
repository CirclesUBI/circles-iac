terraform {
  backend "s3" {
    endpoint                    = "ams3.digitaloceanspaces.com"
    key                         = "terraform.tfstate"
    bucket                      = "circles-stg-tf-state"
    region                      = "us-west-1"
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_get_ec2_platforms      = true
    skip_metadata_api_check     = true
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_vpc" "primary" {
  name     = "circles-vpc-${var.environment}"
  region   = "ams3"
  ip_range = "10.10.10.0/24"
}

resource "digitalocean_droplet" "worker" {
  count  = var.worker_count
  image  = "ubuntu-18-04-x64"
  name   = "worker"
  region = "ams3"
  size   = "s-4vcpu-8gb"
  vpc_uuid    = digitalocean_vpc.primary.id
}

resource "digitalocean_database_cluster" "postgres" {
  name       = "primary-postgres-cluster"
  engine     = "pg"
  version    = "11"
  size       = "db-s-1vcpu-1gb"
  region     = "ams3"
  node_count = 1
}
