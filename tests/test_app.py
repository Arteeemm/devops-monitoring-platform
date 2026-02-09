# tests/test_app.py
import sys
import os

# Добавляем путь к проекту для корректного импорта
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_system():  # Вместо test_root()
    """Тест endpoint /system"""
    response = client.get("/system")
    assert response.status_code == 200
    data = response.json()
    assert "cpu_percent" in data
    assert "memory_percent" in data
    # Дополнительные проверки
    assert isinstance(data["cpu_percent"], (int, float))
    assert isinstance(data["memory_percent"], (int, float))


def test_metrics():
    """Тест endpoint /metrics"""
    response = client.get("/metrics")
    assert response.status_code == 200
    # Проверяем, что это Prometheus формат
    assert "text/plain" in response.headers.get("content-type", "")
    # Проверяем наличие метрик в ответе
    content = response.text
    assert "system_cpu_percent" in content
    assert "system_memory_percent" in content
