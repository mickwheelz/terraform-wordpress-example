//create the network for gcp containers
resource "google_compute_network" "default" {
  name = "vpc-network"
  auto_create_subnetworks = false
}
//create the subnet for the network
resource "google_compute_subnetwork" "default" {
  name          = "default"
  ip_cidr_range = "10.2.0.0/16"
  network       = "${google_compute_network.default.self_link}"
}
//create the cluster
resource "google_container_cluster" "primary" {
  name     = "example-cluster"
  remove_default_node_pool = true
  initial_node_count = 1
  master_auth { //disable basic auth
    username = ""
    password = ""
    client_certificate_config { //disable hsts
        issue_client_certificate = false
    }
  }
  network = "${google_compute_network.default.self_link}"
  subnetwork = "${google_compute_subnetwork.default.self_link}"
}
//create the node pool and nodes for the cluster
resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "example-pool"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 2
  node_config {
    preemptible  = true
    machine_type = "g1-small"
    metadata {
      disable-legacy-endpoints = "true"
    }
    oauth_scopes = [
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/service.management.readonly",
        "https://www.googleapis.com/auth/servicecontrol",
        "https://www.googleapis.com/auth/trace.append"
    ]
  }
}
//get the gcp config
data "google_client_config" "default" {
}