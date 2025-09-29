#!/bin/bash

# Script para iniciar a aplicação de Gestão de Projetos
# Resolve automaticamente problemas de dependências e ambiente

echo "🚀 Iniciando Aplicação de Gestão de Projetos"
echo "=============================================="

# Verificar se estamos no diretório correto
if [ ! -f "src/main.py" ]; then
    echo "❌ Erro: Execute este script no diretório raiz do projeto"
    exit 1
fi

# Verificar se o ambiente virtual existe
if [ ! -d "venv_new" ]; then
    echo "📦 Criando novo ambiente virtual..."
    python3 -m venv venv_new
fi

# Ativar ambiente virtual
echo "🔧 Ativando ambiente virtual..."
source venv_new/bin/activate

# Verificar se Flask está instalado
if ! python -c "import flask" 2>/dev/null; then
    echo "📥 Instalando dependências..."
    pip install -r requirements.txt
fi

# Verificar se a porta 53000 está em uso
if lsof -i :53000 >/dev/null 2>&1; then
    echo "⚠️  Porta 53000 já está em uso. Parando processo anterior..."
    pkill -f "python.*main.py" || true
    sleep 2
fi

# Iniciar aplicação
echo "🌐 Iniciando servidor Flask na porta 53000..."
echo "📱 Acesse: http://localhost:53000"
echo "🛑 Pressione Ctrl+C para parar o servidor"
echo ""

python src/main.py
