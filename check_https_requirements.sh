#!/bin/bash

# ============================================
# Script de Verificação de Requisitos HTTPS
# ============================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOMAIN="iot.schulztech.com.br"
APP_PORT=53000
ISSUES=0

echo "=========================================="
echo -e "${BLUE}🔍 Verificação de Requisitos HTTPS${NC}"
echo "=========================================="
echo ""

# Função para verificar
check() {
    local name=$1
    local command=$2
    local expected=$3
    
    echo -ne "${YELLOW}Verificando ${name}...${NC} "
    
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗${NC}"
        ((ISSUES++))
        return 1
    fi
}

# 1. Verificar se servidor está acessível
echo -e "${BLUE}[1] Conectividade${NC}"
check "Conexão com servidor" "ping -c 1 ${DOMAIN}"

# 2. Verificar DNS
echo ""
echo -e "${BLUE}[2] DNS${NC}"
DNS_IP=$(nslookup ${DOMAIN} | grep -A 1 "Name:" | grep "Address:" | head -1 | awk '{print $2}')
echo "   DNS resolve para: ${DNS_IP}"

# 3. Verificar portas
echo ""
echo -e "${BLUE}[3] Portas${NC}"
echo -n "   Porta 80 (HTTP): "
if timeout 5 bash -c "echo > /dev/tcp/${DOMAIN}/80" 2>/dev/null; then
    echo -e "${RED}✗ Porta 80 já está respondendo (OK para HTTPS)${NC}"
else
    echo -e "${YELLOW}⚠ Porta 80 não responde (será configurada)${NC}"
fi

echo -n "   Porta 443 (HTTPS): "
if timeout 5 bash -c "echo > /dev/tcp/${DOMAIN}/443" 2>/dev/null; then
    echo -e "${GREEN}✓ Porta 443 já está configurada${NC}"
else
    echo -e "${YELLOW}⚠ Porta 443 não responde (será configurada)${NC}"
fi

echo -n "   Porta ${APP_PORT} (App): "
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://${DOMAIN}:${APP_PORT}/ 2>/dev/null || echo "000")
if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "301" ] || [ "$HTTP_STATUS" = "302" ]; then
    echo -e "${GREEN}✓ Aplicação respondendo (HTTP ${HTTP_STATUS})${NC}"
else
    echo -e "${RED}✗ Aplicação não responde (HTTP ${HTTP_STATUS})${NC}"
    ((ISSUES++))
fi

# 4. Verificar sistema
echo ""
echo -e "${BLUE}[4] Sistema Operacional${NC}"
if [ -f /etc/os-release ]; then
    OS_NAME=$(grep "^NAME=" /etc/os-release | cut -d'"' -f2)
    OS_VERSION=$(grep "^VERSION=" /etc/os-release | cut -d'"' -f2)
    echo "   Sistema: ${OS_NAME} ${OS_VERSION}"
else
    echo -e "   ${YELLOW}⚠ Não foi possível detectar o OS${NC}"
fi

# 5. Resumo
echo ""
echo "=========================================="
if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✅ TODOS OS REQUISITOS ATENDIDOS!${NC}"
    echo ""
    echo -e "Você está pronto para configurar HTTPS."
    echo -e "Execute: ${GREEN}sudo ./setup_https.sh${NC}"
else
    echo -e "${RED}⚠️ ENCONTRADOS ${ISSUES} PROBLEMA(S)${NC}"
    echo ""
    echo "Por favor, corrija os problemas antes de continuar."
    echo ""
    echo -e "${YELLOW}Ações necessárias:${NC}"
    
    if [ "$HTTP_STATUS" != "200" ] && [ "$HTTP_STATUS" != "301" ] && [ "$HTTP_STATUS" != "302" ]; then
        echo "  1. Verificar se a aplicação Flask está rodando:"
        echo "     sudo systemctl status gestao-projetos"
        echo "     sudo systemctl start gestao-projetos"
        echo ""
    fi
    
    echo "  2. Conectar ao servidor via SSH:"
    echo "     ssh fabio@${DOMAIN}"
    echo ""
    echo "  3. Verificar firewall no servidor:"
    echo "     sudo ufw status"
    echo ""
fi
echo "=========================================="

exit $ISSUES
