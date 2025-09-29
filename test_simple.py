#!/usr/bin/env python3
"""
Teste simples da API
"""

import requests
import json

def test_api():
    base_url = "http://localhost:53000"
    
    print("🧪 Testando API...")
    
    # Teste 1: Listar projetos
    print("\n1️⃣ Testando listagem de projetos...")
    try:
        response = requests.get(f"{base_url}/api/projects")
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            if isinstance(data, list):
                print(f"   ✅ {len(data)} projetos encontrados")
            else:
                print(f"   📊 Resposta: {data}")
        else:
            print(f"   ❌ Erro: {response.text}")
    except Exception as e:
        print(f"   ❌ Erro: {e}")
    
    # Teste 2: Estatísticas
    print("\n2️⃣ Testando estatísticas...")
    try:
        response = requests.get(f"{base_url}/api/projects/stats")
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   ✅ Estatísticas: {data}")
        else:
            print(f"   ❌ Erro: {response.text}")
    except Exception as e:
        print(f"   ❌ Erro: {e}")

if __name__ == '__main__':
    test_api()
