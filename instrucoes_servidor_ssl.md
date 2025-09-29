# 🔧 Soluções para Problemas de SSL no Servidor

## ❌ Problema Identificado

O servidor está com problemas de certificado SSL, impedindo downloads seguros do GitHub.

## ✅ Soluções Alternativas

### Solução 1: Download com SSL Desabilitado

```bash
# Baixar script ignorando certificado SSL
wget --no-check-certificate https://raw.githubusercontent.com/fabio-schulztech/gestao-projetos-schulz/main/deploy_auto.sh

# Tornar executável e executar
chmod +x deploy_auto.sh
./deploy_auto.sh
```

### Solução 2: Usar curl com SSL Desabilitado

```bash
# Baixar com curl
curl -k -o deploy_auto.sh https://raw.githubusercontent.com/fabio-schulztech/gestao-projetos-schulz/main/deploy_auto.sh

# Tornar executável e executar
chmod +x deploy_auto.sh
./deploy_auto.sh
```

### Solução 3: Download Manual (Recomendada)

```bash
# 1. Baixar arquivo ZIP do projeto
wget --no-check-certificate https://github.com/fabio-schulztech/gestao-projetos-schulz/archive/main.zip

# 2. Extrair
unzip main.zip
cd gestao-projetos-schulz-main

# 3. Executar deploy
chmod +x deploy_auto.sh
./deploy_auto.sh
```

### Solução 4: Instalação Manual Completa

```bash
# 1. Criar diretório do projeto
sudo mkdir -p /opt/gestao-projetos
sudo chown $USER:$USER /opt/gestao-projetos

# 2. Copiar arquivos do projeto atual
cp -r /tmp/gestao-projetos-schulz/* /opt/gestao-projetos/

# 3. Navegar para o diretório
cd /opt/gestao-projetos

# 4. Criar ambiente virtual
python3 -m venv venv
source venv/bin/activate

# 5. Instalar dependências
pip install -r requirements.txt

# 6. Configurar banco de dados
mkdir -p src/database
python -c "
from src.main import app, db
with app.app_context():
    db.create_all()
    print('Banco de dados inicializado!')
"

# 7. Criar arquivo de serviço systemd
cat > gestao-projetos.service << 'EOF'
[Unit]
Description=Gestão de Projetos Schulz Tech
After=network.target

[Service]
Type=simple
User=fabio
WorkingDirectory=/opt/gestao-projetos
Environment=PATH=/opt/gestao-projetos/venv/bin
ExecStart=/opt/gestao-projetos/venv/bin/python src/main.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 8. Configurar e iniciar serviço
sudo cp gestao-projetos.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable gestao-projetos
sudo systemctl start gestao-projetos

# 9. Verificar status
sudo systemctl status gestao-projetos
```

### Solução 5: Upload via SCP

```bash
# No seu computador local, fazer upload do script
scp deploy_auto.sh fabio@seu-servidor:/tmp/gestao-projetos-schulz/

# No servidor, executar
cd /tmp/gestao-projetos-schulz
chmod +x deploy_auto.sh
./deploy_auto.sh
```

## 🚀 Recomendação

**Use a Solução 4 (Instalação Manual)** - É a mais confiável e não depende de downloads externos.

## 🔍 Verificação Após Instalação

```bash
# Verificar se o serviço está rodando
sudo systemctl status gestao-projetos

# Testar aplicação
curl http://localhost:53000

# Verificar logs
sudo journalctl -u gestao-projetos -f
```

## 🎯 Acesso à Aplicação

Após a instalação, acesse:
- **URL**: http://seu-servidor:53000
- **Dashboard**: Interface principal de gestão de projetos
