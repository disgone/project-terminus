# Cloud-Init Template Module
# Creates a cloud-init enabled template that can be cloned for rapid deployment
# Based on: https://github.com/UntouchedWagons/Ubuntu-CloudInit-Docs

terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc04"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}

# Download cloud image
resource "null_resource" "download_cloud_image" {
  triggers = {
    image_url  = var.image_url
    image_name = var.image_name
    disk_size  = var.disk_size
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      # Clean up any existing image
      rm -f "${var.image_name}"
      
      # Download the cloud image
      if ! wget -q "${var.image_url}" -O "${var.image_name}"; then
        echo "Failed to download cloud image from ${var.image_url}"
        exit 1
      fi
      
      # Resize the image
      if ! qemu-img resize "${var.image_name}" "${var.disk_size}"; then
        echo "Failed to resize image ${var.image_name} to ${var.disk_size}"
        exit 1
      fi
    EOT
  }
}

# Create the VM
resource "proxmox_vm_qemu" "template" {
  depends_on = [null_resource.download_cloud_image]

  target_node = var.target_node
  vmid        = var.vm_id
  name        = var.template_name
  desc        = var.description

  # OS Settings
  os_type = "cloud-init"

  # Hardware Settings
  memory  = var.memory
  balloon = var.balloon
  agent   = 1

  # UEFI Boot
  bios    = "ovmf"
  machine = "q35"

  # EFI Disk
  efidisk {
    storage           = var.storage_pool
    pre_enrolled_keys = false
  }

  # CPU Settings
  cpu {
    type    = var.cpu_type
    sockets = var.cpu_sockets
    cores   = var.cpu_cores
    numa    = var.numa_enabled
  }

  # Display
  vga {
    type   = var.vga_type
    memory = var.vga_memory
  }

  # Serial Console
  serial {
    id   = 0
    type = "socket"
  }

  # Network
  network {
    id       = 0
    model    = "virtio"
    bridge   = var.network_bridge
    tag      = var.network_vlan_tag
    firewall = var.network_firewall
  }

  # This prevents the VM from being started
  # Templates should not run, only be cloned
  lifecycle {
    ignore_changes = [
      target_node,
    ]
  }
}

# Import the downloaded disk
resource "null_resource" "import_disk" {
  depends_on = [
    null_resource.download_cloud_image,
    proxmox_vm_qemu.template
  ]

  triggers = {
    vm_id      = var.vm_id
    image_name = var.image_name
    storage    = var.storage_pool
  }

  provisioner "local-exec" {
    command = "qm importdisk ${var.vm_id} '${var.image_name}' ${var.storage_pool}"
  }
}

# Configure the imported disk
resource "null_resource" "configure_disk" {
  depends_on = [null_resource.import_disk]

  triggers = {
    vm_id   = var.vm_id
    storage = var.storage_pool
    discard = var.disk_discard
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      # Set SCSI hardware type and attach the disk
      qm set ${var.vm_id} --scsihw virtio-scsi-pci --virtio0 ${var.storage_pool}:vm-${var.vm_id}-disk-1${var.disk_discard ? ",discard=on" : ""}
      
      # Set boot order
      qm set ${var.vm_id} --boot order=virtio0
      
      # Add cloud-init drive
      qm set ${var.vm_id} --scsi1 ${var.storage_pool}:cloudinit
    EOT
  }
}

# Create cloud-init vendor configuration
resource "local_file" "cloud_init_vendor" {
  filename = "/var/lib/vz/snippets/${var.cloud_init_file_name}"
  content = templatefile("${path.module}/templates/vendor.yaml.tftpl", {
    packages          = var.cloud_init_packages
    runcmd            = var.cloud_init_runcmd
    additional_config = var.cloud_init_additional_config
  })

  depends_on = [proxmox_vm_qemu.template]
}

# Configure cloud-init settings
resource "null_resource" "configure_cloud_init" {
  depends_on = [
    null_resource.configure_disk,
    local_file.cloud_init_vendor
  ]

  triggers = {
    vm_id           = var.vm_id
    cloud_init_file = var.cloud_init_file_name
    tags            = join(",", var.tags)
    user            = var.cloud_init_user
    ssh_keys_file   = var.ssh_keys_file
    ip_config       = var.ip_config
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      # Set custom cloud-init vendor file
      qm set ${var.vm_id} --cicustom "vendor=local:snippets/${var.cloud_init_file_name}"
      
      # Add tags
      qm set ${var.vm_id} --tags "${join(",", var.tags)}"
      
      # Set cloud-init user
      qm set ${var.vm_id} --ciuser ${var.cloud_init_user}
      
      # Import SSH keys
      qm set ${var.vm_id} --sshkeys ${var.ssh_keys_file}
      
      # Set IP configuration
      qm set ${var.vm_id} --ipconfig0 ${var.ip_config}
    EOT
  }
}

# Convert to template
resource "null_resource" "convert_to_template" {
  depends_on = [null_resource.configure_cloud_init]

  triggers = {
    vm_id = var.vm_id
  }

  provisioner "local-exec" {
    command = "qm template ${var.vm_id}"
  }
}

# Clean up downloaded image
resource "null_resource" "cleanup" {
  depends_on = [null_resource.convert_to_template]

  triggers = {
    image_name = var.image_name
  }

  provisioner "local-exec" {
    command = "rm -f '${var.image_name}'"
  }
}
