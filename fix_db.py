#!/usr/bin/env python3
"""
Script de correção para problemas de SQLAlchemy
"""

import os
import sys

# Adicionar diretório atual ao path
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, current_dir)

try:
    # Importar Flask app
    from src.main import app
    
    # Importar modelos
    from src.models.project import db, Project, ProjectHistory
    
    print("🔧 Corrigindo configuração do banco de dados...")
    
    with app.app_context():
        # Criar diretório do banco se não existir
        db_dir = os.path.join(current_dir, 'src', 'database')
        os.makedirs(db_dir, exist_ok=True)
        
        # Criar todas as tabelas
        db.create_all()
        
        print("✅ Tabelas criadas com sucesso!")
        
        # Verificar se existem projetos
        project_count = Project.query.count()
        print(f"📊 Projetos existentes: {project_count}")
        
        if project_count == 0:
            print("💡 Use o comando: python init_db.py")
            print("   para popular o banco com dados iniciais via API")
        
except Exception as e:
    print(f"❌ Erro: {e}")
    print("\nTentando correção alternativa...")
    
    try:
        # Método alternativo usando SQLite diretamente
        import sqlite3
        
        db_path = os.path.join(current_dir, 'src', 'database', 'app.db')
        os.makedirs(os.path.dirname(db_path), exist_ok=True)
        
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Criar tabela de projetos
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS projects (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name VARCHAR(200) NOT NULL,
                description TEXT,
                category VARCHAR(50) NOT NULL,
                current_stage INTEGER DEFAULT 1,
                priority VARCHAR(20) DEFAULT 'média',
                roi FLOAT DEFAULT 0.0,
                effort INTEGER DEFAULT 0,
                budget INTEGER DEFAULT 0,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Criar tabela de histórico
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS project_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                project_id INTEGER NOT NULL,
                field_name VARCHAR(100) NOT NULL,
                old_value TEXT,
                new_value TEXT,
                changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (project_id) REFERENCES projects (id)
            )
        ''')
        
        conn.commit()
        conn.close()
        
        print("✅ Banco criado com SQLite diretamente!")
        print("💡 Agora execute: python init_db.py")
        
    except Exception as e2:
        print(f"❌ Erro na correção alternativa: {e2}")
        sys.exit(1)
