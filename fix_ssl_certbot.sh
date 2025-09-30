#!/bin/bash

# ============================================
# Script para Corrigir Problema SSL do Certbot
# ============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo -e "${YELLOW}🔧 Correção de SSL para Certbot${NC}"
echo "=========================================="
echo ""

DOMAIN="iot.schulztech.com.br"
EMAIL="fabio@schulztech.com.br"

# ============================================
# SOLUÇÃO 1: Atualizar certificados CA
# ============================================
echo -e "${GREEN}[1/4] Atualizando certificados CA do sistema...${NC}"
sudo apt update
sudo apt install -y ca-certificates
sudo update-ca-certificates --fresh
echo -e "${GREEN}✓ Certificados CA atualizados${NC}"
echo ""

# ============================================
# SOLUÇÃO 2: Reinstalar Certbot
# ============================================
echo -e "${GREEN}[2/4] Reinstalando Certbot...${NC}"
sudo apt remove --purge -y certbot python3-certbot-nginx
sudo apt autoremove -y
sudo apt install -y certbot python3-certbot-nginx
echo -e "${GREEN}✓ Certbot reinstalado${NC}"
echo ""

# ============================================
# SOLUÇÃO 3: Verificar conectividade HTTPS
# ============================================
echo -e "${GREEN}[3/4] Testando conectividade HTTPS...${NC}"
if curl -I https://acme-v02.api.letsencrypt.org/directory 2>&1 | grep -q "200 OK\|HTTP/2 200"; then
    echo -e "${GREEN}✓ Conectividade OK${NC}"
else
    echo -e "${YELLOW}⚠ Problema de conectividade detectado${NC}"
    echo ""
    echo -e "${YELLOW}Possível proxy corporativo ou firewall Fortinet.${NC}"
    echo -e "${YELLOW}Vamos tentar com certificado autoassinado como fallback.${NC}"
    echo ""
fi

# ============================================
# SOLUÇÃO 4: Tentar obter certificado SSL
# ============================================
echo -e "${GREEN}[4/4] Tentando obter certificado SSL...${NC}"
echo ""

# Tentar com servidor de staging primeiro (para debug)
echo -e "${YELLOW}Tentativa 1: Servidor de teste (staging)${NC}"
if sudo certbot certonly --nginx --staging \
    -d ${DOMAIN} \
    --non-interactive \
    --agree-tos \
    --email ${EMAIL} 2>&1 | tee /tmp/certbot_staging.log; then
    
    echo -e "${GREEN}✓ Staging funcionou! Tentando produção...${NC}"
    
    # Remover certificado de staging
    sudo certbot delete --cert-name ${DOMAIN} --non-interactive || true
    
    # Tentar produção
    echo ""
    echo -e "${YELLOW}Tentativa 2: Servidor de produção${NC}"
    sudo certbot --nginx \
        -d ${DOMAIN} \
        --non-interactive \
        --agree-tos \
        --email ${EMAIL} \
        --redirect
    
    echo -e "${GREEN}✓ Certificado SSL obtido com sucesso!${NC}"
else
    echo -e "${RED}✗ Falha no staging${NC}"
    echo ""
    echo -e "${YELLOW}=========================================="
    echo "SOLUÇÃO ALTERNATIVA: Certificado Autoassinado"
    echo -e "==========================================${NC}"
    echo ""
    echo "O Let's Encrypt não está acessível deste servidor."
    echo "Vamos criar um certificado autoassinado temporário."
    echo ""
    read -p "Pressione ENTER para criar certificado autoassinado..."
    
    # Criar diretório para certificado
    sudo mkdir -p /etc/nginx/ssl
    
    # Gerar certificado autoassinado
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/${DOMAIN}.key \
        -out /etc/nginx/ssl/${DOMAIN}.crt \
        -subj "/C=BR/ST=SC/L=Joinville/O=Schulz Tech/CN=${DOMAIN}"
    
    # Configurar Nginx para HTTPS com certificado autoassinado
    sudo tee /etc/nginx/sites-available/gestao-projetos > /dev/null << 'NGINX_EOF'
# HTTP - Redirecionar para HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name iot.schulztech.com.br;
    
    return 301 https://$server_name$request_uri;
}

# HTTPS - Certificado autoassinado
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name iot.schulztech.com.br;

    # Certificado autoassinado
    ssl_certificate /etc/nginx/ssl/iot.schulztech.com.br.crt;
    ssl_certificate_key /etc/nginx/ssl/iot.schulztech.com.br.key;

    # Configurações SSL
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';

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
NGINX_EOF
    
    # Testar e reiniciar Nginx
    sudo nginx -t
    sudo systemctl restart nginx
    
    echo ""
    echo -e "${GREEN}✓ HTTPS configurado com certificado autoassinado${NC}"
    echo ""
    echo -e "${YELLOW}⚠ IMPORTANTE:${NC}"
    echo "  • O navegador mostrará aviso de segurança"
    echo "  • Clique em 'Avançado' e 'Continuar para o site'"
    echo "  • O certificado é válido por 365 dias"
    echo "  • Para usar Let's Encrypt, contate o suporte de TI"
    echo "    sobre o bloqueio do firewall Fortinet"
    echo ""
fi

echo ""
echo "=========================================="
echo -e "${GREEN}✅ CONFIGURAÇÃO CONCLUÍDA${NC}"
echo "=========================================="
echo ""
echo "🌐 Acesse: https://${DOMAIN}"
echo ""
echo "📋 Próximos passos:"
echo "  1. Teste o acesso via HTTPS"
echo "  2. Se usar certificado autoassinado, ignore o aviso do navegador"
echo "  3. Para certificado válido, contate TI sobre acesso ao Let's Encrypt"
echo ""
