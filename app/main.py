from flask import Flask, request
import time
import psutil

import streamlink
import ffmpeg
import os
import signal
import datetime

app = Flask(__name__)

def bucle_segundo_plano():
    # Bucle que se ejecutará en segundo plano
    for i in range(120):
        print(f"Segundos restantes: {120-i}")
        time.sleep(1)

@app.route("/hola")
def hola():
    return "Hola mundo!"

# http://localhost:5000/execute
@app.route("/grabarcanal", methods=['GET'])
def grabarcanal():
    # # Crear un proceso para ejecutar la función en segundo plano
    # p = multiprocessing.Process(target=bucle_segundo_plano)
    # # Iniciar el proceso
    # p.start()

    # proceso_id = p.pid

    # print(f"El ID del proceso es: {proceso_id}")

    # return str(proceso_id)
    
    # Configurar el objeto ffmpeg para grabar el audio de la transmisión
    try:
        canal_twitch = request.args.get('canal_id')
        # Nombre del canal que deseas comprobar
        # canal_twitch = "viviendoenlacalle"
        # Calidad de la transmisión que deseas grabar
        calidad = "audio_only"
        # Duración de la grabación en segundos
        duracion = 9000 # PONEMOS COMO TOPE 2 HORAS DE GRABACIÓN DEL STREAM
        # Crear objeto de streamlink
        streams = streamlink.streams("https://www.twitch.tv/" + canal_twitch)
        # Obtener la URL de la transmisión
        stream_url = streams[calidad].url

        # # Crear objeto ffmpeg para guardar la transmisión
        stream = ffmpeg.input(stream_url, t=duracion) #, t=duracion

        # Establecer formato y códec de salida
        audio_quality = "320k"

        fecha_actual = datetime.datetime.now()
        fecha_formateada = fecha_actual.strftime("%d-%m-%Y")
            # Crear objeto ffmpeg para archivo de salida
        output_file = "./output/{}_{}.mp3".format(canal_twitch,fecha_formateada)
        if os.path.isfile(output_file):
            os.remove(output_file)

        process = ffmpeg.output(stream, output_file, acodec="libmp3lame", audio_bitrate=audio_quality).run_async(pipe_stdin=True)
    
    except Exception as  e:

        print(e.args[1])
        return "No se pudo iniciar la grabación de audio."
    
    return f"Grabando audio de {canal_twitch}... - PID: {str(process.pid)}"

# http://localhost:5000/cancelar?proceso_id=400428
@app.route('/cancelar', methods=['GET'])
def cancelar():
    # Obtener el PID del proceso a cancelar desde el cuerpo de la solicitud POST
    proceso_id = request.args.get('proceso_id')

    if proceso_id is None:
        return "El PID del proceso a cancelar no se especificó en la solicitud", 400
    # Intentar cancelar el proceso usando el PID especificado
    try:
        proceso = psutil.Process(int(proceso_id))
        proceso.send_signal(signal.SIGINT)
        proceso.wait()
        print("El proceso de grabación del streaming ha sido deteneido.")
        return f"El proceso con PID {proceso_id} ha sido cancelado"
    except Exception as e:
        return f"Error al cancelar el proceso con PID {proceso_id}: {e}", 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True, port=80)