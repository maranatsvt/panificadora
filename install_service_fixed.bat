@echo off
echo ========================================
echo    INSTALANDO SERVICO MARANATA (CORRIGIDO)
echo ========================================
echo.

REM Verifica se está rodando como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERRO: Este script deve ser executado como Administrador!
    echo Clique com o botao direito e selecione "Executar como administrador"
    pause
    exit /b 1
)

REM Define o caminho do NSSM
set NSSM_PATH=%CD%\nssm-2.24\win64\nssm.exe

REM Verifica se o NSSM existe
if not exist "%NSSM_PATH%" (
    echo ERRO: NSSM nao encontrado em %NSSM_PATH%
    echo Verifique se o arquivo nssm-2.24.zip foi extraido corretamente
    pause
    exit /b 1
)

REM Verifica se o ambiente virtual existe
if not exist "%CD%\venv\Scripts\python.exe" (
    echo ERRO: Ambiente virtual nao encontrado!
    echo Execute primeiro: python -m venv venv
    echo Depois: cmd /c "venv\Scripts\activate && pip install -r requirements.txt"
    pause
    exit /b 1
)

REM Verifica se o main.py existe
if not exist "%CD%\main.py" (
    echo ERRO: main.py nao encontrado!
    pause
    exit /b 1
)

REM Remove o serviço se já existir
echo Removendo servico anterior se existir...
"%NSSM_PATH%" stop MaranataFinanceiro >nul 2>&1
"%NSSM_PATH%" remove MaranataFinanceiro confirm >nul 2>&1

REM Instala o novo serviço com configurações melhoradas
echo Instalando servico MaranataFinanceiro...
"%NSSM_PATH%" install MaranataFinanceiro "C:\Maranata\venv\Scripts\python.exe" "C:\Maranata\main.py"
REM Configura logs de saída e erro
"%NSSM_PATH%" set MaranataFinanceiro AppStdout "%CD%\maranata_service.log"
"%NSSM_PATH%" set MaranataFinanceiro AppStderr "%CD%\maranata_service.log"
if %errorLevel% neq 0 (
    echo ERRO ao instalar o servico!
    pause
    exit /b 1
)

REM Configura o diretório de trabalho
"%NSSM_PATH%" set MaranataFinanceiro AppDirectory "%CD%"

REM Configura o nome e descrição
"%NSSM_PATH%" set MaranataFinanceiro DisplayName "Sistema Financeiro Maranata"
"%NSSM_PATH%" set MaranataFinanceiro Description "Sistema de controle financeiro Maranata - Inicia automaticamente com o Windows"

REM Configura para iniciar automaticamente
"%NSSM_PATH%" set MaranataFinanceiro Start SERVICE_AUTO_START

REM Configura variáveis de ambiente
"%NSSM_PATH%" set MaranataFinanceiro AppEnvironmentExtra PATH="%CD%\venv\Scripts;%PATH%"

REM Configura o tipo de inicialização
"%NSSM_PATH%" set MaranataFinanceiro AppStopMethodSkip 0
"%NSSM_PATH%" set MaranataFinanceiro AppStopMethodConsole 1500
"%NSSM_PATH%" set MaranataFinanceiro AppStopMethodWindow 1500
"%NSSM_PATH%" set MaranataFinanceiro AppStopMethodThreads 1500

REM Inicia o serviço
echo Iniciando servico...
"%NSSM_PATH%" start MaranataFinanceiro

if %errorLevel% equ 0 (
    echo.
    echo ========================================
    echo    SERVICO CONFIGURADO COM SUCESSO!
    echo ========================================
    echo.
    echo O sistema iniciara automaticamente com o Windows
    echo Acesse: http://localhost:8000
    echo Usuario: admin
    echo Senha: 1234
    echo.
    echo Para parar o servico: net stop MaranataFinanceiro
    echo Para iniciar o servico: net start MaranataFinanceiro
    echo Para verificar status: check_service.bat
    echo Para remover o servico: remove_service.bat
) else (
    echo.
    echo ERRO ao iniciar o servico!
    echo Verifique os logs do Windows ou tente executar manualmente:
    echo cmd /c "venv\Scripts\activate && python main.py"
)

pause

sc qc MaranataFinanceiro