# COMANDOS PARA HACER EL BUILD DE LA IMAGEN Y LEVANTAR UN CONTENEDOR
# docker build -t twitch_recorder_image .
#Para windows powershell:
# docker run -d --name twitch_recorder -p 8081:80 -v ${PWD}/app:/app twitch_recorder_image
#Para linux:
# docker run -d --name twitch_recorder -p 8081:80 -v "/home/pi/Desktop/Proyectos/00. Imagen Docker/app/output":/app/output twitch_recorder_image

# Use an official Python runtime based on Debian 10 "buster" as a parent image.
FROM python:3.7-slim-buster

# The maintainer name and email
LABEL maintainer="Carlos_HC"

RUN apt-get update && apt-get install -y nginx gcc python3-dev ffmpeg

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install requirements
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Install uWSGI
RUN pip install uwsgi

# URL under which static (not modified by Python) files will be requested
# They will be served by Nginx directly, without being handled by uWSGI
ENV STATIC_URL /static
# Absolute path in where the static files wil be
ENV STATIC_PATH /app/static

# If STATIC_INDEX is 1, serve / with /static/index.html directly (or the static URL configured)
# ENV STATIC_INDEX 1
ENV STATIC_INDEX 0

# Add demo app
COPY ./app /app
WORKDIR /app

# Make /app/* available to be imported by Python globally to better support several use cases like Alembic migrations.
ENV PYTHONPATH=/app

# Move the base entrypoint to reuse it
RUN mv /entrypoint.sh /uwsgi-nginx-entrypoint.sh
# Copy the entrypoint that will generate Nginx additional configs
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# Run the start script provided by the parent image tiangolo/uwsgi-nginx.
# It will check for an /app/prestart.sh script (e.g. for migrations)
# And then will start Supervisor, which in turn will start Nginx and uWSGI
CMD ["/start.sh"]
