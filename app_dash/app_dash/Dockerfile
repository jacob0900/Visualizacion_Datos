# Imagen base de Python (versión ligera 3.10)
FROM python:3.10-slim

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar archivo de dependencias primero (mejora cache de Docker)
COPY requirements.txt requirements.txt

# Instalar dependencias del proyecto
RUN pip install -r requirements.txt

# Copiar el resto del código de la aplicación al contenedor
COPY . .

# Exponer el puerto 8080 para acceder a la aplicación
EXPOSE 8080

# Comando por defecto para ejecutar la aplicación con Gunicorn
# "app:server" significa que en app.py existe un objeto llamado "server"
CMD ["gunicorn", "-b", "0.0.0.0:8080", "app:server"]