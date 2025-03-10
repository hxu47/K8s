provider "google" {
  project = "kubernetes-452918"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_container_cluster" "primary" {
  name     = "huidong-gke-cluster"
  location = "us-central1-c"
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "huidong-node-pool"
  location   = "us-central1-c"
  cluster    = google_container_cluster.primary.name
  node_count = 1         # only create 1 node for this cluster

  node_config {
    machine_type = "e2-micro"
    disk_type    = "pd-standard"  # Choose “Standard persistent disk” for Boot disk type
    disk_size_gb = 10             # “10” for Boot disk size
    
    # Choose “container-Optimized OS with containerd (cos_containerd) (default)” as the
    # image type for the node.
    image_type   = "cos_containerd"  

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/compute",
    ]
  }
}

# Create a GCE Persistent Disk for our PV to use
resource "google_compute_disk" "default" {
  name  = "huidong-disk"
  type  = "pd-standard"
  size  = 1
  zone  = "us-central1-c"
}