#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$LOCAL_DIR    = "$env:LOCALAPPDATA\Astrometrica"
$DATA_DIR     = "C:\Astrometrica\Data"
$CATALOG_DIR  = "C:\Astrometrica\Catalogs"
$EXE_PATH     = "C:\Astrometrica\Astrometrica.exe"
$MPCORB_URL   = "https://minorplanetcenter.net/iau/MPCORB/MPCORB.DAT"
$MPCORB_DEST  = "$CATALOG_DIR\MPCORB.DAT"

function Write-Ok($msg)      { Write-Host "[OK]      " -ForegroundColor Green  -NoNewline; Write-Host $msg }
function Write-Check($msg)   { Write-Host "[CHECK]   " -ForegroundColor Green  -NoNewline; Write-Host $msg }
function Write-Warn($msg)    { Write-Host "[AVISO]   " -ForegroundColor Yellow -NoNewline; Write-Host $msg }
function Write-Err($msg)     { Write-Host "[ERRO]    " -ForegroundColor Red    -NoNewline; Write-Host $msg }
function Write-Removed($msg) { Write-Host "[REMOVED] " -ForegroundColor Green  -NoNewline; Write-Host $msg }
function Write-Missing($msg) { Write-Host "[MISSING] " -ForegroundColor Red    -NoNewline; Write-Host $msg }

function Wait-ForKeyPress {
    Write-Host ""
    Write-Host "Pressione qualquer tecla para voltar ao menu..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Confirm-Action($prompt) {
    Write-Host ""
    $answer = Read-Host "$prompt [S/N]"
    return ($answer -match "^[Ss]$")
}

function Test-Admin {
    $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

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
    Write-Host "  [3]" -ForegroundColor Yellow -NoNewline; Write-Host " Corrigir erro MPCorb.dat (MPCORB.DAT)"
    Write-Host "  [4]" -ForegroundColor Yellow -NoNewline; Write-Host " Remover pastas criadas (cleanup)"
    Write-Host "  [5]" -ForegroundColor Yellow -NoNewline; Write-Host " Iniciar Astrometrica.exe"
    Write-Host "  [6]" -ForegroundColor Yellow -NoNewline; Write-Host " Verificar Status"
    Write-Host "  [7]" -ForegroundColor Yellow -NoNewline; Write-Host " LEIA-ME"
    Write-Host "  [8]" -ForegroundColor Yellow -NoNewline; Write-Host " Sair"
    Write-Host ""
}

function Repair-RuntimeError {
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

    Wait-ForKeyPress
}

function Repair-IOError {
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

    Wait-ForKeyPress
}

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
            Wait-ForKeyPress
        }
        "2" {
            Remove-Folder $DATA_DIR "Data Folder"
            Wait-ForKeyPress
        }
        "3" {
            if (Confirm-Action "Excluir ambas as pastas?") {
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
            Wait-ForKeyPress
        }
        "4" { return }
        default {
            Write-Warn "Opcao invalida."
            Wait-ForKeyPress
        }
    }
}

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
        Wait-ForKeyPress
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
            Write-Host " - Permissoes insuficientes. Tente executar como administrador."
            Write-Host " - O arquivo .exe pode estar corrompido ou bloqueado pelo antivirus."
            Write-Host " - Uma dependencia necessaria (ex: runtime DLL) esta ausente."
        }
    } catch {
        Write-Err "Falha ao executar: $_"
    }

    Wait-ForKeyPress
}

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
        Write-Warn "Processo Astrometrica.exe sem execução"
    }

    Write-Host ""
    Write-Warn "Caso um caminho estiver marcado como [MISSING], use a opcao de correcao correspondente no menu principal."

    Wait-ForKeyPress
}

function Show-Readme {
    Clear-Host
    Write-Host "Astrometrica Toolkit - LEIA-ME" -ForegroundColor White
    Write-Host ""
    Write-Host "Este toolkit auxilia na correcao de erros comuns relacionados"
    Write-Host "a paths que ocorrem ao executar o software Astrometrica no Windows."
    Write-Host ""
    Write-Host "Runtime error 217" -ForegroundColor Yellow
    Write-Host "Ausencia da pasta 'LocalAppData' do Astrometrica (Astrometrica.ini)."
    Write-Host "Use a opcao [1] para cria-la automaticamente."
    Write-Host "Path: $LOCAL_DIR"
    Write-Host ""
    Write-Host "I/O error 103" -ForegroundColor Yellow
    Write-Host "Ausencia da pasta 'Data' (log MPCOrbit.txt)."
    Write-Host "Use a opcao [2] para cria-la automaticamente."
    Write-Host "Path: $DATA_DIR"
    Write-Host ""
    Write-Host "MPCOrb.dat not found" -ForegroundColor Yellow
    Write-Host "Ausencia do catalogo 'MPCOrb.DAT'."
    Write-Host "Use a opcao [3] para realizar o download do MPC."
    Write-Host "Path: $CATALOG_DIR"
    Write-Host ""
    Write-Host "Menu" -ForegroundColor White
    Write-Host ""
    Write-Host "[4] Limpeza: " -ForegroundColor Yellow -NoNewline; Write-Host "Remove com seguranca as pastas criadas, com confirmacao."
    Write-Host "[5] Iniciar: " -ForegroundColor Yellow -NoNewline; Write-Host "Abre o Astrometrica.exe diretamente por este toolkit."
    Write-Host "[6] Status:  " -ForegroundColor Yellow -NoNewline; Write-Host "Verifica rapidamente quais caminhos existem ou estao ausentes."
    Write-Host "[8] Sair:    " -ForegroundColor Yellow -NoNewline; Write-Host "Encerra o toolkit."
    Write-Host ""
    Write-Host "REQUISITOS" -ForegroundColor White
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

    Wait-ForKeyPress
}

function Save-MPCOrb {
    Clear-Host
    Write-Host "[Download MPC Orbit Catalog - MPCORB.DAT]" -ForegroundColor White
    Write-Host ""
    Write-Host "Fonte: $MPCORB_URL" -ForegroundColor DarkGray
    Write-Host "Destino: $MPCORB_DEST" -ForegroundColor DarkGray
    Write-Host ""

    if (-not (Test-Path $CATALOG_DIR)) {
        try {
            New-Item -ItemType Directory -Path $CATALOG_DIR -Force | Out-Null
            Write-Check "Pasta criada: `"$CATALOG_DIR`""
        } catch {
            Write-Err "Falha ao criar pasta de catalogos: $_"
            Write-Warn "Tente executar o toolkit como 'Administrador'."
            Wait-ForKeyPress
            return
        }
    } else {
        Write-Ok "Pasta de catalogos encontrada: `"$CATALOG_DIR`""
    }

    if (Test-Path $MPCORB_DEST) {
        $existing = Get-Item $MPCORB_DEST
        Write-Warn "MPCORB.DAT ja existe (modificado em: $($existing.LastWriteTime.ToString('dd/MM/yyyy HH:mm')))"
        if (-not (Confirm-Action "Deseja substituir o arquivo existente?")) {
            Write-Host "Operacao cancelada." -ForegroundColor DarkGray
            Wait-ForKeyPress
            return
        }
    }

    Write-Host ""
    Write-Host "Iniciando download..." -ForegroundColor Yellow
    Write-Host ""

    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "Astrometrica-Toolkit/2.0")

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

        if (Test-Path $MPCORB_DEST) {
            Remove-Item $MPCORB_DEST -Force -ErrorAction SilentlyContinue
        }
    }

    Wait-ForKeyPress
}

while ($true) {
    Show-Menu
    $choice = Read-Host "Selecione uma opcao [1-8]"

    switch ($choice) {
        "1" { Repair-RuntimeError }
        "2" { Repair-IOError }
        "3" { Save-MPCOrb }
        "4" { Show-CleanupMenu }
        "5" { Start-Astrometrica }
        "6" { Show-Status }
        "7" { Show-Readme }
        "8" {
            Clear-Host
            Write-Host "[Sair]" -ForegroundColor White
            Write-Host ""
            $confirm = Read-Host "Voce quer sair? [S/N]"
            if ($confirm -match "^[Ss]$") { exit }
        }
        default {
            Write-Warn "Opcao invalida. Escolha entre [1] e [8]."
            Start-Sleep -Seconds 1
        }
    }
}
