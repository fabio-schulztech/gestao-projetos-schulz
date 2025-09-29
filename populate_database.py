#!/usr/bin/env python3
"""
Script para popular o banco de dados com dados de exemplo
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from src.main import app
from src.models.project import db, Project, ProjectHistory
from datetime import datetime

def populate_database():
    """Popula o banco de dados com dados de exemplo"""
    
    with app.app_context():
        # Verificar se já existem projetos
        if Project.query.count() > 0:
            print("❌ Banco de dados já possui projetos. Use 'python populate_database.py --force' para forçar.")
            return False
        
        # Dados de exemplo
        sample_projects = [
            {
                'name': 'Sistema de Monitoramento IoT Industrial',
                'category': 'sensores',
                'description': 'Implementação de sensores IoT para monitoramento de equipamentos industriais com alertas em tempo real',
                'currentStage': 2,
                'priority': 'alta',
                'roi': 85,
                'effort': 120,
                'budget': 45000
            },
            {
                'name': 'Rastreamento GPS de Frota',
                'category': 'rastreabilidade',
                'description': 'Sistema completo de rastreamento GPS para frota de veículos com relatórios de rota',
                'currentStage': 3,
                'priority': 'média',
                'roi': 75,
                'effort': 150,
                'budget': 60000
            },
            {
                'name': 'Projeto de Inteligência Artificial',
                'category': 'inovacao',
                'description': 'Desenvolvimento de solução com IA para automação de processos e tomada de decisões',
                'currentStage': 1,
                'priority': 'alta',
                'roi': 90,
                'effort': 200,
                'budget': 80000
            },
            {
                'name': 'Sensor de Temperatura e Umidade',
                'category': 'sensores',
                'description': 'Monitoramento térmico e de umidade de componentes críticos com dashboard web',
                'currentStage': 4,
                'priority': 'média',
                'roi': 65,
                'effort': 75,
                'budget': 28000
            },
            {
                'name': 'Gestão Inteligente de Pneus',
                'category': 'rastreabilidade',
                'description': 'Sistema completo de controle de pneus da frota com previsão de troca',
                'currentStage': 3,
                'priority': 'alta',
                'roi': 80,
                'effort': 130,
                'budget': 48000
            },
            {
                'name': 'Sistema de Detecção de Vazamentos',
                'category': 'sensores',
                'description': 'Detecção automática de vazamentos em tubulações com notificações instantâneas',
                'currentStage': 2,
                'priority': 'alta',
                'roi': 70,
                'effort': 90,
                'budget': 35000
            },
            {
                'name': 'Blockchain para Rastreabilidade',
                'category': 'inovacao',
                'description': 'Implementação de blockchain para rastreabilidade completa da cadeia de suprimentos',
                'currentStage': 1,
                'priority': 'média',
                'roi': 95,
                'effort': 180,
                'budget': 95000
            },
            {
                'name': 'Monitoramento de Vibração',
                'category': 'sensores',
                'description': 'Sistema de monitoramento de vibração para manutenção preditiva de máquinas',
                'currentStage': 5,
                'priority': 'baixa',
                'roi': 60,
                'effort': 110,
                'budget': 42000
            }
        ]
        
        print("🚀 Iniciando população do banco de dados...")
        
        try:
            # Criar projetos
            for i, project_data in enumerate(sample_projects, 1):
                project = Project(
                    name=project_data['name'],
                    description=project_data['description'],
                    category=project_data['category'],
                    current_stage=project_data['currentStage'],
                    priority=project_data['priority'],
                    roi=project_data['roi'],
                    effort=project_data['effort'],
                    budget=project_data['budget']
                )
                db.session.add(project)
                print(f"  ✅ Projeto {i}/{len(sample_projects)}: {project.name}")
            
            # Commit das alterações
            db.session.commit()
            
            print(f"\n🎉 Banco de dados populado com sucesso!")
            print(f"   📊 Total de projetos: {Project.query.count()}")
            print(f"   💰 Orçamento total: R$ {sum(p.budget for p in Project.query.all()):,}")
            print(f"   📈 ROI médio: {sum(p.roi for p in Project.query.all()) / Project.query.count():.1f}%")
            
            return True
            
        except Exception as e:
            db.session.rollback()
            print(f"❌ Erro ao popular banco de dados: {e}")
            return False

def clear_database():
    """Limpa o banco de dados"""
    with app.app_context():
        try:
            print("🗑️  Limpando banco de dados...")
            ProjectHistory.query.delete()
            Project.query.delete()
            db.session.commit()
            print("✅ Banco de dados limpo com sucesso!")
            return True
        except Exception as e:
            db.session.rollback()
            print(f"❌ Erro ao limpar banco de dados: {e}")
            return False

if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == '--force':
        print("⚠️  Modo força ativado - limpando banco existente...")
        if clear_database():
            populate_database()
    elif len(sys.argv) > 1 and sys.argv[1] == '--clear':
        clear_database()
    else:
        populate_database()
