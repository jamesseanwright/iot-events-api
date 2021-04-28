output "connection_string" {
  value = mongodbatlas_cluster.events.connection_strings[0].private_endpoint[0].srv_connection_string
  description = "The private endpoint-aware cluster connection string"
}

output "username" {
  value = local.database_username
  description = "The username of the account with which to access the database"
}


output "password" {
  value = random_password.events_user_password.result
  description = "The password of the account with which to access the database"
}
