#!/bin/bash

# Script de Deploy - Gestão de Projetos Schulz Tech
# Autor: Sistema Manus
# Data: $(date)

set -e

echo "🚀 Iniciando deploy do Sistema de Gestão de Projetos Schulz Tech..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variáveis
PROJECT_NAME="gestao-projetos"
PROJECT_DIR="/opt/$PROJECT_NAME"
SERVICE_NAME="$PROJECT_NAME.service"
BACKUP_DIR="/opt/backups/$PROJECT_NAME"
CURRENT_DIR=$(pwd)

# Função para log
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Verificar se está rodando como root
if [[ $EUID -eq 0 ]]; then
   error "Este script não deve ser executado como root. Use sudo apenas quando necessário."
fi

# Verificar se o Python3 está instalado
if ! command -v python3 &> /dev/null; then
    error "Python3 não está instalado. Instale com: sudo apt update && sudo apt install python3 python3-pip python3-venv"
fi

# Verificar se o pip está instalado
if ! command -v pip3 &> /dev/null; then
    error "pip3 não está instalado. Instale com: sudo apt install python3-pip"
fi

log "Verificações iniciais concluídas ✓"

# Criar backup se o projeto já existir
if [ -d "$PROJECT_DIR" ]; then
    warning "Projeto já existe em $PROJECT_DIR"
    read -p "Deseja fazer backup antes de continuar? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Criando backup..."
        sudo mkdir -p "$BACKUP_DIR"
        sudo cp -r "$PROJECT_DIR" "$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S)"
        log "Backup criado em $BACKUP_DIR ✓"
    fi
    
    log "Parando serviço existente..."
    sudo systemctl stop $SERVICE_NAME 2>/dev/null || true
fi

# Criar diretório do projeto
log "Criando diretório do projeto..."
sudo mkdir -p "$PROJECT_DIR"
sudo chown ubuntu:ubuntu "$PROJECT_DIR"

# Copiar arquivos do projeto
log "Copiando arquivos do projeto..."
cp -r "$CURRENT_DIR"/* "$PROJECT_DIR/"

# Criar ambiente virtual
log "Criando ambiente virtual Python..."
cd "$PROJECT_DIR"
python3 -m venv venv

# Ativar ambiente virtual e instalar dependências
log "Instalando dependências..."
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Criar diretório do banco de dados
log "Configurando banco de dados..."
mkdir -p src/database

# Inicializar banco de dados
log "Inicializando banco de dados SQLite..."
python -c "
from src.main import app, db
with app.app_context():
    db.create_all()
    print('Banco de dados inicializado com sucesso!')
"

# Configurar serviço systemd
log "Configurando serviço systemd..."
sudo cp "$SERVICE_NAME" "/etc/systemd/system/"
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"

# Configurar permissões
log "Configurando permissões..."
sudo chown -R ubuntu:ubuntu "$PROJECT_DIR"
chmod +x "$PROJECT_DIR/deploy.sh"

# Iniciar serviço
log "Iniciando serviço..."
sudo systemctl start "$SERVICE_NAME"

# Verificar status
sleep 3
if sudo systemctl is-active --quiet "$SERVICE_NAME"; then
    log "Serviço iniciado com sucesso! ✓"
    info "Status do serviço:"
    sudo systemctl status "$SERVICE_NAME" --no-pager -l
else
    error "Falha ao iniciar o serviço. Verifique os logs com: sudo journalctl -u $SERVICE_NAME -f"
fi

# Testar API
log "Testando API..."
sleep 2
if curl -s http://localhost:7744/api/projects > /dev/null; then
    log "API respondendo corretamente na porta 7744 ✓"
else
    warning "API não está respondendo. Verifique os logs."
fi

echo
log "🎉 Deploy concluído com sucesso!"
echo
info "📋 Informações importantes:"
echo "   • Projeto instalado em: $PROJECT_DIR"
echo "   • Serviço: $SERVICE_NAME"
echo "   • Porta: 7744"
echo "   • Logs: sudo journalctl -u $SERVICE_NAME -f"
echo "   • Status: sudo systemctl status $SERVICE_NAME"
echo "   • Parar: sudo systemctl stop $SERVICE_NAME"
echo "   • Reiniciar: sudo systemctl restart $SERVICE_NAME"
echo
info "🔧 Próximos passos:"
echo "   1. Configure o Konga para redirecionar api.schulztech.com.br para localhost:7744"
echo "   2. Teste o acesso via: https://api.schulztech.com.br"
echo "   3. Popule o banco com dados iniciais: curl -X POST https://api.schulztech.com.br/api/projects/seed"
echo
log "Sistema pronto para uso! 🚀"
