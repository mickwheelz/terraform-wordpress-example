//create the nginx ingress controller
resource "helm_release" "nginx" { 
    name = "nginx-ingress"
    repository = "stable"
    chart = "nginx-ingress"
    namespace = "kube-system"
    depends_on = [
      "google_container_node_pool.primary_preemptible_nodes",
      "kubernetes_service_account.tiller", 
      "kubernetes_cluster_role_binding.tiller"
    ]
    set_string {
        name  = "controller.config.hsts"
        value = "false"
  }
}
//create the wordpress instance
resource "helm_release" "wordpress" { 
    name = "demo"
    repository = "stable"
    chart = "wordpress"
    namespace = "wordpress"
    depends_on = [
     "helm_release.nginx" 
    ]
    values = ["${file("./wordpress-values.yaml")}"]
}
data "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-ingress-controller"
    namespace = "${helm_release.nginx.metadata.0.namespace}"
  }
}
//show the ip address for the ingress controller
output "nginx-ip" {
  value = "${data.kubernetes_service.nginx.load_balancer_ingress.0.ip}"
}