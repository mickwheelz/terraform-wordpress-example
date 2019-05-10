//local variable for domain to use in cloudflare
locals {
    domain = "mickwheelz.net"
}
//get the cloudflare zone for the domain
data "cloudflare_zones" "mickwheelz" {
  filter {
    name   = "${local.domain}"
  }
}
//create the subdomain for the new wordpress site
resource "cloudflare_record" "wordpress-subdomain" {
  domain = "${data.cloudflare_zones.mickwheelz.zones.0.name}"
  name   = "bog"
  value  = "${data.kubernetes_service.ngnix.load_balancer_ingress.0.ip}"
  type   = "A"
}