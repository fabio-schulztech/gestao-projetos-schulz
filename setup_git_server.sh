#!/bin/bash

# 🚀 Script para configurar Git no servidor e sincronizar com GitHub
# Execute no servidor

echo "🔧 Configurando Git no servidor..."

# Configurar Git globalmente
git config --global user.name "Schulz Tech Server"
git config --global user.email "server@schulztech.com.br"

# Desabilitar verificação SSL temporariamente
git config --global http.sslVerify false

# Configurar branch padrão
git config --global init.defaultBranch main

echo "✅ Git configurado com sucesso!"

# Se o diretório não for um repositório Git, inicializar
if [ ! -d ".git" ]; then
    echo "📁 Inicializando repositório Git..."
    git init
    git remote add origin https://github.com/fabio-schulztech/gestao-projetos-schulz.git
    echo "✅ Repositório Git inicializado!"
fi

echo ""
echo "🚀 Comandos para sincronizar com GitHub:"
echo ""
echo "# Baixar atualizações do GitHub:"
echo "git pull origin main"
echo ""
echo "# Fazer commit de alterações locais:"
echo "git add ."
echo "git commit -m 'Atualizações do servidor'"
echo "git push origin main"
echo ""
echo "# Verificar status:"
echo "git status"
echo ""
echo "✅ Configuração concluída!"
