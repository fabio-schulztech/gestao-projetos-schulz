# 🚀 GUIA COMPLETO DE INSTALAÇÃO NO SERVIDOR

## 📋 **PRÉ-REQUISITOS**

- Servidor Ubuntu/Debian com acesso root/sudo
- Python 3.8+ instalado
- Git instalado
- Conexão com internet

## 🔧 **PASSO 1: CONECTAR NO SERVIDOR**

```bash
# Conectar via SSH (substitua pelo seu IP)
ssh usuario@seu-servidor-ip

# Ou se for root
ssh root@seu-servidor-ip
```

## 📦 **PASSO 2: ATUALIZAR SISTEMA**

```bash
# Atualizar pacotes
sudo apt update && sudo apt upgrade -y

# Instalar dependências necessárias
sudo apt install -y python3 python3-pip python3-venv git curl wget
```

## 📥 **PASSO 3: BAIXAR O PROJETO**

```bash
# Clonar repositório
git clone https://github.com/fabio-schulztech/gestao-projetos-schulz.git

# Entrar no diretório
cd gestao-projetos-schulz

# Verificar se os arquivos estão corretos
ls -la
```

## 🐍 **PASSO 4: CONFIGURAR AMBIENTE PYTHON**

```bash
# Criar ambiente virtual
python3 -m venv venv

# Ativar ambiente virtual
source venv/bin/activate

# Instalar dependências
pip install -r requirements.txt
```

## 🗄️ **PASSO 5: CONFIGURAR BANCO DE DADOS**

```bash
# Popular banco com dados de exemplo
python populate_database.py

# Verificar se funcionou
ls -la src/database/
```

## ⚙️ **PASSO 6: CONFIGURAR SERVIÇO SYSTEMD**

```bash
# Criar usuário para a aplicação (se não existir)
sudo useradd -m -s /bin/bash gestao-projetos

# Mover projeto para diretório do sistema
sudo mv /home/$(whoami)/gestao-projetos-schulz /opt/gestao-projetos
sudo chown -R gestao-projetos:gestao-projetos /opt/gestao-projetos

# Criar arquivo de serviço
sudo tee /etc/systemd/system/gestao-projetos.service > /dev/null <<EOF
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

# Recarregar systemd
sudo systemctl daemon-reload

# Habilitar serviço
sudo systemctl enable gestao-projetos

# Iniciar serviço
sudo systemctl start gestao-projetos

# Verificar status
sudo systemctl status gestao-projetos
```

## 🔥 **PASSO 7: CONFIGURAR FIREWALL**

```bash
# Abrir porta 53000
sudo ufw allow 53000

# Verificar status do firewall
sudo ufw status
```

## ✅ **PASSO 8: TESTAR INSTALAÇÃO**

```bash
# Verificar se o serviço está rodando
sudo systemctl status gestao-projetos

# Verificar logs
sudo journalctl -u gestao-projetos -f

# Testar API
curl http://localhost:53000/api/projects
```

## 🌐 **PASSO 9: ACESSAR APLICAÇÃO**

### **Localmente no servidor:**
```bash
curl http://localhost:53000
```

### **Externamente:**
```
http://SEU-IP-SERVIDOR:53000
```

## 🔧 **COMANDOS ÚTEIS**

### **Gerenciar Serviço:**
```bash
# Parar serviço
sudo systemctl stop gestao-projetos

# Iniciar serviço
sudo systemctl start gestao-projetos

# Reiniciar serviço
sudo systemctl restart gestao-projetos

# Ver status
sudo systemctl status gestao-projetos
```

### **Ver Logs:**
```bash
# Logs em tempo real
sudo journalctl -u gestao-projetos -f

# Últimos logs
sudo journalctl -u gestao-projetos -n 50
```

### **Atualizar Projeto:**
```bash
# Parar serviço
sudo systemctl stop gestao-projetos

# Atualizar código
cd /opt/gestao-projetos
sudo -u gestao-projetos git pull origin main

# Instalar novas dependências (se houver)
sudo -u gestao-projetos /opt/gestao-projetos/venv/bin/pip install -r requirements.txt

# Iniciar serviço
sudo systemctl start gestao-projetos
```

## 🚨 **SOLUÇÃO DE PROBLEMAS**

### **Se o serviço não iniciar:**
```bash
# Verificar logs de erro
sudo journalctl -u gestao-projetos -n 20

# Verificar permissões
sudo chown -R gestao-projetos:gestao-projetos /opt/gestao-projetos

# Verificar se a porta está em uso
sudo netstat -tlnp | grep 53000
```

### **Se a API não responder:**
```bash
# Testar localmente
curl http://localhost:53000/api/projects

# Verificar firewall
sudo ufw status

# Verificar se o serviço está rodando
sudo systemctl status gestao-projetos
```

### **Se houver erro de banco de dados:**
```bash
# Recriar banco
cd /opt/gestao-projetos
sudo -u gestao-projetos /opt/gestao-projetos/venv/bin/python populate_database.py --force
```

## 📊 **VERIFICAÇÃO FINAL**

Após a instalação, verifique se:

1. ✅ Serviço está rodando: `sudo systemctl status gestao-projetos`
2. ✅ Porta 53000 está aberta: `sudo ufw status`
3. ✅ API responde: `curl http://localhost:53000/api/projects`
4. ✅ Frontend carrega: `curl http://localhost:53000`
5. ✅ Banco tem dados: `ls -la /opt/gestao-projetos/src/database/`

## 🎉 **SUCESSO!**

Se tudo estiver funcionando, sua aplicação estará disponível em:
**http://SEU-IP-SERVIDOR:53000**

---

**📞 Precisa de ajuda? Verifique os logs com `sudo journalctl -u gestao-projetos -f`**
