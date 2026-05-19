# Azure VM Access and Networking Assignment

## Project Overview
This project focuses on the fundamental cloud skill of securely accessing and managing cloud-based virtual machines remotely using Microsoft Azure. I deployed both Windows and Linux virtual machines, configured Network Security Groups (NSGs) for secure remote management, and demonstrated cross-platform connectivity using industry-standard protocols (RDP and SSH).

## Project Goals Achieved
* ✅ Deployed Azure infrastructure including Resource Groups, VNets, and Virtual Machines.
* ✅ Established secure remote connections to a Windows VM using RDP (Remote Desktop Protocol).
* ✅ Established secure remote connections to a Linux VM using SSH (Secure Shell).
* ✅ Implemented security best practices by restricting inbound NSG rules to a specific source IP address.
* ✅ Documented the connectivity procedures and troubleshooting methodologies.

---

## Infrastructure Configuration

- **Resource Group:** `rg-vm-access-weu`
- **Location:** West Europe
- **Linux VM:** `vm-linux-weu` (Ubuntu 22.04 LTS, Standard_B2ts_v2)
- **Windows VM:** `vm-windows-weu` (Windows Server 2022 Datacenter, Standard_B2ts_v2)

---

## Remote Access Procedures

### 1. Connecting to the Linux VM (SSH)
1. Ensure your IP address is whitelisted in the NSG (`nsg-linux-weu`).
2. Open a terminal or command prompt.
3. Use the SSH command with the VM's public IP:
   ```bash
   ssh azureadmin@4.180.47.161
   ```
4. Accept the host key fingerprint if prompted, and authenticate using the generated SSH key.

### 2. Connecting to the Windows VM (RDP)
1. Ensure your IP address is whitelisted in the NSG (`nsg-windows-weu`).
2. Open the **Remote Desktop Connection** client on your local machine.
3. Enter the Windows VM's Public IP: `20.229.20.124`.
4. Click **Connect** and enter the credentials:
   - **Username:** `azureadmin`
   - **Password:** `Password123!@#`
5. Accept the security certificate warning to establish the remote desktop session.

---

## Security Implementation: NSG Configuration

Initially, the Virtual Machines were provisioned with default open ports for RDP (3389) and SSH (22) to the entire internet (`*`). To adhere to cloud security best practices, the Network Security Group rules were updated to restrict inbound management traffic strictly to my local IP address.

### Security Script Execution (`secure_nsg.ps1`)
The provided PowerShell script automates the lockdown of both NSGs:
- Updates `default-allow-ssh` rule on `nsg-linux-weu` to only allow traffic from `197.211.52.179`.
- Updates `default-allow-rdp` rule on `nsg-windows-weu` to only allow traffic from `197.211.52.179`.

This prevents unauthorized scanning and brute-force attacks from malicious actors on the internet.

---

## Evidence

### SSH Connection to Linux VM
![SSH Connection to vm-linux-weu](screenshots/ssh_linux_connection.png)
*Successful SSH session — hostname `vm-linux-weu`, user `azureadmin`, Ubuntu 22.04 LTS*

### VM Inventory (Azure Portal)
![Azure Portal VM List](screenshots/vm_list_portal.png)
*Both VMs running in West Europe on Standard_B2ts_v2*

### Linux NSG — SSH Rule Restricted to Admin IP
![Linux NSG SSH Rule](screenshots/nsg_linux_ssh_rule.png)
*Port 22 restricted to 197.211.52.179 only*

### Windows NSG — RDP Rule Restricted to Admin IP
![Windows NSG RDP Rule](screenshots/nsg_windows_rdp_rule.png)
*Port 3389 restricted to 197.211.52.179 only*

### RDP Connection to Windows VM
![RDP Connection to vm-windows-weu](screenshots/rdp_windows_connection.png)
*Successful RDP session to `vm-windows-weu` at `20.229.20.124` using credentials `azureadmin`*

---

## Project Files

| File | Description |
|------|-------------|
| `vm_setup.ps1` | Provisions the resource group, Linux VM, and Windows VM with open NSG rules for initial setup |
| `secure_nsg.ps1` | Locks down both NSGs to restrict SSH and RDP to admin IP only |
| `nsg_config.md` | Detailed NSG rule documentation and security rationale |
| `screenshots/` | Evidence screenshots of VMs, connections, and NSG configurations |
