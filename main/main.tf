terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }

  backend "gcs" {
    bucket = "my-tfstate-bucket-1763375630"
    prefix = "gke-prod"
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

resource "google_project_service" "compute" {
  project = var.project
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  project = var.project
  service = "container.googleapis.com"
}
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.location
  project  = var.project

  remove_default_node_pool = false

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {}

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # <-- add this block
  private_cluster_config {
    enable_private_nodes    = true                 # nodes will NOT have external IPs
    master_ipv4_cidr_block  = "172.16.0.0/28"      # small CIDR for the control-plane
    enable_private_endpoint = false                # optional: keep control plane endpoint public if you want
  }
  # -->

  node_pool {
    name               = "${var.cluster_name}-pool"
    initial_node_count = var.node_count

    autoscaling {
      min_node_count = var.node_min_count
      max_node_count = var.node_max_count
    }

    management {
      auto_repair  = true
      auto_upgrade = true
    }

    node_config {
      machine_type = var.node_machine_type
      disk_size_gb = var.node_disk_size_gb
      disk_type    = "pd-standard"

      oauth_scopes = [
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/devstorage.read_only"
      ]
    }
  }

  depends_on = [
    google_project_service.compute,
    google_project_service.container
  ]
}


