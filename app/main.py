from fastapi import FastAPI
from prometheus_client import Gauge, generate_latest, CONTENT_TYPE_LATEST
from fastapi.responses import Response
import psutil


app = FastAPI()


# Метрики Prometheus
cpu_gauge = Gauge('system_cpu_percent', 'CPU usage in percent')
mem_gauge = Gauge('system_memory_percent', 'Memory usage in percent')


@app.get("/system")
def system_info():
    cpu = psutil.cpu_percent()
    mem = psutil.virtual_memory().percent
    return {
        "cpu_percent": cpu,
        "memory_percent": mem
    }


@app.get("/metrics")
def metrics():
    # Получаем текущие значения
    cpu = psutil.cpu_percent()
    mem = psutil.virtual_memory().percent
    # Обновляем метрики Prometheus
    cpu_gauge.set(cpu)
    mem_gauge.set(mem) 
    # Возвращаем в формате Prometheus
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
