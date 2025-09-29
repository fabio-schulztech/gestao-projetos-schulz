# 🔧 Solução para Erro de Certificado SSL no Servidor

## ❌ Problema Identificado

```
fatal: unable to access 'https://github.com/fabio-schulztech/gestao-projetos-schulz.git/': 
server certificate verification failed. CAfile: none CRLfile: none
```

Este erro ocorre quando o servidor não consegue verificar o certificado SSL do GitHub.

## ✅ Soluções (Escolha uma)

### Solução 1: Desabilitar Verificação SSL (Rápida)

```bash
# Configurar Git para não verificar SSL (temporário)
git config --global http.sslVerify false

# Fazer o clone
git clone https://github.com/fabio-schulztech/gestao-projetos-schulz.git

# Reabilitar verificação SSL (recomendado após o clone)
git config --global http.sslVerify true
```

### Solução 2: Instalar Certificados CA (Recomendada)

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y ca-certificates

# CentOS/RHEL
sudo yum install -y ca-certificates

# Fazer o clone
git clone https://github.com/fabio-schulztech/gestao-projetos-schulz.git
```

### Solução 3: Usar SSH (Mais Segura)

```bash
# 1. Gerar chave SSH (se não tiver)
ssh-keygen -t rsa -b 4096 -C "seu@email.com"

# 2. Adicionar chave ao GitHub
cat ~/.ssh/id_rsa.pub
# Copie o conteúdo e adicione em: https://github.com/settings/keys

# 3. Testar conexão SSH
ssh -T git@github.com

# 4. Clonar via SSH
git clone git@github.com:fabio-schulztech/gestao-projetos-schulz.git
```

### Solução 4: Download Direto (Alternativa)

```bash
# Baixar arquivo ZIP
wget https://github.com/fabio-schulztech/gestao-projetos-schulz/archive/main.zip

# Extrair
unzip main.zip
mv gestao-projetos-schulz-main gestao-projetos-schulz
cd gestao-projetos-schulz
```

## 🚀 Instalação Após Clone

Depois de resolver o problema de SSL, execute:

```bash
# 1. Navegar para o diretório
cd gestao-projetos-schulz

# 2. Executar instalação automática
chmod +x deploy_with_react_fix.sh
./deploy_with_react_fix.sh

# 3. Ou instalação manual
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
mkdir -p src/database
python -c "
from src.main import app, db
with app.app_context():
    db.create_all()
    print('Banco de dados inicializado!')
"
```

## 🔍 Verificação

```bash
# Verificar se o clone funcionou
ls -la gestao-projetos-schulz/

# Verificar se a aplicação funciona
cd gestao-projetos-schulz
source venv/bin/activate
python src/main.py
```

## 📞 Se Ainda Não Funcionar

Execute estes comandos de diagnóstico:

```bash
# Verificar certificados
openssl version
curl -I https://github.com

# Verificar configuração Git
git config --list | grep ssl

# Testar conectividade
ping github.com
telnet github.com 443
```
