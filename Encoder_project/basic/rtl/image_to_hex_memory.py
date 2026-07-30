from PIL import Image
import numpy as np
import sys

def color_a_codigo(pixel):
    """
    Convierte un píxel RGB a su código binario de 2 bits.
    Negro: 00, Amarillo: 10, Blanco: 01, Rojo: 11
    """
    r, g, b = pixel
    
    # Negro (0, 0, 0)
    if r == 0 and g == 0 and b == 0:
        return '00'
    # Rojo (255, 0, 0)
    elif r == 255 and g == 0 and b == 0:
        return '11'
    # Blanco (255, 255, 255)
    elif r == 255 and g == 255 and b == 255:
        return '01'
    # Amarillo (255, 255, 0)
    elif r == 255 and g == 255 and b == 0:
        return '10'
    else:
        # Por si acaso hay algún color inesperado, buscar el más cercano
        colores = {
            '00': np.array([0, 0, 0]),      # Negro
            '11': np.array([255, 0, 0]),    # Rojo
            '01': np.array([255, 255, 255]), # Blanco
            '10': np.array([255, 255, 0])   # Amarillo
        }
        
        pixel_array = np.array([r, g, b])
        distancias = {}
        for codigo, color in colores.items():
            distancia = np.sqrt(np.sum((pixel_array - color) ** 2))
            distancias[codigo] = distancia
        
        return min(distancias, key=distancias.get)

def imagen_a_hex(ruta_imagen, ruta_salida):
    """
    Convierte una imagen de 128x250 a un archivo init_dpram.hex
    para memoria de 4096 celdas de 16 bits.
    Incluye comandos de configuración al inicio y al final.
    """
    try:
        # Comandos de configuración iniciales (direcciones 0-43)
        comandos_inicio = [
            '4D00', '7801', '0000', '0F01', '2901', '0100', '0701', '0001',
            '0300', '1001', '5401', '4401', '0600', '0501', '0001', '3F01',
            '0A01', '2501', '1201', '1A01', '5000', '3701', '6000', '0201',
            '0201', '6100', '0001', '8001', '0001', 'FA01', 'E700', '1C01',
            'E300', '2201', 'B400', 'D001', 'B500', '0301', 'E900', '0101',
            '3000', '0801', '0400', '1000'
        ]
        
        # Comandos finales (después de la imagen)
        comandos_finales = [
            '1100', '8001', '1200', '0001'
        ]
        
        # Abrir y verificar la imagen
        imagen = Image.open(ruta_imagen)
        ancho, alto = imagen.size
        
        print(f"Imagen: {ancho}x{alto} píxeles")
        
        if ancho != 128 or alto != 250:
            print(f"⚠ Advertencia: La imagen debería ser 128x250 píxeles")
            print(f"   Se procesará de todas formas como {ancho}x{alto}")
        
        # Convertir a RGB si no lo está
        if imagen.mode != 'RGB':
            imagen = imagen.convert('RGB')
        
        # Convertir a array numpy
        array_imagen = np.array(imagen)
        
        # Procesar píxeles de izquierda a derecha, arriba a abajo
        bits_totales = []
        total_pixeles = alto * ancho
        
        print(f"Procesando {total_pixeles} píxeles...")
        
        for y in range(alto):
            for x in range(ancho):
                pixel = array_imagen[y, x]
                codigo = color_a_codigo(pixel)
                bits_totales.append(codigo)
        
        # Agrupar en palabras de 16 bits (8 píxeles por palabra)
        palabras_imagen = []
        for i in range(0, len(bits_totales), 8):
            # Tomar 8 píxeles (2 bits cada uno = 16 bits total)
            grupo = bits_totales[i:i+8]
            
            # Si no hay suficientes píxeles, rellenar con 00 (negro)
            while len(grupo) < 8:
                grupo.append('00')
            
            # Unir los 8 códigos de 2 bits para formar 16 bits
            palabra_binaria = ''.join(grupo)
            
            # Convertir de binario a hexadecimal (4 dígitos)
            palabra_hex = format(int(palabra_binaria, 2), '04X')
            palabras_imagen.append(palabra_hex)
        
        # Construir memoria completa
        memoria = []
        
        # 1. Agregar comandos de inicio (direcciones 0-43)
        memoria.extend(comandos_inicio)
        print(f"Comandos de configuración inicial: {len(comandos_inicio)} celdas (0-43)")
        
        # 2. Agregar datos de imagen (direcciones 44-4047)
        # 128x250 = 32000 píxeles / 8 píxeles por celda = 4000 celdas
        memoria.extend(palabras_imagen[:4000])
        print(f"Datos de imagen: {len(palabras_imagen[:4000])} celdas (44-4043)")
        
        # 3. Agregar comandos finales
        memoria.extend(comandos_finales)
        print(f"Comandos finales: {len(comandos_finales)} celdas (4044-4047)")
        
        # 4. Rellenar el resto con FFFF hasta completar 4096 celdas
        while len(memoria) < 4096:
            memoria.append('FFFF')
        
        print(f"Relleno con FFFF: {4096 - 4048} celdas (4048-4095)")
        
        # Verificar que sea exactamente 4096
        if len(memoria) != 4096:
            print(f"⚠ Error: Memoria tiene {len(memoria)} celdas en lugar de 4096")
            return
        
        # Escribir archivo hexadecimal
        with open(ruta_salida, 'w') as f:
            for palabra in memoria:
                f.write(palabra + '\n')
        
        print(f"\n✓ Archivo generado exitosamente: {ruta_salida}")
        print(f"  - Total de celdas: 4096")
        print(f"  - Estructura:")
        print(f"    · 0-43:    Comandos de configuración inicial (44 celdas)")
        print(f"    · 44-4043: Datos de imagen (4000 celdas)")
        print(f"    · 4044-4047: Comandos finales (4 celdas)")
        print(f"    · 4048-4095: Relleno FFFF (48 celdas)")
        
        # Estadísticas de colores
        contador = {'00': 0, '01': 0, '10': 0, '11': 0}
        for bit in bits_totales[:total_pixeles]:
            contador[bit] += 1
        
        print(f"\nEstadísticas de colores en la imagen:")
        print(f"  Negro (00):    {contador['00']:5d} píxeles")
        print(f"  Blanco (01):   {contador['01']:5d} píxeles")
        print(f"  Amarillo (10): {contador['10']:5d} píxeles")
        print(f"  Rojo (11):     {contador['11']:5d} píxeles")
        
    except FileNotFoundError:
        print(f"Error: No se encontró el archivo '{ruta_imagen}'")
        sys.exit(1)
    except Exception as e:
        print(f"Error al procesar la imagen: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python imagen_a_hex.py <imagen_entrada> [archivo_salida]")
        print("Ejemplo: python imagen_a_hex.py imagen_128x250.png")
        print("Ejemplo: python imagen_a_hex.py imagen_128x250.png init_dpram.hex")
        sys.exit(1)
    
    archivo_entrada = sys.argv[1]
    
    # Si no se especifica salida, usar "init_dpram.hex" por defecto
    if len(sys.argv) >= 3:
        archivo_salida = sys.argv[2]
    else:
        archivo_salida = "init_dpram.hex"
    
    print("=== Conversor de Imagen a Memoria HEX ===\n")
    imagen_a_hex(archivo_entrada, archivo_salida)
