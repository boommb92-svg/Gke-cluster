# main.tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }

  backend "gcs" {
    # You can hardcode values here OR pass them at terraform init via -backend-config (recommended)
    bucket = var.state_bucket_name
    prefix = var.state_prefix
    # project and credentials may be passed via -backend-config or ADC.
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

# Enable necessary APIs (optional but recommended to avoid failure)
resource "google_project_service" "container" {
  service = "container.googleapis.com"
  project = var.project
}

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
  project = var.project
}

# Create the GKE cluster and remove default node pool (we'll manage node pool separately)
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.location
  project  = var.project

  remove_default_node_pool = true
  initial_node_count       = 1
  networking_mode          = "VPC_NATIVE"
  ip_allocation_policy {}

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  depends_on = [
    google_project_service.container,
    google_project_service.compute
  ]
}

# Managed node pool (recommended)
resource "google_container_node_pool" "primary_nodes" {
  name     = "${var.cluster_name}-pool"
  project  = var.project
  location = google_container_cluster.primary.location
  cluster  = google_container_cluster.primary.name

  initial_node_count = var.node_count

  node_config {
    machine_type = var.node_machine_type
    disk_size_gb = var.node_disk_size_gb

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
  }

  autoscaling {
    min_node_count = var.node_min_count
    max_node_count = var.node_max_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  depends_on = [google_container_cluster.primary]
}

