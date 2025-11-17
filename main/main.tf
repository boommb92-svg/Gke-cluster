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

# Enable required APIs
resource "google_project_service" "compute" {
  project = var.project
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  project = var.project
  service = "container.googleapis.com"
}

# ------------------------------
#   GKE CLUSTER (MUST EXIST)
# ------------------------------
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.location
  project  = var.project

  deletion_protection = false
  remove_default_node_pool = true
  initial_node_count       = 1

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {}

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  depends_on = [
    google_project_service.compute,
    google_project_service.container
  ]
}


# ------------------------------
#   SEPARATE NODE POOL
# ------------------------------
resource "google_container_node_pool" "primary_nodes" {
  name       = "my-gke-pool"
  cluster    = google_container_cluster.primary.name
  location   = var.location
  project    = var.project

  node_count = var.node_count

  node_config {
    machine_type        = var.node_machine_type
    disk_size_gb        = var.node_disk_size_gb
    disk_type           = "pd-standard"
    enable_external_ips = false   # <-- required to avoid quota issues
  }

  management {
    auto_upgrade = true
    auto_repair  = true
  }
}

  management {
    auto_upgrade = true
    auto_repair  = true
  }
}
