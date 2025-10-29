# Juego de Plataformas Inspirado en Mario
## Descripción
Este proyecto es un juego de plataformas 2D desarrollado en Assembler MIPS para el simulador MARS 4.5 temporalmente, y el cual luego será ejecutado en un entorno virtual. Inspirado en el clásico Mario Bros, el jugador controla un personaje que navega por un mundo, recolectando monedas, evitando enemigos y saltando sobre plataformas. Es una demostración de desarrollo de videojuegos en un entorno de programación de bajo nivel.


## Características
Mecánicas del Jugador: Actualmente controla un cuadrado rojo (Mario), el cual luego será reemplazado por los respectivos sprites, usando W/espacio (saltar), A/D (izquierda/derecha) y Q (salir). El jugador comienza con 3 vidas, recolecta monedas (10 puntos cada una) y elimina enemigos saltando sobre ellos (50 puntos).


## Diseño del Nivel 
Incluye:
- Un suelo verde.
- Dos plataformas flotantes verdes.
- Dos monedas amarillas.
- Dos enemigo marrones (Goombas) que se mueven horizontalmente.


### Físicas y Colisiones
Gravedad, colisiones con plataformas y detección precisa para monedas y enemigos.
Interfaz: Muestra puntos y vidas en la consola (ej., "Puntos: 0 | Vidas: 3").
Condiciones de Victoria/Derrota: Gana recolectando todas las monedas, pierde si se queda sin vidas.


## Instalación y Ejecución
Instalar MARS 4.5: Descarga desde https://dpetersanderson.github.io/download.html.
Cargar Código: Abre mario.asm en MARS.

Configurar Pantalla:
Herramientas > Bitmap Display
Ancho/Alto de Unidad: 8 píxeles
Ancho/Alto de Pantalla: 512 píxeles
Dirección Base: 0x10040000 (heap)

Conectar Entrada: Herramientas > Keyboard and Display MMIO Simulator > Conectar a MIPS.
Ejecutar: Ensambla y ejecuta. Usa W/espacio para saltar, A/D para mover, Q para salir.


## Controles
W o Espacio: Saltar (solo en suelo o plataformas).
A o a: Mover a la izquierda.
D o d: Mover a la derecha.
Q o q: Salir del juego.

## Notas
Diseñado para fines académicos, demostrando programación en MIPS y gráficos en tiempo real. Si la pantalla parpadea, verifica la configuración de Bitmap Display y la conexión del MMIO Simulator.
