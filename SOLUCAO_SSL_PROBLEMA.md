# 🔧 Solução para Problema SSL do Certbot

## 🚨 **PROBLEMA IDENTIFICADO:**

```
SSLError: HTTPSConnectionPool(host='acme-v02.api.letsencrypt.org', port=443): 
Max retries exceeded with url: /directory 
(Caused by SSLError(SSLCertVerificationError(1, 
'[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: 
unable to get local issuer certificate')))
```

### **Causa Raiz:**
O servidor não consegue validar o certificado do Let's Encrypt devido a um **firewall Fortinet** interceptando conexões HTTPS corporativas.

**Evidência:**
```
CN=FG4H0FT922903971,OU=Certificate Authority,O=Fortinet
```

Este é um certificado do firewall Fortinet fazendo inspeção SSL (SSL Deep Inspection).

---

## ✅ **SOLUÇÕES DISPONÍVEIS:**

### **SOLUÇÃO 1: Correção Automática (Recomendada)** ⚡

Execute o script de correção no servidor:

```bash
# No seu Mac, fazer upload do script
cd /Users/fabioobaid/Downloads/backup
scp fix_ssl_certbot.sh fabio@iot.schulztech.com.br:~/gestao-projetos-schulz/

# No servidor
cd ~/gestao-projetos-schulz
chmod +x fix_ssl_certbot.sh
sudo ./fix_ssl_certbot.sh
```

**O que o script faz:**
1. ✅ Atualiza certificados CA do sistema
2. ✅ Reinstala Certbot
3. ✅ Testa conectividade com Let's Encrypt
4. ✅ Tenta obter certificado válido
5. ✅ Se falhar, cria certificado autoassinado como fallback

---

### **SOLUÇÃO 2: Certificado Autoassinado (Rápida)** 🔐

Se o Let's Encrypt continuar bloqueado, use certificado autoassinado:

```bash
# 1. Criar diretório para certificado
sudo mkdir -p /etc/nginx/ssl

# 2. Gerar certificado (válido por 1 ano)
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/iot.schulztech.com.br.key \
    -out /etc/nginx/ssl/iot.schulztech.com.br.crt \
    -subj "/C=BR/ST=SC/L=Joinville/O=Schulz Tech/CN=iot.schulztech.com.br"

# 3. Configurar Nginx
sudo nano /etc/nginx/sites-available/gestao-projetos
```

Cole esta configuração:

```nginx
# HTTP - Redirecionar para HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name iot.schulztech.com.br;
    
    return 301 https://$server_name$request_uri;
}

# HTTPS - Certificado autoassinado
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name iot.schulztech.com.br;

    # Certificado
    ssl_certificate /etc/nginx/ssl/iot.schulztech.com.br.crt;
    ssl_certificate_key /etc/nginx/ssl/iot.schulztech.com.br.key;

    # Configurações SSL
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';

    # Logs
    access_log /var/log/nginx/gestao-projetos-access.log;
    error_log /var/log/nginx/gestao-projetos-error.log;

    # Proxy
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

```bash
# 4. Testar e reiniciar
sudo nginx -t
sudo systemctl restart nginx
```

**✅ Pronto!** Acesse: https://iot.schulztech.com.br

⚠️ **Aviso:** O navegador mostrará um aviso de segurança. Clique em **"Avançado"** → **"Continuar para o site"**.

---

### **SOLUÇÃO 3: Desabilitar Inspeção SSL do Fortinet** 🏢

**Para TI/Administrador de Rede:**

O firewall Fortinet está fazendo inspeção SSL (Deep Inspection) que quebra a verificação de certificados do Certbot.

**Opções:**

1. **Adicionar exceção para Let's Encrypt:**
   ```
   Destino: acme-v02.api.letsencrypt.org
   Porta: 443
   Ação: Bypass SSL Inspection
   ```

2. **Adicionar exceção para o servidor:**
   ```
   IP Origem: 201.16.255.146 e 187.103.113.84
   Destino: acme-v02.api.letsencrypt.org
   Porta: 443
   Ação: Bypass SSL Inspection
   ```

3. **Whitelist de domínios:**
   ```
   - letsencrypt.org
   - acme-v02.api.letsencrypt.org
   ```

**Documentação Fortinet:**
- https://docs.fortinet.com/document/fortigate/7.0.0/administration-guide/954635/deep-inspection

---

### **SOLUÇÃO 4: Certificado Comercial** 💰

Se Let's Encrypt continuar bloqueado, considere comprar um certificado SSL:

**Opções:**
- **DigiCert** (~R$ 300/ano)
- **Sectigo/Comodo** (~R$ 200/ano)
- **GoDaddy** (~R$ 150/ano)

**Instalação:**
```bash
# 1. Copiar certificados para o servidor
sudo mkdir -p /etc/nginx/ssl
sudo cp seu-certificado.crt /etc/nginx/ssl/
sudo cp sua-chave.key /etc/nginx/ssl/

# 2. Usar mesma configuração da Solução 2
# Alterar apenas os caminhos dos certificados
```

---

## 🔍 **DIAGNÓSTICO:**

### **Verificar se problema é o Fortinet:**

```bash
# Testar conexão SSL
curl -v https://acme-v02.api.letsencrypt.org/directory 2>&1 | grep -i "certificate"

# Se retornar "Fortinet" no certificado, o firewall está interceptando
```

### **Verificar logs do Certbot:**

```bash
sudo tail -50 /var/log/letsencrypt/letsencrypt.log
```

### **Testar Nginx:**

```bash
# Status
sudo systemctl status nginx

# Testar configuração
sudo nginx -t

# Ver logs
sudo tail -f /var/log/nginx/error.log
```

---

## 📊 **COMPARAÇÃO DAS SOLUÇÕES:**

| Solução | Tempo | Custo | Aviso Navegador | Renovação | Dificuldade |
|---------|-------|-------|-----------------|-----------|-------------|
| **Let's Encrypt** | 5 min | Grátis | ❌ Não | Automática | ⚠️ Bloqueado |
| **Autoassinado** | 5 min | Grátis | ⚠️ Sim | Manual/1 ano | ✅ Fácil |
| **Desabilitar Fortinet** | Depende TI | Grátis | ❌ Não | Automática | 🔧 Requer TI |
| **Certificado Comercial** | 1 dia | R$ 150-300/ano | ❌ Não | Anual | 💰 Médio |

---

## ✅ **RECOMENDAÇÃO:**

### **Para uso interno (Schulz Tech):**
→ **SOLUÇÃO 2: Certificado Autoassinado** ✅
- Rápido
- Grátis
- Funciona imediatamente
- Usuários internos podem adicionar exceção

### **Para uso externo (clientes):**
→ **SOLUÇÃO 3: Desabilitar Fortinet** + **Let's Encrypt** ✅
- Certificado válido
- Sem aviso no navegador
- Renovação automática

---

## 🚀 **PRÓXIMOS PASSOS:**

### **AGORA:**

```bash
# No seu Mac
cd /Users/fabioobaid/Downloads/backup
scp fix_ssl_certbot.sh fabio@iot.schulztech.com.br:~/gestao-projetos-schulz/

# No servidor
ssh fabio@iot.schulztech.com.br
cd ~/gestao-projetos-schulz
sudo ./fix_ssl_certbot.sh
```

### **DEPOIS:**

1. ✅ Testar acesso: https://iot.schulztech.com.br
2. ✅ Se aparecer aviso, clicar em "Avançado" → "Continuar"
3. ✅ Salvar exceção no navegador

### **FUTURO (Opcional):**

1. Contatar TI sobre exceção do Fortinet para Let's Encrypt
2. Migrar para certificado válido quando firewall permitir

---

## 📞 **SUPORTE:**

### **Se o script falhar:**

```bash
# Ver logs detalhados
sudo tail -100 /var/log/letsencrypt/letsencrypt.log

# Testar Nginx manualmente
sudo nginx -t
sudo systemctl status nginx

# Verificar aplicação
sudo systemctl status gestao-projetos
curl http://localhost:53000
```

---

## 🎯 **RESULTADO ESPERADO:**

### **Com Certificado Autoassinado:**

```
✅ https://iot.schulztech.com.br funciona
⚠️ Navegador mostra "Não seguro" (normal)
✅ Conexão criptografada (TLS 1.3)
✅ Dados protegidos
```

### **Com Let's Encrypt (se firewall permitir):**

```
✅ https://iot.schulztech.com.br funciona
✅ Cadeado verde no navegador 🔒
✅ Certificado válido por 90 dias
✅ Renovação automática
```

---

**Última atualização:** 2025-09-30
