variable "project" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region (for bucket and provider)"
  default     = "US"
}

variable "location" {
  type        = string
  description = "GKE location: region (e.g. us-central1) or zone (e.g. us-central1-a)"
  default     = "us-central1"
}

variable "cluster_name" {
  type    = string
  default = "tf-gke-cluster"
}

# Backend/state variables
variable "state_bucket_name" {
  type        = string
  description = "GCS bucket used for Terraform state (must exist before init)"
}

variable "state_prefix" {
  type    = string
  default = "terraform/state"
}

# Node pool variables
variable "node_count" {
  type    = number
  default = 3
}

variable "node_machine_type" {
  type    = string
  default = "e2-medium"
}

variable "node_disk_size_gb" {
  type    = number
  default = 100
}

variable "node_min_count" {
  type    = number
  default = 1
}

variable "node_max_count" {
  type    = number
  default = 5
}
