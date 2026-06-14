# NSG Security Configuration Report

## Overview
This document details the Network Security Group (NSG) rules configured for both Virtual Machines in this assignment. NSGs act as a cloud-based firewall, controlling inbound and outbound traffic at the network interface and subnet level.

---

## Resource Group
- **Name:** `rg-vm-access-weu`
- **Location:** West Europe

---

## Linux VM — NSG: `nsg-linux-weu`

### Inbound Security Rules

| Priority | Name               | Port | Protocol | Source IP          | Action |
|----------|--------------------|------|----------|--------------------|--------|
| 1000     | default-allow-ssh  | 22   | TCP      | 197.211.52.179    | Allow  |
| 65000    | AllowVnetInBound   | Any  | Any      | VirtualNetwork     | Allow  |
| 65001    | AllowAzureLoadBalancerInBound | Any | Any | AzureLoadBalancer | Allow |
| 65500    | DenyAllInBound     | Any  | Any      | *                  | Deny   |

### Security Rationale
The SSH rule (port 22) was initially open to `*` (any source) to allow initial connectivity. It was then locked down to a single specific source IP address (`197.211.52.179`) using the `secure_nsg.ps1` script. This restricts management access exclusively to the administrator's workstation, preventing brute-force attacks and unauthorized access from internet-facing scanners.

---

## Windows VM — NSG: `nsg-windows-weu`

### Inbound Security Rules

| Priority | Name    | Port | Protocol | Source IP       | Action |
|----------|---------|------|----------|-----------------|--------|
| 1000     | rdp     | 3389 | TCP      | 197.211.52.179 | Allow  |
| 65000    | AllowVnetInBound | Any | Any | VirtualNetwork | Allow |
| 65001    | AllowAzureLoadBalancerInBound | Any | Any | AzureLoadBalancer | Allow |
| 65500    | DenyAllInBound | Any | Any | * | Deny |

### Security Rationale
The RDP rule (port 3389) was similarly restricted from `*` to the administrator's specific IP (`197.211.52.179`). Remote Desktop Protocol is a common target for credential-stuffing attacks; restricting the source IP eliminates the vast majority of attack surface.

---

## 3. Azure Bastion Network Security Architecture

Azure Bastion provides secure and seamless RDP/SSH connectivity to your virtual machines directly in the Azure Portal over SSL/TLS (Port 443). By deploying Bastion, we can completely eliminate public IP addresses on individual VMs and block direct remote access from the internet.

### Secure Network Topology

When using Azure Bastion, the network architecture is structured as follows:

```
[User Browser] (HTTPS: 443) 
       │
       ▼
[Azure Bastion Service] (in AzureBastionSubnet, Public IP: pip-bastion-weu)
       │
       ├─► (RDP: 3389) ─► [Windows VM (vm-windows-weu)] (Private IP: 10.0.0.5)
       └─► (SSH: 22)   ─► [Linux VM (vm-linux-weu)]     (Private IP: 10.0.0.4)
```

### VM-level Network Security Groups (NSGs) Hardening

With Azure Bastion deployed, we can restrict the VM NSG rules to block all direct internet access and only permit traffic originating from the `AzureBastionSubnet` (`10.0.1.0/26`).

#### Hardened Inbound Rules for `nsg-linux-weu` (SSH via Bastion)
| Priority | Name               | Port | Protocol | Source IP                  | Action | Description |
|----------|--------------------|------|----------|----------------------------|--------|-------------|
| 900      | AllowBastionSSH    | 22   | TCP      | `10.0.1.0/26` (Bastion)    | Allow  | Permits Bastion SSH session |
| 1000     | default-allow-ssh  | 22   | TCP      | `197.211.52.179` (Admin)   | Allow  | Direct SSH (Whitelisted Admin) |
| 65500    | DenyAllInBound     | Any  | Any      | *                          | Deny   | Blocks all other inbound traffic |

#### Hardened Inbound Rules for `nsg-windows-weu` (RDP via Bastion)
| Priority | Name               | Port | Protocol | Source IP                  | Action | Description |
|----------|--------------------|------|----------|----------------------------|--------|-------------|
| 900      | AllowBastionRDP    | 3389 | TCP      | `10.0.1.0/26` (Bastion)    | Allow  | Permits Bastion RDP session |
| 1000     | rdp                | 3389 | TCP      | `197.211.52.179` (Admin)   | Allow  | Direct RDP (Whitelisted Admin) |
| 65500    | DenyAllInBound     | Any  | Any      | *                          | Deny   | Blocks all other inbound traffic |

> **Best Practice Recommendation**: In a strict production environment, we should remove the direct SSH/RDP whitelisting rules (Priority 1000) entirely and delete the public IPs from the VMs. Access should be mediated exclusively via Azure Bastion, securing the VMs behind a zero-trust boundary.

---

## 4. Security Script

The `secure_nsg.ps1` PowerShell script automates the IP-restriction lockdown:

```powershell
# Restricts both NSGs to admin IP
az network nsg rule update --resource-group rg-vm-access-weu \
    --nsg-name "nsg-linux-weu" --name "default-allow-ssh" \
    --source-address-prefixes 197.211.52.179

az network nsg rule update --resource-group rg-vm-access-weu \
    --nsg-name "nsg-windows-weu" --name "rdp" \
    --source-address-prefixes 197.211.52.179
```

---

## Evidence Screenshots

| Screenshot | Description |
|------------|-------------|
| `screenshots/vm_list_portal.png` | Azure Portal showing both VMs running |
| `screenshots/nsg_linux_ssh_rule.png` | Linux NSG SSH rule with restricted source IP |
| `screenshots/nsg_windows_rdp_rule.png` | Windows NSG RDP rule with restricted source IP |
| `screenshots/ssh_linux_connection.png` | Successful SSH connection to vm-linux-weu |
| `screenshots/bastion_windows_connect.png` | Successful browser-based RDP connection to vm-windows-weu via Azure Bastion |
| `screenshots/bastion_linux_connect.png` | Successful browser-based SSH connection to vm-linux-weu via Azure Bastion |

