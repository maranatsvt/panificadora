@echo off
echo ========================================
echo    CONFIGURANDO INICIALIZACAO AUTOMATICA
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

REM Define o caminho da pasta de inicialização
set STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
set ATALHO=%STARTUP_FOLDER%\Maranata_Financeiro.lnk

REM Verifica se o ambiente virtual existe
if not exist "%CD%\venv\Scripts\python.exe" (
    echo ERRO: Ambiente virtual nao encontrado!
    echo Execute primeiro: python -m venv venv
    echo Depois: cmd /c "venv\Scripts\activate && pip install -r requirements.txt"
    pause
    exit /b 1
)

REM Remove atalho anterior se existir
if exist "%ATALHO%" (
    echo Removendo atalho anterior...
    del "%ATALHO%"
)

REM Cria o script de inicialização
echo Criando script de inicializacao...
(
echo @echo off
echo cd /d "%CD%"
echo timeout /t 10 /nobreak ^>nul
echo cmd /c "venv\Scripts\activate ^&^& python main.py"
) > "%CD%\start_maranata.bat"

REM Cria o atalho usando powershell
echo Criando atalho na inicializacao...
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%ATALHO%');$s.TargetPath='%CD%\start_maranata.bat';$s.WorkingDirectory='%CD%';$s.WindowStyle=0;$s.Save()"

if exist "%ATALHO%" (
    echo.
    echo ========================================
    echo    CONFIGURACAO CONCLUIDA COM SUCESSO!
    echo ========================================
    echo.
    echo O sistema iniciara automaticamente com o Windows
    echo Acesse: http://localhost:8000
    echo Usuario: admin
    echo Senha: 1234
    echo.
    echo Para testar agora: .\start_maranata.bat
    echo Para remover: del "%ATALHO%"
) else (
    echo.
    echo ERRO ao criar o atalho!
    echo Tente executar este script como administrador
)

pause 