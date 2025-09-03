# Ubuntu LTS Template Stack
# Creates a cloud-init enabled Ubuntu LTS template for the homelab
# This template can be cloned to create multiple VMs

terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc04"
    }
  }
}

# Configure the Proxmox Provider
provider "proxmox" {
  # Configuration will be provided via environment variables:
  # PM_API_URL, PM_USER, PM_PASS, PM_TLS_INSECURE
}

# Create Ubuntu LTS cloud-init template
module "ubuntu_lts_template" {
  source = "../../../modules/cloud_init_template"

  # Proxmox Configuration
  target_node  = var.target_node
  storage_pool = var.storage_pool

  # Template Configuration
  vm_id         = var.template_vm_id
  template_name = var.template_name
  description   = "Ubuntu ${var.ubuntu_version} LTS cloud-init template for homelab"
  tags          = var.tags

  # Image Configuration - Latest Ubuntu LTS
  image_url  = var.image_url
  image_name = var.image_name
  disk_size  = var.disk_size

  # Hardware Configuration
  memory      = var.memory
  cpu_type    = var.cpu_type
  cpu_sockets = var.cpu_sockets
  cpu_cores   = var.cpu_cores

  # Network Configuration
  network_bridge = var.network_bridge

  # Cloud-init Configuration
  cloud_init_user              = var.cloud_init_user
  cloud_init_packages          = var.cloud_init_packages
  cloud_init_runcmd            = var.cloud_init_runcmd
  cloud_init_additional_config = var.cloud_init_additional_config
  ssh_keys_file                = var.ssh_keys_file
}
