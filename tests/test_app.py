
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_system():  
    """Тест endpoint /system"""
    response = client.get("/system")
    assert response.status_code == 200
    data = response.json()
    assert "cpu_percent" in data
    assert "memory_percent" in data
    assert isinstance(data["cpu_percent"], (int, float))
    assert isinstance(data["memory_percent"], (int, float))


def test_metrics():
    """Тест endpoint /metrics"""
    response = client.get("/metrics")
    assert response.status_code == 200
    assert "text/plain" in response.headers.get("content-type", "")
    content = response.text
    assert "system_cpu_percent" in content
    assert "system_memory_percent" in content
