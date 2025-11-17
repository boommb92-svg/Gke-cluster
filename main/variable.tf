variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region (for provider)"
  type        = string
  default     = "us-central1"
}

variable "location" {
  description = "GKE location: region (e.g. us-central1) or zone (e.g. us-central1-a)"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "tf-gke-cluster"
}

variable "node_count" {
  description = "Initial nodes in the node pool"
  type        = number
  default     = 2         # reduced default
}

variable "node_machine_type" {
  description = "GCE machine type for nodes"
  type        = string
  default     = "e2-medium"
}

variable "node_disk_size_gb" {
  description = "Node disk size in GB (pd-standard)"
  type        = number
  default     = 50        # reduced default
}

variable "node_min_count" {
  description = "Autoscaler minimum"
  type        = number
  default     = 1
}

variable "node_max_count" {
  description = "Autoscaler maximum"
  type        = number
  default     = 5
}
