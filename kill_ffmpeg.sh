#!/bin/bash

# Ruta del archivo de log
LOG_FILE="/WebApp/output/archivo.log"

# Función para comprobar y terminar el proceso ffmpeg
check_and_kill_ffmpeg() {
  # Verificar si el proceso ffmpeg está en ejecución
  if pgrep -x "ffmpeg" >/dev/null; then
    # Obtener el estado del proceso ffmpeg
    status=$(ps -o stat= -p $(pgrep -x "ffmpeg"))
    if [[ "$status" == "Z" || "$status" == "T" ]]; then
      echo "$(date): Proceso ffmpeg encontrado en estado $status. Matando el proceso." >> "$LOG_FILE"
      pkill -9 ffmpeg
    fi
  fi
}

# Llamar a la función para verificar y matar el proceso ffmpeg
check_and_kill_ffmpeg

# # Agregar la tarea cron para ejecutar el script cada 15 minutos
# (crontab -l 2>/dev/null; echo "*/15 * * * * kill_ffmpeg.sh") | crontab -