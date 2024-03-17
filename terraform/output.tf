output "instance_public_IP" {
  description = "Public IP for azure"
  value = join("", azurerm_public_ip.ippublica.*.ip_address)
}

output "registry_username" {
  description = "The Username ACR  Admin account"
  value       = join("", azurerm_container_registry.cp2acrsfg.*.admin_username)
}

output "registry_password" {
  description = "The Password associated with the Container Registry Admin account - if the admin account is enabled"
  value       = nonsensitive(join("", azurerm_container_registry.cp2acrsfg.*.admin_password))
}
