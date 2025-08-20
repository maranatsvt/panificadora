@echo off
echo ========================================
echo    INSTALANDO DEPENDENCIAS
echo ========================================
echo.
echo Verificando se Python esta instalado...
python --version
if errorlevel 1 (
    echo ERRO: Python nao encontrado!
    echo Por favor, instale o Python 3.8 ou superior
    echo Download: https://www.python.org/downloads/
    pause
    exit /b 1
)
echo.
echo Instalando dependencias...
pip install -r requirements.txt
if errorlevel 1 (
    echo ERRO: Falha ao instalar dependencias!
    pause
    exit /b 1
)
echo.
echo ========================================
echo    INSTALACAO CONCLUIDA!
echo ========================================
echo.
echo Para iniciar o sistema, execute: start.bat
echo.
pause 