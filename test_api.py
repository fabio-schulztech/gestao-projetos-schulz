#!/usr/bin/env python3
"""
Script para testar a API da aplicação
"""

import requests
import json
import time

def test_api():
    """Testa todas as rotas da API"""
    
    base_url = "http://localhost:53000"
    
    print("🧪 Testando API da aplicação...")
    print(f"🌐 URL base: {base_url}")
    print("-" * 50)
    
    # Teste 1: Verificar se a aplicação está rodando
    print("1️⃣ Testando se a aplicação está rodando...")
    try:
        response = requests.get(f"{base_url}/", timeout=5)
        if response.status_code == 200:
            print("   ✅ Aplicação está rodando")
        else:
            print(f"   ❌ Aplicação retornou status {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"   ❌ Erro ao conectar: {e}")
        return False
    
    # Teste 2: Listar projetos
    print("\n2️⃣ Testando listagem de projetos...")
    try:
        response = requests.get(f"{base_url}/api/projects", timeout=5)
        if response.status_code == 200:
            projects = response.json()
            print(f"   ✅ {len(projects)} projetos encontrados")
            if isinstance(projects, list):
                for project in projects[:3]:  # Mostrar apenas os primeiros 3
                    print(f"      - {project['name']} ({project['category']})")
            else:
                print(f"      Resposta: {projects}")
        else:
            print(f"   ❌ Erro ao listar projetos: {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"   ❌ Erro na requisição: {e}")
    
    # Teste 3: Estatísticas
    print("\n3️⃣ Testando estatísticas...")
    try:
        response = requests.get(f"{base_url}/api/projects/stats", timeout=5)
        if response.status_code == 200:
            stats = response.json()
            print(f"   ✅ Estatísticas obtidas:")
            print(f"      - Total de projetos: {stats['totalProjects']}")
            print(f"      - Projetos finalizados: {stats['completedProjects']}")
            print(f"      - ROI médio: {stats['avgROI']}%")
            print(f"      - Orçamento total: R$ {stats['totalBudget']:,}")
        else:
            print(f"   ❌ Erro ao obter estatísticas: {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"   ❌ Erro na requisição: {e}")
    
    # Teste 4: Criar novo projeto
    print("\n4️⃣ Testando criação de projeto...")
    try:
        new_project = {
            "name": "Projeto de Teste API",
            "description": "Projeto criado para testar a API",
            "category": "inovacao",
            "currentStage": 1,
            "priority": "alta",
            "roi": 85,
            "effort": 100,
            "budget": 50000
        }
        
        response = requests.post(
            f"{base_url}/api/projects",
            json=new_project,
            headers={'Content-Type': 'application/json'},
            timeout=5
        )
        
        if response.status_code == 201:
            project_data = response.json()
            project_id = project_data['data']['id']
            print(f"   ✅ Projeto criado com ID: {project_id}")
            
            # Teste 5: Atualizar projeto
            print("\n5️⃣ Testando atualização de projeto...")
            update_data = {
                "name": "Projeto de Teste API - Atualizado",
                "currentStage": 2,
                "roi": 90
            }
            
            response = requests.put(
                f"{base_url}/api/projects/{project_id}",
                json=update_data,
                headers={'Content-Type': 'application/json'},
                timeout=5
            )
            
            if response.status_code == 200:
                print("   ✅ Projeto atualizado com sucesso")
            else:
                print(f"   ❌ Erro ao atualizar projeto: {response.status_code}")
            
            # Teste 6: Excluir projeto
            print("\n6️⃣ Testando exclusão de projeto...")
            response = requests.delete(f"{base_url}/api/projects/{project_id}", timeout=5)
            
            if response.status_code == 200:
                print("   ✅ Projeto excluído com sucesso")
            else:
                print(f"   ❌ Erro ao excluir projeto: {response.status_code}")
                
        else:
            print(f"   ❌ Erro ao criar projeto: {response.status_code}")
            print(f"      Resposta: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"   ❌ Erro na requisição: {e}")
    
    print("\n" + "=" * 50)
    print("🎉 Testes da API concluídos!")
    print("💡 Acesse http://localhost:53000 para ver a aplicação")

if __name__ == '__main__':
    test_api()
