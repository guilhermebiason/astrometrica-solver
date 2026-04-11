@echo off
setlocal enabledelayedexpansion

for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"

set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "RED=%ESC%[91m"
set "WHITE=%ESC%[97m"
set "RESET=%ESC%[0m"

:: Path Definitions
set "LOCAL_DIR=%localappdata%\Astrometrica"
set "DATA_DIR=C:\Astrometrica\Data"
set "EXE_PATH=C:\Astrometrica\Astrometrica.exe"

:: Main menu
:menu
cls
echo %WHITE%Astrometrica Toolkit Ver 1.0%RESET%
echo.
echo  %YELLOW%[1]%RESET% Corrigir Runtime Error 217 (LocalAppData)
echo  %YELLOW%[2]%RESET% Corrigir I/O Error 103 (MPCOrbit.txt)
echo  %YELLOW%[3]%RESET% Remover pastas criadas (limpeza)
echo  %YELLOW%[4]%RESET% Iniciar Astrometrica.exe
echo  %YELLOW%[5]%RESET% Verificar Status
echo  %YELLOW%[6]%RESET% LEIA-ME
echo  %YELLOW%[7]%RESET% Sair
echo.

choice /c 1234567 /n /m "Selecione uma opcao [1-7]: "

if errorlevel 7 goto confirm_exit
if errorlevel 6 goto readme
if errorlevel 5 goto status
if errorlevel 4 goto run
if errorlevel 3 goto delete
if errorlevel 2 goto io_error
if errorlevel 1 goto runtime_error

:: Exit confirmation
:confirm_exit
cls
echo %WHITE%[Sair]%RESET%
echo.
choice /c SN /n /m "Fechar o prompt de comando? [S/N]: "
if errorlevel 2 goto menu
if errorlevel 1 exit

:: Runtime error fix
:runtime_error
cls
echo %WHITE%[Runtime error 217 fix]%RESET%
echo.
echo %YELLOW%Verificando pasta LocalAppData...%RESET%
if not exist "%LOCAL_DIR%" (
  mkdir "%LOCAL_DIR%"
  echo %GREEN%[CHECK]%RESET% Pasta criada com sucesso em: "%LOCAL_DIR%"
  ) else (
  echo %GREEN%[OK]%RESET% A pasta ja existe: "%LOCAL_DIR%"
  echo Nenhuma acao necessaria.
)
goto end

:: I/O error fix
:io_error
cls
echo %WHITE%[I/O error 103 fix]%RESET%
echo.
echo %YELLOW%Verificando caminho de dados...%RESET%
if not exist "%DATA_DIR%" (
  mkdir "%DATA_DIR%"
  echo %GREEN%[CHECK]%RESET% Pasta criada em: "%DATA_DIR%"
  ) else (
  echo %GREEN%[OK]%RESET% A pasta ja existe: "%DATA_DIR%"
  echo Nenhuma acao necessaria.
)
goto end

:: Cleanup menu
:delete
cls
echo %WHITE%[Menu de limpeza]%RESET%
echo.
echo Selecione qual pasta deseja remover:
echo.
echo %YELLOW%[1]%RESET% LocalAppData: ^(%LOCAL_DIR%^)
echo %YELLOW%[2]%RESET% Data Folder: ^(%DATA_DIR%^)
echo %YELLOW%[3]%RESET% Remover ambas
echo %YELLOW%[4]%RESET% Voltar ao menu principal
echo.

choice /c 1234 /n /m "Selecione uma opcao [1-4]: "

if errorlevel 4 goto menu
if errorlevel 3 goto confirm_both
if errorlevel 2 goto confirm_data
if errorlevel 1 goto confirm_local

:confirm_local
cls
echo Excluir a pasta: "%LOCAL_DIR%"
echo.
choice /c SN /n /m "Confirmar? [S/N]: "
if errorlevel 2 goto delete
if errorlevel 1 goto do_delete_local

:do_delete_local
cls
if exist "%LOCAL_DIR%" (
  rd /s /q "%LOCAL_DIR%"
  echo %GREEN%[REMOVED]%RESET% "%LOCAL_DIR%" removida com sucesso.
  ) else (
  echo %YELLOW%[NOT FOUND]%RESET% "%LOCAL_DIR%" nao existe.
)
goto end

:confirm_data
cls
echo Excluir a pasta: "%DATA_DIR%"
echo.
choice /c SN /n /m "Confirmar? [S/N]: "
if errorlevel 2 goto delete
if errorlevel 1 goto do_delete_data

:do_delete_data
cls
if exist "%DATA_DIR%" (
  rd /s /q "%DATA_DIR%"
  echo %GREEN%[REMOVED]%RESET% "%DATA_DIR%" removida com sucesso.
  ) else (
  echo %YELLOW%[NOT FOUND]%RESET% "%DATA_DIR%" nao existe.
)
goto end

:confirm_both
cls
echo Excluir as pastas:
echo "%LOCAL_DIR%"
echo "%DATA_DIR%"
echo.
choice /c SN /n /m "Confirmar? [S/N]: "
if errorlevel 2 goto delete
if errorlevel 1 goto do_delete_both

:do_delete_both
cls
set "FOUND_ANY=0"
echo %RED%Iniciando processo de limpeza...%RESET%
echo.

if exist "%LOCAL_DIR%" (
  rd /s /q "%LOCAL_DIR%"
  echo %GREEN%[REMOVED]%RESET% "%LOCAL_DIR%" removida.
  set "FOUND_ANY=1"
)

if exist "%DATA_DIR%" (
  rd /s /q "%DATA_DIR%"
  echo %GREEN%[REMOVED]%RESET% "%DATA_DIR%" removida.
  set "FOUND_ANY=1"
)

if "!FOUND_ANY!"=="0" (
  echo %YELLOW%[NOT FOUND]%RESET% Nenhuma pasta associada foi encontrada.
)
goto end

:: Start Astrometrica.exe
:run
cls
echo %WHITE%[Iniciar Astrometrica]%RESET%
echo.
echo %YELLOW%Procurando Astrometrica.exe...%RESET%

if not exist "%EXE_PATH%" (
  echo %RED%[ERROR]%RESET% Astrometrica.exe nao encontrado em: "%EXE_PATH%"
  echo.
  echo %YELLOW%Possiveis causas:%RESET%
  echo  - O Astrometrica nao esta instalado;
  echo  - Esta instalado em um diretorio diferente de C:\Astrometrica;
  echo  - O arquivo foi deletado ou movido.
  echo.
  echo %YELLOW%Sugestao:%RESET% Instale o Astrometrica em C:\Astrometrica\
  echo ou verifique o caminho de instalacao.
  goto end
)

echo %GREEN%[CHECK]%RESET% "%EXE_PATH%"
echo Executando o programa...
echo.

start "" "%EXE_PATH%"

ping -n 5 127.0.0.1 > nul

tasklist /FI "IMAGENAME eq Astrometrica.exe" 2>nul | find /I "Astrometrica.exe" > nul

if errorlevel 1 (
  echo %RED%[ERROR]%RESET% Astrometrica.exe nao foi detectado em
  echo execucao apos tentativa de inicializacao.
  echo.
  echo %YELLOW%Possiveis causas:%RESET%
  echo  - Permissoes insuficientes. Tente executar como administrador.
  echo  - O arquivo .exe pode estar corrompido ou bloqueado pelo antivirus.
  echo  - Uma dependencia necessaria ^(ex: DLL de runtime^) esta ausente.
  echo.
  echo %YELLOW%Aviso:%RESET% Clique com o botao direito no toolkit e selecione
  echo "Executar como administrador", depois tente novamente.
  goto end
)

echo %GREEN%[RUNNING]%RESET% Astrometrica.exe esta ativo.
goto end

:: Status check
:status
cls
echo %WHITE%[Verificacao de status do Windows]%RESET%
echo.

if exist "%LOCAL_DIR%" (
  echo %GREEN%[OK]%RESET% LocalAppData: "%LOCAL_DIR%"
  ) else (
  echo %RED%[MISSING]%RESET% LocalAppData: "%LOCAL_DIR%"
)

if exist "%DATA_DIR%" (
  echo %GREEN%[OK]%RESET% Data Folder: "%DATA_DIR%"
  ) else (
  echo %RED%[MISSING]%RESET% Data Folder: "%DATA_DIR%"
)

:: Check .exe
if exist "%EXE_PATH%" (
  echo %GREEN%[OK]%RESET% Executable: "%EXE_PATH%"
  ) else (
  echo %RED%[MISSING]%RESET% Executable: "%EXE_PATH%"
)

echo.
echo %YELLOW%Aviso:%RESET% Se um caminho estiver marcado como [MISSING],
echo use a opcao de correcao correspondente no menu principal.
goto end

:: README
:readme
cls
echo %WHITE%Astrometrica Toolkit - LEIA-ME%RESET%
echo.
echo Este toolkit auxilia na correcao de erros comuns relacionados
echo a paths que ocorrem ao executar o software Astrometrica no Windows.
echo.
echo %YELLOW%Runtime error 217%RESET%
echo Ausencia da pasta "LocalAppData" do Astrometrica (Astrometrica.ini).
echo Use a opcao [1] para cria-la automaticamente.
echo Path: %LOCAL_DIR%
echo.
echo %YELLOW%I/O error 103%RESET%
echo Ausencia da pasta "Data" (log MPCOrbit.txt).
echo Use a opcao [2] para cria-la automaticamente.
echo Path: %DATA_DIR%
echo.
echo %WHITE%Menu%RESET%
echo.
echo %YELLOW%[3] Limpeza: %RESET% Remove com seguranca as pastas criadas, com confirmacao.
echo %YELLOW%[4] Iniciar: %RESET% Abre o Astrometrica.exe diretamente por este toolkit.
echo %YELLOW%[5] Status: %RESET%Verifica rapidamente quais caminhos existem ou estao ausentes.
echo.
echo %WHITE%Requisitos%RESET%
echo.
echo Windows 10+
echo Astrometrica instalado em C:\Astrometrica;
echo Execute como administrador se a criacao de pastas falhar.
echo.
echo %WHITE%Creditos%RESET%
echo.
echo Dev: G. Biason
echo mail: guilhermebiason@usp.br
echo.
echo Agradecimentos especiais a comunidade
echo Starbyte Network - Asteroid Hunters
echo.
echo %WHITE%LICENSE%RESET%
echo.
echo GNU GENERAL PUBLIC LICENSE
echo Version 3, 29 June 2007
echo.
echo Copyright (C) 2007 Free Software Foundation, Inc. https://fsf.org/
echo Everyone is permitted to copy and distribute verbatim copies
echo of this license document, but changing it is not allowed.
goto end

:: Return main menu
:end
echo.
echo Pressione qualquer tecla para voltar ao menu...
pause > nul
goto menu
