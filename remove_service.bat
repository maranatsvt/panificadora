@echo off
echo ========================================
echo    REMOVENDO SERVICO MARANATA
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

REM Para e remove o serviço
echo Parando servico...
"%NSSM_PATH%" stop MaranataFinanceiro

echo Removendo servico...
"%NSSM_PATH%" remove MaranataFinanceiro confirm

if %errorLevel% equ 0 (
    echo.
    echo ========================================
    echo    SERVICO REMOVIDO COM SUCESSO!
    echo ========================================
    echo.
    echo O sistema nao iniciara mais automaticamente com o Windows
) else (
    echo.
    echo ERRO ao remover o servico!
    echo Verifique se o servico existe e se voce esta executando como administrador
)

pause 