import sys
import os

# Add root and backend directories to sys.path so backend modules can be imported
current_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.abspath(os.path.join(current_dir, ".."))
sys.path.append(project_root)
sys.path.append(os.path.join(project_root, "backend"))

from backend.app.main import app
