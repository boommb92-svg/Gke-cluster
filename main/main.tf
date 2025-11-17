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

# Enable required APIs (safe to keep; provider will no-op if already enabled)
resource "google_project_service" "compute" {
  project = var.project
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  project = var.project
  service = "container.googleapis.com"
}

# ------------------------------
# GKE Cluster (private)
# ------------------------------
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.location
  project  = var.project

  deletion_protection = false

  # We will manage node pools separately, so remove default pool on create.
  remove_default_node_pool = true
  initial_node_count       = 1

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {}

  # Private nodes ensure VMs have no external IPs (avoids IN_USE_ADDRESSES quota)
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"   # adjust if overlaps your VPC
  }

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  depends_on = [
    google_project_service.compute,
    google_project_service.container
  ]
}

# ------------------------------
# EXISTING NODE POOL (imported)
# ------------------------------
# This resource corresponds to the pool that already exists in GCP:
#  - name must match the real pool name ("my-gke-pool")
#  - after placing this block, import the pool into state.
resource "google_container_node_pool" "primary_nodes" {
  name     = "my-gke-pool"                            # must match existing pool name
  cluster  = google_container_cluster.primary.name
  location = var.location
  project  = var.project

  # We don't want Terraform to attempt to change node_config (which would recreate the pool).
  # Ignore node_config and node_count so Terraform will not try to update/recreate the imported pool.
  lifecycle {
    ignore_changes = [
      node_config,
      node_count,
    ]
  }

  # Provide a minimal node_config so the resource has a shape Terraform expects.
  # This will be ignored (see lifecycle) for the imported resource.
  node_config {
    machine_type = var.node_machine_type
    disk_size_gb = var.node_disk_size_gb
    disk_type    = "pd-standard"
    # Do NOT try to change external IPs on this existing pool here.
  }

  management {
    auto_upgrade = true
    auto_repair  = true
  }
}

# ------------------------------
# NEW PRIVATE NODE POOL (internal-only)
# ------------------------------
# This pool will be created with internal-only nodes (private cluster enforces no external IPs).
resource "google_container_node_pool" "private_nodes" {
  name     = "private-pool"
  cluster  = google_container_cluster.primary.name
  location = var.location
  project  = var.project

  # Start small; adjust to your needs
  node_count = 1

  node_config {
    machine_type = var.node_machine_type
    disk_size_gb = var.node_disk_size_gb
    disk_type    = "pd-standard"
    # Do not set external IP fields here — private cluster + create of a new pool will ensure internal-only nodes.
    # If you need taints, use taint block(s) below (example commented).
    # taint {
    #   key    = "dedicated"
    #   value  = "private"
    #   effect = "NO_SCHEDULE"
    # }
  }

  management {
    auto_upgrade = true
    auto_repair  = true
  }
}
