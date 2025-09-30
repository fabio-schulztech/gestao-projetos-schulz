# 🔒 Cloudflare Tunnel - HTTPS Válido sem Firewall

## ✨ **O QUE VOCÊ VAI TER:**

- ✅ **https://iot.schulztech.com.br/gestao_de_projetos** funcionando
- ✅ **SSL/TLS válido** (certificado Cloudflare - sem aviso no navegador!)
- ✅ **Não precisa abrir portas** no firewall
- ✅ **Gratuito** para sempre
- ✅ **CDN global** (mais rápido)
- ✅ **Proteção DDoS** automática

---

## 📋 **PRÉ-REQUISITOS:**

1. Domínio `schulztech.com.br` gerenciado pela Cloudflare
2. Acesso SSH ao servidor
3. 10 minutos de tempo

---

## 🚀 **PASSO 1: Configurar Cloudflare (No navegador)**

### **1.1 - Login na Cloudflare:**
- Acesse: https://dash.cloudflare.com
- Faça login com sua conta

### **1.2 - Selecionar Domínio:**
- Clique no domínio `schulztech.com.br`

### **1.3 - Criar Túnel:**
1. No menu lateral: **Zero Trust** → **Access** → **Tunnels**
2. Clique em **"Create a tunnel"**
3. Nome do túnel: `schulz-gestao-projetos`
4. Clique em **"Save tunnel"**

### **1.4 - Copiar Token:**
- Você verá um comando como:
```bash
cloudflared service install <TOKEN_LONGO_AQUI>
```
- **COPIE ESSE TOKEN!** Você vai precisar dele.

### **1.5 - Configurar Rota:**
1. Em **Public Hostnames**, clique em **"Add a public hostname"**
2. Preencha:
   ```
   Subdomain: (vazio ou "iot" se quiser usar subdomínio)
   Domain: schulztech.com.br (ou iot.schulztech.com.br)
   Path: /gestao_de_projetos
   Type: HTTP
   URL: localhost:53100
   ```
3. Clique em **"Save hostname"**

**NÃO FECHE A PÁGINA AINDA!**

---

## 🖥️ **PASSO 2: Instalar no Servidor**

Execute no **servidor**:

```bash
# 1. Baixar Cloudflared
cd ~
curl -L --output cloudflared-linux-amd64.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb

# 2. Instalar
sudo dpkg -i cloudflared-linux-amd64.deb

# 3. Verificar instalação
cloudflared --version
```

---

## ⚙️ **PASSO 3: Configurar Túnel**

```bash
# 1. Criar diretório de configuração
sudo mkdir -p /etc/cloudflared

# 2. Criar arquivo de configuração
sudo nano /etc/cloudflared/config.yml
```

**Cole este conteúdo** (substitua `SEU_TOKEN_AQUI` pelo token que você copiou):

```yaml
tunnel: SEU_TOKEN_AQUI
credentials-file: /etc/cloudflared/credentials.json

ingress:
  # Rota para Gestão de Projetos
  - hostname: iot.schulztech.com.br
    path: /gestao_de_projetos/*
    service: http://localhost:53100
  
  # Rota para root (opcional)
  - hostname: iot.schulztech.com.br
    service: http://localhost:53100
  
  # Catch-all rule (obrigatório)
  - service: http_status:404
```

Salve: `Ctrl+O`, `Enter`, `Ctrl+X`

---

## 🔐 **PASSO 4: Autenticar**

**Volte para o dashboard da Cloudflare** e copie o comando completo que aparece.

Será algo como:

```bash
sudo cloudflared service install eyJhIjoiZXhhbXBsZS10b2tlbi1oZXJlIn0=
```

**Execute esse comando no servidor.**

Alternativamente, use o método manual:

```bash
# Login interativo
cloudflared tunnel login

# Isso abrirá um link no navegador
# Autorize o acesso
```

---

## 🚀 **PASSO 5: Criar Serviço Systemd**

```bash
# 1. Criar serviço
sudo tee /etc/systemd/system/cloudflared.service > /dev/null << 'EOF'
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/cloudflared tunnel --config /etc/cloudflared/config.yml run
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 2. Recarregar systemd
sudo systemctl daemon-reload

# 3. Habilitar e iniciar
sudo systemctl enable cloudflared
sudo systemctl start cloudflared

# 4. Verificar status
sudo systemctl status cloudflared
```

---

## ✅ **PASSO 6: Testar**

```bash
# Ver logs
sudo journalctl -u cloudflared -f

# Deve mostrar algo como:
# "Connection established" ou "Registered tunnel connection"
```

**No navegador:**
- Acesse: **https://iot.schulztech.com.br/gestao_de_projetos**
- ✅ Deve carregar com cadeado verde! 🔒

---

## 🔧 **CONFIGURAÇÃO AVANÇADA (Opcional)**

### **Múltiplos Projetos:**

Se quiser adicionar mais aplicações:

```yaml
tunnel: SEU_TOKEN_AQUI
credentials-file: /etc/cloudflared/credentials.json

ingress:
  # Gestão de Projetos
  - hostname: iot.schulztech.com.br
    path: /gestao_de_projetos/*
    service: http://localhost:53100
  
  # Outro Projeto (exemplo)
  - hostname: iot.schulztech.com.br
    path: /tpms/*
    service: http://localhost:53005
  
  # Catch-all
  - service: http_status:404
```

---

## 🐛 **TROUBLESHOOTING**

### **Erro: "Connection refused"**

```bash
# Verificar se aplicação está rodando
sudo systemctl status gestao-projetos-novo
curl http://localhost:53100
```

### **Erro: "Tunnel not found"**

```bash
# Reautenticar
cloudflared tunnel login

# Listar túneis
cloudflared tunnel list

# Deletar túnel antigo (se necessário)
cloudflared tunnel delete schulz-gestao-projetos

# Criar novo
cloudflared tunnel create schulz-gestao-projetos
```

### **Logs do Cloudflared:**

```bash
# Logs em tempo real
sudo journalctl -u cloudflared -f

# Últimas 50 linhas
sudo journalctl -u cloudflared -n 50
```

### **Reiniciar Túnel:**

```bash
sudo systemctl restart cloudflared
sudo systemctl status cloudflared
```

---

## 🎯 **CONFIGURAÇÃO ALTERNATIVA: Com Cloudflare Zero Trust**

Se você quiser adicionar **autenticação** (login antes de acessar):

### **No Dashboard Cloudflare:**

1. **Zero Trust** → **Access** → **Applications**
2. **Add an application** → **Self-hosted**
3. Configurar:
   ```
   Application name: Gestão de Projetos
   Subdomain: iot
   Domain: schulztech.com.br
   Path: /gestao_de_projetos
   ```
4. Adicionar política de acesso (emails permitidos, domínio, etc.)

---

## 📊 **COMPARAÇÃO**

### **Antes (Tentativa SSL):**
```
❌ http://iot.schulztech.com.br:53100
⚠️ Porta não padrão
❌ Sem SSL
```

### **Depois (Cloudflare Tunnel):**
```
✅ https://iot.schulztech.com.br/gestao_de_projetos
✅ Porta 443 padrão
✅ SSL válido (cadeado verde)
✅ CDN global
✅ Proteção DDoS
✅ Sem configuração de firewall
```

---

## 🔄 **COMANDOS ÚTEIS**

```bash
# Status do túnel
sudo systemctl status cloudflared

# Ver logs
sudo journalctl -u cloudflared -f

# Reiniciar
sudo systemctl restart cloudflared

# Parar
sudo systemctl stop cloudflared

# Ver configuração
cat /etc/cloudflared/config.yml

# Listar túneis
cloudflared tunnel list

# Informações do túnel
cloudflared tunnel info schulz-gestao-projetos
```

---

## 💰 **CUSTO**

- ✅ **100% GRATUITO** para uso ilimitado
- Cloudflare oferece túneis gratuitamente
- Sem limite de banda
- Sem limite de requisições

---

## 🔐 **SEGURANÇA**

- ✅ Conexão criptografada ponto a ponto
- ✅ Não expõe IP do servidor
- ✅ Proteção DDoS automática
- ✅ Certificado SSL gerenciado automaticamente
- ✅ WAF (Web Application Firewall) disponível

---

## 🎉 **RESULTADO FINAL**

Após configurar:

1. **https://iot.schulztech.com.br/gestao_de_projetos** ← Funciona!
2. ✅ Cadeado verde no navegador
3. ✅ Certificado SSL válido da Cloudflare
4. ✅ Sem avisos de segurança
5. ✅ Acesso global via CDN
6. ✅ Proteção contra ataques

---

## 📞 **SUPORTE**

- Documentação: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/
- Community: https://community.cloudflare.com/

---

**Tempo total de configuração: ~10 minutos** ⏱️

**Última atualização:** 2025-09-30
