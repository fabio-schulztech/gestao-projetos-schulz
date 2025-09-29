# 🚀 Guia Completo - Instalação e Atualização no Servidor

## 📋 Pré-requisitos
- Ubuntu 20.04+ ou similar
- Python 3.8+
- Git
- Acesso sudo

## 🔧 Instalação Inicial

### 1. Baixar e Configurar Projeto
```bash
# Baixar projeto
wget --no-check-certificate https://github.com/fabio-schulztech/gestao-projetos-schulz/archive/refs/heads/main.zip
unzip main.zip
mv gestao-projetos-schulz-main gestao-projetos-schulz
cd gestao-projetos-schulz

# Configurar Git
chmod +x setup_git_server.sh
./setup_git_server.sh
```

### 2. Instalar Dependências
```bash
# Criar ambiente virtual
python3 -m venv venv
source venv/bin/activate

# Instalar dependências
pip install -r requirements.txt
```

### 3. Configurar Banco de Dados
```bash
# Criar diretório do banco
mkdir -p src/database

# Inicializar banco
python init_db.py

# Popular com dados de exemplo
python populate_database.py
```

### 4. Configurar Serviço Systemd
```bash
# Copiar arquivo de serviço
sudo cp gestao-projetos.service /etc/systemd/system/

# Recarregar systemd
sudo systemctl daemon-reload

# Habilitar e iniciar serviço
sudo systemctl enable gestao-projetos
sudo systemctl start gestao-projetos

# Verificar status
sudo systemctl status gestao-projetos
```

## 🔄 Atualizações Futuras

### Método 1: Script Automático (Recomendado)
```bash
# Executar script de atualização
chmod +x update_server.sh
./update_server.sh
```

### Método 2: Manual
```bash
# Parar serviço
sudo systemctl stop gestao-projetos

# Fazer backup do banco
cp src/database/app.db src/database/app.db.backup.$(date +%Y%m%d_%H%M%S)

# Atualizar código
git pull origin main

# Instalar novas dependências
source venv/bin/activate
pip install -r requirements.txt

# Reiniciar serviço
sudo systemctl start gestao-projetos
```

## 🛠️ Comandos Úteis

### Verificar Status
```bash
# Status do serviço
sudo systemctl status gestao-projetos

# Logs do serviço
sudo journalctl -u gestao-projetos -f

# Verificar porta
netstat -tlnp | grep 53000
```

### Gerenciar Serviço
```bash
# Parar
sudo systemctl stop gestao-projetos

# Iniciar
sudo systemctl start gestao-projetos

# Reiniciar
sudo systemctl restart gestao-projetos

# Desabilitar
sudo systemctl disable gestao-projetos
```

### Backup e Restauração
```bash
# Backup do banco
cp src/database/app.db backup_$(date +%Y%m%d_%H%M%S).db

# Restaurar banco
cp backup_YYYYMMDD_HHMMSS.db src/database/app.db
sudo systemctl restart gestao-projetos
```

## 🌐 Acesso à Aplicação

- **URL**: `http://SEU_IP:53000`
- **API**: `http://SEU_IP:53000/api/projects`

## 🔧 Solução de Problemas

### Erro de SSL
```bash
# Desabilitar verificação SSL
git config --global http.sslVerify false
```

### Erro de Permissões
```bash
# Corrigir permissões
sudo chown -R $USER:$USER /opt/gestao-projetos
```

### Erro de Banco de Dados
```bash
# Recriar banco
rm src/database/app.db
python init_db.py
python populate_database.py
```

### Porta em Uso
```bash
# Verificar processo na porta
sudo lsof -i :53000

# Matar processo
sudo kill -9 PID
```

## 📱 Funcionalidades Implementadas

### ✅ Frontend Completo
- **Tema escuro** consistente com Schulz Tech
- **Progress bars** animadas para cada projeto
- **KPIs atualizados** com métricas relevantes
- **Interface responsiva** para mobile e desktop

### ✅ CRUD Completo
- **Criar** novos projetos
- **Editar** projetos existentes
- **Excluir** projetos
- **Visualizar** todos os projetos

### ✅ Categorias
- **Sensores e Monitoramento** ⚙️
- **Rastreabilidade e Operações** 📡
- **Inovação e Projetos Especiais** 🚀

### ✅ Métricas
- Total de projetos
- Projetos finalizados
- ROI médio
- Orçamento total
- Projetos em andamento
- Projetos de alta prioridade

## 🎯 Próximos Passos

1. **Testar** todas as funcionalidades
2. **Configurar** backup automático
3. **Monitorar** logs do sistema
4. **Atualizar** regularmente via GitHub

---

**Desenvolvido por Schulz Tech** 🚀
