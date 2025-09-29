# 🚀 Sistema de Gestão de Projetos - Schulz Tech

Sistema completo de gestão e acompanhamento de projetos tecnológicos com dashboard interativo, métricas de ROI, e interface moderna.

## ✨ Funcionalidades

- 📊 **Dashboard Interativo** - Visão geral de todos os projetos
- 🎯 **Gestão de Projetos** - Criação, edição e acompanhamento
- 📈 **Métricas Avançadas** - ROI, esforço, orçamento e prioridades
- 🔍 **Filtros Inteligentes** - Por categoria, status, ROI, etc.
- 📱 **Interface Responsiva** - Funciona em desktop e mobile
- 🎨 **Design Moderno** - Interface intuitiva e profissional

## 🏗️ Arquitetura

- **Backend**: Flask + SQLAlchemy
- **Frontend**: React + Vite
- **Database**: SQLite (desenvolvimento) / PostgreSQL (produção)
- **Deploy**: Docker + Nginx (opcional)

## 🚀 Instalação Rápida

### Pré-requisitos
- Python 3.8+
- pip
- Git

### 1. Clone o repositório
```bash
git clone https://github.com/SEU_USUARIO/gestao-projetos-schulz.git
cd gestao-projetos-schulz
```

### 2. Instalação Local
```bash
# Criar ambiente virtual
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate     # Windows

# Instalar dependências
pip install -r requirements.txt

# Iniciar aplicação
python src/main.py
```

### 3. Acessar a aplicação
- **URL**: http://localhost:53000
- **Dashboard**: Interface principal de gestão

## 🐳 Instalação com Docker

```bash
# Build da imagem
docker build -t gestao-projetos .

# Executar container
docker run -p 53000:53000 gestao-projetos
```

## 🖥️ Instalação no Servidor

### Ubuntu/Debian

```bash
# 1. Atualizar sistema
sudo apt update && sudo apt upgrade -y

# 2. Instalar dependências
sudo apt install python3 python3-pip python3-venv git nginx -y

# 3. Clone do repositório
git clone https://github.com/SEU_USUARIO/gestao-projetos-schulz.git
cd gestao-projetos-schulz

# 4. Executar script de deploy
chmod +x deploy_with_react_fix.sh
./deploy_with_react_fix.sh
```

### CentOS/RHEL

```bash
# 1. Instalar dependências
sudo yum install python3 python3-pip git nginx -y

# 2. Clone e deploy
git clone https://github.com/SEU_USUARIO/gestao-projetos-schulz.git
cd gestao-projetos-schulz
chmod +x deploy_with_react_fix.sh
./deploy_with_react_fix.sh
```

## 🔧 Configuração

### Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto:

```env
# Configurações do Flask
FLASK_ENV=production
SECRET_KEY=sua_chave_secreta_aqui

# Configurações do Banco
DATABASE_URL=sqlite:///src/database/app.db

# Configurações do Servidor
HOST=0.0.0.0
PORT=53000
```

### Configuração do Nginx

```nginx
server {
    listen 80;
    server_name seu-dominio.com;

    location / {
        proxy_pass http://localhost:53000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 📊 Categorias de Projetos

1. **⚙️ Sensores e Monitoramento**
   - Projetos de sensores IoT
   - Monitoramento de equipamentos
   - Controle de temperatura

2. **📡 Rastreabilidade e Operações**
   - Rastreamento de veículos
   - Gestão de pneus
   - Roteirização

3. **🚀 Inovação e Projetos Especiais**
   - P&D e inovação
   - Projetos experimentais
   - Tecnologias emergentes

## 🛠️ Desenvolvimento

### Estrutura do Projeto

```
gestao-projetos-schulz/
├── src/
│   ├── main.py              # Aplicação Flask principal
│   ├── models/              # Modelos de dados
│   ├── routes/              # Rotas da API
│   └── static/              # Arquivos estáticos (React)
├── requirements.txt         # Dependências Python
├── deploy_with_react_fix.sh # Script de deploy
├── fix_server_react_error.py # Correção de erros React
└── README.md               # Este arquivo
```

### Scripts Disponíveis

- `start_app.sh` - Inicia aplicação local
- `deploy_with_react_fix.sh` - Deploy no servidor
- `fix_server_react_error.py` - Correção de erros React #130
- `check_and_fix.py` - Diagnóstico e correção automática

## 🐛 Solução de Problemas

### Erro React #130

Se encontrar o erro "Minified React error #130":

```bash
# 1. Limpar cache do navegador (Ctrl+Shift+R)
# 2. Executar correção automática
python3 fix_server_react_error.py

# 3. Reiniciar serviço
sudo systemctl restart gestao-projetos
```

### Problemas de Dependências

```bash
# Reinstalar dependências
pip install -r requirements.txt --force-reinstall

# Verificar ambiente virtual
which python
python --version
```

### Logs do Sistema

```bash
# Ver logs da aplicação
sudo journalctl -u gestao-projetos -f

# Ver logs do Nginx
sudo tail -f /var/log/nginx/error.log
```

## 📈 Monitoramento

### Métricas Disponíveis

- **Total de Projetos**: Contagem geral
- **Projetos Finalizados**: Percentual de conclusão
- **ROI Médio**: Retorno sobre investimento
- **Orçamento Total**: Soma de todos os orçamentos

### API Endpoints

- `GET /api/projects` - Listar projetos
- `POST /api/projects` - Criar projeto
- `PUT /api/projects/<id>` - Atualizar projeto
- `DELETE /api/projects/<id>` - Deletar projeto

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 📞 Suporte

- **Email**: suporte@schulztech.com.br
- **Documentação**: [Wiki do Projeto](https://github.com/SEU_USUARIO/gestao-projetos-schulz/wiki)
- **Issues**: [GitHub Issues](https://github.com/SEU_USUARIO/gestao-projetos-schulz/issues)

## 🎯 Roadmap

- [ ] Autenticação de usuários
- [ ] Relatórios em PDF
- [ ] Integração com APIs externas
- [ ] Notificações por email
- [ ] Dashboard em tempo real
- [ ] Mobile app

---

**Desenvolvido com ❤️ pela equipe Schulz Tech**
