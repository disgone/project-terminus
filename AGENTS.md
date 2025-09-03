# agents.md

## Purpose  
This file explains the **rules and style guide** for any AI assistant or agent generating infrastructure code or project structure for my homelab.  

The goal is to ensure **repeatability, simplicity, and flexibility** without over-engineering or baking in assumptions.

---

## Context  
- This is a **homelab project**, not enterprise infra.  
- All tooling runs in a **devcontainer** on Windows.  
- Current tools: **OpenTofu + Ansible**, but folder names and modules must remain **tool-agnostic**.  
- Scope for now:  
  - Automate creating/refreshing a **virtual machine template**.  
  - Clone multiple **virtual machines** (3+) from that template.  
  - Prepare them for configuration management (e.g., Ansible installing k3s).  

---

## Naming Rules  
1. **Generic until it can’t be**  
   - Modules = generic, reusable building blocks.  
   - Stacks = specific, outcome-focused compositions.  

2. **Modules**  
   - Always singular (`virtual_machine_template`, not `virtual_machine_templates`).  
   - Scoped by function, not vendor (`virtual_machine_template`, `network_bridge`, not `proxmox_template`).  

3. **Stacks**  
   - Specific to my homelab outcomes (`cluster_nodes`, `storage_server`).  
   - All stacks live under `stacks/homelab/`.  

4. **Tools never in names**  
   - Never use `terraform`, `tofu`, `ansible`, `packer` in folder/module names.  

5. **OS/distro only when necessary**  
   - Allowed only in var/file names (e.g., `vars/ubuntu-24.04.pkrvars.hcl`).  

6. **Clarity > brevity**  
   - Use scope prefixes if needed to avoid ambiguity.  

---

## Examples  

✅ `infrastructure/modules/virtual_machine_template/`  
- Good: describes a reusable building block (generic VM template).  
- Not tied to Proxmox or any one hypervisor.  

✅ `infrastructure/stacks/homelab/cluster_nodes/`  
- Good: outcome-specific for my homelab.  
- Clear, specific, but still flexible (not tied to k3s, just “nodes”).  

❌ `infrastructure/modules/proxmox_template/`  
- Bad: vendor-locked (Proxmox). Would require renaming if hypervisor changes.  

❌ `terraform/ubuntu-template/`  
- Bad: tool name (terraform) and distro name (ubuntu) baked in. Locks me into Terraform + Ubuntu.  

---

## Red Flags (never do these)  
- Don’t suggest CI/CD pipelines, Helm charts, or service meshes for 3 VMs.  
- Don’t bake vendor names (Proxmox, k3s) into module names.  
- Don’t hardcode tool names into folder structure.  
