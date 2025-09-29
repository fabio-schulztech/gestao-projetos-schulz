from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import json

db = SQLAlchemy()

class Project(db.Model):
    __tablename__ = 'projects'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    category = db.Column(db.String(50), nullable=False)  # sensores, rastreabilidade, inovacao
    current_stage = db.Column(db.Integer, default=1)  # 1-5
    priority = db.Column(db.String(20), default='média')  # alta, média, baixa
    roi = db.Column(db.Float, default=0.0)  # 0-100
    effort = db.Column(db.Integer, default=0)  # horas
    budget = db.Column(db.Integer, default=0)  # valor em reais
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def to_dict(self):
        """Converte o projeto para dicionário"""
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'category': self.category,
            'currentStage': self.current_stage,
            'priority': self.priority,
            'roi': self.roi,
            'effort': self.effort,
            'budget': self.budget,
            'createdAt': self.created_at.isoformat() if self.created_at else None,
            'updatedAt': self.updated_at.isoformat() if self.updated_at else None
        }
    
    @staticmethod
    def from_dict(data):
        """Cria um projeto a partir de dicionário"""
        return Project(
            name=data.get('name'),
            description=data.get('description'),
            category=data.get('category'),
            current_stage=data.get('currentStage', 1),
            priority=data.get('priority', 'média'),
            roi=data.get('roi', 0.0),
            effort=data.get('effort', 0),
            budget=data.get('budget', 0)
        )
    
    def update_from_dict(self, data):
        """Atualiza projeto a partir de dicionário"""
        self.name = data.get('name', self.name)
        self.description = data.get('description', self.description)
        self.category = data.get('category', self.category)
        self.current_stage = data.get('currentStage', self.current_stage)
        self.priority = data.get('priority', self.priority)
        self.roi = data.get('roi', self.roi)
        self.effort = data.get('effort', self.effort)
        self.budget = data.get('budget', self.budget)
        self.updated_at = datetime.utcnow()
    
    def __repr__(self):
        return f'<Project {self.name}>'

class ProjectHistory(db.Model):
    __tablename__ = 'project_history'
    
    id = db.Column(db.Integer, primary_key=True)
    project_id = db.Column(db.Integer, db.ForeignKey('projects.id'), nullable=False)
    stage = db.Column(db.Integer)
    priority = db.Column(db.String(20))
    roi = db.Column(db.Float)
    effort = db.Column(db.Integer)
    budget = db.Column(db.Integer)
    changed_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    project = db.relationship('Project', backref=db.backref('history', lazy=True))
    
    def to_dict(self):
        return {
            'id': self.id,
            'projectId': self.project_id,
            'stage': self.stage,
            'priority': self.priority,
            'roi': self.roi,
            'effort': self.effort,
            'budget': self.budget,
            'changedAt': self.changed_at.isoformat() if self.changed_at else None
        }
    
    def __repr__(self):
        return f'<ProjectHistory {self.project_id}: stage={self.stage}>'
