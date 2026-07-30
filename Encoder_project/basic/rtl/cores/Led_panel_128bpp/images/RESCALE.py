import sys
import os
from PIL import Image

# --- CONSTANTES ---
ANCHO = 128
ALTO = 64
N_PLANOS_BITS = 4 # P0, P1, P2, P3 (para PWM, logrando 16 niveles de brillo)

# Nombres de los archivos de salida basados en R/G/B y Scan 0/1 (Upper/Lower)
NOMBRE_ARCHIVOS = {
    'R0': "images/imageR0.hex",
    'R1': "images/imageR1.hex",
    'G0': "images/imageG0.hex",
    'G1': "images/imageG1.hex",
    'B0': "images/imageB0.hex",
    'B1': "images/imageB1.hex",
}

def get_bit(valor_8bit, plano_idx):
    """
    Obtiene el bit correspondiente al plano de bits (idx) del valor de 8 bits.
    Utiliza los 4 bits más significativos (MSB) del valor 0-255.
    """
    # Escala el valor 0-255 a un rango de 0-15 (comprimiendo a los 4 MSBs)
    scaled_value = valor_8bit // 16 
    # Comprueba el k-ésimo bit (donde k es el plano_idx)
    return (scaled_value >> plano_idx) & 0b1

def generar_mapa_hex_separado(ruta_imagen):
    try:
        # Redimensionar la imagen a 128x64
        img = Image.open(ruta_imagen).resize((ANCHO, ALTO), Image.Resampling.LANCZOS).convert('RGB')
        pixel_data = list(img.getdata())
        
        # Diccionario para almacenar los bits de 6 canales organizados por Scan/Color/Plano
        # Estructura: data_buffers[Plano_idx][Canal_Scan] -> lista de bits
        data_buffers = {}
        
        # 1. PASO DE PROCESAMIENTO: Extraer y clasificar todos los bits
        # Iterar a través de los Planos de Bits (P0, P1, P2, P3)
        for plano_idx in range(N_PLANOS_BITS):
            print(f"Procesando Plano de Bits: {plano_idx}")
            
            # Inicializar el buffer para este plano
            data_buffers[plano_idx] = {key: [] for key in NOMBRE_ARCHIVOS}
            
            # Iterar sobre las 64 filas de la matriz
            for y in range(ALTO): # y va de 0 a 63
                
                # El FM6363 es 1/32, por lo que la fila 'y' debe ser mapeada a un Scan
                # Scan 0 (Upper): y = 0 a 31
                # Scan 1 (Lower): y = 32 a 63
                
                # Clasificamos el segmento de escaneo (Scan 0 o Scan 1)
                if y < ALTO // 2:
                    # Scan 0: Fila superior (y=0 a 31)
                    canal_r = 'R0'
                    canal_g = 'G0'
                    canal_b = 'B0'
                else:
                    # Scan 1: Fila inferior (y=32 a 63)
                    canal_r = 'R1'
                    canal_g = 'G1'
                    canal_b = 'B1'

                # Iterar sobre los 128 píxeles de ancho
                for x in range(ANCHO):
                    # Obtener los 8 bits RGB del píxel actual
                    r, g, b = pixel_data[y * ANCHO + x]

                    # Extraer el bit (0 o 1) y almacenarlo en el buffer de su canal/scan correspondiente
                    data_buffers[plano_idx][canal_r].append(get_bit(r, plano_idx))
                    data_buffers[plano_idx][canal_g].append(get_bit(g, plano_idx))
                    data_buffers[plano_idx][canal_b].append(get_bit(b, plano_idx))

        # 2. PASO DE EMPAQUETADO y ESCRITURA:
        
        # Iterar sobre los 6 canales (R0, R1, G0, ...)
        for canal_scan, ruta_salida in NOMBRE_ARCHIVOS.items():
            
            bits_totales_canal = []
            
            # El orden de la memoria es crucial: P0 (primero), P1, P2, P3
            # Los datos de P0 de las 64 filas (8192 bits), luego P1, P2, P3.
            for plano_idx in range(N_PLANOS_BITS):
                # La memoria debe almacenar todos los datos de P0, luego todos los de P1, etc.
                # Cada plano tiene 64 filas * 128 píxeles = 8192 bits.
                bits_totales_canal.extend(data_buffers[plano_idx][canal_scan])
            
            # 'bits_totales_canal' ahora contiene 8192 * 4 = 32768 bits.
            
            bytes_canal = []
            # Empaquetar la secuencia de 32768 bits en 4096 bytes
            for i in range(0, len(bits_totales_canal), 8):
                byte_bits = bits_totales_canal[i:i+8]
                # Convertir la lista de bits a un solo byte (MSB primero)
                byte_val = sum(bit << (7 - j) for j, bit in enumerate(byte_bits))
                bytes_canal.append(byte_val)
                
            # Escribir el archivo .HEX
            with open(ruta_salida, "w") as f:
                for byte_val in bytes_canal:
                    # Formato HEX de 2 caracteres por línea, seguido de salto de línea
                    f.write(f"{byte_val:02X}\n")

            # Verificación del tamaño
            if len(bytes_canal) == 4096:
                print(f"Éxito: {canal_scan} guardado en {ruta_salida}. Tamaño: {len(bytes_canal)} bytes (¡4096 líneas OK!).")
            else:
                print(f"¡ADVERTENCIA! Tamaño de {canal_scan} inesperado: {len(bytes_canal)} bytes.")


        print("\n¡Proceso finalizado! 6 archivos .hex generados.")

    except FileNotFoundError:
        print(f"Error: Archivo no encontrado en la ruta '{ruta_imagen}'")
        sys.exit(1)
    except Exception as e:
        print(f"Ocurrió un error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Uso: python script_nombre.py <ruta_a_imagen>")
        sys.exit(1)
    
    # Asegurarse de que el directorio 'images' exista
    if not os.path.exists("images"):
        os.makedirs("images")
        
    ruta_imagen = sys.argv[1]
    generar_mapa_hex_separado(ruta_imagen)