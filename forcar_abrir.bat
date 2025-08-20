@echo off
echo ========================================
echo    FORCANDO ABERTURA DO SISTEMA
echo ========================================
echo.

REM Verifica se o servidor está rodando
netstat -an | findstr :8000 >nul
if %errorLevel% neq 0 (
    echo ERRO: O servidor nao esta rodando!
    echo Execute: cmd /c "venv\Scripts\activate && python main.py"
    pause
    exit /b 1
)

echo Servidor detectado! Tentando diferentes metodos de abertura...
echo.

REM Método 1: localhost
echo Tentando http://localhost:8000
start http://localhost:8000
timeout /t 2 /nobreak >nul

REM Método 2: IP local
echo Tentando http://127.0.0.1:8000
start http://127.0.0.1:8000
timeout /t 2 /nobreak >nul

REM Método 3: Forçar com PowerShell
echo Tentando com PowerShell...
powershell -Command "Start-Process 'http://localhost:8000'"
timeout /t 2 /nobreak >nul

REM Método 4: Tentar com diferentes navegadores
echo Tentando com navegadores especificos...

REM Chrome
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    echo Tentando Chrome...
    "C:\Program Files\Google\Chrome\Application\chrome.exe" http://localhost:8000
)

REM Firefox
if exist "C:\Program Files\Mozilla Firefox\firefox.exe" (
    echo Tentando Firefox...
    "C:\Program Files\Mozilla Firefox\firefox.exe" http://localhost:8000
)

REM Edge
if exist "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" (
    echo Tentando Edge...
    "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" http://localhost:8000
)

echo.
echo ========================================
echo    ABERTURA FORCADA CONCLUIDA!
echo ========================================
echo.
echo Se ainda nao abriu, tente manualmente:
echo.
echo 1. Abra o navegador
echo 2. Digite na barra de enderecos: http://localhost:8000
echo 3. Ou tente: http://127.0.0.1:8000
echo.
echo Credenciais:
echo Usuario: admin
echo Senha: 1234
echo.

pause 