# Copilot Instructions

This repository has a style guide for AI assistants in [agents.md](../agents.md).  
All suggestions must follow the rules defined there.  

Key points for Copilot:
- **Project context**: this is a homelab automation project.  
- **Goals**: repeatability, simplicity, flexibility.  
- **Naming rules**: use generic names for modules, specific names for stacks.  
- **Do not** bake tool names (terraform, tofu, ansible, packer) or vendor names (Proxmox, k3s) into folder/module names.  
- **Red flags**: no CI/CD pipelines, Helm charts, or enterprise over-engineering for 3 VMs.  

When generating code, project layouts, or configs:
- First, consult `agents.md` for detailed rules.  
- Always explain why a suggestion is good or bad in this context.  
