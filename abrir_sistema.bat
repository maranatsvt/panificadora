@echo off
echo ========================================
echo    ABRINDO SISTEMA MARANATA
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

echo Servidor detectado na porta 8000
echo Abrindo navegador...

REM Tenta abrir com diferentes navegadores
start http://localhost:8000 2>nul
if %errorLevel% neq 0 (
    start http://127.0.0.1:8000 2>nul
)

echo.
echo ========================================
echo    SISTEMA ABERTO!
echo ========================================
echo.
echo URL: http://localhost:8000
echo Usuario: admin
echo Senha: 1234
echo.
echo Se o navegador nao abriu automaticamente,
echo copie e cole esta URL: http://localhost:8000
echo.

pause 