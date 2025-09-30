#!/bin/bash

# ============================================
# Script de Configuração HTTPS com Let's Encrypt
# Para: Gestão de Projetos Schulz Tech
# ============================================

set -e

echo "=========================================="
echo "🔒 Configuração HTTPS - Schulz Tech"
echo "=========================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variáveis
DOMAIN="iot.schulztech.com.br"
EMAIL="fabio@schulztech.com.br"  # ALTERE ESTE EMAIL
APP_PORT=53000
APP_PATH="/home/fabio/gestao-projetos-schulz"

echo -e "${YELLOW}Domínio: ${DOMAIN}${NC}"
echo -e "${YELLOW}Porta da aplicação: ${APP_PORT}${NC}"
echo ""

# Função para verificar se comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================
# PASSO 1: Instalar Nginx
# ============================================
echo -e "${GREEN}[1/6] Instalando Nginx...${NC}"
if ! command_exists nginx; then
    sudo apt update
    sudo apt install -y nginx
    echo -e "${GREEN}✓ Nginx instalado${NC}"
else
    echo -e "${GREEN}✓ Nginx já está instalado${NC}"
fi

# ============================================
# PASSO 2: Instalar Certbot
# ============================================
echo -e "${GREEN}[2/6] Instalando Certbot (Let's Encrypt)...${NC}"
if ! command_exists certbot; then
    sudo apt install -y certbot python3-certbot-nginx
    echo -e "${GREEN}✓ Certbot instalado${NC}"
else
    echo -e "${GREEN}✓ Certbot já está instalado${NC}"
fi

# ============================================
# PASSO 3: Configurar Nginx (HTTP temporário)
# ============================================
echo -e "${GREEN}[3/6] Configurando Nginx...${NC}"

sudo tee /etc/nginx/sites-available/gestao-projetos << EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN};

    # Logs
    access_log /var/log/nginx/gestao-projetos-access.log;
    error_log /var/log/nginx/gestao-projetos-error.log;

    # Proxy para aplicação Flask
    location / {
        proxy_pass http://127.0.0.1:${APP_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Tamanho máximo de upload
    client_max_body_size 10M;
}
EOF

# Ativar site
sudo ln -sf /etc/nginx/sites-available/gestao-projetos /etc/nginx/sites-enabled/

# Remover configuração padrão
sudo rm -f /etc/nginx/sites-enabled/default

# Testar configuração
echo -e "${YELLOW}Testando configuração do Nginx...${NC}"
sudo nginx -t

# Reiniciar Nginx
sudo systemctl restart nginx
sudo systemctl enable nginx

echo -e "${GREEN}✓ Nginx configurado${NC}"

# ============================================
# PASSO 4: Configurar Firewall
# ============================================
echo -e "${GREEN}[4/6] Configurando Firewall...${NC}"

if command_exists ufw; then
    sudo ufw allow 'Nginx Full'
    sudo ufw allow 22/tcp
    sudo ufw --force enable
    echo -e "${GREEN}✓ Firewall configurado${NC}"
else
    echo -e "${YELLOW}⚠ UFW não encontrado. Configure o firewall manualmente:${NC}"
    echo "  - Porta 80 (HTTP)"
    echo "  - Porta 443 (HTTPS)"
    echo "  - Porta 22 (SSH)"
fi

# ============================================
# PASSO 5: Obter Certificado SSL
# ============================================
echo -e "${GREEN}[5/6] Obtendo certificado SSL...${NC}"
echo -e "${YELLOW}⚠ Certifique-se de que o DNS está apontando para este servidor!${NC}"
echo ""
read -p "Pressione ENTER para continuar ou Ctrl+C para cancelar..."

# Obter certificado
sudo certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos --email ${EMAIL} --redirect

echo -e "${GREEN}✓ Certificado SSL instalado${NC}"

# ============================================
# PASSO 6: Configurar Renovação Automática
# ============================================
echo -e "${GREEN}[6/6] Configurando renovação automática...${NC}"

# Testar renovação
sudo certbot renew --dry-run

# Adicionar cronjob (se não existir)
(crontab -l 2>/dev/null | grep -q certbot) || (crontab -l 2>/dev/null; echo "0 0,12 * * * certbot renew --quiet --post-hook 'systemctl reload nginx'") | crontab -

echo -e "${GREEN}✓ Renovação automática configurada${NC}"

# ============================================
# VERIFICAÇÃO FINAL
# ============================================
echo ""
echo "=========================================="
echo -e "${GREEN}✓ HTTPS CONFIGURADO COM SUCESSO!${NC}"
echo "=========================================="
echo ""
echo "🌐 Acesse sua aplicação em:"
echo -e "   ${GREEN}https://${DOMAIN}${NC}"
echo ""
echo "📋 Informações importantes:"
echo "   • Certificado SSL válido por 90 dias"
echo "   • Renovação automática configurada"
echo "   • HTTP redireciona automaticamente para HTTPS"
echo "   • Logs em: /var/log/nginx/"
echo ""
echo "🔧 Comandos úteis:"
echo "   • Verificar status: sudo systemctl status nginx"
echo "   • Renovar SSL: sudo certbot renew"
echo "   • Ver certificados: sudo certbot certificates"
echo "   • Logs Nginx: sudo tail -f /var/log/nginx/gestao-projetos-access.log"
echo ""
echo "=========================================="
