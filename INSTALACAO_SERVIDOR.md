# 🖥️ Guia de Instalação no Servidor

Este guia te ajudará a instalar o Sistema de Gestão de Projetos no seu servidor de forma completa e segura.

## 📋 Pré-requisitos

- Servidor Ubuntu 18.04+ ou CentOS 7+
- Acesso root ou sudo
- Conexão com internet
- Domínio configurado (opcional)

## 🚀 Instalação Passo a Passo

### 1. Preparar o Servidor

```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependências básicas
sudo apt install -y python3 python3-pip python3-venv git curl wget unzip

# Instalar Nginx (opcional, para proxy reverso)
sudo apt install -y nginx

# Instalar PostgreSQL (opcional, para produção)
sudo apt install -y postgresql postgresql-contrib
```

### 2. Clonar o Repositório

```bash
# Criar diretório para aplicações
sudo mkdir -p /opt/apps
cd /opt/apps

# Clonar repositório
sudo git clone https://github.com/SEU_USUARIO/gestao-projetos-schulz.git
cd gestao-projetos-schulz

# Configurar permissões
sudo chown -R $USER:$USER /opt/apps/gestao-projetos-schulz
```

### 3. Instalação Automática (Recomendada)

```bash
# Tornar script executável
chmod +x deploy_with_react_fix.sh

# Executar instalação automática
./deploy_with_react_fix.sh
```

### 4. Instalação Manual

Se preferir instalação manual:

```bash
# Criar ambiente virtual
python3 -m venv venv
source venv/bin/activate

# Instalar dependências
pip install -r requirements.txt

# Configurar banco de dados
mkdir -p src/database
python -c "
from src.main import app, db
with app.app_context():
    db.create_all()
    print('Banco de dados inicializado!')
"

# Configurar serviço systemd
sudo cp gestao-projetos.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable gestao-projetos
sudo systemctl start gestao-projetos
```

## 🔧 Configuração do Servidor

### 1. Configurar Firewall

```bash
# Ubuntu/Debian
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw allow 53000 # Aplicação (se não usar proxy)
sudo ufw enable

# CentOS/RHEL
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=53000/tcp
sudo firewall-cmd --reload
```

### 2. Configurar Nginx (Proxy Reverso)

```bash
# Criar configuração do site
sudo nano /etc/nginx/sites-available/gestao-projetos
```

Adicione o seguinte conteúdo:

```nginx
server {
    listen 80;
    server_name seu-dominio.com www.seu-dominio.com;

    # Redirecionar HTTP para HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name seu-dominio.com www.seu-dominio.com;

    # Configurações SSL (substitua pelos seus certificados)
    ssl_certificate /etc/ssl/certs/gestao-projetos.crt;
    ssl_certificate_key /etc/ssl/private/gestao-projetos.key;
    
    # Configurações SSL modernas
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # Headers de segurança
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # Proxy para aplicação Flask
    location / {
        proxy_pass http://localhost:53000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Headers para resolver problemas de cache React
        proxy_set_header Cache-Control "no-cache, no-store, must-revalidate";
        proxy_set_header Pragma "no-cache";
        proxy_set_header Expires "0";
    }

    # Configurações específicas para arquivos estáticos
    location /assets/ {
        proxy_pass http://localhost:53000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Headers para arquivos JavaScript
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        add_header Expires "0";
        add_header Content-Type "application/javascript; charset=utf-8";
    }
}
```

Ativar o site:

```bash
# Criar link simbólico
sudo ln -s /etc/nginx/sites-available/gestao-projetos /etc/nginx/sites-enabled/

# Testar configuração
sudo nginx -t

# Reiniciar Nginx
sudo systemctl restart nginx
```

### 3. Configurar SSL com Let's Encrypt

```bash
# Instalar Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obter certificado SSL
sudo certbot --nginx -d seu-dominio.com -d www.seu-dominio.com

# Configurar renovação automática
sudo crontab -e
# Adicionar linha:
# 0 12 * * * /usr/bin/certbot renew --quiet
```

## 🔍 Verificação da Instalação

### 1. Verificar Status dos Serviços

```bash
# Verificar aplicação Flask
sudo systemctl status gestao-projetos

# Verificar Nginx
sudo systemctl status nginx

# Verificar logs
sudo journalctl -u gestao-projetos -f
```

### 2. Testar Aplicação

```bash
# Testar localmente
curl http://localhost:53000

# Testar via domínio
curl https://seu-dominio.com

# Testar arquivos JavaScript
curl -I https://seu-dominio.com/assets/index-DDT9FNxU.js
```

### 3. Verificar Headers HTTP

```bash
# Verificar se headers de cache estão corretos
curl -I https://seu-dominio.com/assets/index-DDT9FNxU.js | grep -i cache
```

## 🛠️ Manutenção

### Comandos Úteis

```bash
# Reiniciar aplicação
sudo systemctl restart gestao-projetos

# Ver logs em tempo real
sudo journalctl -u gestao-projetos -f

# Atualizar aplicação
cd /opt/apps/gestao-projetos-schulz
git pull origin main
sudo systemctl restart gestao-projetos

# Backup do banco de dados
cp src/database/app.db backup-$(date +%Y%m%d).db
```

### Monitoramento

```bash
# Verificar uso de recursos
htop
df -h
free -h

# Verificar portas em uso
sudo netstat -tlnp | grep :53000
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443
```

## 🐛 Solução de Problemas

### Erro React #130

```bash
# Executar correção automática
cd /opt/apps/gestao-projetos-schulz
python3 fix_server_react_error.py

# Reiniciar serviços
sudo systemctl restart gestao-projetos
sudo systemctl reload nginx
```

### Problemas de Permissão

```bash
# Corrigir permissões
sudo chown -R ubuntu:ubuntu /opt/apps/gestao-projetos-schulz
sudo chmod -R 755 /opt/apps/gestao-projetos-schulz
```

### Problemas de Porta

```bash
# Verificar se porta está em uso
sudo lsof -i :53000

# Matar processo se necessário
sudo kill -9 PID_DO_PROCESSO
```

## 📊 Configuração de Produção

### 1. Otimizar Python

```bash
# Instalar dependências de produção
pip install gunicorn

# Configurar Gunicorn
sudo nano /etc/systemd/system/gestao-projetos.service
```

Conteúdo do serviço otimizado:

```ini
[Unit]
Description=Gestão de Projetos Schulz Tech
After=network.target

[Service]
Type=exec
User=ubuntu
Group=ubuntu
WorkingDirectory=/opt/apps/gestao-projetos-schulz
Environment=PATH=/opt/apps/gestao-projetos-schulz/venv/bin
ExecStart=/opt/apps/gestao-projetos-schulz/venv/bin/gunicorn --workers 3 --bind 0.0.0.0:53000 src.main:app
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### 2. Configurar Logs

```bash
# Criar diretório de logs
sudo mkdir -p /var/log/gestao-projetos
sudo chown ubuntu:ubuntu /var/log/gestao-projetos

# Configurar rotação de logs
sudo nano /etc/logrotate.d/gestao-projetos
```

Conteúdo:

```
/var/log/gestao-projetos/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 ubuntu ubuntu
    postrotate
        systemctl reload gestao-projetos
    endscript
}
```

## ✅ Checklist de Instalação

- [ ] Servidor atualizado e dependências instaladas
- [ ] Repositório clonado e permissões configuradas
- [ ] Aplicação instalada e funcionando
- [ ] Serviço systemd configurado e ativo
- [ ] Firewall configurado
- [ ] Nginx configurado (se usando proxy)
- [ ] SSL configurado (se usando HTTPS)
- [ ] Aplicação acessível via navegador
- [ ] Headers HTTP corretos
- [ ] Logs funcionando
- [ ] Backup configurado

## 🎯 Próximos Passos

1. **Acesse a aplicação**: https://seu-dominio.com
2. **Configure usuários**: Se necessário
3. **Popule dados iniciais**: Adicione projetos de exemplo
4. **Configure monitoramento**: Para produção
5. **Configure backups**: Automáticos

---

**🎉 Instalação concluída com sucesso!**

Para suporte adicional, consulte a documentação completa ou abra uma issue no GitHub.
