# MARIO - RUBIN, BERARDO, BYRNE, CAFFARATTI, RUBERTO

## Descripción
Este proyecto es un juego de plataformas 2D desarrollado en Assembler MIPS para el simulador MARS 4.5, y el cual luego será ejecutado en un entorno virtual. Inspirado en el clásico Mario Bros, el jugador controla un personaje que navega por un mundo, recolectando monedas, evitando enemigos y saltando sobre plataformas. Es una demostración de desarrollo de videojuegos en un entorno de programación de bajo nivel.


# MIPS Super Mario — mipsgames

Proyecto de ejemplo: un micro-juego tipo "Super Mario" escrito en ensamblador MIPS con desplazamiento horizontal (scrolling) y renderizado por píxeles en una pantalla bitmap.

Este README describe cómo funciona el proyecto y cómo ejecutarlo en el simulador MARS (u otro emulador MIPS compatible con Bitmap Display y Keyboard MMIO).

## Resumen del proyecto

- Archivo principal: Juego Final/marioAssembler.asm.
- Objetivo: demostrar físicas simples (gravedad, salto, fricción), detección de colisiones (plataformas, tubos, enemigos, monedas), desplazamiento de cámara y renderizado en un framebuffer en memoria.
- Escala: unidad 4x4 píxeles.

## Requisitos

- MARS (MIPS Assembler and Runtime Simulator) o un emulador similar que ofrezca:
	- Bitmap Display (para ver el framebuffer en memoria)
	- Keyboard MMIO (para leer teclas desde direcciones MMIO)
- Espacio en disco y permisos de lectura/escritura en la carpeta del proyecto.

## Conceptos importantes y constantes

- framebuffer: buffer reservado en el segmento de datos (base por defecto en MARS: 0x10080000 si usas "gp") — se usa para almacenar la imagen (512×256 píxeles, 32-bit color).
- Resolución interna usada por este archivo: 512×256 píxeles.
- Posición inicial del jugador:
	- mario_x = 40
	- mario_y = 200
- Posición de la meta (castillo): CASTLE_X = 2256 — cuando mario_x >= CASTLE_X el juego considera victoria.
- Rango del mundo: WORLD_WIDTH (2400 en el archivo) — cámara se limita para no salir de los bordes.

## Cómo ejecutar (MARS)

1. Abrir Juego Final/marioAssembler.asm en MARS.
2. Asegúrate de que el panel de Bitmap Display está configurado así (Tools -> Bitmap Display):
	 - Unit Width in Pixels: 1
	 - Unit Height in Pixels: 1
	 - Display Width in Pixels: 512
	 - Display Height in Pixels: 256
	 - Base address for display: 0x10080000 (dirección base del framebuffer en segmento de datos gp).
3. Tools -> Keyboard MMIO -> Connect to MIPS (habilita lectura de teclado en 0xffff0000).
4. Assemble el programa (Assemble), luego Run.
5. Verás un texto de inicio en la consola. Presiona SPACE para empezar.

Nota: si usas otro emulador, debes asegurarte de mapear la pantalla y el teclado a las mismas direcciones (bitmap base y MMIO en 0xffff0000).

## Controles

- Movimiento izquierda: A / a (ASCII 0x61 o 0x41) — manejo en process_input.
- Movimiento derecha: D / d (ASCII 0x64 o 0x44).
- Saltar: W / w o SPACE (ASCII 0x77, 0x57, 0x20).
- Salir: ESC (ASCII 0x1B).
- Al terminar una partida, SPACE reinicia el juego.

## Estructura del código (principales rutinas)

- main — inicialización; muestra pantalla inicial; espera SPACE y entra en game_loop.
- init_game_state — inicializa variables del juego (posición de Mario, vidas, cámara, reinicia enemigos y monedas). Se ejecuta al iniciar y al reiniciar.
- game_loop — bucle principal. Comprueba vidas, condición de victoria (mario_x >= CASTLE_X), procesa entrada, actualiza física, cámaras, enemigos, colisiones, dibuja el frame y hace un pequeño delay.
- process_input — lee 0xffff0000 para detectar tecla actualmente presionada y ajustar mario_vx y mario_vy (saltos) o salir con ESC.
- update_mario_physics — aplica gravedad, limita velocidad, actualiza posición, chequea colisiones con suelo/plataformas/tubos.
- update_camera — mueve camera_x para mantener a Mario centrado (con límites que impiden que la cámara salga del mundo).
- update_goombas — lógica de movimiento y reversión de goombas (enemigos) y evitar tuberías.
- check_goomba_collisions, check_coin_collisions, check_pipe_collisions, check_platform_collisions — detectan y reaccionan a colisiones.
- render_frame — orquesta el dibujo de fondo, plataformas, tubos, castillo, bandera, monedas, Mario y Goombas.
- draw_pixel, fill_rect — primitivas de dibujo que escriben en framebuffer.
- show_start_screen, show_win_screen_visual, show_game_over_screen_visual — renders especiales que rellenan el framebuffer con mensajes grandes.

## Datos y tablas en .data

- platforms — lista de plataformas (x, y, width, height). Terminada con -1, -1, -1, -1.
- ground_segments — segmentos del suelo (x_start, x_end). Usado por is_on_ground_segment para decidir si Mario está sobre suelo.
- pipes — tubos con (x, y, width, height).
- goombas — tabla de enemigos: (x, aliveFlag, direction, patrol_left, patrol_right).
- coins_data — lista de monedas (x, y, collectedFlag).

Estas tablas se inicializan en init_game_state (las flags de enemigos y monedas son puestas a su estado inicial).

## Por qué antes se mostraba "YOU WIN" inmediatamente (diagnóstico y solución aplicada)

Sintetizo la causa por la que el juego antes saltaba directo a victoria:
- Originalmente el código de dibujo escribía directamente en una dirección constante 0x10008000. Esa dirección coincidía con la región de datos estáticos del ensamblador y sobrescribía variables (como mario_x), escribiendo ahí valores de color. Si mario_x se machacaba con un color (por ejemplo 0x5C94FC), al leer mario_x el valor era grande (≈ 6 dígitos hex) y la comprobación mario_x >= CASTLE_X era verdadera.
- Solución aplicada: he reservado un framebuffer en .data y modifiqué las rutinas de dibujo para usar la $t0, framebuffer (es decir, escribir en la zona de framebuffer dedicada) en lugar de una dirección hardcodeada. En MARS la dirección base de ese buffer suele ser 0x10080000 cuando usas "gp".

Si ves todavía la pantalla celeste y el juego no renderiza los objetos tras el cambio, comprueba que el Base address for display en el panel Bitmap Display esté apuntando a la dirección donde MARS cargó el segmento de datos (usualmente 0x10080000).

## Cambios recientes importantes (resumen)

- Se añadió init_game_state y se usa para inicializar/reinicializar variables del juego (posiciones, flags de enemigos y monedas, cámara, vidas, etc.).
- Se agregó framebuffer en .data y las rutinas de dibujo ahora escriben ahí.
- Se eliminó/limpió el debug printf una vez terminado el diagnóstico.

## Problemas frecuentes y cómo resolverlos

- Pantalla solo celeste y/o "YOU WIN" inmediato:
	- Comprueba que Bitmap Display -> Base address for display apunte a 0x10080000 (o la dirección donde tu emulador carga el segmento .data).
	- Verifica que framebuffer exista (búsqueda en la tabla de símbolos o en el Data Segment en MARS) y apunta a la dirección indicada en el Bitmap Display.
- Caracteres raros en consola tras usar syscall print:
	- El ensamblador imprime enteros y bytes según lo que se pasa en $v0 / $a0. Si ves bytes no legibles, probablemente se imprimió un valor numérico grande como color en lugar de la posición esperada.
- Si la cámara no centrada o Mario aparece fuera de pantalla:
	- Comprueba camera_x y el cálculo en update_camera. Asegúrate de no haber modificado WORLD_WIDTH, MARIO_WIDTH o la constante 320 que define la zona central.

## Cómo depurar localmente

- Usa puntos de inspección (MARS permite Breakpoints y ver valores en el panel de Registros y Data Segment). Revisa mario_x, camera_x, CASTLE_X, framebuffer.
- Para pruebas rápidas, en main puedes comentar la comprobación de victoria (bge $t0, $t1, game_win) y así confirmar si el renderizado y física están funcionando sin saltar a la pantalla de victoria.
