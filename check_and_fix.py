#!/usr/bin/env python3
"""
Script para verificar e corrigir o erro React #130
"""

import os
import sys
import subprocess
import webbrowser
import time
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

def check_server():
    """Verifica se o servidor Flask está rodando"""
    try:
        import requests
        response = requests.get('http://localhost:53000', timeout=5)
        if response.status_code == 200:
            print_status("✅ Servidor Flask está rodando na porta 53000", "SUCCESS")
            return True
    except:
        pass
    
    print_status("❌ Servidor Flask não está rodando", "ERROR")
    return False

def check_files():
    """Verifica se os arquivos necessários existem"""
    files_to_check = [
        "src/main.py",
        "src/static/index.html",
        "src/static/assets/index-DDT9FNxU.js"
    ]
    
    all_exist = True
    for file_path in files_to_check:
        if os.path.exists(file_path):
            print_status(f"✅ {file_path} encontrado", "SUCCESS")
        else:
            print_status(f"❌ {file_path} não encontrado", "ERROR")
            all_exist = False
    
    return all_exist

def start_server():
    """Inicia o servidor Flask"""
    print_status("🚀 Iniciando servidor Flask...", "INFO")
    try:
        # Mudar para o diretório do projeto
        os.chdir('/Users/fabioobaid/Downloads/backup')
        
        # Verificar se o ambiente virtual existe
        venv_path = 'venv_new/bin/python'
        if os.path.exists(venv_path):
            python_executable = venv_path
        else:
            python_executable = sys.executable
        
        # Iniciar servidor em background
        process = subprocess.Popen([
            python_executable, 'src/main.py'
        ], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
        # Aguardar um pouco para o servidor inicializar
        time.sleep(3)
        
        # Verificar se o processo ainda está rodando
        if process.poll() is None:
            print_status("✅ Servidor Flask iniciado com sucesso", "SUCCESS")
            return process
        else:
            print_status("❌ Falha ao iniciar servidor Flask", "ERROR")
            return None
            
    except Exception as e:
        print_status(f"❌ Erro ao iniciar servidor: {e}", "ERROR")
        return None

def open_browser():
    """Abre o navegador na aplicação"""
    try:
        webbrowser.open('http://localhost:53000')
        print_status("🌐 Navegador aberto em http://localhost:53000", "SUCCESS")
    except Exception as e:
        print_status(f"❌ Erro ao abrir navegador: {e}", "ERROR")

def main():
    """Função principal"""
    print_status("🔧 Verificador e Corretor do Erro React #130", "INFO")
    print("=" * 50)
    
    # Verificar arquivos
    print_status("\n📁 Verificando arquivos...", "INFO")
    files_ok = check_files()
    
    if not files_ok:
        print_status("❌ Alguns arquivos necessários não foram encontrados", "ERROR")
        return
    
    # Verificar servidor
    print_status("\n🌐 Verificando servidor...", "INFO")
    server_running = check_server()
    
    if not server_running:
        print_status("\n🚀 Tentando iniciar servidor...", "INFO")
        process = start_server()
        
        if process:
            print_status("✅ Servidor iniciado com sucesso!", "SUCCESS")
        else:
            print_status("❌ Não foi possível iniciar o servidor", "ERROR")
            print_status("💡 Tente executar manualmente: python3 src/main.py", "WARNING")
            return
    else:
        process = None
    
    # Aguardar um pouco para garantir que o servidor está pronto
    time.sleep(2)
    
    # Verificar novamente se o servidor está rodando
    if check_server():
        print_status("\n🎉 Aplicação está funcionando!", "SUCCESS")
        print_status("📱 Acesse: http://localhost:53000", "INFO")
        
        # Perguntar se quer abrir o navegador
        try:
            response = input("\n🌐 Deseja abrir o navegador? (s/n): ").lower()
            if response in ['s', 'sim', 'y', 'yes']:
                open_browser()
        except KeyboardInterrupt:
            print_status("\n👋 Operação cancelada pelo usuário", "WARNING")
    else:
        print_status("❌ Aplicação não está respondendo", "ERROR")
        print_status("💡 Verifique se não há outros processos usando a porta 53000", "WARNING")
    
    # Instruções finais
    print_status("\n📋 Instruções para resolver o erro React #130:", "INFO")
    print("1. Limpe o cache do navegador (Ctrl+Shift+R ou Cmd+Shift+R)")
    print("2. Acesse http://localhost:53000")
    print("3. Se o erro persistir, verifique o console do navegador")
    print("4. Certifique-se de que está usando a versão mais recente dos arquivos")
    
    if process:
        print_status("\n⚠️  Servidor rodando em background. Pressione Ctrl+C para parar.", "WARNING")
        try:
            process.wait()
        except KeyboardInterrupt:
            print_status("\n🛑 Parando servidor...", "INFO")
            process.terminate()

if __name__ == "__main__":
    main()
