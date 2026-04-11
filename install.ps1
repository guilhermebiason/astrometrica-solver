# Astrometrica Toolkit - Bootstrap
# Uso: irm https://raw.githubusercontent.com/guilhermebiason/astrometrica-solver/main/install.ps1 | iex

$url  = "https://raw.githubusercontent.com/guilhermebiason/astrometrica-solver/main/Astrometrica_Toolkit_V1.0_PTBR.bat"
$dest = Join-Path $env:TEMP "Astrometrica_Toolkit.bat"

Write-Host ""
Write-Host "[Astrometrica Toolkit] Baixando Astrometrica Toolkit V1.0..." -ForegroundColor Cyan

try {
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -ErrorAction Stop
    Write-Host "[Astrometrica Toolkit] Download concluido." -ForegroundColor Green
} catch {
    Write-Host "[ERRO] Falha ao baixar o arquivo: $_" -ForegroundColor Red
    exit 1
}

Write-Host "[Astrometrica Toolkit] Iniciando..." -ForegroundColor Cyan
Write-Host ""

Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$dest`"" -Wait -NoNewWindow

Remove-Item $dest -Force -ErrorAction SilentlyContinue
