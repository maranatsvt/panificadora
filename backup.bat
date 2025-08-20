@echo off
echo ========================================
echo    BACKUP DO BANCO DE DADOS
echo ========================================
echo.

set BACKUP_DIR=backups
set DATE_FORMAT=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set DATE_FORMAT=%DATE_FORMAT: =0%

if not exist %BACKUP_DIR% mkdir %BACKUP_DIR%

if exist maranata.db (
    echo Fazendo backup do banco de dados...
    copy maranata.db %BACKUP_DIR%\maranata_%DATE_FORMAT%.db
    echo Backup salvo em: %BACKUP_DIR%\maranata_%DATE_FORMAT%.db
) else (
    echo Banco de dados nao encontrado!
)

echo.
echo Backup concluido!
pause 