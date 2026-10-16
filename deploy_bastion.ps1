# =============================================================================
# Azure Bastion Deployment Automation Script
# Assignment: Cloud VM Connectivity
# =============================================================================

$SUBSCRIPTION_ID = "<subscription-id>"
$LOCATION        = "westeurope"
$RG_NAME         = "rg-vm-access-weu"
$VNET_NAME       = "vnet-vm-access-weu"
$BASTION_NAME    = "bastion-weu"
$BASTION_IP_NAME = "pip-bastion-weu"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Azure Bastion Service Deployment" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# ── Set active subscription ───────────────────────────────────────────────────
az account set --subscription $SUBSCRIPTION_ID

# ── 1. Create AzureBastionSubnet ──────────────────────────────────────────────
Write-Host "[1/3] Creating subnet 'AzureBastionSubnet'..." -ForegroundColor Yellow
# Note: Azure Bastion requires a subnet named exactly 'AzureBastionSubnet' with prefix >= /26
$subnetExists = az network vnet subnet list -g $RG_NAME --vnet-name $VNET_NAME --query "[?name=='AzureBastionSubnet'].name" -o tsv
if ($null -eq $subnetExists -or $subnetExists -eq "") {
    az network vnet subnet create `
        --resource-group $RG_NAME `
        --vnet-name $VNET_NAME `
        --name "AzureBastionSubnet" `
        --address-prefixes "10.0.1.0/26" `
        --output none
    Write-Host "  [OK] Subnet 'AzureBastionSubnet' (10.0.1.0/26) created." -ForegroundColor Green
} else {
    Write-Host "  [OK] Subnet 'AzureBastionSubnet' already exists." -ForegroundColor Gray
}

# ── 2. Create Public IP for Bastion ───────────────────────────────────────────
Write-Host "[2/3] Creating Public IP for Azure Bastion..." -ForegroundColor Yellow
$ipExists = az network public-ip show -g $RG_NAME -n $BASTION_IP_NAME --query name -o tsv 2>$null
if ($null -eq $ipExists -or $ipExists -eq "") {
    az network public-ip create `
        --resource-group $RG_NAME `
        --name $BASTION_IP_NAME `
        --sku Standard `
        --location $LOCATION `
        --output none
    Write-Host "  [OK] Public IP '$BASTION_IP_NAME' created." -ForegroundColor Green
} else {
    Write-Host "  [OK] Public IP '$BASTION_IP_NAME' already exists." -ForegroundColor Gray
}

# ── 3. Deploy Azure Bastion Host ──────────────────────────────────────────────
Write-Host "[3/3] Deploying Azure Bastion Host '$BASTION_NAME'..." -ForegroundColor Yellow
Write-Host "      (Note: Bastion deployment usually takes 5-10 minutes to complete.)" -ForegroundColor Gray

az network bastion create `
    --name $BASTION_NAME `
    --public-ip-address $BASTION_IP_NAME `
    --resource-group $RG_NAME `
    --vnet-name $VNET_NAME `
    --location $LOCATION `
    --sku Basic `
    --output none

Write-Host "  [OK] Azure Bastion Host '$BASTION_NAME' deployed successfully." -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Deployment Complete! You can now connect to your VMs via browser." -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "--- CONNECTION VERIFICATION STEPS ---" -ForegroundColor Yellow
Write-Host "1. Navigate to the Azure Portal: https://portal.azure.com" -ForegroundColor White
Write-Host "2. Go to Virtual Machines and select either 'vm-linux-weu' or 'vm-windows-weu'." -ForegroundColor White
Write-Host "3. Click Connect -> Connect via Bastion." -ForegroundColor White
Write-Host "4. Enter your credentials:" -ForegroundColor White
Write-Host "   - Username: azureadmin" -ForegroundColor White
Write-Host "   - Password/SSH Key as configured." -ForegroundColor White
Write-Host "5. The VM terminal or desktop session will open securely in a new browser tab." -ForegroundColor White
Write-Host "-------------------------------------" -ForegroundColor Yellow
Write-Host ""
