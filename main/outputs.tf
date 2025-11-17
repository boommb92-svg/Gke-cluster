output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "get_credentials" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region=${var.location} --project=${var.project}"
}

output "node_pool_name" {
  value = google_container_node_pool.primary_nodes.name
}

output "node_pool_location" {
  value = google_container_node_pool.primary_nodes.location
}

output "node_pool_initial_node_count" {
  value = google_container_node_pool.primary_nodes.initial_node_count
}

output "node_pool_machine_type" {
  value = google_container_node_pool.primary_nodes.node_config[0].machine_type
}

output "node_pool_disk_type" {
  value = google_container_node_pool.primary_nodes.node_config[0].disk_type
}

output "node_pool_disk_size" {
  value = google_container_node_pool.primary_nodes.node_config[0].disk_size_gb
}

output "node_pool_full_config" {
  value = google_container_node_pool.primary_nodes
}
