#!/usr/bin/env python3
"""
Script para testar as rotas da aplicação
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from src.main import app

def test_routes():
    """Lista todas as rotas registradas"""
    print("🔍 Rotas registradas na aplicação:")
    print("-" * 50)
    
    for rule in app.url_map.iter_rules():
        print(f"  {rule.methods} {rule.rule}")
    
    print(f"\n📊 Total de rotas: {len(list(app.url_map.iter_rules()))}")

if __name__ == '__main__':
    test_routes()
