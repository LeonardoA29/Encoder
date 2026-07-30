import serial
import time
import re
import matplotlib.pyplot as plt
from collections import deque

# ============================================================
# CONFIGURACIÓN
# ============================================================

PUERTO = "/dev/ttyUSB1"
BAUDIOS = 115200
MAX_PUNTOS = 300

SerialPort = serial.Serial(PUERTO, BAUDIOS, timeout=1)
time.sleep(2)

# Expresiones regulares
patron_angulo = re.compile(r'^Angulo:\s*(-?\d+(?:\.\d+)?)$')
patron_velocidad = re.compile(r'^Velocidad:\s*(-?\d+(?:\.\d+)?)$')

# Buffers circulares
muestras = deque(maxlen=MAX_PUNTOS)
angulos = deque(maxlen=MAX_PUNTOS)
velocidades = deque(maxlen=MAX_PUNTOS)

contador = 0
angulo_actual = None

# ============================================================
# CONFIGURACIÓN DE LA GRÁFICA
# ============================================================

plt.ion()

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 7), sharex=True)

linea_angulo, = ax1.plot([], [], linewidth=2)
linea_velocidad, = ax2.plot([], [], linewidth=2)

ax1.set_title("Ángulo")
ax1.set_ylabel("Ángulo (°)")
ax1.grid(True)

ax2.set_title("Velocidad")
ax2.set_xlabel("Número de muestra")
ax2.set_ylabel("Velocidad")
ax2.grid(True)

fig.tight_layout()

print("Esperando datos...")

# ============================================================
# ADQUISICIÓN
# ============================================================

try:

    while True:

        linea = SerialPort.readline().decode(
            "utf-8",
            errors="ignore"
        ).strip()

        if not linea:
            continue

        # Buscar línea de ángulo
        m = patron_angulo.match(linea)

        if m:
            angulo_actual = float(m.group(1))
            continue

        # Buscar línea de velocidad
        m = patron_velocidad.match(linea)

        if m and angulo_actual is not None:

            velocidad = float(m.group(1))

            contador += 1

            muestras.append(contador)
            angulos.append(angulo_actual)
            velocidades.append(velocidad)

            print(
                f"Muestra {contador:5d} | "
                f"Ángulo = {angulo_actual:8.3f} | "
                f"Velocidad = {velocidad:8.3f}"
            )

            # Actualizar gráfica
            linea_angulo.set_data(muestras, angulos)
            linea_velocidad.set_data(muestras, velocidades)

            ax1.relim()
            ax1.autoscale_view()

            ax2.relim()
            ax2.autoscale_view()

            plt.pause(0.001)

            angulo_actual = None

except KeyboardInterrupt:
    print("\nAdquisición finalizada.")

finally:
    SerialPort.close()
    plt.ioff()
    plt.show()