terraform {
  backend "s3" {
    endpoint                    = "ams3.digitaloceanspaces.com"
    key                         = "terraform.tfstate"
    bucket                      = "circles-prod-tf-state"
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

provider "kubernetes" {
  load_config_file = false
  host             = digitalocean_kubernetes_cluster.primary.endpoint
  token            = digitalocean_kubernetes_cluster.primary.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate
  )
}

provider "helm" {
  version = "~> 1.0.0"
  kubernetes {
    load_config_file = false
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
  ip_range = "10.10.1.0/24"
}

resource "digitalocean_database_cluster" "postgres" {
  name       = "prod-primary-postgres-cluster"
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
  name   = "prod-primary-k8s-cluster"
  region = "ams3"
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.18.10-do.2"
  vpc_uuid = digitalocean_vpc.primary.id
  tags    = ["prod"]

  node_pool {
    name       = "prod-pool-a"
    size       = "c-4"
    node_count = 3
  }
}

resource "digitalocean_kubernetes_node_pool" "b" {
  cluster_id = digitalocean_kubernetes_cluster.primary.id

  name       = "prod-pool-b"
  size       = "m-2vcpu-16gb"
  node_count = 1

  labels = {
    pool  = "b"
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
  name = "nginx-ingress"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart = "nginx-ingress"
  set {
    name = "controller.publishService.enabled"
    value = "true"
  }
}

resource "helm_release" "cert_manager" {
  name = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart = "cert-manager"
  version = "v1.0.3"
  set {
    name = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "db" {
  name = "db"
  repository = "https://charts.bitnami.com/bitnami"
  chart = "postgresql"
  version = "9.8.7"
  values = [
	"${file("helm_vals/postgresql.yaml")}"
  ]
}


/*
resource "helm_release" "circles-infra" {
  depends_on = [kubernetes_secret.image_pull]
  name = "circles-infra"
  chart = "${path.module}/../../helm/circles-infra-suite"
  namespace = "default"
}
*/
