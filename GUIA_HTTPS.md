# 🔒 Guia de Implementação HTTPS - Schulz Tech

## 📋 Visão Geral

Este guia explica como configurar HTTPS para a aplicação **Gestão de Projetos Schulz Tech** usando:
- **Let's Encrypt** (Certificado SSL gratuito)
- **Nginx** (Proxy reverso)
- **Certbot** (Gerenciamento automático de certificados)

---

## 🚀 INSTALAÇÃO RÁPIDA

### No seu computador local:

```bash
# 1. Fazer upload do script para o servidor
cd /Users/fabioobaid/Downloads/backup
scp setup_https.sh fabio@iot.schulztech.com.br:~/
```

### No servidor (SSH):

```bash
# 2. Conectar ao servidor
ssh fabio@iot.schulztech.com.br

# 3. Dar permissão de execução
chmod +x setup_https.sh

# 4. IMPORTANTE: Editar o email antes de executar
nano setup_https.sh
# Altere a linha: EMAIL="admin@schulztech.com.br"
# Para seu email real (necessário para avisos do Let's Encrypt)

# 5. Executar o script
sudo ./setup_https.sh
```

---

## 📝 PASSO A PASSO MANUAL

Se preferir fazer manualmente ou se o script falhar:

### 1. Instalar Nginx

```bash
sudo apt update
sudo apt install -y nginx
```

### 2. Instalar Certbot

```bash
sudo apt install -y certbot python3-certbot-nginx
```

### 3. Criar Configuração do Nginx

```bash
sudo nano /etc/nginx/sites-available/gestao-projetos
```

Cole o seguinte conteúdo:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name iot.schulztech.com.br;

    access_log /var/log/nginx/gestao-projetos-access.log;
    error_log /var/log/nginx/gestao-projetos-error.log;

    location / {
        proxy_pass http://127.0.0.1:53000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    client_max_body_size 10M;
}
```

### 4. Ativar Site e Reiniciar Nginx

```bash
# Ativar configuração
sudo ln -s /etc/nginx/sites-available/gestao-projetos /etc/nginx/sites-enabled/

# Remover site padrão
sudo rm /etc/nginx/sites-enabled/default

# Testar configuração
sudo nginx -t

# Reiniciar Nginx
sudo systemctl restart nginx
sudo systemctl enable nginx
```

### 5. Configurar Firewall

```bash
# Permitir tráfego HTTP e HTTPS
sudo ufw allow 'Nginx Full'
sudo ufw allow 22/tcp
sudo ufw enable

# Verificar status
sudo ufw status
```

### 6. Obter Certificado SSL

```bash
# Substituir admin@schulztech.com.br pelo seu email
sudo certbot --nginx -d iot.schulztech.com.br \
    --non-interactive \
    --agree-tos \
    --email admin@schulztech.com.br \
    --redirect
```

### 7. Testar Renovação Automática

```bash
# Teste de renovação (não renova de verdade)
sudo certbot renew --dry-run

# Adicionar renovação automática ao cron
echo "0 0,12 * * * certbot renew --quiet --post-hook 'systemctl reload nginx'" | sudo crontab -
```

---

## ✅ VERIFICAÇÃO

### 1. Verificar se Nginx está rodando

```bash
sudo systemctl status nginx
```

**Esperado:** `active (running)`

### 2. Verificar se a aplicação está respondendo

```bash
curl http://localhost:53000
```

**Esperado:** HTML da aplicação

### 3. Testar HTTPS

```bash
curl -I https://iot.schulztech.com.br
```

**Esperado:** `HTTP/2 200`

### 4. Verificar certificado

```bash
sudo certbot certificates
```

**Esperado:** Certificado válido até ~90 dias no futuro

### 5. Ver logs em tempo real

```bash
# Logs de acesso
sudo tail -f /var/log/nginx/gestao-projetos-access.log

# Logs de erro
sudo tail -f /var/log/nginx/gestao-projetos-error.log
```

---

## 🔧 TROUBLESHOOTING

### ❌ Erro: "Connection refused"

**Causa:** Aplicação Flask não está rodando

**Solução:**
```bash
# Verificar status
sudo systemctl status gestao-projetos

# Se não estiver rodando
sudo systemctl start gestao-projetos

# Ver logs
sudo journalctl -u gestao-projetos -f
```

---

### ❌ Erro: "nginx: [emerg] bind() to 0.0.0.0:80 failed"

**Causa:** Outra aplicação está usando a porta 80

**Solução:**
```bash
# Ver o que está usando a porta 80
sudo lsof -i :80

# Se for outra instância do Nginx
sudo killall nginx
sudo systemctl restart nginx

# Se for Apache
sudo systemctl stop apache2
sudo systemctl disable apache2
```

---

### ❌ Erro: "Certbot failed to authenticate"

**Causa:** DNS não está apontando para o servidor ou firewall bloqueando

**Solução:**
```bash
# 1. Verificar DNS
nslookup iot.schulztech.com.br

# 2. Verificar se consegue acessar pela web
curl http://iot.schulztech.com.br

# 3. Verificar firewall
sudo ufw status

# 4. Se necessário, abrir portas
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

---

### ❌ Erro: "502 Bad Gateway"

**Causa:** Nginx não consegue conectar à aplicação Flask

**Solução:**
```bash
# 1. Verificar se Flask está rodando na porta correta
sudo netstat -tlnp | grep 53000

# 2. Testar conexão local
curl http://localhost:53000

# 3. Verificar logs do Flask
sudo journalctl -u gestao-projetos -n 50

# 4. Reiniciar serviço
sudo systemctl restart gestao-projetos
sudo systemctl restart nginx
```

---

### ❌ Aviso: "Certificate will expire soon"

**Solução:**
```bash
# Renovar manualmente
sudo certbot renew

# Verificar renovação automática
sudo systemctl status certbot.timer
```

---

## 🔄 COMANDOS ÚTEIS

### Nginx

```bash
# Reiniciar
sudo systemctl restart nginx

# Recarregar configuração (sem downtime)
sudo systemctl reload nginx

# Ver status
sudo systemctl status nginx

# Testar configuração
sudo nginx -t

# Ver logs
sudo tail -f /var/log/nginx/gestao-projetos-access.log
sudo tail -f /var/log/nginx/gestao-projetos-error.log
```

### Certbot (SSL)

```bash
# Listar certificados
sudo certbot certificates

# Renovar certificados
sudo certbot renew

# Renovar forçadamente
sudo certbot renew --force-renewal

# Revogar certificado
sudo certbot revoke --cert-path /etc/letsencrypt/live/iot.schulztech.com.br/cert.pem

# Deletar certificado
sudo certbot delete --cert-name iot.schulztech.com.br
```

### Aplicação Flask

```bash
# Status
sudo systemctl status gestao-projetos

# Iniciar
sudo systemctl start gestao-projetos

# Parar
sudo systemctl stop gestao-projetos

# Reiniciar
sudo systemctl restart gestao-projetos

# Ver logs
sudo journalctl -u gestao-projetos -f
```

---

## 🔒 SEGURANÇA ADICIONAL

### 1. Melhorar configuração SSL do Nginx

Adicione ao arquivo `/etc/nginx/sites-available/gestao-projetos`:

```nginx
# SSL Configuration (adicionar dentro do bloco server 443)
ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers on;
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;

# Security headers
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
```

### 2. Limitar taxa de requisições (Rate Limiting)

```nginx
# No topo do arquivo nginx.conf ou sites-available
limit_req_zone $binary_remote_addr zone=mylimit:10m rate=10r/s;

# Dentro do bloco location /
limit_req zone=mylimit burst=20 nodelay;
```

---

## 📊 MONITORAMENTO

### Verificar uso de certificados SSL

```bash
# Ver quando expira
echo | openssl s_client -servername iot.schulztech.com.br -connect iot.schulztech.com.br:443 2>/dev/null | openssl x509 -noout -dates

# Testar SSL completo
openssl s_client -connect iot.schulztech.com.br:443
```

### Teste online de SSL

Após configurar, teste seu SSL em:
- https://www.ssllabs.com/ssltest/analyze.html?d=iot.schulztech.com.br

---

## 📞 SUPORTE

Se encontrar problemas:

1. **Verificar logs:**
   ```bash
   sudo journalctl -xe
   sudo tail -f /var/log/nginx/error.log
   ```

2. **Testar conectividade:**
   ```bash
   curl -v https://iot.schulztech.com.br
   ```

3. **Reiniciar tudo:**
   ```bash
   sudo systemctl restart gestao-projetos
   sudo systemctl restart nginx
   ```

---

## ✅ CHECKLIST FINAL

- [ ] Nginx instalado e rodando
- [ ] Certbot instalado
- [ ] Configuração do Nginx criada
- [ ] Site ativado no Nginx
- [ ] Firewall configurado (portas 80 e 443)
- [ ] Certificado SSL obtido
- [ ] HTTPS funcionando
- [ ] HTTP redirecionando para HTTPS
- [ ] Renovação automática configurada
- [ ] Logs sendo gerados corretamente

---

## 🎉 RESULTADO ESPERADO

Após seguir este guia, você terá:

✅ Acesso via **https://iot.schulztech.com.br**  
✅ Certificado SSL válido e confiável  
✅ Renovação automática a cada 90 dias  
✅ Redirecionamento automático de HTTP para HTTPS  
✅ Logs centralizados no Nginx  
✅ Segurança melhorada  

---

**Última atualização:** 2025-09-30
