# Image Configuration
variable "image_url" {
  description = "URL to download the cloud image from"
  type        = string
  default     = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

variable "image_name" {
  description = "Local filename for the downloaded cloud image"
  type        = string
  default     = "ubuntu-noble-cloudimg-amd64.img"

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+\\.(img|qcow2|raw)$", var.image_name))
    error_message = "Image name must be a valid filename with only alphanumeric characters, dots, underscores, hyphens, and a valid image extension (.img, .qcow2, .raw)."
  }
}

# Proxmox Configuration
variable "target_node" {
  description = "Proxmox target node name"
  type        = string
}

variable "storage_pool" {
  description = "Proxmox storage pool name"
  type        = string
  default     = "local-zfs"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+$", var.storage_pool))
    error_message = "Storage pool name must contain only alphanumeric characters, underscores, and hyphens."
  }
}

# VM Template Configuration
variable "vm_id" {
  description = "VM ID for the template"
  type        = number
  default     = 8000

  validation {
    condition     = var.vm_id > 100 && var.vm_id < 999999999
    error_message = "VM ID must be between 100 and 999999999."
  }
}

variable "template_name" {
  description = "Name of the VM template"
  type        = string
  default     = "ubuntu-noble-template"

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]$", var.template_name))
    error_message = "Template name must start and end with alphanumeric characters and can contain dots, underscores, and hyphens."
  }
}

variable "description" {
  description = "Description of the VM template"
  type        = string
  default     = "Ubuntu 24.04 Noble cloud-init template"
}

variable "tags" {
  description = "Tags to apply to the template"
  type        = list(string)
  default     = ["ubuntu-template", "noble", "cloudinit"]
}

# Hardware Configuration
variable "memory" {
  description = "Memory allocation in MB"
  type        = number
  default     = 1024
}

variable "balloon" {
  description = "Balloon memory allocation in MB (0 to disable)"
  type        = number
  default     = 0
}

variable "cpu_type" {
  description = "CPU type (host recommended for best performance)"
  type        = string
  default     = "host"
}

variable "cpu_sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 1
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 1
}

variable "numa_enabled" {
  description = "Enable NUMA"
  type        = bool
  default     = false
}

# Display Configuration
variable "vga_type" {
  description = "VGA display type (serial0 allows copy/paste)"
  type        = string
  default     = "serial0"
}

variable "vga_memory" {
  description = "VGA memory in MB"
  type        = number
  default     = 4
}

# Network Configuration
variable "network_bridge" {
  description = "Network bridge interface"
  type        = string
  default     = "vmbr0"
}

variable "network_vlan_tag" {
  description = "VLAN tag (optional)"
  type        = number
  default     = null
}

variable "network_firewall" {
  description = "Enable firewall on network interface"
  type        = bool
  default     = false
}

# Disk Configuration
variable "disk_size" {
  description = "Disk size (e.g., '32G', '20G')"
  type        = string
  default     = "20G"

  validation {
    condition     = can(regex("^[0-9]+[KMGT]$", var.disk_size))
    error_message = "Disk size must be a number followed by K, M, G, or T (e.g., '20G', '500M')."
  }
}

variable "disk_discard" {
  description = "Enable discard on disk (recommended for SSDs)"
  type        = bool
  default     = true
}

# Cloud-Init Configuration
variable "cloud_init_file_name" {
  description = "Name of the cloud-init vendor file"
  type        = string
  default     = "vendor.yaml"

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+\\.(yaml|yml)$", var.cloud_init_file_name))
    error_message = "Cloud-init file name must be a valid YAML filename with only alphanumeric characters, dots, underscores, and hyphens."
  }
}

variable "cloud_init_user" {
  description = "Default user to create via cloud-init"
  type        = string
  default     = "ubuntu"

  validation {
    condition     = can(regex("^[a-z]([a-z0-9_-]*[a-z0-9])?$", var.cloud_init_user))
    error_message = "Cloud-init user must be a valid Linux username (lowercase letters, numbers, underscores, and hyphens only)."
  }
}

variable "ssh_keys_file" {
  description = "Path to SSH public keys file"
  type        = string
  default     = "~/.ssh/authorized_keys"

  validation {
    condition     = can(regex("^[a-zA-Z0-9._/~-]+$", var.ssh_keys_file))
    error_message = "SSH keys file path must contain only alphanumeric characters, dots, underscores, forward slashes, tildes, and hyphens."
  }
}

variable "ip_config" {
  description = "IP configuration (e.g., 'ip=dhcp', 'ip=192.168.1.100/24,gw=192.168.1.1')"
  type        = string
  default     = "ip=dhcp"
}

variable "cloud_init_packages" {
  description = "List of packages to install via cloud-init"
  type        = list(string)
  default     = ["qemu-guest-agent"]
}

variable "cloud_init_runcmd" {
  description = "List of commands to run via cloud-init"
  type        = list(string)
  default = [
    "apt-get update",
    "apt-get install -y qemu-guest-agent",
    "systemctl enable qemu-guest-agent",
    "systemctl start qemu-guest-agent",
    "systemctl enable ssh",
    "reboot"
  ]
}

variable "cloud_init_additional_config" {
  description = "Additional cloud-init configuration (YAML format)"
  type        = string
  default     = ""
}
