#!/bin/bash

# 🚀 Script para atualizar o servidor com as últimas versões do GitHub
# Execute no servidor

echo "🔄 Atualizando servidor com GitHub..."

# Parar o serviço
echo "⏹️ Parando serviço..."
sudo systemctl stop gestao-projetos

# Fazer backup do banco de dados
echo "💾 Fazendo backup do banco..."
cp src/database/app.db src/database/app.db.backup.$(date +%Y%m%d_%H%M%S)

# Atualizar código do GitHub
echo "📥 Baixando atualizações do GitHub..."
git pull origin main

# Verificar se houve mudanças
if [ $? -eq 0 ]; then
    echo "✅ Código atualizado com sucesso!"
    
    # Instalar novas dependências se necessário
    echo "📦 Verificando dependências..."
    source venv/bin/activate
    pip install -r requirements.txt
    
    # Reiniciar serviço
    echo "🔄 Reiniciando serviço..."
    sudo systemctl start gestao-projetos
    
    # Verificar status
    echo "🔍 Verificando status do serviço..."
    sudo systemctl status gestao-projetos --no-pager
    
    echo ""
    echo "🎉 Atualização concluída com sucesso!"
    echo "🌐 Acesse: http://$(hostname -I | awk '{print $1}'):53000"
else
    echo "❌ Erro ao atualizar código!"
    echo "🔄 Restaurando serviço..."
    sudo systemctl start gestao-projetos
    exit 1
fi
