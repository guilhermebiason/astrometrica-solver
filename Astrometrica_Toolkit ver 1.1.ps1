#Requires -Version 5.1

<#
.SYNOPSIS
    Astrometrica Toolkit - Ferramenta de suporte para o software Astrometrica no Windows.
.DESCRIPTION
    Corrige erros comuns de paths, gerencia pastas, inicia o executavel e exibe status do ambiente.
.NOTES
    Dev: G. Biason
    mail: guilhermebiason@usp.br
    License: GNU General Public License v3
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
$LOCAL_DIR    = "$env:LOCALAPPDATA\Astrometrica"
$DATA_DIR     = "C:\Astrometrica\Data"
$CATALOG_DIR  = "C:\Astrometrica\Catalogs"
$EXE_PATH     = "C:\Astrometrica\Astrometrica.exe"
$MPCORB_URL   = "https://minorplanetcenter.net/iau/MPCORB/MPCORB.DAT"
$MPCORB_DEST  = "$CATALOG_DIR\MPCORB.DAT"

# ---------------------------------------------------------------------------
# Helpers de output colorido
# ---------------------------------------------------------------------------
function Write-Ok($msg)      { Write-Host "[OK]      " -ForegroundColor Green  -NoNewline; Write-Host $msg }
function Write-Check($msg)   { Write-Host "[CHECK]   " -ForegroundColor Green  -NoNewline; Write-Host $msg }
function Write-Warn($msg)    { Write-Host "[AVISO]   " -ForegroundColor Yellow -NoNewline; Write-Host $msg }
function Write-Err($msg)     { Write-Host "[ERRO]    " -ForegroundColor Red    -NoNewline; Write-Host $msg }
function Write-Removed($msg) { Write-Host "[REMOVED] " -ForegroundColor Green  -NoNewline; Write-Host $msg }
function Write-Missing($msg) { Write-Host "[MISSING] " -ForegroundColor Red    -NoNewline; Write-Host $msg }

function Pause-Return {
    Write-Host ""
    Write-Host "Pressione qualquer tecla para voltar ao menu..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Confirm-Action($prompt) {
    Write-Host ""
    $answer = Read-Host "$prompt [S/N]"
    return ($answer -match "^[Ss]$")
}

# ---------------------------------------------------------------------------
# Verificacao de administrador
# ---------------------------------------------------------------------------
function Test-Admin {
    $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ---------------------------------------------------------------------------
# Menu principal
# ---------------------------------------------------------------------------
function Show-Menu {
    Clear-Host
    Write-Host "Astrometrica Toolkit Ver 2.0 (PowerShell)" -ForegroundColor White
    if (Test-Admin) {
        Write-Host "[Executando como Administrador]" -ForegroundColor Green
    } else {
        Write-Host "[Sem privilegios de Administrador]" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "  [1]" -ForegroundColor Yellow -NoNewline; Write-Host " Corrigir Runtime Error 217 (LocalAppData)"
    Write-Host "  [2]" -ForegroundColor Yellow -NoNewline; Write-Host " Corrigir I/O Error 103 (MPCOrbit.txt)"
    Write-Host "  [3]" -ForegroundColor Yellow -NoNewline; Write-Host " Remover pastas criadas (limpeza)"
    Write-Host "  [4]" -ForegroundColor Yellow -NoNewline; Write-Host " Iniciar Astrometrica.exe"
    Write-Host "  [5]" -ForegroundColor Yellow -NoNewline; Write-Host " Verificar Status"
    Write-Host "  [6]" -ForegroundColor Yellow -NoNewline; Write-Host " LEIA-ME"
    Write-Host "  [7]" -ForegroundColor Yellow -NoNewline; Write-Host " Sair"
    Write-Host "  [8]" -ForegroundColor Cyan   -NoNewline; Write-Host " Baixar catalogo MPC Orbit (MPCORB.DAT)"
    Write-Host ""
}

# ---------------------------------------------------------------------------
# [1] Corrigir Runtime Error 217
# ---------------------------------------------------------------------------
function Fix-RuntimeError {
    Clear-Host
    Write-Host "[Runtime error 217 fix]" -ForegroundColor White
    Write-Host ""
    Write-Host "Verificando pasta LocalAppData..." -ForegroundColor Yellow

    try {
        if (-not (Test-Path $LOCAL_DIR)) {
            New-Item -ItemType Directory -Path $LOCAL_DIR -Force | Out-Null
            Write-Check "Pasta criada com sucesso em: `"$LOCAL_DIR`""
        } else {
            Write-Ok "A pasta ja existe: `"$LOCAL_DIR`""
            Write-Host "     Nenhuma acao necessaria."
        }
    } catch {
        Write-Err "Falha ao criar pasta: $_"
        Write-Warn "Tente executar o toolkit como Administrador."
    }

    Pause-Return
}

# ---------------------------------------------------------------------------
# [2] Corrigir I/O Error 103
# ---------------------------------------------------------------------------
function Fix-IOError {
    Clear-Host
    Write-Host "[I/O error 103 fix]" -ForegroundColor White
    Write-Host ""
    Write-Host "Verificando caminho de dados..." -ForegroundColor Yellow

    try {
        if (-not (Test-Path $DATA_DIR)) {
            New-Item -ItemType Directory -Path $DATA_DIR -Force | Out-Null
            Write-Check "Pasta criada em: `"$DATA_DIR`""
        } else {
            Write-Ok "A pasta ja existe: `"$DATA_DIR`""
            Write-Host "     Nenhuma acao necessaria."
        }
    } catch {
        Write-Err "Falha ao criar pasta: $_"
        Write-Warn "Tente executar o toolkit como Administrador."
    }

    Pause-Return
}

# ---------------------------------------------------------------------------
# [3] Menu de limpeza
# ---------------------------------------------------------------------------
function Remove-Folder($path, $label) {
    if (Test-Path $path) {
        if (Confirm-Action "Excluir a pasta `"$path`"?") {
            try {
                Remove-Item -Path $path -Recurse -Force
                Write-Removed "`"$path`" removida com sucesso."
            } catch {
                Write-Err "Falha ao remover `"$path`": $_"
            }
        } else {
            Write-Host "Operacao cancelada." -ForegroundColor DarkGray
        }
    } else {
        Write-Missing "`"$path`" nao existe."
    }
}

function Show-CleanupMenu {
    Clear-Host
    Write-Host "[Menu de limpeza]" -ForegroundColor White
    Write-Host ""
    Write-Host "Selecione qual pasta deseja remover:"
    Write-Host ""
    Write-Host "  [1]" -ForegroundColor Yellow -NoNewline; Write-Host " LocalAppData: ($LOCAL_DIR)"
    Write-Host "  [2]" -ForegroundColor Yellow -NoNewline; Write-Host " Data Folder:  ($DATA_DIR)"
    Write-Host "  [3]" -ForegroundColor Yellow -NoNewline; Write-Host " Remover ambas"
    Write-Host "  [4]" -ForegroundColor Yellow -NoNewline; Write-Host " Voltar ao menu principal"
    Write-Host ""

    $choice = Read-Host "Selecione uma opcao [1-4]"
    switch ($choice) {
        "1" {
            Remove-Folder $LOCAL_DIR "LocalAppData"
            Pause-Return
        }
        "2" {
            Remove-Folder $DATA_DIR "Data Folder"
            Pause-Return
        }
        "3" {
            if (Confirm-Action "Excluir AMBAS as pastas?") {
                Clear-Host
                Write-Host "Iniciando processo de limpeza..." -ForegroundColor Red
                Write-Host ""
                $found = $false

                foreach ($p in @($LOCAL_DIR, $DATA_DIR)) {
                    if (Test-Path $p) {
                        try {
                            Remove-Item -Path $p -Recurse -Force
                            Write-Removed "`"$p`" removida."
                            $found = $true
                        } catch {
                            Write-Err "Falha ao remover `"$p`": $_"
                        }
                    }
                }

                if (-not $found) {
                    Write-Warn "Nenhuma pasta associada foi encontrada."
                }
            } else {
                Write-Host "Operacao cancelada." -ForegroundColor DarkGray
            }
            Pause-Return
        }
        "4" { return }
        default {
            Write-Warn "Opcao invalida."
            Pause-Return
        }
    }
}

# ---------------------------------------------------------------------------
# [4] Iniciar Astrometrica.exe
# ---------------------------------------------------------------------------
function Start-Astrometrica {
    Clear-Host
    Write-Host "[Iniciar Astrometrica]" -ForegroundColor White
    Write-Host ""
    Write-Host "Procurando Astrometrica.exe..." -ForegroundColor Yellow

    if (-not (Test-Path $EXE_PATH)) {
        Write-Host ""
        Write-Err "Astrometrica.exe nao encontrado em: `"$EXE_PATH`""
        Write-Host ""
        Write-Warn "Possiveis causas:"
        Write-Host "   - O Astrometrica nao esta instalado"
        Write-Host "   - Esta instalado em um diretorio diferente de C:\Astrometrica"
        Write-Host "   - O arquivo foi deletado ou movido"
        Write-Host ""
        Write-Warn "Sugestao: Instale o Astrometrica em C:\Astrometrica\"
        Pause-Return
        return
    }

    Write-Check "`"$EXE_PATH`""
    Write-Host "Executando o programa..."
    Write-Host ""

    try {
        Start-Process -FilePath $EXE_PATH
        Start-Sleep -Seconds 4

        $running = Get-Process -Name "Astrometrica" -ErrorAction SilentlyContinue
        if ($running) {
            Write-Ok "Astrometrica.exe esta ativo."
        } else {
            Write-Err "Astrometrica.exe nao foi detectado em execucao apos inicializacao."
            Write-Host ""
            Write-Warn "Possiveis causas:"
            Write-Host "   - Permissoes insuficientes. Tente executar como administrador."
            Write-Host "   - O arquivo .exe pode estar corrompido ou bloqueado pelo antivirus."
            Write-Host "   - Uma dependencia necessaria (ex: DLL de runtime) esta ausente."
        }
    } catch {
        Write-Err "Falha ao executar: $_"
    }

    Pause-Return
}

# ---------------------------------------------------------------------------
# [5] Verificar Status
# ---------------------------------------------------------------------------
function Show-Status {
    Clear-Host
    Write-Host "[Verificacao de status]" -ForegroundColor White
    Write-Host ""

    $isAdmin = Test-Admin
    if ($isAdmin) {
        Write-Ok "Executando como Administrador"
    } else {
        Write-Warn "Sem privilegios de Administrador"
    }

    Write-Host ""

    if (Test-Path $LOCAL_DIR) {
        Write-Ok "LocalAppData: `"$LOCAL_DIR`""
    } else {
        Write-Missing "LocalAppData: `"$LOCAL_DIR`""
    }

    if (Test-Path $DATA_DIR) {
        Write-Ok "Data Folder:  `"$DATA_DIR`""
    } else {
        Write-Missing "Data Folder:  `"$DATA_DIR`""
    }

    if (Test-Path $EXE_PATH) {
        Write-Ok "Executable:   `"$EXE_PATH`""
    } else {
        Write-Missing "Executable:   `"$EXE_PATH`""
    }

    $running = Get-Process -Name "Astrometrica" -ErrorAction SilentlyContinue
    if ($running) {
        Write-Ok "Astrometrica.exe esta em execucao (PID: $($running.Id))"
    } else {
        Write-Warn "Astrometrica.exe nao esta em execucao"
    }

    Write-Host ""
    Write-Warn "Se um caminho estiver marcado como [MISSING], use a opcao de correcao correspondente."

    Pause-Return
}

# ---------------------------------------------------------------------------
# [6] LEIA-ME
# ---------------------------------------------------------------------------
function Show-Readme {
    Clear-Host
    Write-Host "Astrometrica Toolkit - LEIA-ME" -ForegroundColor White
    Write-Host ""
    Write-Host "Este toolkit auxilia na correcao de erros comuns relacionados"
    Write-Host "a paths que ocorrem ao executar o software Astrometrica no Windows."
    Write-Host ""
    Write-Host "Runtime error 217" -ForegroundColor Yellow
    Write-Host "Ausencia da pasta LocalAppData do Astrometrica (Astrometrica.ini)."
    Write-Host "Use a opcao [1] para cria-la automaticamente."
    Write-Host "Path: $LOCAL_DIR"
    Write-Host ""
    Write-Host "I/O error 103" -ForegroundColor Yellow
    Write-Host "Ausencia da pasta Data (log MPCOrbit.txt)."
    Write-Host "Use a opcao [2] para cria-la automaticamente."
    Write-Host "Path: $DATA_DIR"
    Write-Host ""
    Write-Host "Menu" -ForegroundColor White
    Write-Host ""
    Write-Host "[3] Limpeza: " -ForegroundColor Yellow -NoNewline; Write-Host "Remove com seguranca as pastas criadas, com confirmacao."
    Write-Host "[4] Iniciar: " -ForegroundColor Yellow -NoNewline; Write-Host "Abre o Astrometrica.exe diretamente por este toolkit."
    Write-Host "[5] Status:  " -ForegroundColor Yellow -NoNewline; Write-Host "Verifica rapidamente quais caminhos existem ou estao ausentes."
    Write-Host ""
    Write-Host "Requisitos" -ForegroundColor White
    Write-Host ""
    Write-Host "Windows 10+"
    Write-Host "Astrometrica instalado em C:\Astrometrica"
    Write-Host "Execute como administrador se a criacao de pastas falhar."
    Write-Host ""
    Write-Host "Creditos" -ForegroundColor White
    Write-Host ""
    Write-Host "Dev: G. Biason"
    Write-Host "mail: guilhermebiason@usp.br"
    Write-Host ""
    Write-Host "Agradecimentos especiais a comunidade"
    Write-Host "Starbyte Network - Asteroid Hunters"
    Write-Host ""
    Write-Host "LICENSE" -ForegroundColor White
    Write-Host ""
    Write-Host "GNU General Public License v3 - https://fsf.org/"

    Pause-Return
}

# ---------------------------------------------------------------------------
# [8] Baixar MPCORB.DAT
# ---------------------------------------------------------------------------
function Download-MPCOrb {
    Clear-Host
    Write-Host "[Download MPC Orbit - MPCORB.DAT]" -ForegroundColor White
    Write-Host ""
    Write-Host "Fonte: $MPCORB_URL" -ForegroundColor DarkGray
    Write-Host "Destino: $MPCORB_DEST" -ForegroundColor DarkGray
    Write-Host ""

    # Cria a pasta de catalogos se nao existir
    if (-not (Test-Path $CATALOG_DIR)) {
        try {
            New-Item -ItemType Directory -Path $CATALOG_DIR -Force | Out-Null
            Write-Check "Pasta criada: `"$CATALOG_DIR`""
        } catch {
            Write-Err "Falha ao criar pasta de catalogos: $_"
            Write-Warn "Tente executar o toolkit como Administrador."
            Pause-Return
            return
        }
    } else {
        Write-Ok "Pasta de catalogos encontrada: `"$CATALOG_DIR`""
    }

    # Avisa se ja existe um arquivo anterior
    if (Test-Path $MPCORB_DEST) {
        $existing = Get-Item $MPCORB_DEST
        Write-Warn "MPCORB.DAT ja existe (modificado em: $($existing.LastWriteTime.ToString('dd/MM/yyyy HH:mm')))"
        if (-not (Confirm-Action "Deseja substituir o arquivo existente?")) {
            Write-Host "Operacao cancelada." -ForegroundColor DarkGray
            Pause-Return
            return
        }
    }

    Write-Host ""
    Write-Host "Iniciando download..." -ForegroundColor Yellow
    Write-Host "Atencao: o arquivo tem aproximadamente 90MB. Isso pode levar alguns minutos." -ForegroundColor DarkGray
    Write-Host ""

    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "Astrometrica-Toolkit/2.0")

        # Progresso via evento DownloadProgressChanged
        $progressJob = Register-ObjectEvent -InputObject $webClient -EventName DownloadProgressChanged -Action {
            $pct = $Event.SourceEventArgs.ProgressPercentage
            $recv = [math]::Round($Event.SourceEventArgs.BytesReceived / 1MB, 1)
            $total = [math]::Round($Event.SourceEventArgs.TotalBytesToReceive / 1MB, 1)
            Write-Progress -Activity "Baixando MPCORB.DAT" -Status "$recv MB / $total MB" -PercentComplete $pct
        }

        $webClient.DownloadFile($MPCORB_URL, $MPCORB_DEST)

        Unregister-Event -SourceIdentifier $progressJob.Name -ErrorAction SilentlyContinue
        Write-Progress -Activity "Baixando MPCORB.DAT" -Completed

        $size = [math]::Round((Get-Item $MPCORB_DEST).Length / 1MB, 1)
        Write-Host ""
        Write-Ok "MPCORB.DAT baixado com sucesso! ($size MB)"
        Write-Check "Salvo em: `"$MPCORB_DEST`""
    } catch {
        Write-Progress -Activity "Baixando MPCORB.DAT" -Completed
        Write-Host ""
        Write-Err "Falha no download: $_"
        Write-Warn "Verifique sua conexao com a internet e tente novamente."
        # Remove arquivo incompleto se existir
        if (Test-Path $MPCORB_DEST) {
            Remove-Item $MPCORB_DEST -Force -ErrorAction SilentlyContinue
        }
    }

    Pause-Return
}

# ---------------------------------------------------------------------------
# Loop principal
# ---------------------------------------------------------------------------
while ($true) {
    Show-Menu
    $choice = Read-Host "Selecione uma opcao [1-7]"

    switch ($choice) {
        "1" { Fix-RuntimeError }
        "2" { Fix-IOError }
        "3" { Show-CleanupMenu }
        "4" { Start-Astrometrica }
        "5" { Show-Status }
        "6" { Show-Readme }
        "7" {
            Clear-Host
            Write-Host "[Sair]" -ForegroundColor White
            Write-Host ""
            $confirm = Read-Host "Voce quer sair? [S/N]"
            if ($confirm -match "^[Ss]$") { exit }
        }
        "8" { Download-MPCOrb }
        default {
            Write-Warn "Opcao invalida. Escolha entre 1 e 8."
            Start-Sleep -Seconds 1
        }
    }
}
