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
