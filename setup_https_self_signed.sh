#!/bin/bash

# ============================================
# Configuração HTTPS com Certificado Autoassinado
# Para ambientes com firewall bloqueando Let's Encrypt
# ============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOMAIN="iot.schulztech.com.br"
APP_PORT=53000

echo "=========================================="
echo -e "${BLUE}🔒 Configuração HTTPS - Certificado Autoassinado${NC}"
echo "=========================================="
echo ""
echo -e "${YELLOW}Domínio:${NC} ${DOMAIN}"
echo -e "${YELLOW}Aplicação:${NC} localhost:${APP_PORT}"
echo ""

# ============================================
# PASSO 1: Criar certificado autoassinado
# ============================================
echo -e "${GREEN}[1/4] Criando certificado SSL autoassinado...${NC}"

# Criar diretório
sudo mkdir -p /etc/nginx/ssl

# Gerar certificado (válido por 1 ano)
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/${DOMAIN}.key \
    -out /etc/nginx/ssl/${DOMAIN}.crt \
    -subj "/C=BR/ST=SC/L=Joinville/O=Schulz Tech/OU=TI/CN=${DOMAIN}" \
    2>/dev/null

# Permissões corretas
sudo chmod 600 /etc/nginx/ssl/${DOMAIN}.key
sudo chmod 644 /etc/nginx/ssl/${DOMAIN}.crt

echo -e "${GREEN}✓ Certificado criado${NC}"
echo "  Localização: /etc/nginx/ssl/${DOMAIN}.crt"
echo "  Validade: 365 dias"
echo ""

# ============================================
# PASSO 2: Configurar Nginx
# ============================================
echo -e "${GREEN}[2/4] Configurando Nginx para HTTPS...${NC}"

sudo tee /etc/nginx/sites-available/gestao-projetos > /dev/null << 'NGINX_CONFIG'
# HTTP - Redirecionar para HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name iot.schulztech.com.br;
    
    # Logs
    access_log /var/log/nginx/gestao-projetos-access.log;
    error_log /var/log/nginx/gestao-projetos-error.log;
    
    # Redirecionar para HTTPS
    return 301 https://$server_name$request_uri;
}

# HTTPS - Certificado autoassinado
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name iot.schulztech.com.br;

    # Certificado SSL
    ssl_certificate /etc/nginx/ssl/iot.schulztech.com.br.crt;
    ssl_certificate_key /etc/nginx/ssl/iot.schulztech.com.br.key;

    # Configurações SSL modernas
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Headers de segurança
    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Logs
    access_log /var/log/nginx/gestao-projetos-access.log;
    error_log /var/log/nginx/gestao-projetos-error.log;

    # Proxy para aplicação Flask
    location / {
        proxy_pass http://127.0.0.1:53000;
        proxy_http_version 1.1;
        
        # WebSocket support
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        
        # Headers
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Tamanho máximo de upload
    client_max_body_size 10M;
    client_body_timeout 60s;
}
NGINX_CONFIG

echo -e "${GREEN}✓ Nginx configurado${NC}"
echo ""

# ============================================
# PASSO 3: Ativar site e testar
# ============================================
echo -e "${GREEN}[3/4] Ativando configuração...${NC}"

# Ativar site
sudo ln -sf /etc/nginx/sites-available/gestao-projetos /etc/nginx/sites-enabled/

# Remover configuração padrão (se existir)
sudo rm -f /etc/nginx/sites-enabled/default

# Testar configuração
echo -n "  Testando configuração do Nginx... "
if sudo nginx -t 2>&1 | grep -q "test is successful"; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}ERRO${NC}"
    sudo nginx -t
    exit 1
fi

# Reiniciar Nginx
sudo systemctl restart nginx
sudo systemctl enable nginx >/dev/null 2>&1

echo -e "${GREEN}✓ Nginx reiniciado${NC}"
echo ""

# ============================================
# PASSO 4: Verificar aplicação
# ============================================
echo -e "${GREEN}[4/4] Verificando aplicação Flask...${NC}"

# Verificar se aplicação está rodando
if sudo systemctl is-active --quiet gestao-projetos; then
    echo -e "${GREEN}✓ Aplicação Flask está rodando${NC}"
else
    echo -e "${YELLOW}⚠ Aplicação Flask não está rodando${NC}"
    echo "  Iniciando aplicação..."
    sudo systemctl start gestao-projetos
    sleep 2
    if sudo systemctl is-active --quiet gestao-projetos; then
        echo -e "${GREEN}✓ Aplicação iniciada${NC}"
    else
        echo -e "${RED}✗ Erro ao iniciar aplicação${NC}"
        echo "  Verifique os logs: sudo journalctl -u gestao-projetos -n 50"
    fi
fi

echo ""

# ============================================
# TESTE FINAL
# ============================================
echo -e "${BLUE}Testando conectividade...${NC}"

# Testar HTTP (deve redirecionar)
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/ 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
    echo -e "  HTTP  (porta 80):  ${GREEN}✓ Redirecionando para HTTPS${NC}"
else
    echo -e "  HTTP  (porta 80):  ${YELLOW}⚠ Status $HTTP_CODE${NC}"
fi

# Testar HTTPS (deve funcionar com -k para certificado autoassinado)
HTTPS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -k https://localhost/ 2>/dev/null || echo "000")
if [ "$HTTPS_CODE" = "200" ]; then
    echo -e "  HTTPS (porta 443): ${GREEN}✓ Funcionando (HTTP $HTTPS_CODE)${NC}"
else
    echo -e "  HTTPS (porta 443): ${YELLOW}⚠ Status $HTTPS_CODE${NC}"
fi

# Testar aplicação diretamente
APP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${APP_PORT}/ 2>/dev/null || echo "000")
if [ "$APP_CODE" = "200" ]; then
    echo -e "  App   (porta ${APP_PORT}): ${GREEN}✓ Respondendo (HTTP $APP_CODE)${NC}"
else
    echo -e "  App   (porta ${APP_PORT}): ${YELLOW}⚠ Status $APP_CODE${NC}"
fi

echo ""

# ============================================
# RESUMO FINAL
# ============================================
echo "=========================================="
echo -e "${GREEN}✅ HTTPS CONFIGURADO COM SUCESSO!${NC}"
echo "=========================================="
echo ""
echo -e "${BLUE}🌐 Acesse sua aplicação:${NC}"
echo -e "   ${GREEN}https://${DOMAIN}${NC}"
echo ""
echo -e "${BLUE}📋 Informações importantes:${NC}"
echo "   • Certificado: Autoassinado (365 dias)"
echo "   • Criptografia: TLS 1.2 e 1.3"
echo "   • HTTP → HTTPS: Redirecionamento automático"
echo ""
echo -e "${YELLOW}⚠️  AVISO DO NAVEGADOR:${NC}"
echo "   O navegador mostrará um aviso de segurança."
echo "   Isso é NORMAL para certificados autoassinados."
echo ""
echo -e "${BLUE}📱 Como acessar:${NC}"
echo "   1. Abra: https://${DOMAIN}"
echo "   2. Clique em 'Avançado' ou 'Advanced'"
echo "   3. Clique em 'Continuar para o site' ou 'Proceed'"
echo "   4. ✅ Site carregará normalmente!"
echo ""
echo -e "${BLUE}🔧 Comandos úteis:${NC}"
echo "   • Ver logs Nginx:      sudo tail -f /var/log/nginx/gestao-projetos-access.log"
echo "   • Ver logs App:        sudo journalctl -u gestao-projetos -f"
echo "   • Reiniciar Nginx:     sudo systemctl restart nginx"
echo "   • Reiniciar App:       sudo systemctl restart gestao-projetos"
echo "   • Status dos serviços: sudo systemctl status nginx gestao-projetos"
echo ""
echo -e "${BLUE}🔐 Localização do certificado:${NC}"
echo "   • Certificado: /etc/nginx/ssl/${DOMAIN}.crt"
echo "   • Chave:       /etc/nginx/ssl/${DOMAIN}.key"
echo ""
echo -e "${YELLOW}💡 Para certificado válido (sem aviso):${NC}"
echo "   Contate o TI para liberar acesso ao Let's Encrypt"
echo "   no firewall Fortinet (acme-v02.api.letsencrypt.org)"
echo ""
echo "=========================================="
