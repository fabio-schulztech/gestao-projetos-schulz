from flask import Blueprint, request, jsonify
from src.models.project import db, Project, ProjectHistory
from datetime import datetime
import json

project_bp = Blueprint('project', __name__)

@project_bp.route('/projects', methods=['GET'])
def get_projects():
    """Retorna todos os projetos como array simples"""
    try:
        projects = Project.query.all()
        projects_list = [project.to_dict() for project in projects]
        
        # Retornar array simples para compatibilidade com o frontend
        return jsonify(projects_list), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@project_bp.route('/projects', methods=['POST'])
def create_project():
    """Cria um novo projeto"""
    try:
        data = request.get_json()
        
        if not data or not data.get('name'):
            return jsonify({
                'success': False,
                'error': 'Nome do projeto é obrigatório'
            }), 400
        
        project = Project(
            name=data['name'],
            description=data.get('description', ''),
            category=data.get('category', 'sensores'),
            current_stage=data.get('currentStage', 1),
            priority=data.get('priority', 'média'),
            roi=data.get('roi', 0),
            effort=data.get('effort', 0),
            budget=data.get('budget', 0)
        )
        
        db.session.add(project)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': project.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@project_bp.route('/projects/<int:project_id>', methods=['GET'])
def get_project(project_id):
    """Retorna um projeto específico"""
    try:
        project = Project.query.get_or_404(project_id)
        return jsonify(project.to_dict()), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@project_bp.route('/projects/<int:project_id>', methods=['PUT'])
def update_project(project_id):
    """Atualiza um projeto existente"""
    try:
        project = Project.query.get_or_404(project_id)
        data = request.get_json()
        
        if not data:
            return jsonify({
                'success': False,
                'error': 'Dados não fornecidos'
            }), 400
        
        # Criar histórico antes da atualização
        history = ProjectHistory(
            project_id=project.id,
            stage=project.current_stage,
            priority=project.priority,
            roi=project.roi,
            effort=project.effort,
            budget=project.budget,
            changed_at=datetime.utcnow()
        )
        db.session.add(history)
        
        # Atualizar campos
        if 'name' in data:
            project.name = data['name']
        if 'description' in data:
            project.description = data['description']
        if 'category' in data:
            project.category = data['category']
        if 'currentStage' in data:
            project.current_stage = data['currentStage']
        if 'priority' in data:
            project.priority = data['priority']
        if 'roi' in data:
            project.roi = data['roi']
        if 'effort' in data:
            project.effort = data['effort']
        if 'budget' in data:
            project.budget = data['budget']
        
        project.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': project.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@project_bp.route('/projects/<int:project_id>', methods=['DELETE'])
def delete_project(project_id):
    """Exclui um projeto"""
    try:
        project = Project.query.get_or_404(project_id)
        
        # Deletar histórico relacionado se existir
        ProjectHistory.query.filter_by(project_id=project.id).delete()
        
        db.session.delete(project)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Projeto excluído com sucesso'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@project_bp.route('/projects/stats', methods=['GET'])
def get_project_stats():
    """Retorna estatísticas dos projetos"""
    try:
        total_projects = Project.query.count()
        completed_projects = Project.query.filter_by(current_stage=5).count()
        
        projects = Project.query.all()
        avg_roi = sum(p.roi for p in projects) / len(projects) if projects else 0
        total_budget = sum(p.budget for p in projects)
        
        return jsonify({
            'totalProjects': total_projects,
            'completedProjects': completed_projects,
            'avgROI': round(avg_roi, 1),
            'totalBudget': total_budget
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@project_bp.route('/projects/seed', methods=['POST'])
def seed_projects():
    """Cria projetos de exemplo"""
    try:
        # Verificar se já existem projetos
        if Project.query.count() > 0:
            return jsonify({
                'success': False,
                'message': 'Projetos já existem no banco de dados'
            }), 400
        
        # Dados de exemplo
        sample_projects = [
            {
                'name': 'Sistema de Monitoramento IoT',
                'category': 'sensores',
                'description': 'Implementação de sensores IoT para monitoramento de equipamentos industriais',
                'currentStage': 2,
                'priority': 'alta',
                'roi': 85,
                'effort': 120,
                'budget': 45000
            },
            {
                'name': 'Rastreamento de Veículos',
                'category': 'rastreabilidade',
                'description': 'Sistema de rastreamento GPS para frota de veículos da empresa',
                'currentStage': 3,
                'priority': 'média',
                'roi': 75,
                'effort': 150,
                'budget': 60000
            },
            {
                'name': 'Projeto de Inovação AI',
                'category': 'inovacao',
                'description': 'Desenvolvimento de solução com inteligência artificial para automação',
                'currentStage': 1,
                'priority': 'alta',
                'roi': 90,
                'effort': 200,
                'budget': 80000
            },
            {
                'name': 'Sensor de Temperatura',
                'category': 'sensores',
                'description': 'Monitoramento térmico de componentes críticos',
                'currentStage': 4,
                'priority': 'média',
                'roi': 65,
                'effort': 75,
                'budget': 28000
            },
            {
                'name': 'Gestão de Pneus',
                'category': 'rastreabilidade',
                'description': 'Sistema completo de controle de pneus da frota',
                'currentStage': 3,
                'priority': 'alta',
                'roi': 80,
                'effort': 130,
                'budget': 48000
            }
        ]
        
        for project_data in sample_projects:
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
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': f'{len(sample_projects)} projetos criados com sucesso'
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@project_bp.route('/projects/<int:project_id>/history', methods=['GET'])
def get_project_history(project_id):
    """Retorna histórico de alterações de um projeto"""
    try:
        history = ProjectHistory.query.filter_by(project_id=project_id).order_by(ProjectHistory.changed_at.desc()).all()
        history_list = [{
            'id': h.id,
            'stage': h.stage,
            'priority': h.priority,
            'roi': h.roi,
            'effort': h.effort,
            'budget': h.budget,
            'changedAt': h.changed_at.isoformat()
        } for h in history]
        
        return jsonify(history_list), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
