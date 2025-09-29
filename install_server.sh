#!/bin/bash

# 🚀 Script de Instalação Automática - Gestão de Projetos Schulz Tech
# Execute como root ou com sudo

set -e  # Parar em caso de erro

echo "🚀 Iniciando instalação da Gestão de Projetos Schulz Tech..."
echo "=================================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir com cores
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then
    print_error "Este script deve ser executado como root ou com sudo"
    echo "Use: sudo bash install_server.sh"
    exit 1
fi

# PASSO 1: Atualizar sistema
print_status "Atualizando sistema..."
apt update && apt upgrade -y
apt install -y python3 python3-pip python3-venv git curl wget ufw

# PASSO 2: Baixar projeto
print_status "Baixando projeto do GitHub..."
cd /opt
if [ -d "gestao-projetos" ]; then
    print_warning "Diretório já existe. Fazendo backup..."
    mv gestao-projetos gestao-projetos-backup-$(date +%Y%m%d-%H%M%S)
fi

git clone https://github.com/fabio-schulztech/gestao-projetos-schulz.git gestao-projetos
cd gestao-projetos

# PASSO 3: Configurar ambiente Python
print_status "Configurando ambiente Python..."
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# PASSO 4: Configurar banco de dados
print_status "Configurando banco de dados..."
python populate_database.py

# PASSO 5: Criar usuário para a aplicação
print_status "Criando usuário da aplicação..."
if ! id "gestao-projetos" &>/dev/null; then
    useradd -m -s /bin/bash gestao-projetos
fi

# PASSO 6: Configurar permissões
print_status "Configurando permissões..."
chown -R gestao-projetos:gestao-projetos /opt/gestao-projetos
chmod +x /opt/gestao-projetos/venv/bin/python

# PASSO 7: Criar serviço systemd
print_status "Criando serviço systemd..."
cat > /etc/systemd/system/gestao-projetos.service << EOF
[Unit]
Description=Gestão de Projetos Schulz Tech
After=network.target

[Service]
Type=simple
User=gestao-projetos
WorkingDirectory=/opt/gestao-projetos
Environment=PATH=/opt/gestao-projetos/venv/bin
ExecStart=/opt/gestao-projetos/venv/bin/python src/main.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# PASSO 8: Configurar firewall
print_status "Configurando firewall..."
ufw allow 53000
ufw --force enable

# PASSO 9: Iniciar serviço
print_status "Iniciando serviço..."
systemctl daemon-reload
systemctl enable gestao-projetos
systemctl start gestao-projetos

# PASSO 10: Verificar instalação
print_status "Verificando instalação..."
sleep 5

if systemctl is-active --quiet gestao-projetos; then
    print_success "Serviço iniciado com sucesso!"
else
    print_error "Falha ao iniciar serviço. Verificando logs..."
    journalctl -u gestao-projetos -n 10
    exit 1
fi

# Verificar se a API responde
print_status "Testando API..."
if curl -s http://localhost:53000/api/projects > /dev/null; then
    print_success "API respondendo corretamente!"
else
    print_warning "API não está respondendo. Verificando logs..."
    journalctl -u gestao-projetos -n 10
fi

# Obter IP do servidor
SERVER_IP=$(hostname -I | awk '{print $1}')

echo ""
echo "=================================================="
print_success "🎉 INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
echo "=================================================="
echo ""
echo "📊 Informações da instalação:"
echo "   🌐 URL Local: http://localhost:53000"
echo "   🌍 URL Externa: http://$SERVER_IP:53000"
echo "   📁 Diretório: /opt/gestao-projetos"
echo "   👤 Usuário: gestao-projetos"
echo "   🔧 Serviço: gestao-projetos"
echo ""
echo "🔧 Comandos úteis:"
echo "   Status: sudo systemctl status gestao-projetos"
echo "   Logs: sudo journalctl -u gestao-projetos -f"
echo "   Restart: sudo systemctl restart gestao-projetos"
echo "   Stop: sudo systemctl stop gestao-projetos"
echo "   Start: sudo systemctl start gestao-projetos"
echo ""
echo "📖 Documentação: /opt/gestao-projetos/GUIA_INSTALACAO_SERVIDOR.md"
echo ""
print_success "Aplicação pronta para uso! 🚀"
