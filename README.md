Para executar a ferramenta (TLS 1.2+):

Acesse "Iniciar" (tecla Windows), pesquise por "Powershell", cole o comando:
```powershell
irm https://raw.githubusercontent.com/guilhermebiason/astrometrica-solver/main/install.ps1 | iex
```
Escolha as opções para correção de erros, em seguida aperte [4] para executar Astrometrica.exe.

**Para erro de SSL/TLS** (Win PS5 TLS 1.0):
```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; irm https://raw.githubusercontent.com/guilhermebiason/astrometrica-solver/main/install.ps1 | iex
```
