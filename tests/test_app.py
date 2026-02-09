# tests/test_app.py
import sys
from pathlib import Path

# Получаем абсолютный путь к корню проекта
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_root():
    response = client.get("/")
    assert response.status_code == 200


def test_metrics():
    response = client.get("/metrics")
    assert response.status_code == 200
