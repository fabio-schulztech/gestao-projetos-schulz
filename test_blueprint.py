#!/usr/bin/env python3
"""
Script para testar o blueprint diretamente
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from src.routes.project_new import project_bp
from flask import Flask

app = Flask(__name__)
app.register_blueprint(project_bp, url_prefix='/api')

def test_blueprint():
    """Testa o blueprint diretamente"""
    print("🔍 Testando blueprint diretamente...")
    
    with app.test_client() as client:
        # Testar rota de projetos
        response = client.get('/api/projects')
        print(f"GET /api/projects: {response.status_code}")
        
        # Testar rota de stats
        response = client.get('/api/projects/stats')
        print(f"GET /api/projects/stats: {response.status_code}")
        if response.status_code == 200:
            print(f"  Resposta: {response.get_json()}")
        else:
            print(f"  Erro: {response.get_data(as_text=True)}")

if __name__ == '__main__':
    test_blueprint()
