# Ansible Role: Proxmox LXC Template Manager

[![CI](https://github.com/disgone/project-terminus/actions/workflows/ci.yml/badge.svg)](https://github.com/disgone/project-terminus/actions/workflows/ci.yml)

Downloads and manages LXC container templates on Proxmox VE nodes using the native `pveam` (Proxmox VE Appliance Manager) tool. This role ensures specified templates are available across multiple Proxmox nodes without manual intervention.

## Requirements

- Proxmox VE node with `pveam` command available
- Root or sudo access on Proxmox nodes
- Network connectivity to Proxmox template repositories
- Sufficient storage space for templates

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

### Template Management

    lxctemplatedl_update_list: true

Whether to run `pveam update` to refresh the available template list before operations. Recommended to keep enabled for latest template availability.

    lxctemplatedl_ensure_present: true

Whether to ensure templates in the `lxctemplatedl_templates` list are downloaded and present on the node.

### Storage Configuration

    lxctemplatedl_storage: local

The Proxmox storage identifier where templates should be downloaded. Use `pveam list` to see available storage options.

### Templates Configuration

    lxctemplatedl_templates: []

List of templates to manage. Each template requires a `name` field. The `section` field is optional and used for documentation purposes.

Example configuration:

    lxctemplatedl_templates:
      - name: "ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
      - name: "debian-12-standard_12.2-1_amd64.tar.zst"
      - name: "alpine-3.18-default_20230607_amd64.tar.xz"

### Template Operations

    lxctemplatedl_force_download: false

Whether to force re-download templates even if they already exist. Useful for updating existing templates to newer versions.

    lxctemplatedl_timeout: 300

Timeout in seconds for individual template download operations.

## Dependencies

None.

## Example Playbook

### Basic Usage - Download Standard Templates

    ---
    - hosts: proxmox_nodes
      become: true
      vars:
        lxctemplatedl_templates:
          - name: "ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
          - name: "debian-12-standard_12.2-1_amd64.tar.zst"
      roles:
        - lxctemplatedl

### Multi-Node Template Synchronization

    ---
    - hosts: proxmox_cluster
      become: true
      vars:
        lxctemplatedl_storage: "shared-storage"
        lxctemplatedl_templates:
          - name: "ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
          - name: "ubuntu-20.04-standard_20.04-1_amd64.tar.zst"
          - name: "debian-12-standard_12.2-1_amd64.tar.zst"
          - name: "alpine-3.18-default_20230607_amd64.tar.xz"
      roles:
        - lxctemplatedl

### Force Update Existing Templates

    ---
    - hosts: proxmox_nodes
      become: true
      vars:
        lxctemplatedl_force_download: true
        lxctemplatedl_timeout: 600
        lxctemplatedl_templates:
          - name: "ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
      roles:
        - lxctemplatedl

### Conditional Template Management

    ---
    - hosts: proxmox_nodes
      become: true
      vars:
        lxctemplatedl_update_list: "{{ update_templates | default(true) }}"
        lxctemplatedl_ensure_present: "{{ deploy_templates | default(true) }}"
        lxctemplatedl_templates:
          - name: "{{ primary_template | default('ubuntu-22.04-standard_22.04-1_amd64.tar.zst') }}"
      roles:
        - lxctemplatedl

## Finding Template Names

To find available template names, run on any Proxmox node:

    # Update template list
    pveam update
    
    # List all available templates
    pveam available
    
    # List available system templates only
    pveam available --section system

Common template naming patterns:

- **Ubuntu**: `ubuntu-{VERSION}-standard_{VERSION}-{BUILD}_amd64.tar.zst`
- **Debian**: `debian-{VERSION}-standard_{VERSION}-{BUILD}_amd64.tar.zst`
- **Alpine**: `alpine-{VERSION}-default_{DATE}_amd64.tar.xz`
- **CentOS/AlmaLinux**: `centos-{VERSION}-default_{DATE}_amd64.tar.xz`

## Role Behavior

1. **Updates template list** (if enabled) using `pveam update`
2. **Checks available templates** to validate requested templates exist
3. **Lists currently downloaded templates** to determine what needs downloading
4. **Downloads missing templates** (normal mode) - only if not already present
5. **Force downloads templates** (force mode) - downloads regardless of current state
6. **Verifies final state** and displays downloaded templates

## Tags

All tasks are tagged for selective execution:

- `proxmox` - All Proxmox-related tasks
- `templates` - All template management tasks

Example usage:

    ansible-playbook site.yml --tags "templates"
    ansible-playbook site.yml --skip-tags "proxmox"

## Idempotency

This role is designed to be idempotent:

- Templates are only downloaded if not already present (unless force mode is enabled)
- The `pveam update` command only reports as changed when explicitly enabled
- Template verification uses `changed_when: false` to avoid unnecessary change reports

## Error Handling

- Failed template downloads will cause the playbook to fail
- Invalid template names are detected before download attempts
- Storage verification prevents downloads to non-existent storage

## License

MIT

## Author Information

This role was created as part of the project-terminus infrastructure automation suite for managing LXC templates across multiple Proxmox VE nodes.
