terraform {
  backend "s3" {
    endpoint                    = "ams3.digitaloceanspaces.com"
    key                         = "terraform.tfstate"
    bucket                      = "circles-common-tf-state"
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

resource "digitalocean_container_registry" "primary" {
  name = "circles-registry"
}

resource "digitalocean_container_registry_docker_credentials" "primary" {
  registry_name = "circles-registry"
}
