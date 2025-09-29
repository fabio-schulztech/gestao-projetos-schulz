#!/usr/bin/env python3
"""
Script simplificado para inicializar e popular o banco de dados
"""

import os
import sys
import requests
import json

# URL da API local
API_BASE = "http://localhost:53000/api"

# Dados dos projetos iniciais
initial_projects = [
    # Sensores e Monitoramento
    {
        'name': 'Inclinômetro',
        'description': 'Sistema de monitoramento de inclinação para equipamentos',
        'category': 'sensores',
        'currentStage': 2,
        'priority': 'alta',
        'roi': 85,
        'effort': 120,
        'budget': 45000
    },
    {
        'name': 'Sensor de carga por eixo',
        'description': 'Monitoramento de peso distribuído nos eixos',
        'category': 'sensores',
        'currentStage': 1,
        'priority': 'alta',
        'roi': 92,
        'effort': 180,
        'budget': 65000
    },
    {
        'name': 'Leitor de profundidade de sulco',
        'description': 'Análise automática do desgaste de pneus',
        'category': 'sensores',
        'currentStage': 3,
        'priority': 'média',
        'roi': 78,
        'effort': 90,
        'budget': 35000
    },
    {
        'name': 'Controle de temperatura',
        'description': 'Monitoramento térmico de componentes críticos',
        'category': 'sensores',
        'currentStage': 2,
        'priority': 'média',
        'roi': 65,
        'effort': 75,
        'budget': 28000
    },
    {
        'name': 'Analítico de vídeo de EPI',
        'description': 'Detecção automática do uso correto de EPIs',
        'category': 'sensores',
        'currentStage': 1,
        'priority': 'alta',
        'roi': 88,
        'effort': 200,
        'budget': 85000
    },
    
    # Rastreabilidade e Operações
    {
        'name': 'Rastreamento indoor',
        'description': 'Sistema de localização de empilhadeiras e equipamentos internos',
        'category': 'rastreabilidade',
        'currentStage': 4,
        'priority': 'alta',
        'roi': 88,
        'effort': 150,
        'budget': 55000
    },
    {
        'name': 'Monitoramento do enchimento das caçambas',
        'description': 'Controle automático do nível de enchimento',
        'category': 'rastreabilidade',
        'currentStage': 2,
        'priority': 'média',
        'roi': 72,
        'effort': 100,
        'budget': 40000
    },
    {
        'name': 'Gestão de pneus',
        'description': 'Sistema completo de controle de vida útil dos pneus',
        'category': 'rastreabilidade',
        'currentStage': 3,
        'priority': 'alta',
        'roi': 80,
        'effort': 130,
        'budget': 48000
    },
    {
        'name': 'Roteirização',
        'description': 'Otimização de rotas para máximas eficiência operacional',
        'category': 'rastreabilidade',
        'currentStage': 1,
        'priority': 'alta',
        'roi': 90,
        'effort': 160,
        'budget': 60000
    },
    {
        'name': 'Torre de controle – 1 (operacional)',
        'description': 'Centro de comando operacional integrado',
        'category': 'rastreabilidade',
        'currentStage': 1,
        'priority': 'alta',
        'roi': 85,
        'effort': 220,
        'budget': 95000
    },
    
    # Inovação e Projetos Especiais
    {
        'name': 'Forkvision – Senai',
        'description': 'Projeto de visão computacional para empilhadeiras em parceria com SENAI',
        'category': 'inovacao',
        'currentStage': 2,
        'priority': 'alta',
        'roi': 75,
        'effort': 180,
        'budget': 70000
    },
    {
        'name': 'IoT para fábrica',
        'description': 'Implementação de Internet das Coisas na linha de produção',
        'category': 'inovacao',
        'currentStage': 1,
        'priority': 'alta',
        'roi': 82,
        'effort': 250,
        'budget': 120000
    },
    {
        'name': 'Migração do servidor',
        'description': 'Modernização da infraestrutura de TI e migração para cloud',
        'category': 'inovacao',
        'currentStage': 3,
        'priority': 'alta',
        'roi': 60,
        'effort': 80,
        'budget': 35000
    }
]

def check_server():
    """Verifica se o servidor está rodando"""
    try:
        response = requests.get(f"{API_BASE}/projects", timeout=5)
        return response.status_code == 200
    except:
        return False

def populate_via_api():
    """Popula o banco usando a API"""
    print("🚀 Populando banco de dados via API...")
    
    # Verificar se servidor está rodando
    if not check_server():
        print("❌ Servidor não está rodando na porta 53000")
        print("   Execute: sudo systemctl start gestao-projetos")
        return False
    
    # Verificar projetos existentes
    try:
        response = requests.get(f"{API_BASE}/projects")
        data = response.json()
        
        if data.get('success'):
            existing_count = sum(len(projects) for projects in data['data'].values())
            if existing_count > 0:
                print(f"⚠️  Banco já contém {existing_count} projetos.")
                response = input("Deseja continuar e adicionar mais? (s/N): ")
                if response.lower() != 's':
                    print("Operação cancelada.")
                    return True
    except Exception as e:
        print(f"⚠️  Erro ao verificar projetos existentes: {e}")
    
    # Criar projetos via API
    created_count = 0
    errors = 0
    
    for project_data in initial_projects:
        try:
            response = requests.post(
                f"{API_BASE}/projects",
                json=project_data,
                headers={'Content-Type': 'application/json'},
                timeout=10
            )
            
            if response.status_code == 201:
                created_count += 1
                print(f"✅ Criado: {project_data['name']}")
            else:
                errors += 1
                print(f"❌ Erro ao criar {project_data['name']}: {response.text}")
                
        except Exception as e:
            errors += 1
            print(f"❌ Erro ao criar {project_data['name']}: {e}")
    
    print(f"\n📊 Resultado:")
    print(f"   ✅ Projetos criados: {created_count}")
    print(f"   ❌ Erros: {errors}")
    
    if created_count > 0:
        # Verificar estatísticas finais
        try:
            response = requests.get(f"{API_BASE}/projects")
            data = response.json()
            
            if data.get('success'):
                sensores = len(data['data'].get('sensores', []))
                rastreabilidade = len(data['data'].get('rastreabilidade', []))
                inovacao = len(data['data'].get('inovacao', []))
                total = sensores + rastreabilidade + inovacao
                
                print(f"\n📈 Estatísticas Finais:")
                print(f"   ⚙️  Sensores e Monitoramento: {sensores} projetos")
                print(f"   📡 Rastreabilidade e Operações: {rastreabilidade} projetos")
                print(f"   🚀 Inovação e Projetos Especiais: {inovacao} projetos")
                print(f"   📊 Total: {total} projetos")
                
        except Exception as e:
            print(f"⚠️  Erro ao obter estatísticas: {e}")
    
    return created_count > 0

if __name__ == '__main__':
    print("🎯 Inicializador do Banco de Dados - Schulz Tech")
    print("=" * 50)
    
    success = populate_via_api()
    
    if success:
        print("\n🎉 Banco de dados inicializado com sucesso!")
        print("   Acesse http://iot.schulztech.com.br:53000 para ver os projetos.")
    else:
        print("\n💥 Falha ao inicializar banco de dados.")
        print("\nVerifique se:")
        print("1. O serviço está rodando: sudo systemctl status gestao-projetos")
        print("2. A porta 53000 está acessível: curl http://localhost:53000/api/projects")
        sys.exit(1)
