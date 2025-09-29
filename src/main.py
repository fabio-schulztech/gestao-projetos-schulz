import os
import sys
# DON'T CHANGE THIS !!!
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from flask import Flask, send_from_directory
from flask_cors import CORS
from src.models.project import db
from src.models.project import Project, ProjectHistory
from src.routes.user import user_bp
from src.routes.project_new import project_bp

app = Flask(__name__, static_folder=os.path.join(os.path.dirname(__file__), 'static'))
app.config['SECRET_KEY'] = 'asdf#FGSgvasgf$5$WGT'

# Configurar CORS para permitir requisições do frontend
CORS(app, origins=['*'])

# Configurar headers para resolver problemas de cache React #130
@app.after_request
def after_request(response):
    # Headers para resolver problemas de cache com React
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'
    
    # Headers específicos para arquivos JavaScript
    if response.content_type and 'javascript' in response.content_type:
        response.headers['Content-Type'] = 'application/javascript; charset=utf-8'
    
    return response

# uncomment if you need to use database
app.config['SQLALCHEMY_DATABASE_URI'] = f"sqlite:///{os.path.join(os.path.dirname(__file__), 'database', 'app.db')}"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db.init_app(app)
with app.app_context():
    db.create_all()

# Registrar blueprints DEPOIS da configuração do banco
app.register_blueprint(user_bp, url_prefix='/api')
app.register_blueprint(project_bp, url_prefix='/api')

@app.route('/')
def serve_root():
    static_folder_path = app.static_folder
    if static_folder_path is None:
        return "Static folder not configured", 404

    # Usar o novo frontend que resolve o erro React #130
    index_path = os.path.join(static_folder_path, 'index_new.html')
    if os.path.exists(index_path):
        return send_from_directory(static_folder_path, 'index_new.html')
    else:
        # Fallback para o index.html original
        index_path = os.path.join(static_folder_path, 'index.html')
        if os.path.exists(index_path):
            return send_from_directory(static_folder_path, 'index.html')
        else:
            return "index.html not found", 404

@app.route('/<path:path>')
def serve_static(path):
    static_folder_path = app.static_folder
    if static_folder_path is None:
        return "Static folder not configured", 404

    if os.path.exists(os.path.join(static_folder_path, path)):
        return send_from_directory(static_folder_path, path)
    else:
        # Se não for um arquivo estático, retornar o frontend
        index_path = os.path.join(static_folder_path, 'index_new.html')
        if os.path.exists(index_path):
            return send_from_directory(static_folder_path, 'index_new.html')
        else:
            return "File not found", 404


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=53000, debug=False)
