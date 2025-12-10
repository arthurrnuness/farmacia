@echo off
echo 🚀 Iniciando deploy...

git add .
set /p mensagem="Mensagem do commit: "
git commit -m "%mensagem%"

echo 📤 Enviando para GitHub...
git push origin main

echo 🔄 Deploy no VPS...
ssh root@159.65.190.78 "cd /var/www/farmacia && git pull origin main && docker-compose restart web"

echo ✅ Deploy completo!
pause