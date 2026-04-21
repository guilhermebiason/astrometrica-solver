$url  = "https://raw.githubusercontent.com/guilhermebiason/astrometrica-solver/main/Astrometrica_Toolkit_Ver1.2.ps1"
$dest = Join-Path $env:TEMP "Astrometrica_Toolkit_Ver1.2.ps1"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host ""
Write-Host "[Astrometrica Toolkit] Baixando..." -ForegroundColor Cyan

try {
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -ErrorAction Stop
    Write-Host "[Astrometrica Toolkit] Download concluido." -ForegroundColor Green
} catch {
    Write-Host "[ERRO] Falha ao baixar o arquivo: $_" -ForegroundColor Red
    exit 1
}

Write-Host "[Astrometrica Toolkit] Iniciando..." -ForegroundColor Cyan
Write-Host ""

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$dest`"" -Wait
} else {
    Write-Host "[Astrometrica Toolkit] Solicitando permissao de administrador..." -ForegroundColor Yellow
    Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$dest`"" -Verb RunAs -Wait
}

Remove-Item $dest -Force -ErrorAction SilentlyContinue
