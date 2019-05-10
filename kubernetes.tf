// setup the k8s tiller service account
resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
  automount_service_account_token = true
}
//setup the role for the k8s tiller service account
resource "kubernetes_cluster_role_binding" "tiller" {
  metadata = {
    name = "tiller"
  }
  role_ref = {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject = {
    api_group = ""
    kind = "ServiceAccount"
    name = "${kubernetes_service_account.tiller.metadata.0.name}"
    namespace = "${kubernetes_service_account.tiller.metadata.0.namespace}"
  }
}