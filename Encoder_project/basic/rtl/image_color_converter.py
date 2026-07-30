from PIL import Image
import numpy as np
import sys
import os

def color_mas_cercano(pixel):
    """
    Encuentra el color más cercano entre negro, rojo, blanco y amarillo.
    """
    # Definir los 4 colores disponibles (RGB)
    colores = {
        'negro': np.array([0, 0, 0]),
        'rojo': np.array([255, 0, 0]),
        'blanco': np.array([255, 255, 255]),
        'amarillo': np.array([255, 255, 0])
    }
    
    # Calcular la distancia euclidiana a cada color
    distancias = {}
    for nombre, color in colores.items():
        distancia = np.sqrt(np.sum((pixel - color) ** 2))
        distancias[nombre] = distancia
    
    # Encontrar el color con menor distancia
    color_cercano = min(distancias, key=distancias.get)
    return colores[color_cercano]

def convertir_imagen(ruta_entrada, ruta_salida):
    """
    Convierte una imagen a 128x250 píxeles con solo 4 colores.
    
    Args:
        ruta_entrada: Ruta de la imagen original
        ruta_salida: Ruta donde se guardará la imagen convertida
    """
    try:
        # Abrir la imagen
        imagen = Image.open(ruta_entrada)
        ancho_original, alto_original = imagen.size
        print(f"Imagen original: {ancho_original}x{alto_original} píxeles")
        
        # Rotar 90° si la imagen es más ancha que alta
        if ancho_original > alto_original:
            imagen = imagen.rotate(90, expand=True)
            print("↻ Imagen rotada 90° (era más ancha que alta)")
            print(f"Tamaño después de rotar: {imagen.size[0]}x{imagen.size[1]} píxeles")
        
        # Redimensionar a 128x250 píxeles
        imagen_redimensionada = imagen.resize((128, 250), Image.Resampling.LANCZOS)
        
        # Convertir a RGB si no lo está
        if imagen_redimensionada.mode != 'RGB':
            imagen_redimensionada = imagen_redimensionada.convert('RGB')
        
        # Convertir a array numpy
        array_imagen = np.array(imagen_redimensionada)
        
        # Crear nueva imagen con colores convertidos
        alto, ancho, _ = array_imagen.shape
        imagen_nueva = np.zeros((alto, ancho, 3), dtype=np.uint8)
        
        print("Procesando píxeles...")
        for i in range(alto):
            for j in range(ancho):
                pixel_original = array_imagen[i, j]
                imagen_nueva[i, j] = color_mas_cercano(pixel_original)
            
            # Mostrar progreso cada 50 filas
            if (i + 1) % 50 == 0:
                print(f"Procesadas {i + 1}/{alto} filas")
        
        # Guardar la imagen
        imagen_final = Image.fromarray(imagen_nueva)
        imagen_final.save(ruta_salida)
        print(f"\n✓ Imagen guardada exitosamente en: {ruta_salida}")
        print(f"Tamaño final: 128x250 píxeles con 4 colores")
        
    except FileNotFoundError:
        print(f"Error: No se encontró el archivo '{ruta_entrada}'")
    except Exception as e:
        print(f"Error al procesar la imagen: {str(e)}")

# Ejemplo de uso
if __name__ == "__main__":
    # Verificar argumentos
    if len(sys.argv) < 2:
        print("Uso: python convertir_imagen.py <imagen_entrada> [imagen_salida]")
        print("Ejemplo: python convertir_imagen.py foto.jpg")
        print("Ejemplo: python convertir_imagen.py foto.jpg foto_128x250.png")
        sys.exit(1)
    
    archivo_entrada = sys.argv[1]
    
    # Si no se especifica salida, generarla automáticamente
    if len(sys.argv) >= 3:
        archivo_salida = sys.argv[2]
    else:
        # Generar nombre automático: nombre_128x250.png
        nombre_base = os.path.splitext(archivo_entrada)[0]
        archivo_salida = f"{nombre_base}_128x250.png"
    
    print("=== Conversor de Imágenes a 4 Colores ===\n")
    convertir_imagen(archivo_entrada, archivo_salida)
