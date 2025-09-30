#!/bin/bash

# ============================================
# Configurar Novo Serviço na Porta 53100
# ============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo -e "${BLUE}🔄 Configurando Novo Projeto (Porta 53100)${NC}"
echo "=========================================="
echo ""

# 1. Parar serviço antigo
echo -e "${GREEN}[1/4] Parando serviço antigo (porta 53000)...${NC}"
sudo systemctl stop gestao-projetos
sudo systemctl disable gestao-projetos
echo -e "${GREEN}✓ Serviço antigo desabilitado${NC}"
echo ""

# 2. Criar novo serviço
echo -e "${GREEN}[2/4] Criando novo serviço (porta 53100)...${NC}"

sudo tee /etc/systemd/system/gestao-projetos-novo.service > /dev/null << 'EOF'
[Unit]
Description=Gestão de Projetos Schulz Tech - Novo
After=network.target

[Service]
Type=simple
User=fabio
WorkingDirectory=/home/fabio/gestao-projetos-schulz
Environment="PATH=/home/fabio/gestao-projetos-schulz/venv/bin"
ExecStart=/home/fabio/gestao-projetos-schulz/venv/bin/python /home/fabio/gestao-projetos-schulz/src/main.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo -e "${GREEN}✓ Arquivo de serviço criado${NC}"
echo ""

# 3. Ativar novo serviço
echo -e "${GREEN}[3/4] Ativando novo serviço...${NC}"
sudo systemctl daemon-reload
sudo systemctl enable gestao-projetos-novo
sudo systemctl start gestao-projetos-novo

sleep 2
echo -e "${GREEN}✓ Serviço iniciado${NC}"
echo ""

# 4. Verificar
echo -e "${GREEN}[4/4] Verificando...${NC}"

# Status
sudo systemctl status gestao-projetos-novo --no-pager -l | head -10

echo ""
echo "Portas abertas:"
sudo netstat -tlnp | grep python

echo ""
echo "=========================================="
echo -e "${GREEN}✅ CONFIGURAÇÃO CONCLUÍDA!${NC}"
echo "=========================================="
echo ""
echo -e "${BLUE}🌐 Acesse:${NC}"
echo -e "   ${GREEN}http://iot.schulztech.com.br:53100${NC}"
echo ""
echo -e "${BLUE}🔧 Comandos úteis:${NC}"
echo "   • Ver logs:     sudo journalctl -u gestao-projetos-novo -f"
echo "   • Reiniciar:    sudo systemctl restart gestao-projetos-novo"
echo "   • Parar:        sudo systemctl stop gestao-projetos-novo"
echo "   • Status:       sudo systemctl status gestao-projetos-novo"
echo ""
echo "=========================================="
