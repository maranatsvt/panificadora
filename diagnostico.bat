@echo off
echo ========================================
echo    DIAGNOSTICO DO SISTEMA MARANATA
echo ========================================
echo.

echo 1. Verificando se o servidor esta rodando...
netstat -an | findstr :8000 >nul
if %errorLevel% equ 0 (
    echo [OK] Servidor detectado na porta 8000
) else (
    echo [ERRO] Servidor nao esta rodando!
    echo Execute: cmd /c "venv\Scripts\activate && python main.py"
    pause
    exit /b 1
)

echo.
echo 2. Testando conectividade local...
powershell -Command "try { $response = Invoke-WebRequest -Uri http://localhost:8000 -UseBasicParsing -TimeoutSec 5; Write-Host '[OK] Conectividade local funcionando' } catch { Write-Host '[ERRO] Problema de conectividade local' }"

echo.
echo 3. Testando conectividade com IP...
powershell -Command "try { $response = Invoke-WebRequest -Uri http://127.0.0.1:8000 -UseBasicParsing -TimeoutSec 5; Write-Host '[OK] Conectividade com IP funcionando' } catch { Write-Host '[ERRO] Problema de conectividade com IP' }"

echo.
echo 4. Verificando firewall...
netsh advfirewall firewall show rule name="Maranata" >nul 2>&1
if %errorLevel% equ 0 (
    echo [INFO] Regra de firewall encontrada
) else (
    echo [INFO] Nenhuma regra de firewall especifica encontrada
)

echo.
echo 5. Verificando processos Python...
tasklist | findstr python >nul
if %errorLevel% equ 0 (
    echo [OK] Processo Python encontrado
) else (
    echo [ERRO] Nenhum processo Python encontrado
)

echo.
echo ========================================
echo    SOLUCOES SUGERIDAS
echo ========================================
echo.
echo Se o navegador nao consegue acessar:
echo.
echo 1. Tente acessar: http://127.0.0.1:8000
echo 2. Limpe o cache do navegador (Ctrl+Shift+Delete)
echo 3. Use modo incognito/anonymous
echo 4. Tente outro navegador (Chrome, Firefox, Edge)
echo 5. Desative temporariamente o antivirus/firewall
echo 6. Verifique se nao ha proxy configurado
echo.
echo Para abrir automaticamente:
echo .\abrir_sistema.bat
echo.

pause 