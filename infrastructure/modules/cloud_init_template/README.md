# Cloud-Init Template Module

This module creates a cloud-init enabled template in Proxmox that can be cloned for rapid deployment. It downloads cloud images, configures them with cloud-init, and converts them to reusable templates.

## Features

- Downloads cloud images automatically (Ubuntu, Debian, etc.)
- Configures UEFI boot with Q35 machine type
- Sets up cloud-init with customizable configuration
- Creates reusable templates for rapid deployment
- Supports custom packages and run commands
- Handles SSH key injection and user creation

## Basic Usage

```hcl
module "ubuntu_template" {
  source = "./modules/cloud_init_template"

  # Proxmox Configuration
  target_node  = "pve"
  storage_pool = "local-zfs"
  
  # Template Configuration
  vm_id         = 8000
  template_name = "ubuntu-noble-template"
  
  # Cloud-Init Configuration
  cloud_init_user = "ubuntu"
  ssh_keys_file   = "~/.ssh/authorized_keys"
}
```

## Examples

### Ubuntu 24.04 Template
```hcl
module "ubuntu_template" {
  source = "./modules/cloud_init_template"
  
  target_node   = "pve"
  vm_id         = 8000
  template_name = "ubuntu-noble-template"
  
  image_url  = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  image_name = "ubuntu-noble-cloudimg-amd64.img"
  
  cloud_init_user = "ubuntu"
  disk_size       = "20G"
}
```

### Debian 12 Template
```hcl
module "debian_template" {
  source = "./modules/cloud_init_template"
  
  target_node   = "pve"
  vm_id         = 8001
  template_name = "debian-bookworm-template"
  
  image_url  = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
  image_name = "debian-12-generic-amd64.qcow2"
  
  cloud_init_user = "debian"
  disk_size       = "20G"
}
```

### Template with Custom Software
```hcl
module "docker_template" {
  source = "./modules/cloud_init_template"
  
  target_node   = "pve"
  vm_id         = 8002
  template_name = "ubuntu-docker-template"
  
  cloud_init_user = "ubuntu"
  memory          = 2048
  cpu_cores       = 2
  disk_size       = "40G"
  
  cloud_init_runcmd = [
    "apt-get update",
    "apt-get install -y qemu-guest-agent docker.io",
    "systemctl enable docker",
    "usermod -aG docker ubuntu",
    "systemctl enable ssh",
    "reboot"
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| proxmox | 3.0.2-rc04 |

## Providers

| Name | Version |
|------|---------|
| proxmox | 3.0.2-rc04 |
| local | >= 2.0 |
| null | >= 3.0 |
| local | n/a |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| target_node | Proxmox target node name | `string` | n/a | yes |
| image_url | URL to download the cloud image from | `string` | `"https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"` | no |
| image_name | Local filename for the downloaded cloud image | `string` | `"ubuntu-noble-cloudimg-amd64.img"` | no |
| storage_pool | Proxmox storage pool name | `string` | `"local-zfs"` | no |
| vm_id | VM ID for the template | `number` | `8000` | no |
| template_name | Name of the VM template | `string` | `"ubuntu-noble-template"` | no |
| description | Description of the VM template | `string` | `"Ubuntu 24.04 Noble cloud-init template"` | no |
| tags | Tags to apply to the template | `list(string)` | `["ubuntu-template", "noble", "cloudinit"]` | no |
| memory | Memory allocation in MB | `number` | `1024` | no |
| balloon | Balloon memory allocation in MB (0 to disable) | `number` | `0` | no |
| cpu_type | CPU type (host recommended for best performance) | `string` | `"host"` | no |
| cpu_sockets | Number of CPU sockets | `number` | `1` | no |
| cpu_cores | Number of CPU cores | `number` | `1` | no |
| numa_enabled | Enable NUMA | `bool` | `false` | no |
| vga_type | VGA display type (serial0 allows copy/paste) | `string` | `"serial0"` | no |
| vga_memory | VGA memory in MB | `number` | `4` | no |
| network_bridge | Network bridge interface | `string` | `"vmbr0"` | no |
| network_vlan_tag | VLAN tag (optional) | `number` | `null` | no |
| network_firewall | Enable firewall on network interface | `bool` | `false` | no |
| disk_size | Disk size (e.g., '32G', '20G') | `string` | `"20G"` | no |
| disk_discard | Enable discard on disk (recommended for SSDs) | `bool` | `true` | no |
| cloud_init_file_name | Name of the cloud-init vendor file | `string` | `"vendor.yaml"` | no |
| cloud_init_user | Default user to create via cloud-init | `string` | `"ubuntu"` | no |
| ssh_keys_file | Path to SSH public keys file | `string` | `"~/.ssh/authorized_keys"` | no |
| ip_config | IP configuration (e.g., 'ip=dhcp', 'ip=192.168.1.100/24,gw=192.168.1.1') | `string` | `"ip=dhcp"` | no |
| cloud_init_packages | List of packages to install via cloud-init | `list(string)` | `["qemu-guest-agent"]` | no |
| cloud_init_runcmd | List of commands to run via cloud-init | `list(string)` | See variables.tf | no |
| cloud_init_additional_config | Additional cloud-init configuration (YAML format) | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| template_id | VM ID of the created template |
| template_name | Name of the created template |
| target_node | Proxmox node where template was created |
| storage_pool | Storage pool used for the template |
| cloud_init_file | Path to the cloud-init vendor file |
| tags | Tags applied to the template |
| template_ready | Indicates if template creation is complete |

## Notes

### Prerequisites

1. **Proxmox Setup**: Ensure snippets are enabled for your storage pool:
   - In Proxmox UI: Datacenter → Storage → local → Edit → Content → Check "Snippets"

2. **SSH Keys**: Have your SSH public keys available in `~/.ssh/authorized_keys` or specify a different path

3. **Network**: Ensure the specified bridge interface exists

### Template Usage

After creating a template with this module, you can clone it:

```bash
# Clone the template
qm clone 8000 100 --name "my-vm" --full

# Configure cloned VM
qm set 100 --memory 4096 --cores 4

# Start the VM
qm start 100
```

### Image Sources

- **Ubuntu**: https://cloud-images.ubuntu.com/
- **Debian**: https://cloud.debian.org/images/cloud/
- **CentOS/Rocky**: Check respective cloud image repositories

### Customization

The module supports extensive customization through cloud-init. You can:

- Install packages during first boot
- Run custom commands
- Configure users and SSH keys
- Set up network configuration
- Add custom cloud-init YAML configuration

### Why This Approach?

This module follows the project's style guide:
- **Generic naming**: `virtual_machine_template` (not `proxmox_template`)
- **Tool agnostic**: Works with OpenTofu/Terraform
- **Simple**: Focused on homelab needs, not enterprise complexity
- **Flexible**: Supports multiple OS types and configurations
- **Reusable**: Module can be used across different stacks
