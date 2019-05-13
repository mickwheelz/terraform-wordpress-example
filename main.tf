//setup the terraform backend using gcp storage 
terraform {
    backend "gcs" {
        bucket = "example-terraform-state"
        prefix = "terraform/state"
    }
}
//provider for gcs and cloud flare, not needed for info only
provider "google" {
    //uses env vars
}
provider "cloudflare" {
    //uses env vars
}

//provider for k8s
provider "kubernetes" {
  host = "${google_container_cluster.primary.endpoint}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
  token = "${data.google_client_config.default.access_token}"
  load_config_file = false
}
//provider for helm
provider "helm" {
  kubernetes = {
    host = "${google_container_cluster.primary.endpoint}"
    cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
    token = "${data.google_client_config.default.access_token}"
    load_config_file = false
  }
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.13.1"
  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
}
