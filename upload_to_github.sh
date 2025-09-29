#!/bin/bash

# Script para fazer upload do projeto para o GitHub
# Execute este script após criar o repositório no GitHub

echo "🚀 Upload do Sistema de Gestão de Projetos para GitHub"
echo "====================================================="

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar se git está configurado
if ! git config --global user.name > /dev/null 2>&1; then
    echo -e "${RED}❌ Git não está configurado. Configure primeiro:${NC}"
    echo "git config --global user.name 'Seu Nome'"
    echo "git config --global user.email 'seu@email.com'"
    exit 1
fi

# Verificar se estamos em um repositório git
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Não é um repositório Git. Execute 'git init' primeiro.${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Instruções para criar repositório no GitHub:${NC}"
echo ""
echo "1. Acesse: https://github.com/new"
echo "2. Nome do repositório: gestao-projetos-schulz"
echo "3. Descrição: Sistema de Gestão de Projetos Schulz Tech"
echo "4. Marque como 'Public' ou 'Private'"
echo "5. NÃO marque 'Add a README file'"
echo "6. NÃO marque 'Add .gitignore'"
echo "7. NÃO marque 'Choose a license'"
echo "8. Clique em 'Create repository'"
echo ""

read -p "Pressione Enter após criar o repositório no GitHub..."

# Solicitar URL do repositório
echo ""
echo -e "${YELLOW}🔗 Cole a URL do seu repositório GitHub:${NC}"
echo "Exemplo: https://github.com/SEU_USUARIO/gestao-projetos-schulz.git"
read -p "URL: " REPO_URL

if [ -z "$REPO_URL" ]; then
    echo -e "${RED}❌ URL não fornecida. Saindo...${NC}"
    exit 1
fi

# Adicionar remote origin
echo -e "${YELLOW}🔗 Configurando repositório remoto...${NC}"
git remote add origin "$REPO_URL"

# Verificar se remote foi adicionado
if git remote -v | grep -q "origin"; then
    echo -e "${GREEN}✅ Repositório remoto configurado${NC}"
else
    echo -e "${RED}❌ Erro ao configurar repositório remoto${NC}"
    exit 1
fi

# Fazer push
echo -e "${YELLOW}📤 Fazendo upload para GitHub...${NC}"
git branch -M main
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 Upload concluído com sucesso!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Próximos passos:${NC}"
    echo "1. Acesse seu repositório: $REPO_URL"
    echo "2. Verifique se todos os arquivos foram enviados"
    echo "3. Configure o repositório como público (se desejado)"
    echo "4. Adicione uma descrição e tags"
    echo ""
    echo -e "${YELLOW}🖥️ Para instalar no servidor:${NC}"
    echo "1. Acesse seu servidor"
    echo "2. Execute: git clone $REPO_URL"
    echo "3. Siga o guia: INSTALACAO_SERVIDOR.md"
    echo ""
    echo -e "${GREEN}✅ Projeto pronto para uso!${NC}"
else
    echo -e "${RED}❌ Erro no upload. Verifique sua conexão e permissões.${NC}"
    echo ""
    echo -e "${YELLOW}🔧 Soluções possíveis:${NC}"
    echo "1. Verifique se o repositório existe no GitHub"
    echo "2. Verifique suas credenciais Git"
    echo "3. Execute: git remote -v (para verificar URL)"
    echo "4. Execute: git status (para verificar status)"
fi
