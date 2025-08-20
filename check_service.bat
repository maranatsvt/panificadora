@echo off
echo ========================================
echo    STATUS DO SERVICO MARANATA
echo ========================================
echo.

REM Verifica se o serviço existe
sc query MaranataFinanceiro >nul 2>&1
if %errorLevel% neq 0 (
    echo O servico MaranataFinanceiro nao esta instalado.
    echo Execute start_service.bat como administrador para instalar.
    pause
    exit /b 1
)

REM Mostra o status do serviço
echo Status do servico:
sc query MaranataFinanceiro

echo.
echo ========================================
echo    COMANDOS UTEIS
echo ========================================
echo.
echo Para iniciar o servico: net start MaranataFinanceiro
echo Para parar o servico: net stop MaranataFinanceiro
echo Para reiniciar o servico: net stop MaranataFinanceiro && net start MaranataFinanceiro
echo.
echo Para acessar o sistema: http://localhost:8000
echo Usuario: admin
echo Senha: 1234
echo.

pause 