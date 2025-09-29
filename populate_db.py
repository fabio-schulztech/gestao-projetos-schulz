#!/usr/bin/env python3
"""
Script para popular o banco de dados com os projetos iniciais da Schulz Tech
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from src.main import app, db
from src.models.project import Project
from datetime import datetime

# Dados dos projetos iniciais
initial_projects = [
    # Sensores e Monitoramento
    {
        'name': 'Inclinômetro',
        'description': 'Sistema de monitoramento de inclinação para equipamentos',
        'category': 'sensores',
        'current_stage': 2,
        'priority': 'alta',
        'roi': 85,
        'effort': 120,
        'budget': 45000
    },
    {
        'name': 'Sensor de carga por eixo',
        'description': 'Monitoramento de peso distribuído nos eixos',
        'category': 'sensores',
        'current_stage': 1,
        'priority': 'alta',
        'roi': 92,
        'effort': 180,
        'budget': 65000
    },
    {
        'name': 'Leitor de profundidade de sulco',
        'description': 'Análise automática do desgaste de pneus',
        'category': 'sensores',
        'current_stage': 3,
        'priority': 'média',
        'roi': 78,
        'effort': 90,
        'budget': 35000
    },
    {
        'name': 'Controle de temperatura',
        'description': 'Monitoramento térmico de componentes críticos',
        'category': 'sensores',
        'current_stage': 2,
        'priority': 'média',
        'roi': 65,
        'effort': 75,
        'budget': 28000
    },
    {
        'name': 'Analítico de vídeo de EPI',
        'description': 'Detecção automática do uso correto de EPIs',
        'category': 'sensores',
        'current_stage': 1,
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
        'current_stage': 4,
        'priority': 'alta',
        'roi': 88,
        'effort': 150,
        'budget': 55000
    },
    {
        'name': 'Monitoramento do enchimento das caçambas',
        'description': 'Controle automático do nível de enchimento',
        'category': 'rastreabilidade',
        'current_stage': 2,
        'priority': 'média',
        'roi': 72,
        'effort': 100,
        'budget': 40000
    },
    {
        'name': 'Gestão de pneus',
        'description': 'Sistema completo de controle de vida útil dos pneus',
        'category': 'rastreabilidade',
        'current_stage': 3,
        'priority': 'alta',
        'roi': 80,
        'effort': 130,
        'budget': 48000
    },
    {
        'name': 'Roteirização',
        'description': 'Otimização de rotas para máximas eficiência operacional',
        'category': 'rastreabilidade',
        'current_stage': 1,
        'priority': 'alta',
        'roi': 90,
        'effort': 160,
        'budget': 60000
    },
    {
        'name': 'Torre de controle – 1 (operacional)',
        'description': 'Centro de comando operacional integrado',
        'category': 'rastreabilidade',
        'current_stage': 1,
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
        'current_stage': 2,
        'priority': 'alta',
        'roi': 75,
        'effort': 180,
        'budget': 70000
    },
    {
        'name': 'IoT para fábrica',
        'description': 'Implementação de Internet das Coisas na linha de produção',
        'category': 'inovacao',
        'current_stage': 1,
        'priority': 'alta',
        'roi': 82,
        'effort': 250,
        'budget': 120000
    },
    {
        'name': 'Migração do servidor',
        'description': 'Modernização da infraestrutura de TI e migração para cloud',
        'category': 'inovacao',
        'current_stage': 3,
        'priority': 'alta',
        'roi': 60,
        'effort': 80,
        'budget': 35000
    }
]

def populate_database():
    """Popula o banco de dados com os projetos iniciais"""
    with app.app_context():
        try:
            # Verificar se já existem projetos
            existing_count = Project.query.count()
            if existing_count > 0:
                print(f"⚠️  Banco já contém {existing_count} projetos.")
                response = input("Deseja limpar e recriar? (s/N): ")
                if response.lower() != 's':
                    print("Operação cancelada.")
                    return
                
                # Limpar dados existentes
                Project.query.delete()
                db.session.commit()
                print("✅ Dados existentes removidos.")
            
            # Inserir projetos iniciais
            projects_created = 0
            for project_data in initial_projects:
                project = Project(
                    name=project_data['name'],
                    description=project_data['description'],
                    category=project_data['category'],
                    current_stage=project_data['current_stage'],
                    priority=project_data['priority'],
                    roi=project_data['roi'],
                    effort=project_data['effort'],
                    budget=project_data['budget'],
                    created_at=datetime.utcnow(),
                    updated_at=datetime.utcnow()
                )
                
                db.session.add(project)
                projects_created += 1
            
            db.session.commit()
            print(f"✅ {projects_created} projetos criados com sucesso!")
            
            # Mostrar estatísticas
            sensores_count = Project.query.filter_by(category='sensores').count()
            rastreabilidade_count = Project.query.filter_by(category='rastreabilidade').count()
            inovacao_count = Project.query.filter_by(category='inovacao').count()
            
            print(f"\n📊 Estatísticas:")
            print(f"   ⚙️  Sensores e Monitoramento: {sensores_count} projetos")
            print(f"   📡 Rastreabilidade e Operações: {rastreabilidade_count} projetos")
            print(f"   🚀 Inovação e Projetos Especiais: {inovacao_count} projetos")
            print(f"   📈 Total: {projects_created} projetos")
            
        except Exception as e:
            db.session.rollback()
            print(f"❌ Erro ao popular banco de dados: {str(e)}")
            return False
    
    return True

if __name__ == '__main__':
    print("🚀 Populando banco de dados da Schulz Tech...")
    success = populate_database()
    
    if success:
        print("\n🎉 Banco de dados populado com sucesso!")
        print("   Acesse http://localhost:53000 para ver os projetos.")
    else:
        print("\n💥 Falha ao popular banco de dados.")
        sys.exit(1)
