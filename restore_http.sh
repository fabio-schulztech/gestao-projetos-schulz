#!/bin/bash

# ============================================
# Script para Restaurar Acesso HTTP
# Remove configuração HTTPS e volta ao HTTP
# ============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo -e "${BLUE}🔄 Restaurando Acesso HTTP${NC}"
echo "=========================================="
echo ""

DOMAIN="iot.schulztech.com.br"
APP_PORT=53000

# ============================================
# PASSO 1: Restaurar configuração HTTP
# ============================================
echo -e "${GREEN}[1/3] Restaurando configuração HTTP do Nginx...${NC}"

sudo tee /etc/nginx/sites-available/gestao-projetos > /dev/null << 'NGINX_HTTP'
server {
    listen 80;
    listen [::]:80;
    server_name iot.schulztech.com.br;

    # Logs
    access_log /var/log/nginx/gestao-projetos-access.log;
    error_log /var/log/nginx/gestao-projetos-error.log;

    # Proxy para aplicação Flask
    location / {
        proxy_pass http://127.0.0.1:53000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    client_max_body_size 10M;
}
NGINX_HTTP

echo -e "${GREEN}✓ Configuração HTTP restaurada${NC}"
echo ""

# ============================================
# PASSO 2: Ativar e testar
# ============================================
echo -e "${GREEN}[2/3] Testando configuração...${NC}"

# Ativar configuração
sudo ln -sf /etc/nginx/sites-available/gestao-projetos /etc/nginx/sites-enabled/

# Testar configuração
if sudo nginx -t 2>&1 | grep -q "test is successful"; then
    echo -e "${GREEN}✓ Configuração válida${NC}"
else
    echo -e "${RED}✗ Erro na configuração${NC}"
    sudo nginx -t
    exit 1
fi

# Reiniciar Nginx
sudo systemctl restart nginx

echo -e "${GREEN}✓ Nginx reiniciado${NC}"
echo ""

# ============================================
# PASSO 3: Verificar aplicação
# ============================================
echo -e "${GREEN}[3/3] Verificando aplicação...${NC}"

# Verificar se aplicação está rodando
if ! sudo systemctl is-active --quiet gestao-projetos; then
    echo -e "${YELLOW}⚠ Aplicação não está rodando. Iniciando...${NC}"
    sudo systemctl start gestao-projetos
    sleep 2
fi

# Verificar status
if sudo systemctl is-active --quiet gestao-projetos; then
    echo -e "${GREEN}✓ Aplicação Flask rodando${NC}"
else
    echo -e "${RED}✗ Aplicação com problema${NC}"
    echo "  Veja os logs: sudo journalctl -u gestao-projetos -n 30"
fi

echo ""

# ============================================
# TESTE FINAL
# ============================================
echo -e "${BLUE}Testando conectividade...${NC}"

# Testar aplicação diretamente
APP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${APP_PORT}/ 2>/dev/null || echo "000")
if [ "$APP_CODE" = "200" ]; then
    echo -e "  App   (porta ${APP_PORT}): ${GREEN}✓ Respondendo${NC}"
else
    echo -e "  App   (porta ${APP_PORT}): ${YELLOW}⚠ Status $APP_CODE${NC}"
fi

# Testar HTTP via Nginx
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/ 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "  HTTP  (porta 80):        ${GREEN}✓ Funcionando${NC}"
else
    echo -e "  HTTP  (porta 80):        ${YELLOW}⚠ Status $HTTP_CODE${NC}"
fi

echo ""

# ============================================
# RESUMO
# ============================================
echo "=========================================="
echo -e "${GREEN}✅ HTTP RESTAURADO!${NC}"
echo "=========================================="
echo ""
echo -e "${BLUE}🌐 Acesse sua aplicação:${NC}"
echo -e "   ${GREEN}http://${DOMAIN}:53000${NC} (direto)"
echo -e "   ${GREEN}http://${DOMAIN}${NC} (via Nginx)"
echo ""
echo -e "${BLUE}📋 Status dos serviços:${NC}"
sudo systemctl status nginx --no-pager -l | head -3
sudo systemctl status gestao-projetos --no-pager -l | head -3
echo ""
echo -e "${BLUE}🔧 Comandos úteis:${NC}"
echo "   • Ver logs App:   sudo journalctl -u gestao-projetos -f"
echo "   • Ver logs Nginx: sudo tail -f /var/log/nginx/gestao-projetos-access.log"
echo "   • Reiniciar App:  sudo systemctl restart gestao-projetos"
echo ""
echo "=========================================="
