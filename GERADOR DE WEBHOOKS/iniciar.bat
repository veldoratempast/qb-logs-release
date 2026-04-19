@echo off
title Gerador de Webhooks - Discord Bot
echo.
echo =======================================
echo    GERADOR DE WEBHOOKS - DISCORD BOT
echo =======================================
echo.
echo Registrando comandos slash...
echo.
node deploy-commands.js
echo.
echo Iniciando o bot...
echo.
node index.js
pause
