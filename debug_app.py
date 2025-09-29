#!/usr/bin/env python3
"""
Script para debugar a aplicação
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from src.main import app

def debug_app():
    """Debug da aplicação"""
    print("🔍 Debug da aplicação Flask...")
    print("-" * 50)
    
    # Listar todas as rotas
    print("📋 Rotas registradas:")
    for rule in app.url_map.iter_rules():
        print(f"  {rule.methods} {rule.rule}")
    
    print(f"\n📊 Total de rotas: {len(list(app.url_map.iter_rules()))}")
    
    # Testar com test client
    print("\n🧪 Testando com test client...")
    with app.test_client() as client:
        # Testar rota de projetos
        response = client.get('/api/projects')
        print(f"GET /api/projects: {response.status_code}")
        if response.status_code == 200:
            data = response.get_json()
            print(f"  Resposta: {type(data)} - {len(data) if isinstance(data, list) else 'N/A'}")
        
        # Testar rota de stats
        response = client.get('/api/projects/stats')
        print(f"GET /api/projects/stats: {response.status_code}")
        if response.status_code == 200:
            data = response.get_json()
            print(f"  Resposta: {data}")
        else:
            print(f"  Erro: {response.get_data(as_text=True)}")

if __name__ == '__main__':
    debug_app()
