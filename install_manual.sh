#!/bin/bash

# 🚀 Instalação Manual - Gestão de Projetos Schulz Tech
# Execute comando por comando no seu servidor

echo "🚀 GUIA DE INSTALAÇÃO MANUAL"
echo "=============================="
echo ""
echo "Execute os comandos abaixo no seu servidor:"
echo ""

echo "1️⃣ ATUALIZAR SISTEMA:"
echo "sudo apt update && sudo apt upgrade -y"
echo "sudo apt install -y python3 python3-pip python3-venv git curl wget"
echo ""

echo "2️⃣ BAIXAR PROJETO:"
echo "cd /opt"
echo "sudo git clone https://github.com/fabio-schulztech/gestao-projetos-schulz.git gestao-projetos"
echo "cd gestao-projetos"
echo ""

echo "3️⃣ CONFIGURAR PYTHON:"
echo "sudo python3 -m venv venv"
echo "sudo venv/bin/pip install -r requirements.txt"
echo ""

echo "4️⃣ CONFIGURAR BANCO:"
echo "sudo venv/bin/python populate_database.py"
echo ""

echo "5️⃣ CRIAR USUÁRIO:"
echo "sudo useradd -m -s /bin/bash gestao-projetos"
echo "sudo chown -R gestao-projetos:gestao-projetos /opt/gestao-projetos"
echo ""

echo "6️⃣ CRIAR SERVIÇO:"
echo "sudo tee /etc/systemd/system/gestao-projetos.service > /dev/null <<EOF"
echo "[Unit]"
echo "Description=Gestão de Projetos Schulz Tech"
echo "After=network.target"
echo ""
echo "[Service]"
echo "Type=simple"
echo "User=gestao-projetos"
echo "WorkingDirectory=/opt/gestao-projetos"
echo "Environment=PATH=/opt/gestao-projetos/venv/bin"
echo "ExecStart=/opt/gestao-projetos/venv/bin/python src/main.py"
echo "Restart=always"
echo "RestartSec=10"
echo ""
echo "[Install]"
echo "WantedBy=multi-user.target"
echo "EOF"
echo ""

echo "7️⃣ CONFIGURAR FIREWALL:"
echo "sudo ufw allow 53000"
echo "sudo ufw --force enable"
echo ""

echo "8️⃣ INICIAR SERVIÇO:"
echo "sudo systemctl daemon-reload"
echo "sudo systemctl enable gestao-projetos"
echo "sudo systemctl start gestao-projetos"
echo ""

echo "9️⃣ VERIFICAR:"
echo "sudo systemctl status gestao-projetos"
echo "curl http://localhost:53000/api/projects"
echo ""

echo "🌐 ACESSAR:"
echo "http://SEU-IP-SERVIDOR:53000"
echo ""

echo "✅ PRONTO! Aplicação instalada e funcionando!"
