# Etapa 1: Builder
FROM python:3.11-slim as builder

WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements
COPY src/requirements.txt .

# Crear directorio de paquetes virtuales
RUN pip install --user --no-cache-dir -r requirements.txt

# Etapa 2: Runtime
FROM python:3.11-slim

WORKDIR /app

# Crear usuario no-root por seguridad
RUN useradd -m -u 1000 appuser

# Copiar paquetes de Python desde builder
COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local

# Copiar código de la aplicación
COPY --chown=appuser:appuser src/ .

# Actualizar PATH
ENV PATH=/home/appuser/.local/bin:$PATH \
    PYTHONUNBUFFERED=1

# Cambiar al usuario no-root
USER appuser

# Comando por defecto
CMD ["python", "main.py"]
