output "db_address" {
  value = digitalocean_database_cluster.postgres.private_host
}

output "db_port" {
  value = digitalocean_database_cluster.postgres.port
}

output "db_password" {
  value = digitalocean_database_cluster.postgres.password
  sensitive = true
}
