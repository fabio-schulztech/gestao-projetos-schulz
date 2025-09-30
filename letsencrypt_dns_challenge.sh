#!/bin/bash

# ============================================
# Let's Encrypt via DNS Challenge
# Contorna bloqueio do Fortinet
# ============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOMAIN="iot.schulztech.com.br"
EMAIL="fabio@schulztech.com.br"

echo "=========================================="
echo -e "${BLUE}🔒 Let's Encrypt via DNS Challenge${NC}"
echo "=========================================="
echo ""

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Por favor, execute como root (sudo)${NC}"
    exit 1
fi

# ============================================
# PASSO 1: Instalar Certbot com plugin DNS
# ============================================
echo -e "${GREEN}[1/5] Instalando Certbot com plugin DNS Cloudflare...${NC}"

apt update
apt install -y certbot python3-certbot-dns-cloudflare

echo -e "${GREEN}✓ Certbot instalado${NC}"
echo ""

# ============================================
# PASSO 2: Criar arquivo de credenciais
# ============================================
echo -e "${GREEN}[2/5] Configurando credenciais da Cloudflare...${NC}"
echo ""
echo -e "${YELLOW}⚠ VOCÊ PRECISA DO TOKEN API DA CLOUDFLARE!${NC}"
echo ""
echo "Como obter:"
echo "1. Acesse: https://dash.cloudflare.com/profile/api-tokens"
echo "2. Clique em 'Create Token'"
echo "3. Use o template 'Edit zone DNS'"
echo "4. Permissões: Zone.DNS.Edit"
echo "5. Zone Resources: Include → schulztech.com.br"
echo "6. Copie o token gerado"
echo ""
read -p "Cole o token da Cloudflare aqui: " CF_TOKEN

if [ -z "$CF_TOKEN" ]; then
    echo -e "${RED}Token não pode ser vazio!${NC}"
    exit 1
fi

# Criar diretório
mkdir -p /root/.secrets

# Criar arquivo de credenciais
cat > /root/.secrets/cloudflare.ini << EOF
# Cloudflare API Token
dns_cloudflare_api_token = ${CF_TOKEN}
EOF

# Proteger arquivo
chmod 600 /root/.secrets/cloudflare.ini

echo -e "${GREEN}✓ Credenciais configuradas${NC}"
echo ""

# ============================================
# PASSO 3: Obter certificado
# ============================================
echo -e "${GREEN}[3/5] Obtendo certificado Let's Encrypt...${NC}"
echo ""
echo -e "${YELLOW}Aguarde, isso pode levar 1-2 minutos...${NC}"
echo ""

certbot certonly \
    --dns-cloudflare \
    --dns-cloudflare-credentials /root/.secrets/cloudflare.ini \
    --dns-cloudflare-propagation-seconds 30 \
    -d ${DOMAIN} \
    --non-interactive \
    --agree-tos \
    --email ${EMAIL} \
    --preferred-challenges dns-01

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Certificado obtido com sucesso!${NC}"
else
    echo -e "${RED}✗ Erro ao obter certificado${NC}"
    echo ""
    echo "Possíveis causas:"
    echo "  • Token da Cloudflare inválido"
    echo "  • Token sem permissão de editar DNS"
    echo "  • Domínio não está na Cloudflare"
    exit 1
fi

echo ""

# ============================================
# PASSO 4: Configurar Nginx
# ============================================
echo -e "${GREEN}[4/5] Configurando Nginx...${NC}"

tee /etc/nginx/sites-available/gestao-projetos-ssl > /dev/null << 'NGINX_CONFIG'
# HTTP - Redirecionar para HTTPS
server {
    listen 53080;
    listen [::]:53080;
    server_name iot.schulztech.com.br;
    
    return 301 https://$server_name:53443$request_uri;
}

# HTTPS
server {
    listen 53443 ssl http2;
    listen [::]:53443 ssl http2;
    server_name iot.schulztech.com.br;

    # Certificado Let's Encrypt
    ssl_certificate /etc/letsencrypt/live/iot.schulztech.com.br/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/iot.schulztech.com.br/privkey.pem;

    # Configurações SSL modernas
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/letsencrypt/live/iot.schulztech.com.br/chain.pem;

    # Logs
    access_log /var/log/nginx/gestao-projetos-https-access.log;
    error_log /var/log/nginx/gestao-projetos-https-error.log;

    # Rota /gestao_de_projetos
    location /gestao_de_projetos {
        rewrite ^/gestao_de_projetos/(.*) /$1 break;
        rewrite ^/gestao_de_projetos$ / break;
        
        proxy_pass http://127.0.0.1:53100;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    client_max_body_size 10M;
}
NGINX_CONFIG

# Ativar site
ln -sf /etc/nginx/sites-available/gestao-projetos-ssl /etc/nginx/sites-enabled/

# Testar configuração
nginx -t

# Reiniciar Nginx
systemctl restart nginx
systemctl enable nginx

echo -e "${GREEN}✓ Nginx configurado${NC}"
echo ""

# ============================================
# PASSO 5: Configurar renovação automática
# ============================================
echo -e "${GREEN}[5/5] Configurando renovação automática...${NC}"

# Testar renovação
certbot renew --dry-run

# Adicionar hook de renovação para recarregar Nginx
cat > /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh << 'EOF'
#!/bin/bash
systemctl reload nginx
EOF

chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh

echo -e "${GREEN}✓ Renovação automática configurada${NC}"
echo ""

# ============================================
# RESUMO FINAL
# ============================================
echo "=========================================="
echo -e "${GREEN}✅ HTTPS CONFIGURADO COM SUCESSO!${NC}"
echo "=========================================="
echo ""
echo -e "${BLUE}🌐 Acesse sua aplicação:${NC}"
echo -e "   ${GREEN}https://${DOMAIN}:53443/gestao_de_projetos${NC}"
echo ""
echo -e "${BLUE}📋 Informações:${NC}"
echo "   • Certificado: Let's Encrypt (válido e sem aviso!)"
echo "   • Validade: 90 dias"
echo "   • Renovação: Automática via DNS Challenge"
echo "   • Método: DNS-01 (não bloqueado pelo Fortinet)"
echo ""
echo -e "${BLUE}📂 Localização dos certificados:${NC}"
echo "   /etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
echo "   /etc/letsencrypt/live/${DOMAIN}/privkey.pem"
echo ""
echo -e "${BLUE}🔄 Renovação:${NC}"
echo "   • Automática: Certbot renova 30 dias antes do vencimento"
echo "   • Manual: sudo certbot renew"
echo "   • Testar: sudo certbot renew --dry-run"
echo ""
echo -e "${BLUE}🔧 Comandos úteis:${NC}"
echo "   • Ver certificados: sudo certbot certificates"
echo "   • Renovar manualmente: sudo certbot renew"
echo "   • Logs Nginx: sudo tail -f /var/log/nginx/gestao-projetos-https-access.log"
echo ""
echo "=========================================="
