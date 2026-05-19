# =============================================================================
# Azure VM Access and Networking Setup Script
# Assignment: Cloud VM Connectivity
# =============================================================================

$SUBSCRIPTION_ID = "9335a9cd-ae74-439b-94b3-d965ca478c53"
$LOCATION        = "westeurope"
$RG_NAME         = "rg-vm-access-weu"
$ADMIN_USER      = "azureadmin"
$ADMIN_PASS      = "Password123!@#"  # Note: Required for Windows VM

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Azure VM Infrastructure Setup" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# ── Set active subscription ───────────────────────────────────────────────────
az account set --subscription $SUBSCRIPTION_ID

# ── Create Resource Group ─────────────────────────────────────────────────────
Write-Host "[1/3] Creating Resource Group..." -ForegroundColor Yellow
az group create --name $RG_NAME --location $LOCATION --output none
Write-Host "  [OK] $RG_NAME created." -ForegroundColor Green

# ── Deploy Linux VM ───────────────────────────────────────────────────────────
Write-Host "[2/3] Deploying Linux VM (Ubuntu)... This will take a few minutes." -ForegroundColor Yellow
az vm create `
    --resource-group $RG_NAME `
    --name "vm-linux-weu" `
    --image "Ubuntu2204" `
    --admin-username $ADMIN_USER `
    --generate-ssh-keys `
    --public-ip-sku Standard `
    --nsg "nsg-linux-weu" `
    --size "Standard_B2ts_v2" `
    --output none
Write-Host "  [OK] Linux VM deployed." -ForegroundColor Green

# ── Deploy Windows VM ─────────────────────────────────────────────────────────
Write-Host "[3/3] Deploying Windows VM (Server 2022)... This will take a few minutes." -ForegroundColor Yellow
az vm create `
    --resource-group $RG_NAME `
    --name "vm-windows-weu" `
    --image "Win2022Datacenter" `
    --admin-username $ADMIN_USER `
    --admin-password $ADMIN_PASS `
    --public-ip-sku Standard `
    --nsg "nsg-windows-weu" `
    --size "Standard_B2ts_v2" `
    --output none
Write-Host "  [OK] Windows VM deployed." -ForegroundColor Green

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Setup Complete! Gathering Connection Details..." -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

$LINUX_IP = az vm show -d -g $RG_NAME -n "vm-linux-weu" --query publicIps -o tsv
$WIN_IP   = az vm show -d -g $RG_NAME -n "vm-windows-weu" --query publicIps -o tsv

Write-Host ""
Write-Host "--- CONNECTION DETAILS ---" -ForegroundColor Yellow
Write-Host "Linux VM Public IP: " -NoNewline; Write-Host $LINUX_IP -ForegroundColor White
Write-Host "  SSH Command:      ssh $ADMIN_USER@$LINUX_IP" -ForegroundColor White
Write-Host ""
Write-Host "Windows VM Public IP:" -NoNewline; Write-Host $WIN_IP -ForegroundColor White
Write-Host "  RDP Username:     $ADMIN_USER" -ForegroundColor White
Write-Host "  RDP Password:     $ADMIN_PASS" -ForegroundColor White
Write-Host "--------------------------" -ForegroundColor Yellow
Write-Host ""
