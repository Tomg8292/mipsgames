from PIL import Image # pip install pillow
import os

# --- CONFIGURACIÓN ---
carpeta_entrada = "png"     # carpeta con imágenes de entrada
carpeta_salida = "sprites"  # carpeta para archivos asm generados

# --- PROCESO ---
# Crear carpetas si no existen
os.makedirs(carpeta_entrada, exist_ok=True)
os.makedirs(carpeta_salida, exist_ok=True)

# Procesar cada archivo .png en la carpeta de entrada
for archivo in os.listdir(carpeta_entrada):
    if archivo.lower().endswith(".png"):
        entrada = os.path.join(carpeta_entrada, archivo)
        base = os.path.splitext(archivo)[0]
        salida = os.path.join(carpeta_salida, base + ".asm")
        etiqueta = base + "_data"

        img = Image.open(entrada).convert("RGB")
        ancho, alto = img.size
        pixeles = img.load()

        with open(salida, "w") as f:
            f.write(f".data\n{etiqueta}:\n")

            for y in range(alto):
                linea = []
                for x in range(ancho):
                    r, g, b = pixeles[x, y]

                    # Conversión RGB888 → RGB565
                    r5 = (r >> 3) & 0x1F
                    g6 = (g >> 2) & 0x3F
                    b5 = (b >> 3) & 0x1F
                    rgb565 = (r5 << 11) | (g6 << 5) | b5

                    linea.append(f"0x{rgb565:04X}")

                # Escribir fila como .word
                f.write("    .word " + ", ".join(linea) + "\n")

        print(f"✅ Archivo '{salida}' generado correctamente para '{archivo}'.")
        print(f"Dimensiones: {ancho}x{alto} píxeles (RGB565)")

print("✅ Procesamiento completado para todos los archivos .png.")
