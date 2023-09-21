terraform {
  backend "s3" {
    endpoint                    = "ams3.digitaloceanspaces.com"
    key                         = "terraform.tfstate"
    bucket                      = "circles-stg-tf-state"
    region                      = "us-west-1"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }

  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.30.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

provider "kubernetes" {
  host             = digitalocean_kubernetes_cluster.primary.endpoint
  token            = digitalocean_kubernetes_cluster.primary.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host = digitalocean_kubernetes_cluster.primary.endpoint
    token = digitalocean_kubernetes_cluster.primary.kube_config[0].token
    cluster_ca_certificate = base64decode(
      digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate
    )
  }
}

resource "digitalocean_vpc" "primary" {
  name     = "circles-vpc-${var.environment}"
  region   = "ams3"
  ip_range = "10.10.10.0/24"
}

resource "digitalocean_database_cluster" "postgres" {
  name       = "staging-primary-postgres-cluster"
  engine     = "pg"
  version    = "12"
  size       = "db-s-2vcpu-4gb"
  region     = "ams3"
  private_network_uuid = digitalocean_vpc.primary.id
  node_count = 2
}

resource "digitalocean_database_db" "api" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = "api"
}

resource "digitalocean_database_db" "relayer" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = "relayer"
}

resource "digitalocean_database_firewall" "db-fw" {
  cluster_id = digitalocean_database_cluster.postgres.id
  rule {
    type  = "k8s"
    value = digitalocean_kubernetes_cluster.primary.id
  }
}

resource "digitalocean_kubernetes_cluster" "primary" {
  name      = "staging-primary-k8s-cluster"
  region    = "ams3"
  # Grab the latest version slug from `doctl kubernetes options versions`
  version   = "1.25.12-do.0"
  vpc_uuid  = digitalocean_vpc.primary.id
  tags      = ["staging"]
  node_pool {
    name       = "stg-pool-a"
    size       = "s-1vcpu-2gb"
    node_count = 3
    labels = {
      pool = "a"
    }
  }
}


data "digitalocean_container_registry" "common" {
  name = "circles-registry"
}

resource "digitalocean_container_registry_docker_credentials" "common" {
  registry_name = "circles-registry"
}

resource "kubernetes_secret" "image_pull" {
  metadata {
    name = "docker-cfg"
  }
  data = {
    ".dockerconfigjson" = digitalocean_container_registry_docker_credentials.common.docker_credentials
  }
  type = "kubernetes.io/dockerconfigjson"
}

resource "helm_release" "ingress" {
  name = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  timeout    = var.nginx_ingress_helm_timeout_seconds
  version = "4.0.17"
  set {
    name = "controller.publishService.enabled"
    value = "true"
  }
}

resource "helm_release" "cert_manager" {
  name = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart = "cert-manager"
  version = "v1.7.0"
  set {
    name = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "nfs_server_provisioner" {
  name = "nfs-server-provisioner"
  repository = "https://kvaps.github.io/charts"
  chart = "nfs-server-provisioner"
  version = "1.3.1"
  set {
    name  = "persistence.enabled"
    value = "true"
  }
  set {
    name  = "persistence.storageClass"
    value = "do-block-storage"
  }
  set {
    name  = "persistence.size"
    value = "50Gi"
  }
}
