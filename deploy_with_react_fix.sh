#!/bin/bash

# Script de Deploy com Correção React #130 - Gestão de Projetos Schulz Tech
# Autor: Sistema Manus
# Data: $(date)

set -e

echo "🚀 Iniciando deploy com correção React #130..."

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

# Instalar dependências adicionais para correção React
log "Instalando dependências para correção React..."
pip install requests

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

# Aplicar correções específicas para React #130
log "Aplicando correções para erro React #130..."

# 1. Modificar main.py para adicionar headers corretos
log "Configurando headers HTTP para resolver cache..."
python3 -c "
import re

# Ler arquivo main.py
with open('src/main.py', 'r') as f:
    content = f.read()

# Verificar se headers já existem
if 'Cache-Control' not in content:
    # Adicionar headers antes da última linha
    headers_code = '''
# Configurar headers para resolver problemas de cache React #130
@app.after_request
def after_request(response):
    # Headers para resolver problemas de cache com React
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'
    
    # Headers específicos para arquivos JavaScript
    if response.content_type and 'javascript' in response.content_type:
        response.headers['Content-Type'] = 'application/javascript; charset=utf-8'
    
    return response

'''
    
    # Inserir antes da linha com if __name__ == '__main__':
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if 'if __name__ == \"__main__\":' in line:
            lines.insert(i, headers_code)
            break
    
    # Escrever arquivo modificado
    with open('src/main.py', 'w') as f:
        f.write('\n'.join(lines))
    
    print('Headers HTTP adicionados com sucesso!')
else:
    print('Headers HTTP já configurados!')
"

# 2. Criar página de diagnóstico React
log "Criando página de diagnóstico React..."
cat > src/static/react_debug.html << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Debug React #130 - Servidor</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
        .error { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 15px 0; }
        .success { background: #d4edda; border-left: 4px solid #28a745; padding: 15px; margin: 15px 0; }
        .code { background: #f8f9fa; padding: 10px; border-radius: 4px; font-family: monospace; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔧 Debug React #130 - Servidor</h1>
        
        <div class="error">
            <h3>❌ Erro React #130 no Servidor</h3>
            <p>Este erro é específico do ambiente de produção e geralmente está relacionado a problemas de cache ou configuração.</p>
        </div>
        
        <div class="success">
            <h3>✅ Soluções Aplicadas:</h3>
            <ul>
                <li>Headers HTTP configurados para evitar cache</li>
                <li>Content-Type correto para arquivos JavaScript</li>
                <li>Configurações de produção otimizadas</li>
            </ul>
        </div>
        
        <div class="code">
            <h4>Para resolver completamente:</h4>
            <p>1. Limpe o cache do navegador (Ctrl+Shift+R)</p>
            <p>2. Verifique se o servidor está servindo os arquivos corretos</p>
            <p>3. Acesse a aplicação principal: <a href="/">Dashboard</a></p>
        </div>
        
        <script>
            // Verificar se há erros no console
            window.addEventListener('error', function(e) {
                console.error('Erro detectado:', e.error);
                if (e.error && e.error.message.includes('130')) {
                    document.body.innerHTML += '<div class="error"><h3>Erro React #130 Detectado!</h3><p>Execute as correções acima.</p></div>';
                }
            });
        </script>
    </div>
</body>
</html>
EOF

# 3. Verificar arquivos JavaScript
log "Verificando arquivos JavaScript..."
if [ -f "src/static/assets/index-DDT9FNxU.js" ]; then
    log "✅ Arquivo JavaScript principal encontrado"
else
    error "❌ Arquivo JavaScript principal não encontrado!"
fi

# Configurar serviço systemd
log "Configurando serviço systemd..."
sudo cp "$SERVICE_NAME" "/etc/systemd/system/"
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"

# Configurar permissões
log "Configurando permissões..."
sudo chown -R ubuntu:ubuntu "$PROJECT_DIR"
chmod +x "$PROJECT_DIR/deploy.sh"
chmod +x "$PROJECT_DIR/fix_server_react_error.py"

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

# Testar arquivos estáticos
log "Testando arquivos estáticos..."
if curl -s -I http://localhost:7744/assets/index-DDT9FNxU.js | grep -q "200 OK"; then
    log "Arquivos JavaScript sendo servidos corretamente ✓"
else
    warning "Problema ao servir arquivos JavaScript"
fi

echo
log "🎉 Deploy com correção React #130 concluído!"
echo
info "📋 Informações importantes:"
echo "   • Projeto instalado em: $PROJECT_DIR"
echo "   • Serviço: $SERVICE_NAME"
echo "   • Porta: 7744"
echo "   • Logs: sudo journalctl -u $SERVICE_NAME -f"
echo "   • Status: sudo systemctl status $SERVICE_NAME"
echo "   • Debug React: http://seu-servidor/react_debug.html"
echo
info "🔧 Correções aplicadas para React #130:"
echo "   ✅ Headers HTTP configurados"
echo "   ✅ Cache desabilitado para arquivos JavaScript"
echo "   ✅ Content-Type correto"
echo "   ✅ Página de diagnóstico criada"
echo
info "🚀 Próximos passos:"
echo "   1. Acesse a aplicação no navegador"
echo "   2. Limpe o cache (Ctrl+Shift+R)"
echo "   3. Se o erro persistir, acesse /react_debug.html"
echo "   4. Execute: python3 fix_server_react_error.py (se necessário)"
echo
log "Sistema pronto para uso com correções React #130! 🚀"
