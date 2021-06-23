terraform {
  backend "s3" {
    endpoint                    = "ams3.digitaloceanspaces.com"
    key                         = "terraform.tfstate"
    bucket                      = "circles-common-tf-state"
    region                      = "us-west-1"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }

  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_container_registry" "primary" {
  name = "circles-registry"
  subscription_tier_slug = "basic"
}

resource "digitalocean_container_registry_docker_credentials" "primary" {
  registry_name = "circles-registry"
}
