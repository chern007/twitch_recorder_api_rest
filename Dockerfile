# docker build -t twitch_recorder_image .
# docker run -d --name twitch_recorder -p 8080:8000 --restart unless-stopped -v $(pwd)/WebApp:/WebApp twitch_recorder_image

# docker run -d --name twitch_recorder -p 8080:8000 --restart unless-stopped -v /media/pi/80f2bf0f-25c4-47e7-8a27-3d19ef6b397e/00.\ TORRENTS:/WebApp/output twitch_recorder_image

# Para copiar los archivos desde el servidor linux:
# scp pi@192.168.1.171:"/media/pi/80f2bf0f-25c4-47e7-8a27-3d19ef6b397e/00.' 'TORRENTS/viviendoenlacalle_30-03-2023.mp3" .

FROM python:3.10
LABEL maintainer="Carlos Hernández Crespo"

# Se instala uWSGI y todas las librerias que necesita la aplicacion
COPY WebApp/requirements.txt requirements.txt

# Instalamos el programa ffmpeg
RUN apt-get update && apt-get install -y ffmpeg

RUN pip install uwsgi && pip install -r requirements.txt

# Puerto HTTP por defecto para uWSGI
ARG UWSGI_HTTP_PORT=8000
ENV UWSGI_HTTP_PORT=$UWSGI_HTTP_PORT

# Aplicacion por defecto para uWSGI
ARG UWSGI_APP=webapp
ENV UWSGI_APP=$UWSGI_APP

# Se crea un usuario para arrancar uWSGI
RUN useradd -ms /bin/bash admin
USER admin

# Se copia el contenido de la aplicacion
COPY WebApp /WebApp

# Se copia el fichero con la configuración de uWSGI
COPY uwsgi.ini uwsgi.ini

# Se establece el directorio de trabajo
WORKDIR /WebApp

# Se crea un volumen con el contenido de la aplicacion
VOLUME /WebApp

# Se inicia uWSGI
ENTRYPOINT ["uwsgi", "--ini", "/uwsgi.ini"]
