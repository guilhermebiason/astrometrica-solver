@echo off
setlocal enabledelayedexpansion

for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"

set "check=%ESC%[92m"
set "warning=%ESC%[93m"
set "error=%ESC%[91m"
set "title=%ESC%[97m"
set "color=%ESC%[0m"

:: Path Definitions
set "LOCAL_DIR=%localappdata%\Astrometrica"
set "DATA_DIR=C:\Astrometrica\Data"
set "EXE_PATH=C:\Astrometrica\Astrometrica.exe"

:: Main menu
:menu
cls
echo %title%Astrometrica Toolkit Ver 1.0%color%
echo.
echo  %warning%[1]%color% Corrigir Runtime Error 217 (LocalAppData)
echo  %warning%[2]%color% Corrigir I/O Error 103 (MPCOrbit.txt)
echo  %warning%[3]%color% Remover pastas criadas (limpeza)
echo  %warning%[4]%color% Iniciar Astrometrica.exe
echo  %warning%[5]%color% Verificar Status
echo  %warning%[6]%color% LEIA-ME
echo  %warning%[7]%color% Sair
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
echo %title%[Sair]%color%
echo.
choice /c SN /n /m "Fechar o prompt de comando? [S/N]: "
if errorlevel 2 goto menu
if errorlevel 1 exit

:: Runtime error fix
:runtime_error
cls
echo %title%[Runtime error 217 fix]%color%
echo.
echo %warning%Verificando pasta LocalAppData...%color%
if not exist "%LOCAL_DIR%" (
  mkdir "%LOCAL_DIR%"
  echo %check%[CHECK]%color% Pasta criada com sucesso em: "%LOCAL_DIR%"
  ) else (
  echo %check%[OK]%color% A pasta ja existe: "%LOCAL_DIR%"
  echo Nenhuma acao necessaria.
)
goto end

:: I/O error fix
:io_error
cls
echo %title%[I/O error 103 fix]%color%
echo.
echo %warning%Verificando caminho de dados...%color%
if not exist "%DATA_DIR%" (
  mkdir "%DATA_DIR%"
  echo %check%[CHECK]%color% Pasta criada em: "%DATA_DIR%"
  ) else (
  echo %check%[OK]%color% A pasta ja existe: "%DATA_DIR%"
  echo Nenhuma acao necessaria.
)
goto end

:: Cleanup menu
:delete
cls
echo %title%[Menu de limpeza]%color%
echo.
echo Selecione qual pasta deseja remover:
echo.
echo %warning%[1]%color% LocalAppData: ^(%LOCAL_DIR%^)
echo %warning%[2]%color% Data Folder: ^(%DATA_DIR%^)
echo %warning%[3]%color% Remover ambas
echo %warning%[4]%color% Voltar ao menu principal
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
  echo %check%[REMOVED]%color% "%LOCAL_DIR%" removida com sucesso.
  ) else (
  echo %warning%[NOT FOUND]%color% "%LOCAL_DIR%" nao existe.
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
  echo %check%[REMOVED]%color% "%DATA_DIR%" removida com sucesso.
  ) else (
  echo %warning%[NOT FOUND]%color% "%DATA_DIR%" nao existe.
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
echo %error%Iniciando processo de limpeza...%color%
echo.

if exist "%LOCAL_DIR%" (
  rd /s /q "%LOCAL_DIR%"
  echo %check%[REMOVED]%color% "%LOCAL_DIR%" removida.
  set "FOUND_ANY=1"
)

if exist "%DATA_DIR%" (
  rd /s /q "%DATA_DIR%"
  echo %check%[REMOVED]%color% "%DATA_DIR%" removida.
  set "FOUND_ANY=1"
)

if "!FOUND_ANY!"=="0" (
  echo %warning%[NOT FOUND]%color% Nenhuma pasta associada foi encontrada.
)
goto end

:: Start Astrometrica.exe
:run
cls
echo %title%[Iniciar Astrometrica]%color%
echo.
echo %warning%Procurando Astrometrica.exe...%color%

if not exist "%EXE_PATH%" (
  echo %error%[ERROR]%color% Astrometrica.exe nao encontrado em: "%EXE_PATH%"
  echo.
  echo %warning%Possiveis causas:%color%
  echo  - O Astrometrica nao esta instalado;
  echo  - Esta instalado em um diretorio diferente de C:\Astrometrica;
  echo  - O arquivo foi deletado ou movido.
  echo.
  echo %warning%Sugestao:%color% Instale o Astrometrica em C:\Astrometrica\
  echo ou verifique o caminho de instalacao.
  goto end
)

echo %check%[CHECK]%color% "%EXE_PATH%"
echo Executando o programa...
echo.

start "" "%EXE_PATH%"

ping -n 5 127.0.0.1 > nul

tasklist /FI "IMAGENAME eq Astrometrica.exe" 2>nul | find /I "Astrometrica.exe" > nul

if errorlevel 1 (
  echo %error%[ERROR]%color% Astrometrica.exe nao foi detectado em
  echo execucao apos tentativa de inicializacao.
  echo.
  echo %warning%Possiveis causas:%color%
  echo  - Permissoes insuficientes. Tente executar como administrador.
  echo  - O arquivo .exe pode estar corrompido ou bloqueado pelo antivirus.
  echo  - Uma dependencia necessaria ^(ex: DLL de runtime^) esta ausente.
  echo.
  echo %warning%Aviso:%color% Clique com o botao direito no toolkit e selecione
  echo "Executar como administrador", depois tente novamente.
  goto end
)

echo %check%[RUNNING]%color% Astrometrica.exe esta ativo.
goto end

:: Status check
:status
cls
echo %title%[Verificacao de status do Windows]%color%
echo.

if exist "%LOCAL_DIR%" (
  echo %check%[OK]%color% LocalAppData: "%LOCAL_DIR%"
  ) else (
  echo %error%[MISSING]%color% LocalAppData: "%LOCAL_DIR%"
)

if exist "%DATA_DIR%" (
  echo %check%[OK]%color% Data Folder: "%DATA_DIR%"
  ) else (
  echo %error%[MISSING]%color% Data Folder: "%DATA_DIR%"
)

:: Check .exe
if exist "%EXE_PATH%" (
  echo %check%[OK]%color% Executable: "%EXE_PATH%"
  ) else (
  echo %error%[MISSING]%color% Executable: "%EXE_PATH%"
)

echo.
echo %warning%Aviso:%color% Se um caminho estiver marcado como [MISSING],
echo use a opcao de correcao correspondente no menu principal.
goto end

:: README
:readme
cls
echo %title%Astrometrica Toolkit - LEIA-ME%color%
echo.
echo Este toolkit auxilia na correcao de erros comuns relacionados
echo a paths que ocorrem ao executar o software Astrometrica no Windows.
echo.
echo %warning%Runtime error 217%color%
echo Ausencia da pasta "LocalAppData" do Astrometrica (Astrometrica.ini).
echo Use a opcao [1] para cria-la automaticamente.
echo Path: %LOCAL_DIR%
echo.
echo %warning%I/O error 103%color%
echo Ausencia da pasta "Data" (log MPCOrbit.txt).
echo Use a opcao [2] para cria-la automaticamente.
echo Path: %DATA_DIR%
echo.
echo %title%Menu%color%
echo.
echo %warning%[3] Limpeza: %color% Remove com seguranca as pastas criadas, com confirmacao.
echo %warning%[4] Iniciar: %color% Abre o Astrometrica.exe diretamente por este toolkit.
echo %warning%[5] Status: %color%Verifica rapidamente quais caminhos existem ou estao ausentes.
echo.
echo %title%Requisitos%color%
echo.
echo Windows 10+
echo Astrometrica instalado em C:\Astrometrica;
echo Execute como administrador se a criacao de pastas falhar.
echo.
echo %title%Cerroritos%color%
echo.
echo Dev: G. Biason
echo mail: guilhermebiason@usp.br
echo.
echo Agradecimentos especiais a comunidade
echo Starbyte Network - Asteroid Hunters
echo.
echo %title%LICENSE%color%
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
