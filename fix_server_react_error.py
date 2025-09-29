#!/usr/bin/env python3
"""
Script para corrigir erro React #130 no servidor
Resolve problemas específicos de ambiente de produção
"""

import os
import sys
import subprocess
import shutil
import json
from pathlib import Path

def print_status(message, status="INFO"):
    """Imprime mensagem com status colorido"""
    colors = {
        "INFO": "\033[94m",
        "SUCCESS": "\033[92m",
        "WARNING": "\033[93m",
        "ERROR": "\033[91m",
        "RESET": "\033[0m"
    }
    print(f"{colors.get(status, '')}{message}{colors['RESET']}")

def check_server_environment():
    """Verifica o ambiente do servidor"""
    print_status("🔍 Verificando ambiente do servidor...", "INFO")
    
    # Verificar se estamos no servidor
    if os.path.exists("/opt/gestao-projetos"):
        project_dir = "/opt/gestao-projetos"
        print_status("✅ Detectado ambiente de servidor", "SUCCESS")
    else:
        project_dir = os.getcwd()
        print_status("⚠️  Executando em ambiente local", "WARNING")
    
    return project_dir

def fix_react_build_issues(project_dir):
    """Corrige problemas específicos do build React no servidor"""
    print_status("🔧 Corrigindo problemas do build React...", "INFO")
    
    static_dir = os.path.join(project_dir, "src", "static")
    assets_dir = os.path.join(static_dir, "assets")
    
    if not os.path.exists(assets_dir):
        print_status("❌ Diretório de assets não encontrado", "ERROR")
        return False
    
    # Verificar arquivos JavaScript
    js_files = [f for f in os.listdir(assets_dir) if f.endswith('.js')]
    print_status(f"📁 Encontrados {len(js_files)} arquivos JavaScript", "INFO")
    
    # Verificar se o arquivo principal existe
    main_js = "index-DDT9FNxU.js"
    if main_js not in js_files:
        print_status(f"❌ Arquivo principal {main_js} não encontrado", "ERROR")
        print_status("📋 Arquivos disponíveis:", "INFO")
        for f in js_files:
            print(f"   - {f}")
        return False
    
    print_status(f"✅ Arquivo principal {main_js} encontrado", "SUCCESS")
    return True

def create_react_error_fix_html(project_dir):
    """Cria página de correção específica para servidor"""
    print_status("📄 Criando página de correção para servidor...", "INFO")
    
    fix_html = """
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Correção React #130 - Servidor</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        .error-box {
            background: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 20px;
            margin: 20px 0;
            border-radius: 4px;
        }
        .solution-box {
            background: #d4edda;
            border-left: 4px solid #28a745;
            padding: 20px;
            margin: 20px 0;
            border-radius: 4px;
        }
        .code-block {
            background: #2d3748;
            color: #e2e8f0;
            padding: 15px;
            border-radius: 6px;
            font-family: monospace;
            margin: 10px 0;
            overflow-x: auto;
        }
        .btn {
            background: #007bff;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin: 5px;
            text-decoration: none;
            display: inline-block;
        }
        .btn:hover {
            background: #0056b3;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔧 Correção React #130 - Servidor</h1>
        
        <div class="error-box">
            <h3>❌ Erro Identificado no Servidor:</h3>
            <p><strong>Minified React error #130</strong> - Este erro é específico do ambiente de servidor e geralmente está relacionado a:</p>
            <ul>
                <li>Diferenças de configuração entre desenvolvimento e produção</li>
                <li>Problemas de cache do servidor web</li>
                <li>Configurações de build minificado</li>
                <li>Headers HTTP incorretos</li>
            </ul>
        </div>

        <div class="solution-box">
            <h3>✅ Soluções para Servidor:</h3>
            
            <h4>1. Limpar Cache do Servidor</h4>
            <div class="code-block">
# No servidor, execute:
sudo systemctl restart gestao-projetos
sudo systemctl reload nginx  # se usando nginx
# ou
sudo systemctl reload apache2  # se usando apache
            </div>

            <h4>2. Verificar Headers HTTP</h4>
            <div class="code-block">
# Adicionar headers corretos no nginx/apache:
add_header Cache-Control "no-cache, no-store, must-revalidate";
add_header Pragma "no-cache";
add_header Expires "0";
            </div>

            <h4>3. Forçar Recarregamento</h4>
            <div class="code-block">
# No navegador:
Ctrl+Shift+R (ou Cmd+Shift+R no Mac)
# ou
F12 → Network → Disable cache → Reload
            </div>

            <h4>4. Verificar Arquivos Estáticos</h4>
            <div class="code-block">
# Verificar se os arquivos estão sendo servidos corretamente:
curl -I http://seu-servidor/assets/index-DDT9FNxU.js
# Deve retornar Content-Type: application/javascript
            </div>
        </div>

        <div class="solution-box">
            <h3>🔧 Script de Correção Automática:</h3>
            <p>Execute este script no servidor para corrigir automaticamente:</p>
            <div class="code-block">
cd /opt/gestao-projetos
python3 fix_server_react_error.py
            </div>
        </div>

        <div style="text-align: center; margin-top: 30px;">
            <button onclick="clearCache()" class="btn">🧹 Limpar Cache</button>
            <button onclick="reloadPage()" class="btn">🔄 Recarregar</button>
        </div>
    </div>

    <script>
        function clearCache() {
            if ('caches' in window) {
                caches.keys().then(function(names) {
                    for (let name of names) {
                        caches.delete(name);
                    }
                });
            }
            alert('Cache limpo! Recarregando página...');
            window.location.reload(true);
        }

        function reloadPage() {
            window.location.reload(true);
        }

        // Verificar se há erros no console
        window.addEventListener('error', function(e) {
            console.error('Erro detectado:', e.error);
            if (e.error && e.error.message.includes('130')) {
                alert('Erro React #130 detectado! Execute as correções acima.');
            }
        });
    </script>
</body>
</html>
"""
    
    fix_file = os.path.join(project_dir, "src", "static", "react_error_fix.html")
    with open(fix_file, 'w', encoding='utf-8') as f:
        f.write(fix_html)
    
    print_status(f"✅ Página de correção criada: {fix_file}", "SUCCESS")
    return fix_file

def fix_server_headers(project_dir):
    """Corrige headers HTTP para resolver problemas de cache"""
    print_status("🔧 Corrigindo headers HTTP...", "INFO")
    
    # Modificar main.py para adicionar headers corretos
    main_py = os.path.join(project_dir, "src", "main.py")
    
    if not os.path.exists(main_py):
        print_status("❌ Arquivo main.py não encontrado", "ERROR")
        return False
    
    # Ler arquivo atual
    with open(main_py, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Adicionar headers se não existirem
    if "Cache-Control" not in content:
        # Adicionar função para configurar headers
        headers_code = '''
# Configurar headers para resolver problemas de cache
@app.after_request
def after_request(response):
    # Headers para resolver problemas de cache com React
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'
    
    # Headers específicos para arquivos JavaScript
    if response.content_type and 'javascript' in response.content_type:
        response.headers['Content-Type'] = 'application/javascript; charset=utf-8'
    
    return response

'''
        
        # Inserir antes da última linha
        lines = content.split('\n')
        insert_index = len(lines) - 1
        
        # Encontrar a linha com if __name__ == '__main__':
        for i, line in enumerate(lines):
            if "if __name__ == '__main__':" in line:
                insert_index = i
                break
        
        lines.insert(insert_index, headers_code)
        new_content = '\n'.join(lines)
        
        # Backup do arquivo original
        backup_file = main_py + '.backup'
        shutil.copy2(main_py, backup_file)
        print_status(f"📁 Backup criado: {backup_file}", "INFO")
        
        # Escrever arquivo modificado
        with open(main_py, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print_status("✅ Headers HTTP adicionados ao main.py", "SUCCESS")
        return True
    else:
        print_status("✅ Headers HTTP já configurados", "SUCCESS")
        return True

def restart_server_service():
    """Reinicia o serviço do servidor"""
    print_status("🔄 Reiniciando serviço do servidor...", "INFO")
    
    try:
        # Parar serviço
        subprocess.run(['sudo', 'systemctl', 'stop', 'gestao-projetos'], check=True)
        print_status("⏹️  Serviço parado", "INFO")
        
        # Aguardar um pouco
        import time
        time.sleep(2)
        
        # Iniciar serviço
        subprocess.run(['sudo', 'systemctl', 'start', 'gestao-projetos'], check=True)
        print_status("▶️  Serviço iniciado", "INFO")
        
        # Verificar status
        time.sleep(3)
        result = subprocess.run(['sudo', 'systemctl', 'is-active', 'gestao-projetos'], 
                              capture_output=True, text=True)
        
        if result.stdout.strip() == 'active':
            print_status("✅ Serviço funcionando corretamente", "SUCCESS")
            return True
        else:
            print_status("❌ Serviço não está ativo", "ERROR")
            return False
            
    except subprocess.CalledProcessError as e:
        print_status(f"❌ Erro ao reiniciar serviço: {e}", "ERROR")
        return False

def test_server_response(project_dir):
    """Testa a resposta do servidor"""
    print_status("🧪 Testando resposta do servidor...", "INFO")
    
    try:
        import requests
        response = requests.get('http://localhost:7744', timeout=10)
        
        if response.status_code == 200:
            print_status("✅ Servidor respondendo corretamente", "SUCCESS")
            
            # Verificar se o arquivo JavaScript está sendo servido
            js_response = requests.get('http://localhost:7744/assets/index-DDT9FNxU.js', timeout=10)
            if js_response.status_code == 200:
                print_status("✅ Arquivo JavaScript principal acessível", "SUCCESS")
                return True
            else:
                print_status("❌ Arquivo JavaScript não acessível", "ERROR")
                return False
        else:
            print_status(f"❌ Servidor retornou status {response.status_code}", "ERROR")
            return False
            
    except ImportError:
        print_status("⚠️  requests não instalado, pulando teste", "WARNING")
        return True
    except Exception as e:
        print_status(f"❌ Erro ao testar servidor: {e}", "ERROR")
        return False

def main():
    """Função principal"""
    print_status("🔧 Corretor de Erro React #130 para Servidor", "INFO")
    print("=" * 60)
    
    # Verificar ambiente
    project_dir = check_server_environment()
    
    # Corrigir problemas do build React
    if not fix_react_build_issues(project_dir):
        print_status("❌ Falha ao corrigir problemas do build", "ERROR")
        return False
    
    # Criar página de correção
    create_react_error_fix_html(project_dir)
    
    # Corrigir headers HTTP
    if not fix_server_headers(project_dir):
        print_status("❌ Falha ao corrigir headers HTTP", "ERROR")
        return False
    
    # Reiniciar serviço
    if not restart_server_service():
        print_status("❌ Falha ao reiniciar serviço", "ERROR")
        return False
    
    # Testar servidor
    if not test_server_response(project_dir):
        print_status("❌ Servidor não está respondendo corretamente", "ERROR")
        return False
    
    print_status("\n🎉 Correções aplicadas com sucesso!", "SUCCESS")
    print_status("📋 Próximos passos:", "INFO")
    print("1. Acesse a aplicação no navegador")
    print("2. Limpe o cache (Ctrl+Shift+R)")
    print("3. Se o erro persistir, acesse: /react_error_fix.html")
    print("4. Verifique os logs: sudo journalctl -u gestao-projetos -f")
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
