# Deploy Supabase to Synology NAS via SSH
# Usage: .\deploy-nas.ps1

param(
    [string]$User = "Artiros",
    [string]$Host_IP = "192.168.50.44",
    [string]$RemotePath = "/volume2/docker/supabase"
)

$ErrorActionPreference = "Stop"
$TarFile = "deploy_bundle.tar"

Write-Host "--- Deploying Supabase to NAS (${User}@${Host_IP}:${RemotePath}) ---" -ForegroundColor Cyan

# 1. Create deployment archive (excluding unnecessary files)
Write-Host "Creating local archive $TarFile..."
tar --exclude='.git' --exclude='.vscode' --exclude='volumes/db/data' --exclude="$TarFile" -cf $TarFile .

if (-not (Test-Path $TarFile)) {
    Write-Error "Failed to create tar file."
    exit 1
}

# 2. Ensure remote directory exists
Write-Host "Creating remote directory if needed..."
ssh "${User}@${Host_IP}" "mkdir -p $RemotePath"

# 3. Upload archive  
Write-Host "Uploading archive..."
scp -O $TarFile "${User}@${Host_IP}:${RemotePath}/${TarFile}"

# 4. Remote Commands - create dirs, extract, and start
Write-Host "Connecting via SSH to setup and start..."

ssh -t "${User}@${Host_IP}" "cd $RemotePath && mkdir -p volumes/db/data volumes/storage volumes/api volumes/pooler volumes/logs volumes/functions/main && tar -xf $TarFile && rm $TarFile && echo 'Files extracted. Starting Supabase...' && sudo /usr/local/bin/docker-compose down 2>/dev/null; sudo /usr/local/bin/docker-compose up -d"

# 5. Cleanup local
if (Test-Path $TarFile) { Remove-Item $TarFile }

Write-Host "--- Deployment Complete! ---" -ForegroundColor Green
Write-Host ""
Write-Host "Supabase URLs:" -ForegroundColor Cyan
Write-Host "  API Gateway:      http://${Host_IP}:8100" -ForegroundColor White
Write-Host "  Studio Dashboard: http://${Host_IP}:8100" -ForegroundColor White
Write-Host "  Direct Studio:    http://${Host_IP}:3100" -ForegroundColor White
Write-Host "  Database:         postgresql://postgres@${Host_IP}:5432/postgres" -ForegroundColor White
Write-Host ""
Write-Host "Dashboard login: supabase / (see .env for password)" -ForegroundColor Yellow
