# 🔒 PASSOS PARA CONFIGURAR HTTPS - GUIA RÁPIDO

## ⚡ MODO RÁPIDO (Recomendado)

### 1️⃣ **No seu Mac (pasta atual):**

```bash
# Fazer upload dos scripts para o servidor
scp setup_https.sh check_https_requirements.sh fabio@iot.schulztech.com.br:~/
```

### 2️⃣ **Conectar ao servidor:**

```bash
ssh fabio@iot.schulztech.com.br
```

### 3️⃣ **No servidor, executar:**

```bash
# Dar permissão aos scripts
chmod +x setup_https.sh check_https_requirements.sh

# IMPORTANTE: Editar o email no script
nano setup_https.sh
# Procure a linha: EMAIL="admin@schulztech.com.br"
# Altere para seu email real
# Salve: Ctrl+O, Enter, Ctrl+X

# Executar script de configuração
sudo ./setup_https.sh
```

**Pronto!** O script fará tudo automaticamente:
- ✅ Instalar Nginx
- ✅ Instalar Certbot
- ✅ Configurar proxy reverso
- ✅ Obter certificado SSL
- ✅ Configurar renovação automática

---

## 📋 MODO PASSO A PASSO (Manual)

Se preferir fazer manualmente, siga estes comandos **no servidor**:

### 1. Instalar dependências

```bash
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx
```

### 2. Criar configuração do Nginx

```bash
sudo nano /etc/nginx/sites-available/gestao-projetos
```

Cole este conteúdo:

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

### 3. Ativar site

```bash
sudo ln -s /etc/nginx/sites-available/gestao-projetos /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
```

### 4. Configurar firewall

```bash
sudo ufw allow 'Nginx Full'
sudo ufw allow 22
sudo ufw enable
```

### 5. Obter certificado SSL

```bash
# ALTERE O EMAIL!
sudo certbot --nginx -d iot.schulztech.com.br \
    --non-interactive \
    --agree-tos \
    --email SEU_EMAIL@schulztech.com.br \
    --redirect
```

### 6. Configurar renovação automática

```bash
sudo certbot renew --dry-run
```

---

## ✅ VERIFICAÇÃO

Após concluir, teste:

### No navegador:
- Acesse: https://iot.schulztech.com.br
- Deve carregar com o cadeado verde 🔒

### No terminal:
```bash
curl -I https://iot.schulztech.com.br
```

**Esperado:** `HTTP/2 200` ou `HTTP/1.1 200`

---

## 🚨 PROBLEMAS COMUNS

### ❌ "Connection refused"

**Solução:**
```bash
# Verificar se aplicação está rodando
sudo systemctl status gestao-projetos
sudo systemctl start gestao-projetos
```

### ❌ "502 Bad Gateway"

**Solução:**
```bash
# Reiniciar tudo
sudo systemctl restart gestao-projetos
sudo systemctl restart nginx
```

### ❌ "Certbot failed"

**Solução:**
```bash
# Verificar firewall
sudo ufw status
sudo ufw allow 80
sudo ufw allow 443

# Tentar novamente
sudo certbot --nginx -d iot.schulztech.com.br
```

---

## 📞 COMANDOS ÚTEIS

```bash
# Ver status do Nginx
sudo systemctl status nginx

# Ver logs em tempo real
sudo tail -f /var/log/nginx/gestao-projetos-access.log

# Ver certificados instalados
sudo certbot certificates

# Renovar SSL manualmente
sudo certbot renew

# Reiniciar serviços
sudo systemctl restart gestao-projetos
sudo systemctl restart nginx
```

---

## 🎯 RESULTADO FINAL

Depois de configurado:

✅ **Antes:** http://iot.schulztech.com.br:53000  
✅ **Depois:** https://iot.schulztech.com.br (porta 443 padrão)

✅ HTTP → redireciona automaticamente para HTTPS  
✅ Certificado válido por 90 dias  
✅ Renovação automática configurada  
✅ Conexão segura e criptografada  

---

## 📚 DOCUMENTAÇÃO COMPLETA

Para mais detalhes, consulte: `GUIA_HTTPS.md`

---

**Última atualização:** 2025-09-30
