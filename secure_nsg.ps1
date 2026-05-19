# =============================================================================
# Secure NSG Script
# Restricts SSH and RDP access to the administrator's specific IP address
# =============================================================================

$RG_NAME     = "rg-vm-access-weu"
$ADMIN_IP    = "197.211.52.179"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Securing Network Security Groups (NSGs)" -ForegroundColor Cyan
Write-Host "  Restricting access to Admin IP: $ADMIN_IP" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# ── 1. Secure Linux NSG (Port 22) ─────────────────────────────────────────────
Write-Host "Securing Linux VM (nsg-linux-weu)..." -ForegroundColor Yellow
az network nsg rule update `
    --resource-group $RG_NAME `
    --nsg-name "nsg-linux-weu" `
    --name "default-allow-ssh" `
    --source-address-prefixes $ADMIN_IP `
    --output none

Write-Host "  [OK] SSH access restricted to $ADMIN_IP" -ForegroundColor Green

# ── 2. Secure Windows NSG (Port 3389) ─────────────────────────────────────────
Write-Host "Securing Windows VM (nsg-windows-weu)..." -ForegroundColor Yellow
az network nsg rule update `
    --resource-group $RG_NAME `
    --nsg-name "nsg-windows-weu" `
    --name "rdp" `
    --source-address-prefixes $ADMIN_IP `
    --output none

Write-Host "  [OK] RDP access restricted to $ADMIN_IP" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  NSG Security Configuration Complete!" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
