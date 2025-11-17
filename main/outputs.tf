output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "get_credentials" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region=${var.location} --project=${var.project}"
}

