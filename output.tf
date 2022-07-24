output "kubeconfig" {
  sensitive   = true
  value       = null_resource.kubeconfig
  description = "Kubeconfig"
}

output "rdb_users" {
  sensitive   = true
  value       = scaleway_rdb_user.default
  description = "Rdb users informations"
}

output "nginx_ip" {
  value       = scaleway_lb_ip.nginx_ip
  description = "Loadbalancer ip for nginx"
}
