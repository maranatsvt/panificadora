@echo off
echo ========================================
echo    LIMPANDO PROJETO MARANATA
echo ========================================
echo.

REM Remove arquivos de cache Python
echo Removendo arquivos de cache...
if exist __pycache__ rmdir /s /q __pycache__
if exist .venv rmdir /s /q .venv

REM Remove arquivos temporários
echo Removendo arquivos temporarios...
if exist *.tmp del *.tmp
if exist *.log del *.log

REM Remove diretórios desnecessários
echo Removendo diretorios desnecessarios...
if exist ncm rmdir /s /q ncm
if exist nssm rmdir /s /q nssm

REM Remove arquivos duplicados de serviço
echo Removendo arquivos duplicados...
if exist start_service.bat del start_service.bat
if exist start_service_now.bat del start_service_now.bat
if exist auto_start.bat del auto_start.bat

echo.
echo ========================================
echo    LIMPEZA CONCLUIDA!
echo ========================================
echo.
echo Arquivos mantidos:
echo - install_service_fixed.bat (servico Windows)
echo - setup_auto_start.bat (inicializacao automatica)
echo - abrir_sistema.bat (abrir no navegador)
echo - check_service.bat (verificar status)
echo - remove_service.bat (remover servico)
echo - start_maranata.bat (inicializacao manual)
echo.
echo Para configurar inicializacao automatica:
echo 1. Execute setup_auto_start.bat como administrador
echo 2. Ou execute install_service_fixed.bat como administrador
echo.

pause 