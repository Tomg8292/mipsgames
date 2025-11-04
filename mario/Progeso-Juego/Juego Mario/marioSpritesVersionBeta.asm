# Super Mario Bros - MIPS Assembly with SCROLLING (UNIT 4x4) - OPTIMIZADO
# BITMAP DISPLAY SETUP:
#    Tools -> Bitmap Display:
#    Unit Width: 4, Unit Height: 4
#    Display Width: 512, Display Height: 256
#    Base: 0x10008000 ($gp)
# KEYBOARD MMIO:
#    Tools -> Keyboard MMIO -> Connect to MIPS

.data
    # Screen dimensions (DOUBLED for 4x4 units)
    SCREEN_WIDTH: .word 128
    SCREEN_HEIGHT: .word 64 
    WORLD_WIDTH: .word 1100
   
    # Colors
    COLOR_SKY: .word 0x5C94FC
    COLOR_GROUND: .word 0x8B4513
    COLOR_BRICK: .word 0xFF8800
    COLOR_MARIO_RED: .word 0xFF0000
    COLOR_MARIO_SKIN: .word 0xFFE4B5
    COLOR_GOOMBA: .word 0x8B4513
    COLOR_CLOUD: .word 0xFFFFFF
    COLOR_COIN: .word 0xFFD700
    COLOR_PIPE: .word 0x00AA00
    COLOR_PIPE_DARK: .word 0x008800
    COLOR_CASTLE: .word 0x808080
    COLOR_CASTLE_DARK: .word 0x404040
    COLOR_FLAG_POLE: .word 0x404040
    COLOR_FLAG: .word 0xFF0000
   
    # Camera
    camera_x: .word 0
   
    # Game state
    mario_x: .word 10
    mario_y: .word 50
    mario_vy: .word 0
    mario_vx: .word 0
    mario_on_ground: .word 1
    mario_lives: .word 3
    score: .word 0
    coins: .word 0
   
MARIO_WIDTH: .word 12
MARIO_HEIGHT: .word 12
   
    # Ground level (DOUBLED)
    GROUND_Y: .word 56
    GROUND_HEIGHT: .word 8
   
    # Physics
    GRAVITY: .word 1
    JUMP_VELOCITY: .word -9
    BOUNCE_VELOCITY: .word -8
    MAX_FALL_SPEED: .word 8
    ACCELERATION: .word 3
    MAX_SPEED: .word 5
    FRICTION: .word 1

platforms: .word
    # === ISLA 1: Inicio Simple (0-140) ===
    40, 30, 24, 8,      # Plataforma 1 COMPLETA (unida, sin hueco)
    90, 22, 16, 8,      # Plataforma 2 (más alta)
    
    # === ISLA 2: Salto de Confianza (180-260) ===
    190, 28, 12, 8,     # Plataforma pequeña izq
    220, 20, 12, 8,     # Plataforma central alta
    250, 28, 12, 8,     # Plataforma pequeña der
    
    # === ISLA 3: Tubería Gigante (300-400) - SIN PLATAFORMAS ===
    
    # === ISLA 4: Plataforma Flotante (440-540) ===
    460, 30, 60, 8,     # Plataforma larga COMPLETA (sin hueco)
    
    # === ISLA 5: Laberinto Bajo (580-680) ===
    590, 36, 16, 8,     
    620, 32, 16, 8,     
    650, 36, 16, 8,     
    
    # === ISLA 7: Carrera Final (840-940) ===
    860, 36, 18, 8,     
    900, 36, 18, 8,     
    
    -1, -1, -1, -1
ground_segments: .word
    0, 140,         # Isla 1: Inicio
    180, 260,       # Isla 2: Salto
    300, 400,       # Isla 3: Tubería
    440, 540,       # Isla 4: Flotante
    580, 680,       # Isla 5: Laberinto
    720, 800,       # Isla 6: Torre
    840, 940,       # Isla 7: Carrera
    980, 1100,      # Isla 8: Castillo
    -1, -1
    # Pipes (x, y, width, height) - DOUBLED
pipes: .word
    130, 48, 8, 8,      # Pipe 1 - Final Isla 1
    350, 32, 8, 24,     # Pipe 2 - GIGANTE Isla 3
    535, 48, 8, 8,      # Pipe 3 - Antes Isla 4
    790, 48, 8, 8,      # Pipe 4 - Final Isla 6
    # ELIMINADA pipe 5 del castillo (1070) para evitar superposición
    -1, -1, -1, -1
    # Goombas (x, alive, direction, patrol_left, patrol_right) - DOUBLED
goombas: .word
    # Isla 1
    60, 1, 1, 40, 100,

    
    # Isla 2
    200, 1, 1, 185, 255,

    
    # Isla 3
    315, 1, 1, 305, 340,
    370, 1, -1, 360, 395,
    
    # Isla 4 (sobre plataforma)
    480, 1, 1, 465, 515,
    500, 1, -1, 465, 515,
    
    # Isla 5
    605, 1, 1, 585, 640,
    655, 1, -1, 640, 675,
    
    # Isla 6
    740, 1, 1, 725, 775,
    
    # Isla 7 - MUCHOS enemigos
    855, 1, 1, 845, 895,
    875, 1, -1, 845, 895,
    915, 1, 1, 905, 935,
    
    # Isla 8 - Guardianes finales
    1000, 1, 1, 985, 1040,

    
    -1, -1, -1, -1, -1
        -1, -1, -1, -1, -1
   
    goomba_move_counter: .word 0
    goomba_move_delay: .word 2

    GOOMBA_WIDTH: .word 8
    GOOMBA_HEIGHT: .word 8
   
coins_data: .word
    # === ISLA 1: Tutorial (0-140) ===
    20, 48, 0,      # Ground
    40, 48, 0,      # Ground
    60, 48, 0,      # Ground
    80, 48, 0,      # Ground
    100, 48, 0,     # Ground
    120, 48, 0,     # Ground
    # Sobre plataforma 1 (y=30, moneda en 18)
    48, 18, 0,
    56, 18, 0,
    # Sobre plataforma 2 (y=22, moneda en 10)
    96, 10, 0,
    102, 10, 0,
    
    # === ISLA 2: Salto de Confianza (180-260) ===
    185, 48, 0,     # Ground
    205, 48, 0,     # Ground
    # Sobre plat izq (y=28, moneda en 16)
    194, 16, 0,
    # Sobre plat central (y=20, moneda en 8)
    224, 8, 0,
    # Sobre plat der (y=28, moneda en 16)
    254, 16, 0,
    
    # === ISLA 3: Tubería (300-400) ===
    305, 48, 0,     # Ground antes de pipe
    320, 48, 0,     # Ground
    380, 48, 0,     # Ground después de pipe
    390, 48, 0,     # Ground
    
    # === ISLA 4: Flotante (440-540) ===
    445, 48, 0,     # Ground inicio
    # Sobre plataforma larga (y=30, moneda en 18)
    468, 18, 0,
    478, 18, 0,
    488, 18, 0,
    498, 18, 0,
    508, 18, 0,
    518, 18, 0,
    
    # === ISLA 5: Laberinto (580-680) ===
    585, 48, 0,     # Ground
    # Sobre plataforma 1 (y=36, moneda en 24)
    596, 24, 0,
    # Sobre plataforma 2 (y=32, moneda en 20)
    626, 20, 0,
    # Sobre plataforma 3 (y=36, moneda en 24)
    656, 24, 0,
    675, 48, 0,     # Ground
    
    # === ISLA 6: Círculo de monedas en aire (720-800) ===
    745, 20, 0,     # Top
    740, 25, 0,     # Top-left
    735, 30, 0,     # Left
    740, 35, 0,     # Bottom-left
    745, 40, 0,     # Bottom
    755, 20, 0,     # Top-right
    760, 25, 0,
    765, 30, 0,     # Right
    760, 35, 0,
    755, 40, 0,     # Bottom-right
    750, 30, 0,     # Centro
    
    # === ISLA 7: Carrera (840-940) ===
    845, 48, 0,     # Ground
    # Sobre plataforma 1 (y=36, moneda en 24)
    868, 24, 0,
    # Sobre plataforma 2 (y=36, moneda en 24)
    908, 24, 0,
    930, 48, 0,     # Ground
    
    # === ISLA 8: Castillo (980-1100) ===
    985, 48, 0,     # Ground
    1005, 48, 0,    # Ground
    1025, 48, 0,    # Ground
    
    -1, -1, -1



    COIN_WIDTH: .word 4
    COIN_HEIGHT: .word 4
   
    # Pipe dimensions
    PIPE_WIDTH: .word 8
    PIPE_HEIGHT: .word 10
   
    # Castle position - DOUBLED
CASTLE_X: .word 1050
CASTLE_Y: .word 36
CASTLE_WIDTH: .word 24
CASTLE_HEIGHT: .word 20

FLAG_X: .word 1042
FLAG_POLE_HEIGHT: .word 30
   
    # Messages
    msg_start: .asciiz "\nSUPER MARIO SCROLLING (4x4) - Press ENTER to start\nCollect coins and avoid Goombas!\nReach the castle to win!\n"


# Reemplaza tu moneda_data con este sprite mejorado 8x8
.align 2
moneda_data:
    .word
    # Fila 0
    0x00000000, 0x00000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0x00000000, 0x00000000,
    # Fila 1
    0x00000000, 0xff000000, 0xffffff00, 0xffffff00, 0xffffff00, 0xffffff00, 0xff000000, 0x00000000,
    # Fila 2
    0xff000000, 0xffffff00, 0xffffffff, 0xffffd700, 0xffffd700, 0xffffff00, 0xffffff00, 0xff000000,
    # Fila 3
    0xff000000, 0xffffff00, 0xffffd700, 0xffffd700, 0xffffd700, 0xffffd700, 0xffffff00, 0xff000000,
    # Fila 4
    0xff000000, 0xffffff00, 0xffffd700, 0xffffd700, 0xffffd700, 0xffffd700, 0xffffff00, 0xff000000,
    # Fila 5
    0xff000000, 0xffffff00, 0xffffd700, 0xffffd700, 0xffffd700, 0xffaa8800, 0xffaa8800, 0xff000000,
    # Fila 6
    0x00000000, 0xff000000, 0xffffff00, 0xffaa8800, 0xffaa8800, 0xffaa8800, 0xff000000, 0x00000000,
    # Fila 7
    0x00000000, 0x00000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0x00000000, 0x00000000

# Sprite de bloque de suelo 8x8 (marrón con detalles)
.align 2
ground_tile_sprite:
    .word
    # Fila 0 - Borde superior
    0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000,
    # Fila 1
    0xff000000, 0xffaa5500, 0xffaa5500, 0xffaa5500, 0xffaa5500, 0xffaa5500, 0xffaa5500, 0xff000000,
    # Fila 2
    0xff000000, 0xffaa5500, 0xff885522, 0xff885522, 0xff885522, 0xff885522, 0xffaa5500, 0xff000000,
    # Fila 3
    0xff000000, 0xffaa5500, 0xff885522, 0xff000000, 0xff000000, 0xff885522, 0xffaa5500, 0xff000000,
    # Fila 4
    0xff000000, 0xffaa5500, 0xff885522, 0xff000000, 0xff000000, 0xff885522, 0xffaa5500, 0xff000000,
    # Fila 5
    0xff000000, 0xffaa5500, 0xff885522, 0xff885522, 0xff885522, 0xff885522, 0xffaa5500, 0xff000000,
    # Fila 6
    0xff000000, 0xffaa5500, 0xff664433, 0xff664433, 0xff664433, 0xff664433, 0xffaa5500, 0xff000000,
    # Fila 7 - Borde inferior
    0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000
    
# Sprite de bloque de ladrillo 4x4 (estilo Super Mario Bros)
# Sprite de bloque de ladrillo 8x8 (estilo Super Mario Bros mejorado)

# Versión alternativa con más detalle
.align 2
brick_tile_sprite:
    .word
    # Fila 0 - Borde
    0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000,
    # Fila 1 - Ladrillo con brillo y textura
    0xff000000, 0xffff9955, 0xffdd7744, 0xff000000, 0xffff9955, 0xffdd7744, 0xffdd7744, 0xff000000,
    # Fila 2 - Cuerpo con detalles
    0xff000000, 0xffdd7744, 0xffaa4422, 0xff000000, 0xffdd7744, 0xffaa4422, 0xffaa4422, 0xff000000,
    # Fila 3 - Línea de mortero
    0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000,
    # Fila 4 - Segunda fila (desplazada)
    0xff000000, 0xffff9955, 0xff000000, 0xffff9955, 0xffdd7744, 0xff000000, 0xffff9955, 0xff000000,
    # Fila 5 - Cuerpo segunda fila
    0xff000000, 0xffdd7744, 0xff000000, 0xffdd7744, 0xffaa4422, 0xff000000, 0xffdd7744, 0xff000000,
    # Fila 6 - Sombra
    0xff000000, 0xff884422, 0xff000000, 0xff884422, 0xff884422, 0xff000000, 0xff884422, 0xff000000,
    # Fila 7 - Borde
    0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000
    
    
# Sprite de nube 12x6 (simplificado)
.align 2
cloud_sprite:
    .word
    # Fila 0
    0x00000000, 0x00000000, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 1
    0x00000000, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 2
    0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0x00000000, 0x00000000,
    # Fila 3
    0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff,
    # Fila 4
    0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff,
    # Fila 5
    0x00000000, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff, 0x00000000, 0x00000000

# Sprite de pájaro 6x4 (muy simple)
.align 2
bird_sprite:
    .word
    # Fila 0
    0xff000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff000000,
    # Fila 1
    0xff000000, 0xff666666, 0x00000000, 0x00000000, 0xff666666, 0xff000000,
    # Fila 2
    0x00000000, 0xff666666, 0xff666666, 0xff666666, 0xff666666, 0x00000000,
    # Fila 3
    0x00000000, 0x00000000, 0xff000000, 0xff000000, 0x00000000, 0x00000000

# Posiciones de nubes en el mundo (x, y)
# Posiciones de nubes en el mundo (x, y) - Reposicionadas
# En la línea ~435, REEMPLAZAR clouds_data CON:
clouds_data: .word
    30, 2,      # Isla 1 - MUY alto
    120, 4,     # Isla 1 final
    200, 3,     # Isla 2
    330, 48,    # Isla 3 - ABAJO (no obstruye gameplay)
    480, 2,     # Isla 4
    620, 3,     # Isla 5
    750, 48,    # Isla 6 - ABAJO
    880, 4,     # Isla 7
    1020, 2,    # Isla 8
    -1, -1

# En la línea ~446, REEMPLAZAR birds_data CON:
birds_data: .word
    70, 8,      # Isla 1 - ARRIBA (y=8)
    165, 6,     # Gap 1?2 - MÁS ARRIBA
    280, 7,     # Gap 2?3
    420, 6,     # Gap 3?4
    560, 8,     # Gap 4?5
    700, 7,     # Gap 5?6
    820, 6,     # Gap 6?7
    960, 8,     # Gap 7?8
    -1, -1
# Sprite de pipe mejorado estilo SMB - 8 píxeles de ancho
# Diseño con labio superior prominente y cuerpo con textura

# AGREGAR DESPUÉS de bird_sprite y ANTES de .text:

# Sprite de pipe mejorado estilo SMB - 8 píxeles de ancho
.align 2
pipe_top_sprite:
    .word
    # Fila 0 - Borde superior del labio
    0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000,
    # Fila 1 - Labio exterior
    0xff000000, 0xff00dd00, 0xff00dd00, 0xff00dd00, 0xff00dd00, 0xff00dd00, 0xff00dd00, 0xff000000,
    # Fila 2 - Interior del labio
    0xff000000, 0xff008800, 0xff008800, 0xff004400, 0xff004400, 0xff008800, 0xff008800, 0xff000000

.align 2
pipe_body_sprite:
    .word
    # Fila 0
    0xff000000, 0xff00bb00, 0xff00bb00, 0xff006600, 0xff006600, 0xff00bb00, 0xff00bb00, 0xff000000,
    # Fila 1
    0xff000000, 0xff00dd00, 0xff00bb00, 0xff006600, 0xff006600, 0xff00bb00, 0xff009900, 0xff000000,
    # Fila 2
    0xff000000, 0xff00bb00, 0xff00bb00, 0xff006600, 0xff006600, 0xff00bb00, 0xff00bb00, 0xff000000,
    # Fila 3
    0xff000000, 0xff009900, 0xff00bb00, 0xff006600, 0xff006600, 0xff00bb00, 0xff009900, 0xff000000


# Agregar después de bird_sprite y antes de clouds_data:

# Sprite de Mario 8x12 - Frame 1 (parado/neutral)
# Sprite de Mario 8x12 - Frame 1 (PARADO - basado en pose1)
# Sprite de Mario 16x16 - Frame 1 (PARADO)
# Colores: Piel oscura (0xffaa7755), Remera azul/amarilla, Pelo negro
# Sprite de Mario 12x12 - Frame 1 (PARADO)
# Colores mejorados: Piel morena, Remera azul/amarilla vibrante, Pelo negro
# Sprite de Mario 12x12 - Frame 1 (PARADO - mirando derecha)
.align 2
mario_sprite_frame1:
	.word
	# Fila 1
0x00000000, 0x00000000, 0x00000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0x00000000, 0x00000000, 0x00000000
# Fila 2
0x00000000, 0x00000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFFDAA520, 0xFF000000, 0xFFDAA520, 0xFF000000, 0x00000000, 0x00000000, 0x00000000
# Fila 3
0x00000000, 0x00000000, 0xFF000000, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0x00000000, 0x00000000
# Fila 4
0x00000000, 0x00000000, 0xFF8B4513, 0xFF000000, 0xFFDAA520, 0xFF000000, 0xFFDAA520, 0xFF000000, 0xFF000000, 0x00000000, 0x00000000, 0x00000000
# Fila 5
0x00000000, 0x00000000, 0x00000000, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0x00000000, 0x00000000, 0x00000000, 0x00000000
# Fila 6
0x00000000, 0x00000000, 0x00000000, 0xFF0000FF, 0xFF0000FF, 0xFF0000FF, 0xFF0000FF, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000
# Fila 7
0x00000000, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0x00000000, 0x00000000, 0x00000000
# Fila 8
0xFF8B4513, 0xFF8B4513, 0xFF8B4513, 0xFF0000FF, 0xFF0000FF, 0xFF0000FF, 0xFF0000FF, 0xFF0000FF, 0xFF0000FF, 0xFF8B4513, 0x00000000, 0x00000000
# Fila 9
0xFF8B4513, 0xFF8B4513, 0xFF8B4513, 0xFF8B4513, 0xFF0000FF, 0xFF0000FF, 0xFF0000FF, 0xFF0000FF, 0xFF0000FF, 0xFF8B4513, 0xFF8B4513, 0x00000000
# Fila 10
0x00000000, 0xFF8B4513, 0xFF8B4513, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0x00000000, 0x00000000, 0x00000000
# Fila 11
0x00000000, 0x00000000, 0xFFC0C0C0, 0xFFC0C0C0, 0x00000000, 0x00000000, 0x00000000, 0xFFC0C0C0, 0xFFC0C0C0, 0xFFC0C0C0, 0x00000000, 0x00000000
# Fila 12
0x00000000, 0xFFC0C0C0, 0xFFC0C0C0, 0xFFC0C0C0, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000
# Sprite de Mario 12x12 - Frame 2 (CAMINANDO - pierna izquierda, mirando derecha)
.align 2
mario_sprite_frame2:
    .word
     # Fila 1
0x00000000, 0x00000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0x00000000, 0x00000000, 0x00000000
# Fila 2
0x00000000, 0x00000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFFDAA520, 0xFF000000, 0xFFDAA520, 0xFFDAA520, 0x00000000, 0x00000000, 0x00000000
# Fila 3
0x00000000, 0x00000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0x00000000, 0x00000000
# Fila 4
0x00000000, 0x00000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFF000000, 0xFF000000, 0xFF000000, 0x00000000
# Fila 5
0x00000000, 0x00000000, 0x00000000, 0xFF8B4513, 0xFF8B4513, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFF000000, 0xFF000000, 0xFF000000, 0x00000000
# Fila 6
0x00000000, 0xFF0000FF, 0xFF0000FF, 0xFF0000FF, 0xFF0000FF, 0xFF0000FF, 0xFF0000FF, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000
# Fila 7
0xFF8B4513, 0xFF0000FF, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFF8B4513, 0xFF8B4513, 0x00000000
# Fila 8
0xFF8B4513, 0x00000000, 0x00000000, 0xFF0000FF, 0xFF0000FF, 0xFF000000, 0xFF000000, 0xFF000000, 0x00000000, 0x00000000, 0xFFC0C0C0, 0x00000000
# Fila 9
0x00000000, 0x00000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000
# Fila 10
0x00000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0x00000000, 0x00000000, 0x00000000
# Fila 11
0x00000000, 0xFFC0C0C0, 0xFFC0C0C0, 0xFFC0C0C0, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000
# Fila 12
0x00000000, 0x00000000, 0xFFC0C0C0, 0xFFC0C0C0, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000

# Sprite de Mario 12x12 - Frame 3 (CAMINANDO - pierna derecha, mirando derecha)
.align 2
mario_sprite_frame3:
    .word
	# Fila 1
0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0x00000000, 0x00000000
# Fila 2
0x00000000, 0x00000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFFDAA520, 0xFF000000, 0xFFDAA520, 0x00000000, 0x00000000, 0x00000000, 0x00000000
# Fila 3
0x00000000, 0x00000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0x00000000, 0x00000000, 0x00000000
# Fila 4
0x00000000, 0x00000000, 0xFF000000, 0xFF8B4513, 0xFFDAA520, 0xFFDAA520, 0xFF000000, 0xFF000000, 0xFF000000, 0x00000000, 0x00000000, 0x00000000
# Fila 5
0x00000000, 0x00000000, 0x00000000, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0x00000000, 0x00000000
# Fila 6
0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xFFFFFF00, 0xFF0000FF, 0xFF0000FF, 0xFF0000FF, 0x00000000, 0xFFDAA520, 0xFFDAA520, 0x00000000
# Fila 7
0x00000000, 0x00000000, 0xFF8B4513, 0xFF8B4513, 0xFFFFFF00, 0xFFFFFF00, 0xFFFFFF00, 0xFFFFFF00, 0xFF8B4513, 0xFFDAA520, 0xFFDAA520, 0x00000000
# Fila 8
0x00000000, 0x00000000, 0xFFC0C0C0, 0xFFC0C0C0, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0x00000000, 0x00000000
# Fila 9
0x00000000, 0x00000000, 0xFFC0C0C0, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0x00000000, 0x00000000, 0x00000000
# Fila 10
0x00000000, 0xFFC0C0C0, 0x00000000, 0x00000000, 0x00000000, 0xFFC0C0C0, 0xFFC0C0C0, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000
# Fila 11
0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xFFC0C0C0, 0xFFC0C0C0, 0xFFC0C0C0, 0x00000000, 0x00000000, 0x00000000
# Fila 12
0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000
.align 2
mario_sprite_frame_jump:
    .word
    # Fila 0 - Gorra
    0x00000000, 0x00000000, 0x00000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 1 - Gorra y orejas
    0x00000000, 0x00000000, 0xFF000000, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFF000000, 0xFFDAA520, 0xFF000000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 2 - Cara superior
    0x00000000, 0xFF8B4513, 0xFF000000, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFF8B4513, 0x00000000, 0x00000000,
    # Fila 3 - Ojos y nariz
    0x00000000, 0xFF8B4513, 0xFF8B4513, 0xFF000000, 0xFFDAA520, 0xFF000000, 0xFFDAA520, 0xFF000000, 0xFF000000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 4 - Cara baja
    0x00000000, 0x00000000, 0xFF8B4513, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0xFFDAA520, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 5 - Remera amarilla
    0x00000000, 0x00000000, 0xFFFFFF00, 0xFFFFFF00, 0xFF0000FF, 0xFF0000FF, 0xFF0000FF, 0xFFFFFF00, 0xFFFFFF00, 0x00000000, 0x00000000, 0x00000000,
    # Fila 6 - Brazo izq + remera azul
    0x00000000, 0xFFDAA520, 0xFFDAA520, 0xFFFFFF00, 0xFF0000FF, 0xFF0000FF, 0xFF0000FF, 0xFFFFFF00, 0xFFDAA520, 0xFFDAA520, 0x00000000, 0x00000000,
    # Fila 7 - Brazos + remera
    0xFFDAA520, 0xFFDAA520, 0xFFFFFF00, 0xFFFFFF00, 0xFFFFFF00, 0xFF0000FF, 0xFFFFFF00, 0xFFFFFF00, 0xFFFFFF00, 0xFFDAA520, 0xFFDAA520, 0x00000000,
    # Fila 8 - Pantalón superior
    0x00000000, 0xFFDAA520, 0xFFFFFF00, 0xFF0000FF, 0xFF0000FF, 0xFF0000FF, 0xFF0000FF, 0xFF0000FF, 0xFFFFFF00, 0xFFDAA520, 0x00000000, 0x00000000,
    # Fila 9 - Pantalón
    0x00000000, 0x00000000, 0xFF000000, 0xFF000000, 0xFF0000FF, 0xFF0000FF, 0xFF0000FF, 0xFF000000, 0xFF000000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 10 - Piernas
    0x00000000, 0x00000000, 0xFF8B4513, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF8B4513, 0x00000000, 0x00000000, 0x00000000,
    # Fila 11 - Zapatos
    0x00000000, 0xFF8B4513, 0xFF8B4513, 0xFF8B4513, 0x00000000, 0x00000000, 0x00000000, 0xFF8B4513, 0xFF8B4513, 0xFF8B4513, 0x00000000, 0x00000000
# Variables de animación de Mario
# Contador de animación de Mario
# Sprite de Goomba 6x6 - Frame 1 (patas abajo)
# Sprite de Goomba 8x8 - Frame 1 (patas separadas)
.align 2
goomba_sprite_frame1:
    .word
    # Fila 0 - Parte superior redondeada
    0x00000000, 0x00000000, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0x00000000, 0x00000000,
    # Fila 1 - Cabeza con ojos
    0x00000000, 0xff8B4513, 0xffffffff, 0xff8B4513, 0xff8B4513, 0xffffffff, 0xff8B4513, 0x00000000,
    # Fila 2 - Pupilas y cejas
    0xff8B4513, 0xffffffff, 0xff000000, 0xff8B4513, 0xff8B4513, 0xff000000, 0xffffffff, 0xff8B4513,
    # Fila 3 - Cejas enojadas
    0xff8B4513, 0xff000000, 0xff000000, 0xff8B4513, 0xff8B4513, 0xff000000, 0xff000000, 0xff8B4513,
    # Fila 4 - Cuerpo superior
    0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513,
    # Fila 5 - Cuerpo medio
    0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513,
    # Fila 6 - Patas separadas (frame 1)
    0xff8B4513, 0xff8B4513, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff8B4513, 0xff8B4513,
    # Fila 7 - Pies
    0xff664422, 0xff664422, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff664422, 0xff664422

# Sprite de Goomba 8x8 - Frame 2 (patas juntas)
.align 2
goomba_sprite_frame2:
    .word
    # Fila 0 - Parte superior redondeada
    0x00000000, 0x00000000, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0x00000000, 0x00000000,
    # Fila 1 - Cabeza con ojos
    0x00000000, 0xff8B4513, 0xffffffff, 0xff8B4513, 0xff8B4513, 0xffffffff, 0xff8B4513, 0x00000000,
    # Fila 2 - Pupilas y cejas
    0xff8B4513, 0xffffffff, 0xff000000, 0xff8B4513, 0xff8B4513, 0xff000000, 0xffffffff, 0xff8B4513,
    # Fila 3 - Cejas enojadas
    0xff8B4513, 0xff000000, 0xff000000, 0xff8B4513, 0xff8B4513, 0xff000000, 0xff000000, 0xff8B4513,
    # Fila 4 - Cuerpo superior
    0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513,
    # Fila 5 - Cuerpo medio
    0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513,
    # Fila 6 - Patas juntas (frame 2)
    0x00000000, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0xff8B4513, 0x00000000,
    # Fila 7 - Pies juntos
    0x00000000, 0xff664422, 0xff664422, 0xff664422, 0xff664422, 0xff664422, 0xff664422, 0x00000000
# Contador de animación de goombas
goomba_animation_frame: .word 0
# Contador de animación de Mario
mario_animation_frame: .word 0
mario_animation_counter: .word 0
mario_facing_right: .word 1

# Sprite de castillo 24x20 con textura de ladrillos
.align 2
castle_sprite:
    .word
    # Fila 0 - Torres superiores
    0xff808080, 0xff808080, 0xff404040, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff404040, 0xff808080, 0xff808080,
    # Fila 1
    0xff808080, 0xff606060, 0xff808080, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff808080, 0xff606060, 0xff808080,
    # Fila 2
    0xff808080, 0xff606060, 0xff808080, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff808080, 0xff606060, 0xff808080,
    # Fila 3 - Base de las torres
    0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff404040, 0xff808080, 0xff808080, 0xff808080, 0xff808080,
    # Fila 4 - Ladrillos
    0xff808080, 0xff606060, 0xff808080, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff404040, 0xff808080, 0xff606060, 0xff808080,
    # Fila 5
    0xff808080, 0xff808080, 0xff404040, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff606060, 0xff404040, 0xff808080, 0xff808080,
    # Fila 6 - Ladrillos
    0xff808080, 0xff606060, 0xff808080, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff404040, 0xff808080, 0xff606060, 0xff808080,
    # Fila 7
    0xff808080, 0xff808080, 0xff404040, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff606060, 0xff404040, 0xff808080, 0xff808080,
    # Fila 8 - Ladrillos
    0xff808080, 0xff606060, 0xff808080, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff404040, 0xff808080, 0xff606060, 0xff808080,
    # Fila 9
    0xff808080, 0xff808080, 0xff404040, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff606060, 0xff404040, 0xff808080, 0xff808080,
    # Fila 10 - Puerta empieza
    0xff808080, 0xff606060, 0xff808080, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff808080,
    # Fila 11
    0xff808080, 0xff808080, 0xff404040, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff808080,
    # Fila 12 - Puerta
    0xff808080, 0xff606060, 0xff808080, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff808080,
    # Fila 13
    0xff808080, 0xff808080, 0xff404040, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff808080,
    # Fila 14
    0xff808080, 0xff606060, 0xff808080, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff808080,
    # Fila 15
    0xff808080, 0xff808080, 0xff404040, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff808080,
    # Fila 16
    0xff808080, 0xff606060, 0xff808080, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff808080,
    # Fila 17
    0xff808080, 0xff808080, 0xff404040, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff808080,
    # Fila 18
    0xff808080, 0xff606060, 0xff808080, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff404040, 0xff808080, 0xff606060, 0xff404040, 0xff808080, 0xff606060, 0xff808080,
    # Fila 19 - Base
    0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080, 0xff808080

# Sprite de bandera argentina 12x8
.align 2
argentina_flag_sprite:
    .word
    # Fila 0 - Azul celeste superior
    0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB,
    # Fila 1
    0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB,
    # Fila 2 - Blanco con sol (centro)
    0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF,
    # Fila 3 - Blanco con sol
    0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF,
    # Fila 4 - Blanco con sol
    0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF,
    # Fila 5 - Blanco con sol
    0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF,
    # Fila 6 - Azul celeste inferior
    0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB,
    # Fila 7
    0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB, 0xff75AADB

# ============= SPRITES PARA MENÚ Y GAME OVER =============

# Sprite de título "MARIO" 60x12 (simplificado para legibilidad)
.align 2
title_mario_sprite:
    .word
    # M (0-11)    A (13-23)    R (26-36)    I (39-47)    O (50-59)
    # Fila 0
    0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 1
    0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 2
    0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 3
    0xffFF0000, 0xffFF0000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 4
    0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 5
    0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000

# Sprite de "BROS" 48x8
.align 2
title_bros_sprite:
    .word
    # B (0-9)      R (12-21)    O (24-33)    S (36-45)
    # Fila 0
    0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 1
    0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 2
    0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 3
    0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 4
    0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000

# Sprite de "VERSION MIPS" 64x6 (más pequeño)
.align 2
subtitle_sprite:
    .word
    # V     E     R     S     I     O     N           M     I     P     S
    # Fila 0
    0xff00FF00, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0x00000000, 0xff00FF00, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00,
    # Fila 1
    0xff00FF00, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0x00000000, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0x00000000, 0xff00FF00, 0x00000000, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000,
    # Fila 2
    0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0xff00FF00, 0xff00FF00, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0x00000000, 0xff00FF00, 0x00000000, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00,
    # Fila 3
    0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0xff00FF00, 0xff00FF00, 0x00000000, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0x00000000, 0xff00FF00, 0x00000000, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000,
    # Fila 4
    0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0xff00FF00, 0xff00FF00, 0x00000000, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0x00000000, 0xff00FF00, 0x00000000, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0x00000000, 0x00000000, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00, 0xff00FF00

# Sprite de "PRESS ENTER" 56x6
.align 2
press_enter_sprite:
    .word
    # P     R     E     S     S           E     N     T     E     R
    # Fila 0
    0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF,
    # Fila 1
    0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF,
    # Fila 2
    0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000,
    # Fila 3
    0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0x00000000, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0x00000000, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFFFFFF, 0xffFFFFFF, 0x00000000, 0x00000000, 0x00000000

# Sprite de "GAME OVER" 70x10 (más grande y dramático)
.align 2
gameover_sprite:
    .word
    # G             A             M             E                   O             V             E             R
    # (10 filas x 70 columnas = 700 palabras)
    # Fila 0
    0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 1
    0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 2
    0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0xffFF0000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 3
    0xffFF0000, 0xffFF0000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 4
    0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 5
    0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000


# Sprite de bloque sorpresa (?) 8x8 - Amarillo
.align 2
mystery_block_sprite:
    .word
    # Fila 0 - Borde superior
    0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000,
    # Fila 1
    0xff000000, 0xffFFFF00, 0xffFFFF00, 0xffFFFF00, 0xffFFFF00, 0xffFFFF00, 0xffFFFF00, 0xff000000,
    # Fila 2 - Con "?"
    0xff000000, 0xffFFFF00, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xffFFFF00, 0xff000000,
    # Fila 3
    0xff000000, 0xffFFFF00, 0xffFFFF00, 0xffFFFF00, 0xff000000, 0xff000000, 0xffFFFF00, 0xff000000,
    # Fila 4
    0xff000000, 0xffFFFF00, 0xffFFFF00, 0xffFFFF00, 0xff000000, 0xff000000, 0xffFFFF00, 0xff000000,
    # Fila 5
    0xff000000, 0xffFFFF00, 0xffFFFF00, 0xffFFFF00, 0xff000000, 0xff000000, 0xffFFFF00, 0xff000000,
    # Fila 6
    0xff000000, 0xffFFFF00, 0xffFFFF00, 0xffFFFF00, 0xffFFFF00, 0xffFFFF00, 0xffFFFF00, 0xff000000,
    # Fila 7 - Borde inferior
    0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000

# Sprite de bloque sorpresa USADO (más oscuro) 8x8
.align 2
mystery_block_used_sprite:
    .word
    # Fila 0 - Borde
    0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000,
    # Fila 1
    0xff000000, 0xffCC8800, 0xffCC8800, 0xffCC8800, 0xffCC8800, 0xffCC8800, 0xffCC8800, 0xff000000,
    # Fila 2
    0xff000000, 0xffCC8800, 0xff884400, 0xff884400, 0xff884400, 0xff884400, 0xffCC8800, 0xff000000,
    # Fila 3
    0xff000000, 0xffCC8800, 0xff884400, 0xffCC8800, 0xffCC8800, 0xff884400, 0xffCC8800, 0xff000000,
    # Fila 4
    0xff000000, 0xffCC8800, 0xff884400, 0xffCC8800, 0xffCC8800, 0xff884400, 0xffCC8800, 0xff000000,
    # Fila 5
    0xff000000, 0xffCC8800, 0xff884400, 0xff884400, 0xff884400, 0xff884400, 0xffCC8800, 0xff000000,
    # Fila 6
    0xff000000, 0xffCC8800, 0xffCC8800, 0xffCC8800, 0xffCC8800, 0xffCC8800, 0xffCC8800, 0xff000000,
    # Fila 7
    0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000

# Sprite de estrella 8x8
.align 2
star_sprite:
    .word
    # Fila 0
    0x00000000, 0x00000000, 0x00000000, 0xffFFFF00, 0xffFFFF00, 0x00000000, 0x00000000, 0x00000000,
    # Fila 1
    0x00000000, 0x00000000, 0xffFFFF00, 0xffFFD700, 0xffFFD700, 0xffFFFF00, 0x00000000, 0x00000000,
    # Fila 2
    0x00000000, 0xffFFFF00, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFFF00, 0x00000000,
    # Fila 3
    0xffFFFF00, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFFF00,
    # Fila 4
    0x00000000, 0xffFFFF00, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFD700, 0xffFFFF00, 0x00000000,
    # Fila 5
    0x00000000, 0x00000000, 0xffFFFF00, 0xffFFD700, 0xffFFD700, 0xffFFFF00, 0x00000000, 0x00000000,
    # Fila 6
    0x00000000, 0x00000000, 0x00000000, 0xffFFFF00, 0xffFFFF00, 0x00000000, 0x00000000, 0x00000000,
    # Fila 7
    0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000

# Sprite de corazón 8x8
.align 2
heart_sprite:
    .word
    # Fila 0
    0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000,
    # Fila 1
    0xffFF0000, 0xffFF69B4, 0xffFF69B4, 0xffFF0000, 0xffFF0000, 0xffFF69B4, 0xffFF69B4, 0xffFF0000,
    # Fila 2
    0xffFF0000, 0xffFF69B4, 0xffFF69B4, 0xffFF69B4, 0xffFF69B4, 0xffFF69B4, 0xffFF69B4, 0xffFF0000,
    # Fila 3
    0xffFF0000, 0xffFF69B4, 0xffFF69B4, 0xffFF69B4, 0xffFF69B4, 0xffFF69B4, 0xffFF69B4, 0xffFF0000,
    # Fila 4
    0x00000000, 0xffFF0000, 0xffFF69B4, 0xffFF69B4, 0xffFF69B4, 0xffFF69B4, 0xffFF0000, 0x00000000,
    # Fila 5
    0x00000000, 0x00000000, 0xffFF0000, 0xffFF69B4, 0xffFF69B4, 0xffFF0000, 0x00000000, 0x00000000,
    # Fila 6
    0x00000000, 0x00000000, 0x00000000, 0xffFF0000, 0xffFF0000, 0x00000000, 0x00000000, 0x00000000,
    # Fila 7
    0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000

# Mystery blocks (x, y, hit, item_type) 
    # item_type: 0=estrella, 1=corazon
# Mystery blocks (x, y, hit, item_type) 
mystery_blocks: .word
    52, 8, 0, 0,        # Isla 1 - Altura 8 (6 píxeles más alto)
    485, 8, 0, 1,       # Isla 4 - Altura 8 (6 píxeles más alto)
    -1, -1, -1, -1

    MYSTERY_BLOCK_SIZE: .word 8
    
    # Power-ups activos (x, y, type, collected, vy)
    # type: 0=estrella, 1=corazon
powerups: .word
    -1, -1, -1, -1, 0,
    -1, -1, -1, -1, 0,
    -1, -1, -1, -1, -1
    
    POWERUP_GRAVITY: .word 1
    POWERUP_BOUNCE: .word -6
    
    
# Sprite de corazón vacío/negro 8x8
.align 2
heart_empty_sprite:
    .word
    # Fila 0
    0x00000000, 0xff333333, 0xff333333, 0x00000000, 0x00000000, 0xff333333, 0xff333333, 0x00000000,
    # Fila 1
    0xff333333, 0xff222222, 0xff222222, 0xff333333, 0xff333333, 0xff222222, 0xff222222, 0xff333333,
    # Fila 2
    0xff333333, 0xff222222, 0xff222222, 0xff222222, 0xff222222, 0xff222222, 0xff222222, 0xff333333,
    # Fila 3
    0xff333333, 0xff222222, 0xff222222, 0xff222222, 0xff222222, 0xff222222, 0xff222222, 0xff333333,
    # Fila 4
    0x00000000, 0xff333333, 0xff222222, 0xff222222, 0xff222222, 0xff222222, 0xff333333, 0x00000000,
    # Fila 5
    0x00000000, 0x00000000, 0xff333333, 0xff222222, 0xff222222, 0xff333333, 0x00000000, 0x00000000,
    # Fila 6
    0x00000000, 0x00000000, 0x00000000, 0xff333333, 0xff333333, 0x00000000, 0x00000000, 0x00000000,
    # Fila 7
    0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000


.text           # ? ESTO FALTA!
.globl main

main:
    jal clear_screen

   
wait_for_start:
    li $t0, 0xffff0000
    lw $t1, 0($t0)
    andi $t1, $t1, 1
    beqz $t1, wait_for_start
   
    lw $t1, 4($t0)
li $t2, 0x20          # CAMBIAR: Enter key
    bne $t1, $t2, wait_for_start

game_loop:
    lw $t0, mario_lives
    blez $t0, game_over
   
    lw $t0, mario_x
    lw $t1, CASTLE_X
    bge $t0, $t1, game_win
   
    jal process_input
    jal update_mario_physics
    jal check_mystery_block_hits
    jal update_powerups
    jal check_powerup_collection
    jal update_camera
    jal update_goombas
    jal check_goomba_collisions
    jal check_coin_collisions
    jal check_pit_death
    jal render_frame
   
    # CAMBIAR ESTO:
    li $a0, 1              # Era 3, ahora 1 (MUCHO más rápido)
    jal delay
   
    j game_loop

game_win:
    jal show_win_screen_visual
    j wait_for_restart

game_over:
    jal show_game_over_screen_visual
   
wait_for_restart:
    li $t0, 0xffff0000
    lw $t1, 0($t0)
    andi $t1, $t1, 1
    beqz $t1, wait_for_restart
   
    lw $t1, 4($t0)
    li $t2, 0x20
    beq $t1, $t2, reset_game
    li $t2, 0x1B
    beq $t1, $t2, exit_program
    j wait_for_restart

reset_game:
    # Resetear posición y estado de Mario
    li $t0, 10
    sw $t0, mario_x
    li $t0, 50
    sw $t0, mario_y
    sw $zero, mario_vy
    sw $zero, mario_vx
    li $t0, 1
    sw $t0, mario_on_ground
    li $t0, 3
    sw $t0, mario_lives
    sw $zero, score
    sw $zero, coins
    sw $zero, camera_x
    sw $zero, goomba_move_counter
    sw $zero, mario_animation_frame
    sw $zero, mario_animation_counter
    li $t0, 1
    sw $t0, mario_facing_right
   
    # Resetear goombas
    la $t0, goombas
reset_goombas_loop:
    lw $t1, 0($t0)
    li $t2, -1
    beq $t1, $t2, reset_coins_start
    li $t3, 1
    sw $t3, 4($t0)              # alive = 1
    addi $t0, $t0, 20
    j reset_goombas_loop
   
reset_coins_start:
    la $t0, coins_data
reset_coins_loop:
    lw $t1, 0($t0)
    li $t2, -1
    beq $t1, $t2, reset_mystery_start
    sw $zero, 8($t0)            # collected = 0
    addi $t0, $t0, 12
    j reset_coins_loop

# NUEVA SECCIÓN: Resetear Mystery Blocks
reset_mystery_start:
    la $t0, mystery_blocks
reset_mystery_loop:
    lw $t1, 0($t0)              # Cargar X del bloque
    li $t2, -1
    beq $t1, $t2, reset_powerups_start  # Si es -1, terminamos
    sw $zero, 8($t0)            # hit = 0 (NO golpeado)
    addi $t0, $t0, 16           # Siguiente bloque (4 words)
    j reset_mystery_loop

# NUEVA SECCIÓN: Resetear Powerups activos
reset_powerups_start:
    la $t0, powerups
    li $t1, -1
    li $t2, 0                   # Contador
reset_powerups_loop:
    sw $t1, 0($t0)              # x = -1
    sw $t1, 4($t0)              # y = -1
    sw $t1, 8($t0)              # type = -1
    sw $t1, 12($t0)             # collected = -1
    sw $zero, 16($t0)           # vy = 0
    
    addi $t0, $t0, 20           # Siguiente powerup
    addi $t2, $t2, 1
    li $t3, 3                   # Hay 3 slots de powerups
    blt $t2, $t3, reset_powerups_loop
   
reset_done:
    j main


exit_program:
    li $v0, 10
    syscall

check_pit_death:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    lw $t0, mario_y
    li $t1, 64
    blt $t0, $t1, pit_check_done
   
    jal mario_hit

pit_check_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

update_camera:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    lw $t0, mario_x
    lw $t1, camera_x
   
    sub $t2, $t0, $t1
    li $t3, 80
    ble $t2, $t3, camera_bounds_check
   
    sub $t1, $t0, $t3
   
camera_bounds_check:
    bltz $t1, camera_clamp_left
   
    lw $t4, WORLD_WIDTH
    li $t5, 128
    sub $t4, $t4, $t5
    bgt $t1, $t4, camera_clamp_right
   
    sw $t1, camera_x
    j camera_done
   
camera_clamp_left:
    sw $zero, camera_x
    j camera_done
   
camera_clamp_right:
    sw $t4, camera_x

camera_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

process_input:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    li $s0, 0
   
    li $t0, 0xffff0000
    lw $t1, 0($t0)
    andi $t1, $t1, 1
    beqz $t1, apply_friction
   
    lw $t2, 4($t0)
   
    li $t3, 0x61
    beq $t2, $t3, move_left
    li $t3, 0x41
    beq $t2, $t3, move_left
   
    li $t3, 0x64
    beq $t2, $t3, move_right
    li $t3, 0x44
    beq $t2, $t3, move_right
   
    li $t3, 0x77
    beq $t2, $t3, try_jump
    li $t3, 0x57
    beq $t2, $t3, try_jump
    li $t3, 0x20
    beq $t2, $t3, try_jump
   
    li $t3, 0x1B
    beq $t2, $t3, exit_program
   
    j apply_friction

move_left:
    li $s0, 1
    lw $t0, mario_vx
    lw $t1, ACCELERATION
    sub $t0, $t0, $t1
   
    lw $t1, MAX_SPEED
    neg $t2, $t1
    blt $t0, $t2, clamp_left
    sw $t0, mario_vx
    j apply_friction
clamp_left:
    sw $t2, mario_vx
    j apply_friction

move_right:
    li $s0, 1
    lw $t0, mario_vx
    lw $t1, ACCELERATION
    add $t0, $t0, $t1
   
    lw $t1, MAX_SPEED
    bgt $t0, $t1, clamp_right
    sw $t0, mario_vx
    j apply_friction
clamp_right:
    sw $t1, mario_vx
    j apply_friction

try_jump:
    lw $t0, mario_on_ground
    beqz $t0, apply_friction    # Si NO está en el suelo, NO puede saltar
   
    # VERIFICAR TAMBIÉN que la velocidad vertical sea 0 o positiva
    lw $t2, mario_vy
    bltz $t2, apply_friction    # Si ya está subiendo, NO puede saltar de nuevo
   
    lw $t1, JUMP_VELOCITY
    sw $t1, mario_vy
    sw $zero, mario_on_ground
    j apply_friction

apply_friction:
    beqz $s0, do_friction
    j input_done

do_friction:
    lw $t0, mario_vx
    beqz $t0, input_done
   
    lw $t1, FRICTION
    bgtz $t0, friction_right
   
friction_left:
    add $t0, $t0, $t1
    bgtz $t0, friction_stop
    sw $t0, mario_vx
    j input_done
   
friction_right:
    sub $t0, $t0, $t1
    bltz $t0, friction_stop
    sw $t0, mario_vx
    j input_done
   
friction_stop:
    sw $zero, mario_vx

input_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

update_mario_physics:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
   
    lw $s0, mario_y
   
    lw $t0, mario_vy
    lw $t1, GRAVITY
    add $t0, $t0, $t1
   
    lw $t1, MAX_FALL_SPEED
    blt $t0, $t1, vy_ok
    move $t0, $t1
vy_ok:
    sw $t0, mario_vy
   
    lw $t1, mario_y
    add $t1, $t1, $t0
    sw $t1, mario_y
   
    lw $t0, mario_vx
    lw $t1, mario_x
    add $t1, $t1, $t0
   
    bltz $t1, clamp_x_left
    lw $t2, WORLD_WIDTH
    addi $t2, $t2, -4
    bge $t1, $t2, clamp_x_right
    sw $t1, mario_x
    j check_pipes
   
clamp_x_left:
    sw $zero, mario_x
    sw $zero, mario_vx
    j check_pipes
   
clamp_x_right:
    sw $t2, mario_x
    sw $zero, mario_vx

check_pipes:
    jal check_pipe_collisions

check_platforms:
    move $a0, $s0
    jal check_platform_collisions
   
    jal check_ground_collision

physics_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

check_ground_collision:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
   
    lw $t0, mario_y
    lw $t1, MARIO_HEIGHT
    add $t0, $t0, $t1
    lw $t2, GROUND_Y
   
    blt $t0, $t2, check_if_falling_off_ground
   
    lw $t3, mario_x
    move $a0, $t3
    jal is_on_ground_segment
   
    beqz $v0, check_if_falling_off_ground
   
    lw $t2, GROUND_Y
    lw $t1, MARIO_HEIGHT
    sub $t3, $t2, $t1
    sw $t3, mario_y
    sw $zero, mario_vy
    li $t4, 1
    sw $t4, mario_on_ground
    j ground_collision_done

check_if_falling_off_ground:
    lw $t0, mario_on_ground
    beqz $t0, ground_collision_done
   
    lw $t3, mario_x
    move $a0, $t3
    jal is_on_ground_segment
   
    bnez $v0, ground_collision_done
   
    sw $zero, mario_on_ground

ground_collision_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

is_on_ground_segment:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
   
    move $t3, $a0           # mario_x
    la $s0, ground_segments
   
check_segment_loop:
    lw $s1, 0($s0)          # segment_start
    li $t0, -1
    beq $s1, $t0, no_ground_found
   
    lw $t1, 4($s0)          # segment_end
   
    # CORRECCIÓN: Verificar OVERLAP entre [mario_x, mario_x+width] y [start, end]
    # Hay overlap si: mario_x < segment_end AND (mario_x + width) > segment_start
    
    lw $t4, MARIO_WIDTH
    add $t5, $t3, $t4       # mario_right = mario_x + width
    
    # Si mario_x >= segment_end, no hay overlap
    bge $t3, $t1, next_segment
    
    # Si mario_right <= segment_start, no hay overlap
    ble $t5, $s1, next_segment
    
    # ¡Hay overlap! Mario está sobre este segmento
    li $v0, 1
    j ground_segment_done

next_segment:
    addi $s0, $s0, 8
    j check_segment_loop

no_ground_found:
    li $v0, 0

ground_segment_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra
check_pipe_collisions:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
   
    la $s0, pipes
   
pipe_loop:
    lw $s1, 0($s0)
    li $t0, -1
    beq $s1, $t0, pipes_done
   
    lw $s2, 4($s0)
    lw $s3, 8($s0)
    lw $s4, 12($s0)
   
    lw $t0, mario_x
    lw $t1, MARIO_WIDTH
    add $t2, $t0, $t1
   
    add $t3, $s1, $s3
   
    bge $t0, $t3, next_pipe
    ble $t2, $s1, next_pipe
   
    lw $t0, mario_y
    lw $t1, MARIO_HEIGHT
    add $t2, $t0, $t1
   
    add $t3, $s2, $s4
   
    bge $t0, $t3, next_pipe
    ble $t2, $s2, next_pipe
   
    lw $t0, mario_vy
    bgtz $t0, check_pipe_landing
   
    j resolve_pipe_horizontal

check_pipe_landing:
    lw $t0, mario_y
    lw $t1, MARIO_HEIGHT
    add $t0, $t0, $t1      # mario_bottom
   
    sub $t1, $t0, $s2      # distancia = mario_bottom - pipe_top
    li $t2, 8              # REDUCIR de 12 a 8 para mejor detección
    bgt $t1, $t2, resolve_pipe_horizontal
   
    lw $t1, MARIO_HEIGHT
    sub $t3, $s2, $t1
    sw $t3, mario_y
    sw $zero, mario_vy
    li $t4, 1
    sw $t4, mario_on_ground
    j next_pipe

resolve_pipe_horizontal:
    lw $t0, mario_x
    lw $t1, MARIO_WIDTH
    add $t2, $t0, $t1
   
    sub $t3, $t2, $s1
    add $t4, $s1, $s3
    sub $t5, $t4, $t0
   
    blt $t3, $t5, push_left_pipe
   
push_right_pipe:
    add $t6, $s1, $s3
    sw $t6, mario_x
    sw $zero, mario_vx
    j next_pipe
   
push_left_pipe:
    lw $t1, MARIO_WIDTH
    sub $t6, $s1, $t1
    sw $t6, mario_x
    sw $zero, mario_vx

next_pipe:
    addi $s0, $s0, 16
    j pipe_loop

pipes_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra

check_platform_collisions:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
   
    move $s4, $a0       # prev_mario_y
    la $s0, platforms
   
platform_loop:
    lw $s1, 0($s0)      # platform_x
    li $t0, -1
    beq $s1, $t0, platform_check_done
   
    lw $s2, 4($s0)      # platform_y
    lw $s3, 8($s0)      # platform_width
   
    # PASO 1: Verificar overlap horizontal
    lw $t0, mario_x
    lw $t1, MARIO_WIDTH
    add $t2, $t0, $t1   # mario_right
   
    add $t3, $s1, $s3   # platform_right
   
    # Si no hay overlap horizontal, siguiente plataforma
    bge $t0, $t3, next_platform
    ble $t2, $s1, next_platform
   
    # PASO 2: Hay overlap horizontal - verificar tipo de colisión
    lw $t0, mario_vy
    bgtz $t0, check_platform_landing      # Mario cayendo
    bltz $t0, check_platform_bottom       # Mario subiendo
    
    # PASO 3: Velocidad vertical = 0, verificar colisión lateral
    j check_platform_sides

check_platform_landing:
    # Mario cayendo - verificar aterrizaje desde arriba
    lw $t1, mario_y
    lw $t2, MARIO_HEIGHT
    add $t1, $t1, $t2       # mario_bottom
   
    add $t3, $s4, $t2       # prev_mario_bottom
   
    # Solo aterrizar si venía desde arriba
    blt $t1, $s2, next_platform
    bgt $t3, $s2, next_platform
   
    sub $t4, $t1, $s2
    li $t5, 10
    bgt $t4, $t5, next_platform
   
    # Aterrizar en la plataforma
    sub $t1, $s2, $t2
    sw $t1, mario_y
    sw $zero, mario_vy
    li $t6, 1
    sw $t6, mario_on_ground
    j platform_check_done

check_platform_bottom:
    # Mario subiendo - golpear desde abajo
    lw $t4, 12($s0)     # platform_height
    add $t1, $s2, $t4   # platform_bottom
   
    lw $t2, mario_y
    bgt $t2, $t1, next_platform
    blt $s4, $t1, next_platform
   
    sub $t3, $t1, $t2
    li $t5, 10
    bgt $t3, $t5, next_platform
   
    sw $t1, mario_y
    sw $zero, mario_vy
    sw $zero, mario_on_ground
    j platform_check_done

check_platform_sides:
    # NUEVA LÓGICA: Colisión lateral
    lw $t0, mario_y
    lw $t1, MARIO_HEIGHT
    add $t2, $t0, $t1       # mario_bottom
   
    lw $t4, 12($s0)         # platform_height
    add $t3, $s2, $t4       # platform_bottom
   
    # Verificar overlap vertical
    bge $t0, $t3, next_platform     # Mario arriba de plataforma
    ble $t2, $s2, next_platform     # Mario debajo de plataforma
   
    # HAY OVERLAP VERTICAL - Resolver colisión lateral
    lw $t0, mario_x
    lw $t1, MARIO_WIDTH
    add $t2, $t0, $t1       # mario_right
   
    # Calcular distancia desde cada lado
    sub $t3, $t2, $s1       # overlap_left = mario_right - platform_left
    add $t4, $s1, $s3       # platform_right
    sub $t5, $4, $t0        # overlap_right = platform_right - mario_x
   
    # Empujar por el lado con menos overlap
    blt $t3, $t5, push_mario_left
   
push_mario_right:
    # Empujar Mario a la derecha
    add $t6, $s1, $s3       # platform_right
    sw $t6, mario_x
    sw $zero, mario_vx
    j next_platform
   
push_mario_left:
    # Empujar Mario a la izquierda
    lw $t1, MARIO_WIDTH
    sub $t6, $s1, $t1       # platform_left - mario_width
    sw $t6, mario_x
    sw $zero, mario_vx
    j next_platform

next_platform:
    addi $s0, $s0, 16
    j platform_loop

platform_check_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra

update_goombas:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
   
    lw $t0, goomba_move_counter
    addi $t0, $t0, 1
    lw $t1, goomba_move_delay
   
    blt $t0, $t1, save_counter
    sw $zero, goomba_move_counter
   
    la $s0, goombas
   
update_goomba_loop:
    lw $t0, 0($s0)
    li $t1, -1
    beq $t0, $t1, goombas_done
   
    lw $t1, 4($s0)
    beqz $t1, next_goomba
   
    lw $t2, 8($s0)
    lw $t3, 12($s0)
    lw $t4, 16($s0)
   
    move $t5, $t0
    bgtz $t2, calc_goomba_right
   
calc_goomba_left:
    addi $t5, $t5, -1
    ble $t5, $t3, reverse_goomba_right
    j check_goomba_pipe_collision

calc_goomba_right:
    addi $t5, $t5, 1
    bge $t5, $t4, reverse_goomba_left
    j check_goomba_pipe_collision

check_goomba_pipe_collision:
    move $a0, $t5
    move $a1, $t0
    jal goomba_pipe_collision
   
    beqz $v0, save_goomba_pos
   
    lw $t2, 8($s0)
    bgtz $t2, force_reverse_left
   
force_reverse_right:
    li $t2, 1
    sw $t2, 8($s0)
    j next_goomba
   
force_reverse_left:
    li $t2, -1
    sw $t2, 8($s0)
    j next_goomba

reverse_goomba_left:
    li $t2, -1
    sw $t2, 8($s0)
    move $t5, $t0
    j save_goomba_pos

reverse_goomba_right:
    li $t2, 1
    sw $t2, 8($s0)
    move $t5, $t0
    j save_goomba_pos

save_goomba_pos:
    sw $t5, 0($s0)

next_goomba:
    addi $s0, $s0, 20
    j update_goomba_loop

save_counter:
    sw $t0, goomba_move_counter

goombas_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

goomba_pipe_collision:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
   
    move $s1, $a0
    move $s2, $a1
   
    la $s0, pipes
   
gpc_pipe_loop:
    lw $t0, 0($s0)
    li $t1, -1
    beq $t0, $t1, gpc_no_collision
   
    lw $t1, 8($s0)
    add $t2, $t0, $t1
   
    lw $t3, GOOMBA_WIDTH
    add $t4, $s1, $t3
   
    bge $s1, $t2, gpc_next_pipe
    ble $t4, $t0, gpc_next_pipe
   
    li $v0, 1
    j gpc_done

gpc_next_pipe:
    addi $s0, $s0, 16
    j gpc_pipe_loop

gpc_no_collision:
    li $v0, 0

gpc_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra

# ============= FUNCIÓN CORREGIDA PARA MATAR GOOMBAS =============
check_goomba_collisions:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
   
    la $s0, goombas
   
check_goomba_loop:
    lw $s1, 0($s0)          # x del goomba
    li $t0, -1
    beq $s1, $t0, goombas_collision_done
   
    lw $t0, 4($s0)          # alive flag
    beqz $t0, next_goomba_check
   
    # Verificar colisión horizontal (eje X)
    lw $t1, mario_x
    lw $t2, MARIO_WIDTH
    add $t3, $t1, $t2       # mario_right = mario_x + width
   
    lw $t4, GOOMBA_WIDTH
    add $t5, $s1, $t4       # goomba_right = goomba_x + width
   
    # No hay colisión si:
    # mario_x >= goomba_right OR mario_right <= goomba_x
    bge $t1, $t5, next_goomba_check
    ble $t3, $s1, next_goomba_check
   
    # Calcular posición Y del goomba (siempre en el suelo)
    lw $t4, GROUND_Y
    lw $t5, GOOMBA_HEIGHT
    sub $t6, $t4, $t5       # goomba_top = GROUND_Y - GOOMBA_HEIGHT
   
    # Verificar colisión vertical (eje Y)
    lw $t1, mario_y         # mario_top
    lw $t2, MARIO_HEIGHT
    add $t3, $t1, $t2       # mario_bottom = mario_y + height
   
    add $t7, $t6, $t5       # goomba_bottom = goomba_top + height
   
    # No hay colisión si:
    # mario_top >= goomba_bottom OR mario_bottom <= goomba_top
    bge $t1, $t7, next_goomba_check
    ble $t3, $t6, next_goomba_check
   
    # ============= HAY COLISIÓN =============
    # NUEVA LÓGICA: Mario mata al Goomba si viene desde arriba
   
    # Calcular el centro vertical de Mario y Goomba
    lw $t0, mario_y
    lw $t1, MARIO_HEIGHT
    srl $t1, $t1, 1         # height / 2
    add $t0, $t0, $t1       # mario_center_y
   
    add $t2, $t6, $t5       # goomba_bottom
    sub $t3, $t2, $t6       # goomba_height
    srl $t3, $t3, 1         # goomba_height / 2
    add $t2, $t6, $t3       # goomba_center_y
   
    # Si el centro de Mario está POR ENCIMA del centro del Goomba
    # Y Mario está cayendo (vy >= 0), entonces mata al Goomba
    bge $t0, $t2, mario_dies_goomba  # Centro de Mario está abajo
   
    # Mario está arriba - verificar que está cayendo
    lw $t4, mario_vy
    blez $t4, mario_dies_goomba      # No está cayendo
   
    # CORREGIDO: Verificar distancia más generosa
    # Mario_bottom debe estar cerca de goomba_top
    lw $t1, mario_y
    lw $t2, MARIO_HEIGHT
    add $t1, $t1, $t2       # mario_bottom
    
    sub $t5, $t1, $t6       # distancia = mario_bottom - goomba_top
    
    # Si la distancia es razonable (< 6 píxeles), Mario mata al Goomba
    li $t7, 6
    bgt $t5, $t7, mario_dies_goomba
   
kill_goomba_stomp:
    # Matar al Goomba
    sw $zero, 4($s0)        # alive = 0
   
    # Dar puntos
    lw $t0, score
    addi $t0, $t0, 100
    sw $t0, score
   
    # Hacer que Mario rebote hacia arriba
    lw $t1, BOUNCE_VELOCITY
    sw $t1, mario_vy
   
    j next_goomba_check

mario_dies_goomba:
    jal mario_hit
    j goombas_collision_done

next_goomba_check:
    addi $s0, $s0, 20
    j check_goomba_loop

goombas_collision_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

check_coin_collisions:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
   
    la $s0, coins_data
   
check_coin_loop:
    lw $t0, 0($s0)
    li $t1, -1
    beq $t0, $t1, coins_collision_done
   
    lw $t1, 8($s0)
    bnez $t1, next_coin
   
    lw $t1, 4($s0)
   
    lw $t2, mario_x
    lw $t3, MARIO_WIDTH
    add $t4, $t2, $t3
   
    lw $t5, COIN_WIDTH
    add $t6, $t0, $t5
   
    bgt $t2, $t6, next_coin
    blt $t4, $t0, next_coin
   
    lw $t2, mario_y
    lw $t3, MARIO_HEIGHT
    add $t4, $t2, $t3
   
    lw $t5, COIN_HEIGHT
    add $t6, $t1, $t5
   
    bgt $t2, $t6, next_coin
    blt $t4, $t1, next_coin
   
    li $t7, 1
    sw $t7, 8($s0)
   
    lw $t0, coins
    addi $t0, $t0, 1
    sw $t0, coins
   
    lw $t0, score
    addi $t0, $t0, 10
    sw $t0, score

next_coin:
    addi $s0, $s0, 12
    j check_coin_loop

coins_collision_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

check_mystery_block_hits:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
   
    # Solo verificar si Mario está subiendo
    lw $t0, mario_vy
    bgez $t0, mystery_check_done
   
    la $s0, mystery_blocks
   
check_mystery_loop:
    lw $s1, 0($s0)              # block x
    li $t0, -1
    beq $s1, $t0, mystery_check_done
   
    lw $t1, 8($s0)              # hit flag
    bnez $t1, next_mystery      # Ya fue golpeado
   
    # Verificar colisión horizontal
    lw $t2, mario_x
    lw $t3, MARIO_WIDTH
    add $t4, $t2, $t3           # mario_right
   
    lw $t5, MYSTERY_BLOCK_SIZE
    add $t6, $s1, $t5           # block_right
   
    bge $t2, $t6, next_mystery
    ble $t4, $s1, next_mystery
   
    # Verificar colisión vertical (Mario golpea desde abajo)
    lw $t2, mario_y             # mario_top
    lw $t3, 4($s0)              # block_y
    lw $t5, MYSTERY_BLOCK_SIZE
    add $t4, $t3, $t5           # block_bottom
   
    # Mario debe estar debajo del bloque
    bge $t2, $t4, next_mystery  # Mario está arriba del bloque
   
    # La cabeza de Mario debe estar MUY cerca del fondo del bloque
    sub $t6, $t2, $t4           # distancia = mario_top - block_bottom
    bgtz $t6, next_mystery      # Positivo = no hay contacto
    li $t7, -10                 # Tolerancia aumentada a 10 píxeles
    blt $t6, $t7, next_mystery
   
    # ¡Golpe detectado!
    li $t8, 1
    sw $t8, 8($s0)              # Marcar como golpeado
   
    # Crear power-up
    lw $a0, 0($s0)              # block x
    lw $a1, 4($s0)              # block y
    lw $a2, 12($s0)             # item type
    jal spawn_powerup
   
    # Hacer rebotar a Mario un poco
    li $t0, 3                   # Aumentado de 2 a 3
    lw $t1, mario_vy
    add $t1, $t1, $t0
    sw $t1, mario_vy
   
    j mystery_check_done

next_mystery:
    addi $s0, $s0, 16
    j check_mystery_loop

mystery_check_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

spawn_powerup:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
   
    move $s0, $a0               # x
    move $s1, $a1               # y
    move $s2, $a2               # type
   
    # Buscar slot vacío en powerups
    la $t0, powerups
find_empty_slot:
    lw $t1, 0($t0)
    li $t2, -1
    beq $t1, $t2, found_slot
    addi $t0, $t0, 20
    j find_empty_slot
   
found_slot:
    sw $s0, 0($t0)              # x
    addi $s1, $s1, -8           # y (arriba del bloque)
    sw $s1, 4($t0)
    sw $s2, 8($t0)              # type
    sw $zero, 12($t0)           # collected = 0
    lw $t3, POWERUP_BOUNCE
    sw $t3, 16($t0)             # vy inicial (salta)
   
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

update_powerups:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
   
    la $s0, powerups
   
update_powerup_loop:
    lw $t0, 0($s0)              # x
    li $t1, -1
    beq $t0, $t1, powerups_update_done
   
    lw $t2, 12($s0)             # collected
    bnez $t2, next_powerup_update
   
    # Aplicar gravedad
    lw $t3, 16($s0)             # vy
    lw $t4, POWERUP_GRAVITY
    add $t3, $t3, $t4
    sw $t3, 16($s0)
   
    # Actualizar Y
    lw $t5, 4($s0)
    add $t5, $t5, $t3
    sw $t5, 4($s0)
   
    # Verificar suelo
    lw $t6, GROUND_Y
    addi $t6, $t6, -8
    blt $t5, $t6, next_powerup_update
    sw $t6, 4($s0)
    sw $zero, 16($s0)           # vy = 0

next_powerup_update:
    addi $s0, $s0, 20
    j update_powerup_loop

powerups_update_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

draw_powerups:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
   
    la $s0, powerups
   
draw_powerup_loop:
    lw $t0, 0($s0)              # x
    li $t1, -1
    beq $t0, $t1, powerups_draw_done
   
    lw $t2, 12($s0)             # collected
    bnez $t2, skip_powerup_draw
   
    lw $t1, camera_x
    sub $a0, $t0, $t1           # Screen X
   
    # Verificar visibilidad
    li $t2, -16
    blt $a0, $t2, skip_powerup_draw
    li $t2, 136
    bge $a0, $t2, skip_powerup_draw
   
    lw $a1, 4($s0)              # y
    lw $t3, 8($s0)              # type
   
    # Seleccionar sprite
    beqz $t3, draw_star_powerup
   
draw_heart_powerup:
    la $s1, heart_sprite
    j draw_powerup_sprite
   
draw_star_powerup:
    la $s1, star_sprite
   
draw_powerup_sprite:
    move $a2, $s1
    jal draw_8x8_sprite

skip_powerup_draw:
    addi $s0, $s0, 20
    j draw_powerup_loop

powerups_draw_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

# Función auxiliar para dibujar sprites 8x8
draw_8x8_sprite:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    
    move $s0, $a0               # screen x
    move $s1, $a1               # screen y
    move $s2, $a2               # sprite address
    li $s3, 0                   # row
    
sprite_8x8_row:
    li $s4, 0                   # col
sprite_8x8_col:
    lw $t0, 0($s2)
    beqz $t0, skip_8x8_pixel
    
    add $a0, $s0, $s4
    add $a1, $s1, $s3
    move $a2, $t0
    jal draw_pixel
    
skip_8x8_pixel:
    addi $s2, $s2, 4
    addi $s4, $s4, 1
    li $t0, 8
    blt $s4, $t0, sprite_8x8_col
    
    addi $s3, $s3, 1
    li $t0, 8
    blt $s3, $t0, sprite_8x8_row
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra
    check_powerup_collection:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
   
    la $s0, powerups
   
collect_powerup_loop:
    lw $t0, 0($s0)              # x
    li $t1, -1
    beq $t0, $t1, collection_done
   
    lw $t1, 12($s0)             # collected
    bnez $t1, next_collect
   
    # Verificar colisión con Mario
    lw $t2, mario_x
    lw $t3, MARIO_WIDTH
    add $t4, $t2, $t3
   
    li $t5, 8
    add $t6, $t0, $t5
   
    bge $t2, $t6, next_collect
    ble $t4, $t0, next_collect
   
    lw $t2, mario_y
    lw $t3, MARIO_HEIGHT
    add $t4, $t2, $t3
   
    lw $t1, 4($s0)
    li $t5, 8
    add $t6, $t1, $t5
   
    bge $t2, $t6, next_collect
    ble $t4, $t1, next_collect
   
    # ¡Colectado!
    li $t7, 1
    sw $t7, 12($s0)
   
    # Aplicar efecto según tipo
    lw $t8, 8($s0)              # type
    beqz $t8, give_star
   
give_heart:
    lw $t0, mario_lives
    addi $t0, $t0, 1
    li $t1, 3
    ble $t0, $t1, store_lives
    li $t0, 3                   # Max 3 vidas
store_lives:
    sw $t0, mario_lives
    j next_collect
   
give_star:
    lw $t0, score
    addi $t0, $t0, 5000
    sw $t0, score

next_collect:
    addi $s0, $s0, 20
    j collect_powerup_loop

collection_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

mario_hit:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    lw $t0, mario_lives
    addi $t0, $t0, -1
    sw $t0, mario_lives
   
    blez $t0, hit_done
   
    li $t1, 10
    sw $t1, mario_x
    li $t1, 50
    sw $t1, mario_y
    sw $zero, mario_vy
    sw $zero, mario_vx
    li $t1, 1
    sw $t1, mario_on_ground
    sw $zero, camera_x
   
    li $a0, 15              # Delay más corto después de morir
    jal delay

hit_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Función para dibujar sprite de nube 12x6
# $a0 = screen X position
# $a1 = screen Y position
draw_cloud_sprite:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    
    move $s0, $a0               # X position
    move $s1, $a1               # Y position
    
    la $s2, cloud_sprite        # Sprite data
    li $s3, 0                   # Row counter (0-5)

cloud_row_loop:
    li $s4, 0                   # Column counter (0-11)
    
cloud_col_loop:
    lw $t0, 0($s2)              # Load pixel color
    
    # Skip transparent pixels
    beqz $t0, cloud_skip_pixel
    
    add $a0, $s0, $s4           # X = base_x + col
    add $a1, $s1, $s3           # Y = base_y + row
    move $a2, $t0               # Color
    
    jal draw_pixel

cloud_skip_pixel:
    addi $s2, $s2, 4            # Next pixel
    addi $s4, $s4, 1            # Next column
    li $t0, 12
    blt $s4, $t0, cloud_col_loop
    
    addi $s3, $s3, 1            # Next row
    li $t0, 6
    blt $s3, $t0, cloud_row_loop
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra

# Función para dibujar sprite de pájaro 6x4
# $a0 = screen X position
# $a1 = screen Y position
draw_bird_sprite:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    
    move $s0, $a0
    move $s1, $a1
    
    la $s2, bird_sprite
    li $s3, 0                   # Row counter (0-3)

bird_row_loop:
    li $s4, 0                   # Column counter (0-5)
    
bird_col_loop:
    lw $t0, 0($s2)
    
    beqz $t0, bird_skip_pixel
    
    add $a0, $s0, $s4
    add $a1, $s1, $s3
    move $a2, $t0
    
    jal draw_pixel

bird_skip_pixel:
    addi $s2, $s2, 4
    addi $s4, $s4, 1
    li $t0, 6
    blt $s4, $t0, bird_col_loop
    
    addi $s3, $s3, 1
    li $t0, 4
    blt $s3, $t0, bird_row_loop
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra

# Función para dibujar todas las nubes
draw_clouds:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
   
    la $s0, clouds_data
   
draw_clouds_loop:
    lw $t0, 0($s0)              # Cloud X
    li $t1, -1
    beq $t0, $t1, clouds_done
   
    lw $t1, camera_x
    sub $a0, $t0, $t1           # Screen X
   
    # Check if visible
    li $t2, -20
    blt $a0, $t2, skip_cloud
    li $t2, 140
    bge $a0, $t2, skip_cloud
   
    lw $a1, 4($s0)              # Cloud Y
    jal draw_cloud_sprite

skip_cloud:
    addi $s0, $s0, 8
    j draw_clouds_loop

clouds_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

# Función para dibujar todos los pájaros
draw_birds:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
   
    la $s0, birds_data
   
draw_birds_loop:
    lw $t0, 0($s0)              # Bird X
    li $t1, -1
    beq $t0, $t1, birds_done
   
    lw $t1, camera_x
    sub $a0, $t0, $t1           # Screen X
   
    # Check if visible
    li $t2, -10
    blt $a0, $t2, skip_bird
    li $t2, 135
    bge $a0, $t2, skip_bird
   
    lw $a1, 4($s0)              # Bird Y
    jal draw_bird_sprite

skip_bird:
    addi $s0, $s0, 8
    j draw_birds_loop

birds_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra
    

draw_lives_hud:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    lw $s0, mario_lives      # Cargar vidas actuales
    li $s1, 0                # Contador de corazón
    
draw_lives_loop:
    li $t0, 3
    bge $s1, $t0, lives_hud_done
    
    # Calcular posición X: 112 - (heart_index * 10)
    li $t1, 10
    mul $t2, $s1, $t1
    li $a0, 112
    sub $a0, $a0, $t2        # X = 112, 102, 92
    
    li $a1, 2                # Y fijo arriba
    
    # Determinar si dibujar corazón lleno o vacío
    blt $s1, $s0, draw_full_heart
    
draw_empty_heart:
    la $a2, heart_empty_sprite
    j draw_heart_sprite_call
    
draw_full_heart:
    la $a2, heart_sprite
    
draw_heart_sprite_call:
    jal draw_8x8_sprite
    
    addi $s1, $s1, 1
    j draw_lives_loop
    
lives_hud_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

# Función para dibujar el HUD (Score y Coins)
draw_hud:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    
    # Dibujar "SCORE:" en la esquina superior izquierda
    li $s0, 0xFFFFFFFF          # Color blanco
    
    # S
    li $a0, 2
    li $a1, 2
    li $a2, 2
    li $a3, 8
    move $t0, $s0
    jal fill_rect
    
    li $a0, 2
    li $a1, 2
    li $a2, 6
    li $a3, 2
    move $t0, $s0
    jal fill_rect
    
    li $a0, 2
    li $a1, 5
    li $a2, 6
    li $a3, 2
    move $t0, $s0
    jal fill_rect
    
    li $a0, 6
    li $a1, 8
    li $a2, 2
    li $a3, 2
    move $t0, $s0
    jal fill_rect
    
    # Dibujar valor del score (simplificado - mostrar dígitos)
    lw $t1, score
    
    # Dividir en dígitos y dibujar
    li $a0, 12                  # Posición X para números
    li $a1, 2                   # Posición Y
    move $a2, $t1               # Score
    jal draw_number
    
    # Dibujar símbolo de moneda
    li $a0, 50
    li $a1, 3
    la $a2, moneda_data
    jal draw_8x8_sprite
    
    # Dibujar cantidad de monedas
    li $a0, 60
    li $a1, 2
    lw $a2, coins
    jal draw_number
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

# Función auxiliar para dibujar un número (máximo 5 dígitos)
draw_number:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    
    move $s0, $a0               # X position
    move $s1, $a1               # Y position
    move $s2, $a2               # Number
    
    # Convertir número a string (máx 5 dígitos)
    li $s3, 10000               # Divisor inicial
    
draw_digit_loop:
    beqz $s3, draw_number_done
    
    div $s2, $s3
    mflo $t0                    # Dígito actual
    mfhi $s2                    # Resto
    
    # Dibujar dígito (0-9)
    move $a0, $s0
    move $a1, $s1
    move $a2, $t0
    jal draw_digit_sprite
    
    addi $s0, $s0, 6            # Siguiente posición X
    
    li $t1, 10
    div $s3, $t1
    mflo $s3                    # Siguiente divisor
    
    j draw_digit_loop
    
draw_number_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra

# Función para dibujar un dígito (0-9) simplificado 4x6
draw_digit_sprite:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    move $s0, $a0               # X
    move $s1, $a1               # Y
    
    li $t9, 0xFFFFFF00          # Color amarillo
    
    # Switch case para cada dígito
    beqz $a2, draw_0
    li $t0, 1
    beq $a2, $t0, draw_1
    li $t0, 2
    beq $a2, $t0, draw_2
    li $t0, 3
    beq $a2, $t0, draw_3
    li $t0, 4
    beq $a2, $t0, draw_4
    li $t0, 5
    beq $a2, $t0, draw_5
    li $t0, 6
    beq $a2, $t0, draw_6
    li $t0, 7
    beq $a2, $t0, draw_7
    li $t0, 8
    beq $a2, $t0, draw_8
    li $t0, 9
    beq $a2, $t0, draw_9
    j digit_done

draw_0:
    move $a0, $s0
    move $a1, $s1
    li $a2, 4
    li $a3, 6
    move $t0, $t9
    jal fill_rect
    addi $a0, $s0, 1
    addi $a1, $s1, 1
    li $a2, 2
    li $a3, 4
    lw $t0, COLOR_SKY
    jal fill_rect
    j digit_done

draw_1:
    addi $a0, $s0, 1
    move $a1, $s1
    li $a2, 2
    li $a3, 6
    move $t0, $t9
    jal fill_rect
    j digit_done

draw_2:
    move $a0, $s0
    move $a1, $s1
    li $a2, 4
    li $a3, 2
    move $t0, $t9
    jal fill_rect
    addi $a0, $s0, 2
    addi $a1, $s1, 2
    li $a2, 2
    li $a3, 2
    move $t0, $t9
    jal fill_rect
    move $a0, $s0
    addi $a1, $s1, 4
    li $a2, 4
    li $a3, 2
    move $t0, $t9
    jal fill_rect
    j digit_done

draw_3:
    move $a0, $s0
    move $a1, $s1
    li $a2, 4
    li $a3, 2
    move $t0, $t9
    jal fill_rect
    move $a0, $s0
    addi $a1, $s1, 2
    li $a2, 4
    li $a3, 2
    move $t0, $t9
    jal fill_rect
    move $a0, $s0
    addi $a1, $s1, 4
    li $a2, 4
    li $a3, 2
    move $t0, $t9
    jal fill_rect
    j digit_done

draw_4:
    move $a0, $s0
    move $a1, $s1
    li $a2, 2
    li $a3, 4
    move $t0, $t9
    jal fill_rect
    addi $a0, $s0, 2
    move $a1, $s1
    li $a2, 2
    li $a3, 6
    move $t0, $t9
    jal fill_rect
    move $a0, $s0
    addi $a1, $s1, 3
    li $a2, 4
    li $a3, 1
    move $t0, $t9
    jal fill_rect
    j digit_done

draw_5:
    move $a0, $s0
    move $a1, $s1
    li $a2, 4
    li $a3, 2
    move $t0, $t9
    jal fill_rect
    move $a0, $s0
    addi $a1, $s1, 2
    li $a2, 4
    li $a3, 2
    move $t0, $t9
    jal fill_rect
    move $a0, $s0
    addi $a1, $s1, 4
    li $a2, 4
    li $a3, 2
    move $t0, $t9
    jal fill_rect
    move $a0, $s0
    addi $a1, $s1, 2
    li $a2, 2
    li $a3, 2
    lw $t0, COLOR_SKY
    jal fill_rect
    j digit_done

draw_6:
    move $a0, $s0
    move $a1, $s1
    li $a2, 4
    li $a3, 6
    move $t0, $t9
    jal fill_rect
    addi $a0, $s0, 1
    addi $a1, $s1, 4
    li $a2, 2
    li $a3, 1
    lw $t0, COLOR_SKY
    jal fill_rect
    addi $a0, $s0, 2
    addi $a1, $s1, 1
    li $a2, 2
    li $a3, 2
    lw $t0, COLOR_SKY
    jal fill_rect
    j digit_done

draw_7:
    move $a0, $s0
    move $a1, $s1
    li $a2, 4
    li $a3, 2
    move $t0, $t9
    jal fill_rect
    addi $a0, $s0, 2
    addi $a1, $s1, 2
    li $a2, 2
    li $a3, 4
    move $t0, $t9
    jal fill_rect
    j digit_done

draw_8:
    move $a0, $s0
    move $a1, $s1
    li $a2, 4
    li $a3, 6
    move $t0, $t9
    jal fill_rect
    addi $a0, $s0, 1
    addi $a1, $s1, 1
    li $a2, 2
    li $a3, 1
    lw $t0, COLOR_SKY
    jal fill_rect
    addi $a0, $s0, 1
    addi $a1, $s1, 4
    li $a2, 2
    li $a3, 1
    lw $t0, COLOR_SKY
    jal fill_rect
    j digit_done

draw_9:
    move $a0, $s0
    move $a1, $s1
    li $a2, 4
    li $a3, 6
    move $t0, $t9
    jal fill_rect
    addi $a0, $s0, 1
    addi $a1, $s1, 4
    li $a2, 2
    li $a3, 1
    lw $t0, COLOR_SKY
    jal fill_rect
    addi $a0, $s0, 1
    addi $a1, $s1, 1
    li $a2, 2
    li $a3, 1
    lw $t0, COLOR_SKY
    jal fill_rect

digit_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

render_frame:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    jal clear_screen
    jal draw_clouds
    jal draw_birds
    jal draw_ground
    jal draw_platforms
    jal draw_mystery_blocks
    jal draw_pipes
    jal draw_castle
    jal draw_flag
    jal draw_coins
    jal draw_powerups 
    jal draw_lives_hud       # ? AGREGA ESTA LÍNEA (estaba faltando!)
    jal draw_mario
    jal draw_goombas
    jal draw_hud  
   
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
clear_screen:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    li $t0, 0x10008000
    lw $t1, COLOR_SKY
    li $t2, 8192
   
clear_loop:
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    addi $t2, $t2, -1
    bgtz $t2, clear_loop
   
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

draw_ground:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
   
    la $s0, ground_segments
   
draw_ground_loop:
    lw $s1, 0($s0)              # x_start
    li $t0, -1
    beq $s1, $t0, ground_done
   
    lw $s2, 4($s0)              # x_end
   
    # Dibujar tiles de suelo a lo largo del segmento
    move $s3, $s1               # x_current = x_start
   
draw_ground_tiles:
    bge $s3, $s2, next_ground_segment
   
    # NUEVO: Verificar si hay una pipe en esta posición
    move $a0, $s3
    jal check_if_pipe_here
    bnez $v0, skip_ground_for_pipe
   
    lw $t0, camera_x
    sub $a0, $s3, $t0
   
    li $t1, -10
    blt $a0, $t1, skip_ground_tile
    li $t1, 130
    bge $a0, $t1, skip_ground_tile
   
    lw $a1, GROUND_Y
    jal draw_ground_tile_sprite

skip_ground_tile:
skip_ground_for_pipe:
    addi $s3, $s3, 8
    j draw_ground_tiles

next_ground_segment:
    addi $s0, $s0, 8
    j draw_ground_loop

ground_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra

# Verifica si hay una pipe en la posición X dada
# $a0 = x position
# $v0 = 1 si hay pipe, 0 si no
check_if_pipe_here:
    addi $sp, $sp, -8
    sw $s0, 0($sp)
    sw $ra, 4($sp)
    
    move $t0, $a0
    la $s0, pipes
    
check_pipe_x_loop:
    lw $t1, 0($s0)          # pipe_x
    li $t2, -1
    beq $t1, $t2, no_pipe_here
    
    lw $t3, 8($s0)          # pipe_width
    add $t4, $t1, $t3       # pipe_right
    
    blt $t0, $t1, next_pipe_check
    bge $t0, $t4, next_pipe_check
    
    # Hay pipe aquí
    li $v0, 1
    j check_pipe_done
    
next_pipe_check:
    addi $s0, $s0, 16
    j check_pipe_x_loop
    
no_pipe_here:
    li $v0, 0
    
check_pipe_done:
    lw $s0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra
# Función para dibujar sprite de bloque de suelo 8x8
# $a0 = screen X position
# $a1 = screen Y position
draw_ground_tile_sprite:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    
    move $s0, $a0               # X position
    move $s1, $a1               # Y position
    
    la $s2, ground_tile_sprite  # Sprite data
    li $s3, 0                   # Row counter (0-7)

ground_tile_row_loop:
    li $s4, 0                   # Column counter (0-7)
    
ground_tile_col_loop:
    lw $t0, 0($s2)              # Load pixel color
    
    # Calculate screen position
    add $a0, $s0, $s4           # X = base_x + col
    add $a1, $s1, $s3           # Y = base_y + row
    move $a2, $t0               # Color
    
    jal draw_pixel

    addi $s2, $s2, 4            # Next pixel
    addi $s4, $s4, 1            # Next column
    li $t0, 8
    blt $s4, $t0, ground_tile_col_loop
    
    addi $s3, $s3, 1            # Next row
    li $t0, 8
    blt $s3, $t0, ground_tile_row_loop
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra

draw_platforms:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
   
    la $s0, platforms
   
draw_platform_loop:
    lw $s1, 0($s0)
    li $t0, -1
    beq $s1, $t0, platforms_draw_done
   
    lw $t0, camera_x
    sub $a0, $s1, $t0
   
    li $t1, -16
    blt $a0, $t1, skip_platform
    li $t1, 140
    bge $a0, $t1, skip_platform
   
    lw $s2, 8($s0)              # width
    li $s3, 0
   
draw_platform_tiles:
    bge $s3, $s2, skip_platform
   
    lw $t0, camera_x
    add $t1, $s1, $s3
    sub $a0, $t1, $t0
   
    li $t2, -16
    blt $a0, $t2, next_platform_tile
    li $t2, 140
    bge $a0, $t2, next_platform_tile
   
    lw $a1, 4($s0)
    jal draw_brick_tile_sprite

next_platform_tile:
    addi $s3, $s3, 8            # Avanzar 8 píxeles
    j draw_platform_tiles

skip_platform:
    addi $s0, $s0, 16
    j draw_platform_loop

platforms_draw_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra
    
    
draw_mystery_blocks:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
   
    la $s0, mystery_blocks
   
draw_mystery_loop:
    lw $s1, 0($s0)              # block x
    li $t0, -1
    beq $s1, $t0, mystery_blocks_done
   
    # Verificar visibilidad
    lw $t0, camera_x
    sub $t1, $s1, $t0           # Screen X
   
    li $t2, -16
    blt $t1, $t2, skip_mystery
    li $t2, 140
    bge $t1, $t2, skip_mystery
   
    lw $s3, 4($s0)              # block y
    lw $t2, 8($s0)              # hit flag
   
    # Seleccionar sprite según si fue golpeado
    beqz $t2, draw_normal_block
   
draw_used_block:
    la $s2, mystery_block_used_sprite
    j draw_mystery_sprite_start
   
draw_normal_block:
    la $s2, mystery_block_sprite
   
draw_mystery_sprite_start:
    # Dibujar sprite 8x8
    li $t3, 0                   # row counter
    
mystery_row_loop:
    li $t4, 0                   # col counter
    
mystery_col_loop:
    lw $t0, 0($s2)              # Load pixel color
    
    # Calcular posición en pantalla
    add $t5, $s1, $t4           # block_x + col
    lw $t6, camera_x
    sub $a0, $t5, $t6           # screen_x
    
    add $a1, $s3, $t3           # block_y + row
    move $a2, $t0               # color
    
    # Guardar registros antes de llamar draw_pixel
    addi $sp, $sp, -24
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $t3, 16($sp)
    sw $t4, 20($sp)
    
    jal draw_pixel
    
    # Restaurar registros
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $t3, 16($sp)
    lw $t4, 20($sp)
    addi $sp, $sp, 24
    
    addi $s2, $s2, 4            # Next pixel
    addi $t4, $t4, 1            # Next column
    li $t0, 8
    blt $t4, $t0, mystery_col_loop
    
    addi $t3, $t3, 1            # Next row
    li $t0, 8
    blt $t3, $t0, mystery_row_loop

skip_mystery:
    addi $s0, $s0, 16           # Next mystery block
    j draw_mystery_loop

mystery_blocks_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra
# Función para dibujar sprite de ladrillo 8x8
draw_brick_tile_sprite:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    
    move $s0, $a0
    move $s1, $a1
    
    la $s2, brick_tile_sprite
    li $s3, 0                   # Row counter (0-7)

brick_tile_row_loop:
    li $s4, 0                   # Column counter (0-7)
    
brick_tile_col_loop:
    lw $t0, 0($s2)
    
    add $a0, $s0, $s4
    add $a1, $s1, $s3
    move $a2, $t0
    
    jal draw_pixel

    addi $s2, $s2, 4
    addi $s4, $s4, 1
    li $t0, 8                   # CAMBIADO A 8
    blt $s4, $t0, brick_tile_col_loop
    
    addi $s3, $s3, 1
    li $t0, 8                   # CAMBIADO A 8
    blt $s3, $t0, brick_tile_row_loop
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra

draw_pipes:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
   
    la $s0, pipes
   
draw_pipe_loop:
    lw $s1, 0($s0)
    li $t0, -1
    beq $s1, $t0, pipes_draw_done
   
    lw $t0, camera_x
    sub $a0, $s1, $t0
   
    li $t1, -20
    blt $a0, $t1, skip_pipe
    li $t1, 128
    bge $a0, $t1, skip_pipe
   
    lw $a1, 4($s0)
    lw $a2, 8($s0)
    lw $a3, 12($s0)
    
    # Llamar a la nueva función de sprite
    jal draw_pipe_sprite_simple

skip_pipe:
    addi $s0, $s0, 16
    j draw_pipe_loop

pipes_draw_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra

# Función para dibujar pipe completo estilo SMB
# $a0 = screen X position
# $a1 = screen Y position  
# $a2 = height (altura total del pipe en píxeles)
# Función simple para dibujar pipe con sprite
# $a0 = screen X, $a1 = Y, $a2 = width, $a3 = height
draw_pipe_sprite_simple:
    addi $sp, $sp, -32
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    sw $s5, 24($sp)
    sw $s6, 28($sp)
    
    move $s0, $a0          # X
    move $s1, $a1          # Y
    move $s2, $a2          # width (ignorado, siempre usar 8)
    move $s3, $a3          # height
    
    # Dibujar labio superior (3 filas)
    la $s4, pipe_top_sprite
    li $s5, 0              # row counter
    
pipe_top_loop:
    bge $s5, 3, pipe_body_start
    li $s6, 0              # col counter
    
pipe_top_col:
    bge $s6, 8, pipe_top_next_row
    
    lw $t0, 0($s4)
    add $a0, $s0, $s6
    add $a1, $s1, $s5
    move $a2, $t0
    jal draw_pixel
    
    addi $s4, $s4, 4
    addi $s6, $s6, 1
    j pipe_top_col
    
pipe_top_next_row:
    addi $s5, $s5, 1
    j pipe_top_loop

pipe_body_start:
    addi $s5, $s1, 3       # Start Y after lip
    add $t0, $s1, $s3      # End Y
    
    # IMPORTANTE: Ajustar para que no atraviese el suelo
    lw $t1, GROUND_Y
    bgt $t0, $t1, clamp_pipe_to_ground
    j pipe_body_loop
    
clamp_pipe_to_ground:
    move $t0, $t1          # Limitar al nivel del suelo
    
pipe_body_loop:
    bge $s5, $t0, pipe_done
    
    # Calcular fila del patrón (0-3)
    sub $t2, $s5, $s1
    sub $t2, $t2, 3        # Restar las 3 filas del labio
    andi $t2, $t2, 3       # Módulo 4
    la $s4, pipe_body_sprite
    sll $t3, $t2, 5        # * 32 (8 pixels * 4 bytes)
    add $s4, $s4, $t3
    
    li $s6, 0
    
pipe_body_col:
    bge $s6, 8, pipe_body_next_row
    
    lw $t0, 0($s4)
    add $a0, $s0, $s6
    move $a1, $s5
    move $a2, $t0
    jal draw_pixel
    
    addi $s4, $s4, 4
    addi $s6, $s6, 1
    j pipe_body_col
    
pipe_body_next_row:
    addi $s5, $s5, 1
    j pipe_body_loop

pipe_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    lw $s6, 28($sp)
    addi $sp, $sp, 32
    jr $ra
    
draw_castle:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
   
    lw $t0, CASTLE_X
    lw $t1, camera_x
    sub $s0, $t0, $t1           # Screen X
   
    # Verificar si está visible
    li $t2, -30
    blt $s0, $t2, castle_done
    li $t2, 128
    bge $s0, $t2, castle_done
   
    lw $s1, CASTLE_Y            # Screen Y
    
    # Dibujar sprite del castillo 24x20
    la $s2, castle_sprite
    li $s3, 0                   # Row counter (0-19)

castle_row_loop:
    li $s4, 0                   # Column counter (0-23)
    
castle_col_loop:
    lw $t0, 0($s2)              # Load pixel color
    
    # Skip transparent pixels
    beqz $t0, castle_skip_pixel
    
    add $a0, $s0, $s4           # X = base_x + col
    add $a1, $s1, $s3           # Y = base_y + row
    move $a2, $t0               # Color
    
    jal draw_pixel

castle_skip_pixel:
    addi $s2, $s2, 4            # Next pixel
    addi $s4, $s4, 1            # Next column
    li $t0, 24
    blt $s4, $t0, castle_col_loop
    
    addi $s3, $s3, 1            # Next row
    li $t0, 20
    blt $s3, $t0, castle_row_loop

castle_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra

draw_flag:
    addi $sp, $sp, -28
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    sw $s5, 24($sp)
   
    lw $t0, FLAG_X
    lw $t1, camera_x
    sub $s0, $t0, $t1           # Screen X
   
    # Verificar si está visible
    li $t2, -15
    blt $s0, $t2, flag_done
    li $t2, 128
    bge $s0, $t2, flag_done
   
    # Dibujar asta de la bandera (gris oscuro)
    lw $t3, GROUND_Y
    lw $t4, FLAG_POLE_HEIGHT
    sub $s5, $t3, $t4           # Top Y del asta
    
    move $a0, $s0
    move $a1, $s5
    li $a2, 2                   # width del asta
    move $a3, $t4               # height del asta
    lw $t0, COLOR_FLAG_POLE
    jal fill_rect
   
    # Dibujar bandera argentina con sprite 12x8
    addi $s0, $s0, 2            # X después del asta
    addi $s1, $s5, 4            # Y un poco abajo del tope
    
    la $s2, argentina_flag_sprite
    li $s3, 0                   # Row counter (0-7)

flag_row_loop:
    li $s4, 0                   # Column counter (0-11)
    
flag_col_loop:
    lw $t0, 0($s2)              # Load pixel color
    
    add $a0, $s0, $s4           # X = base_x + col
    add $a1, $s1, $s3           # Y = base_y + row
    move $a2, $t0               # Color
    
    jal draw_pixel
    
    addi $s2, $s2, 4            # Next pixel
    addi $s4, $s4, 1            # Next column
    li $t0, 12
    blt $s4, $t0, flag_col_loop
    
    addi $s3, $s3, 1            # Next row
    li $t0, 8
    blt $s3, $t0, flag_row_loop

flag_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    addi $sp, $sp, 28
    jr $ra
draw_coins:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
   
    la $s0, coins_data
   
draw_coin_loop:
    lw $t0, 0($s0)          # Coin X
    li $t1, -1
    beq $t0, $t1, coins_draw_done
   
    lw $t1, 8($s0)          # Collected flag
    bnez $t1, skip_coin
   
    lw $t1, camera_x
    sub $a0, $t0, $t1       # Screen X = world X - camera X
   
    # Check if coin is on screen
    li $t2, -20             # Extended left boundary
    blt $a0, $t2, skip_coin
    li $t2, 128
    bge $a0, $t2, skip_coin
   
    lw $a1, 4($s0)          # Coin Y
    
    # DRAW SPRITE INSTEAD OF RECTANGLE
    jal draw_coin_sprite    # Call new sprite function!

skip_coin:
    addi $s0, $s0, 12
    j draw_coin_loop

coins_draw_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

# New function: draws 16x16 coin sprite
# $a0 = screen X position (in units)
# $a1 = screen Y position (in units)
# Función actualizada para sprite 4x4
draw_coin_sprite:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    
    move $s0, $a0           # X position
    move $s1, $a1           # Y position
    
    la $s2, moneda_data     # Sprite data
    li $s3, 0               # Row counter (0-7)

coin_sprite_row_loop:
    li $s4, 0               # Column counter (0-7)
    
coin_sprite_col_loop:
    lw $t0, 0($s2)          # Load pixel color
    
    # Skip if transparent
    beqz $t0, coin_sprite_skip_pixel
    
    # Calculate screen position
    add $a0, $s0, $s4       # X = base_x + col
    add $a1, $s1, $s3       # Y = base_y + row
    move $a2, $t0           # Color
    
    jal draw_pixel

coin_sprite_skip_pixel:
    addi $s2, $s2, 4        # Next pixel
    addi $s4, $s4, 1        # Next column
    li $t0, 8               # 8 columnas
    blt $s4, $t0, coin_sprite_col_loop
    
    addi $s3, $s3, 1        # Next row
    li $t0, 8               # 8 filas
    blt $s3, $t0, coin_sprite_row_loop
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra

draw_mario:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    
    # Calcular posición en pantalla
    lw $t0, mario_x
    lw $t1, camera_x
    sub $s0, $t0, $t1       # Screen X
    lw $s1, mario_y         # Screen Y
    
    # Determinar dirección basada en velocidad
    lw $t0, mario_vx
    bgtz $t0, set_facing_right
    bltz $t0, set_facing_left
    j check_jump_animation
    
set_facing_right:
    li $t1, 1
    sw $t1, mario_facing_right
    j check_jump_animation
    
set_facing_left:
    sw $zero, mario_facing_right

check_jump_animation:
    # Si está en el aire, usar sprite de salto
    lw $t0, mario_on_ground
    beqz $t0, mario_jumping
    
    # Si está en el suelo, determinar animación normal
    lw $t0, mario_vx
    beqz $t0, mario_standing
    
    # Mario se está moviendo - ciclar animación
    lw $t1, mario_animation_counter
    addi $t1, $t1, 1
    sw $t1, mario_animation_counter
    
    li $t2, 5
    div $t1, $t2
    mfhi $t3
    bnez $t3, mario_select_sprite
    
    lw $t4, mario_animation_frame
    addi $t4, $t4, 1
    li $t5, 3
    blt $t4, $t5, save_new_frame
    li $t4, 0
    
save_new_frame:
    sw $t4, mario_animation_frame
    j mario_select_sprite

mario_standing:
    sw $zero, mario_animation_frame
    sw $zero, mario_animation_counter
    j mario_select_sprite

mario_jumping:
    # Usar sprite de salto
    li $t0, 99
    sw $t0, mario_animation_frame
    j mario_select_sprite

mario_select_sprite:
    lw $t0, mario_animation_frame
    
    # Si frame == 99, es salto
    li $t1, 99
    beq $t0, $t1, use_mario_jump
    
    # Frames normales
    beqz $t0, use_mario_frame1
    li $t1, 1
    beq $t0, $t1, use_mario_frame2
    li $t1, 2
    beq $t0, $t1, use_mario_frame3
    j use_mario_frame1

use_mario_frame1:
    la $s2, mario_sprite_frame1
    j start_mario_draw

use_mario_frame2:
    la $s2, mario_sprite_frame2
    j start_mario_draw

use_mario_frame3:
    la $s2, mario_sprite_frame3
    j start_mario_draw

use_mario_jump:
    la $s2, mario_sprite_frame_jump

start_mario_draw:
    li $s3, 0               # Row counter (0-11)

mario_sprite_row_loop:
    li $s4, 0               # Column counter (0-11)
    
mario_sprite_col_loop:
    # Calcular índice en el sprite
    lw $t0, mario_facing_right
    beqz $t0, mario_flip_pixel
    
    # Normal (mirando derecha)
    li $t1, 12
    mul $t2, $s3, $t1
    add $t2, $t2, $s4
    sll $t2, $t2, 2
    add $t3, $s2, $t2
    lw $t0, 0($t3)
    
    move $t4, $s4          # x_offset normal
    j mario_draw_pixel
    
mario_flip_pixel:
    # Espejado (mirando izquierda)
    li $t1, 12
    mul $t2, $s3, $t1
    li $t5, 11
    sub $t6, $t5, $s4      # Invertir columna
    add $t2, $t2, $t6
    sll $t2, $t2, 2
    add $t3, $s2, $t2
    lw $t0, 0($t3)
    
    move $t4, $s4          # x_offset normal (no invertir posición)

mario_draw_pixel:
    # Skip transparent pixels
    beqz $t0, mario_sprite_skip_pixel
    
    # Calculate screen position
    add $a0, $s0, $t4      # X = base_x + col
    add $a1, $s1, $s3      # Y = base_y + row
    move $a2, $t0          # Color
    
    jal draw_pixel

mario_sprite_skip_pixel:
    addi $s4, $s4, 1       # Next column
    li $t0, 12
    blt $s4, $t0, mario_sprite_col_loop
    
    addi $s3, $s3, 1       # Next row
    li $t0, 12
    blt $s3, $t0, mario_sprite_row_loop
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra
    
    
draw_goombas:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
   
    # Alternar frame de animación basado en goomba_move_counter
    lw $t0, goomba_move_counter
    andi $t0, $t0, 1              # 0 o 1
    sw $t0, goomba_animation_frame
   
    la $s0, goombas
   
draw_goomba_loop:
    lw $t0, 0($s0)                # X del goomba
    li $t1, -1
    beq $t0, $t1, goombas_draw_done
   
    lw $t1, 4($s0)                # alive flag
    beqz $t1, skip_goomba
   
    lw $t1, camera_x
    sub $a0, $t0, $t1             # Screen X
   
    # Check si está visible
    li $t2, -8
    blt $a0, $t2, skip_goomba
    li $t2, 128
    bge $a0, $t2, skip_goomba
   
    # Calcular Y (siempre en el suelo)
    lw $t3, GROUND_Y
    lw $t4, GOOMBA_HEIGHT
    sub $a1, $t3, $t4
   
    # Dibujar sprite animado
    jal draw_goomba_sprite

skip_goomba:
    addi $s0, $s0, 20
    j draw_goomba_loop

goombas_draw_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

# Nueva función para dibujar sprite de goomba animado
# $a0 = screen X position
# $a1 = screen Y position
draw_goomba_sprite:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    
    move $s0, $a0               # X position
    move $s1, $a1               # Y position
    
    # Seleccionar frame según goomba_animation_frame
    lw $t0, goomba_animation_frame
    beqz $t0, use_frame1
    
use_frame2:
    la $s2, goomba_sprite_frame2
    j start_goomba_draw
    
use_frame1:
    la $s2, goomba_sprite_frame1
    
start_goomba_draw:
    li $s3, 0                   # Row counter (0-5)

goomba_sprite_row_loop:
    li $s4, 0                   # Column counter (0-5)
    
goomba_sprite_col_loop:
    lw $t0, 0($s2)              # Load pixel color
    
    # Skip transparent pixels
    beqz $t0, goomba_sprite_skip_pixel
    
    add $a0, $s0, $s4           # X = base_x + col
    add $a1, $s1, $s3           # Y = base_y + row
    move $a2, $t0               # Color
    
    jal draw_pixel

goomba_sprite_skip_pixel:
    addi $s2, $s2, 4            # Next pixel
    addi $s4, $s4, 1            # Next column
    li $t0, 6
    li $t0, 8
    blt $s4, $t0, goomba_sprite_col_loop
    
    addi $s3, $s3, 1            # Next row
    li $t0, 8
    blt $s3, $t0, goomba_sprite_row_loop
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra

fill_rect:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
   
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    move $t9, $t0
   
    li $t8, 0
rect_row:
    bge $t8, $s3, rect_done
    li $t7, 0
rect_col:
    bge $t7, $s2, rect_next_row
    add $a0, $s0, $t7
    add $a1, $s1, $t8
    move $a2, $t9
    jal draw_pixel
    addi $t7, $t7, 1
    j rect_col
rect_next_row:
    addi $t8, $t8, 1
    j rect_row
rect_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra

draw_pixel:
    bltz $a0, pixel_skip
    bltz $a1, pixel_skip
    li $t0, 128
    bge $a0, $t0, pixel_skip
    li $t0, 64
    bge $a1, $t0, pixel_skip
   
    li $t0, 0x10008000
    sll $t1, $a1, 7
    add $t1, $t1, $a0
    sll $t1, $t1, 2
    add $t0, $t0, $t1
    sw $a2, 0($t0)
pixel_skip:
    jr $ra

# ============= NUEVA FUNCIÓN DE MENÚ DE INICIO =============
show_start_screen:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    # Llenar pantalla con azul oscuro
    li $t0, 0x10008000
    li $t1, 0x001133FF      # Azul oscuro
    li $t2, 8192
   
start_clear:
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    addi $t2, $t2, -1
    bgtz $t2, start_clear
   
    # Dibujar "MARIO" en rojo (posición 34, 10)
    li $a0, 34
    li $a1, 10
    jal draw_title_mario
   
    # Dibujar "BROS" en dorado (posición 40, 24)
    li $a0, 40
    li $a1, 24
    jal draw_title_bros
   
    # Dibujar "VERSION MIPS" en verde (posición 32, 36)
    li $a0, 32
    li $a1, 36
    jal draw_subtitle
   
    # Dibujar "PRESS ENTER" en blanco (posición 36, 48)
    li $a0, 36
    li $a1, 48
    jal draw_press_enter
   
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Función para dibujar sprite de "MARIO" 60x6
draw_title_mario:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    
    move $s0, $a0
    move $s1, $a1
    la $s2, title_mario_sprite
    li $s3, 0               # Row counter
    
mario_title_row:
    li $s4, 0               # Column counter
    
mario_title_col:
    lw $t0, 0($s2)
    beqz $t0, mario_title_skip
    
    add $a0, $s0, $s4
    add $a1, $s1, $s3
    move $a2, $t0
    jal draw_pixel
    
mario_title_skip:
    addi $s2, $s2, 4
    addi $s4, $s4, 1
    li $t0, 60
    blt $s4, $t0, mario_title_col
    
    addi $s3, $s3, 1
    li $t0, 6
    blt $s3, $t0, mario_title_row
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra

# Función para dibujar sprite de "BROS" 48x5
draw_title_bros:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    
    move $s0, $a0
    move $s1, $a1
    la $s2, title_bros_sprite
    li $s3, 0
    
bros_title_row:
    li $s4, 0
    
bros_title_col:
    lw $t0, 0($s2)
    beqz $t0, bros_title_skip
    
    add $a0, $s0, $s4
    add $a1, $s1, $s3
    move $a2, $t0
    jal draw_pixel
    
bros_title_skip:
    addi $s2, $s2, 4
    addi $s4, $s4, 1
    li $t0, 48
    blt $s4, $t0, bros_title_col
    
    addi $s3, $s3, 1
    li $t0, 5
    blt $s3, $t0, bros_title_row
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra

# Función para dibujar "VERSION MIPS" 64x5
draw_subtitle:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    
    move $s0, $a0
    move $s1, $a1
    la $s2, subtitle_sprite
    li $s3, 0
    
subtitle_row:
    li $s4, 0
    
subtitle_col:
    lw $t0, 0($s2)
    beqz $t0, subtitle_skip
    
    add $a0, $s0, $s4
    add $a1, $s1, $s3
    move $a2, $t0
    jal draw_pixel
    
subtitle_skip:
    addi $s2, $s2, 4
    addi $s4, $s4, 1
    li $t0, 64
    blt $s4, $t0, subtitle_col
    
    addi $s3, $s3, 1
    li $t0, 5
    blt $s3, $t0, subtitle_row
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra

# Función para dibujar "PRESS ENTER" 57x4
draw_press_enter:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    
    move $s0, $a0
    move $s1, $a1
    la $s2, press_enter_sprite
    li $s3, 0
    
press_row:
    li $s4, 0
    
press_col:
    lw $t0, 0($s2)
    beqz $t0, press_skip
    
    add $a0, $s0, $s4
    add $a1, $s1, $s3
    move $a2, $t0
    jal draw_pixel
    
press_skip:
    addi $s2, $s2, 4
    addi $s4, $s4, 1
    li $t0, 57
    blt $s4, $t0, press_col
    
    addi $s3, $s3, 1
    li $t0, 4
    blt $s3, $t0, press_row
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra

# ============= NUEVA FUNCIÓN DE GAME OVER =============
show_game_over_screen_visual:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    # Llenar pantalla con negro
    li $t0, 0x10008000
    li $t1, 0x00000000
    li $t2, 8192
   
gameover_clear:
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    addi $t2, $t2, -1
    bgtz $t2, gameover_clear
   
    # Dibujar "GAME OVER" grande en rojo (posición 29, 24)
    li $a0, 29
    li $a1, 24
    jal draw_gameover_sprite
   
    # Dibujar "PRESS R TO RETRY" pequeño debajo (posición 28, 40)
    li $s7, 0xFFFFFFFF       # Blanco
    li $a0, 28
    li $a1, 40
    li $a2, 2
    li $a3, 8
    move $t0, $s7
    jal fill_rect
   
    li $a0, 31
    li $a1, 40
    li $a2, 2
    li $a3, 2
    move $t0, $s7
    jal fill_rect
   
    li $a0, 31
    li $a1, 44
    li $a2, 2
    li $a3, 4
    move $t0, $s7
    jal fill_rect
   
    # Continue with more simple text patterns for "PRESS R"
    # (Esto es un placeholder - puedes hacer un sprite completo si quieres)
   
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Función para dibujar sprite de "GAME OVER" 70x6
draw_gameover_sprite:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    
    move $s0, $a0
    move $s1, $a1
    la $s2, gameover_sprite
    li $s3, 0
    
gameover_row:
    li $s4, 0
    
gameover_col:
    lw $t0, 0($s2)
    beqz $t0, gameover_skip
    
    add $a0, $s0, $s4
    add $a1, $s1, $s3
    move $a2, $t0
    jal draw_pixel
    
gameover_skip:
    addi $s2, $s2, 4
    addi $s4, $s4, 1
    li $t0, 70
    blt $s4, $t0, gameover_col
    
    addi $s3, $s3, 1
    li $t0, 10
    blt $s3, $t0, gameover_row
    
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra

show_win_screen_visual:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    li $t0, 0x10008000
    lw $t1, COLOR_SKY
    li $t2, 8192
   
win_clear:
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    addi $t2, $t2, -1
    bgtz $t2, win_clear
   
    li $s7, 0xFFD700
   
    li $a0, 20
    li $a1, 16
    li $a2, 2
    li $a3, 10
    move $t0, $s7
    jal fill_rect
   
    li $a0, 28
    li $a1, 16
    li $a2, 2
    li $a3, 10
    move $t0, $s7
    jal fill_rect
   
    li $a0, 22
    li $a1, 20
    li $a2, 2
    li $a3, 4
    move $t0, $s7
    jal fill_rect
   
    li $a0, 26
    li $a1, 20
    li $a2, 2
    li $a3, 4
    move $t0, $s7
    jal fill_rect
   
    li $a0, 24
    li $a1, 22
    li $a2, 2
    li $a3, 4
    move $t0, $s7
    jal fill_rect
   
    li $a0, 32
    li $a1, 16
    li $a2, 8
    li $a3, 10
    move $t0, $s7
    jal fill_rect
   
    li $a0, 34
    li $a1, 18
    li $a2, 4
    li $a3, 6
    lw $t0, COLOR_SKY
    jal fill_rect
   
    li $a0, 42
    li $a1, 16
    li $a2, 2
    li $a3, 10
    move $t0, $s7
    jal fill_rect
   
    li $a0, 48
    li $a1, 16
    li $a2, 2
    li $a3, 10
    move $t0, $s7
    jal fill_rect
   
    li $a0, 42
    li $a1, 24
    li $a2, 8
    li $a3, 2
    move $t0, $s7
    jal fill_rect
   
    li $a0, 20
    li $a1, 30
    li $a2, 2
    li $a3, 10
    move $t0, $s7
    jal fill_rect
   
    li $a0, 28
    li $a1, 30
    li $a2, 2
    li $a3, 10
    move $t0, $s7
    jal fill_rect
   
    li $a0, 22
    li $a1, 36
    li $a2, 2
    li $a3, 4
    move $t0, $s7
    jal fill_rect
   
    li $a0, 26
    li $a1, 36
    li $a2, 2
    li $a3, 4
    move $t0, $s7
    jal fill_rect
   
    li $a0, 24
    li $a1, 38
    li $a2, 2
    li $a3, 2
    move $t0, $s7
    jal fill_rect
   
    li $a0, 36
    li $a1, 30
    li $a2, 2
    li $a3, 10
    move $t0, $s7
    jal fill_rect
   
    li $a0, 40
    li $a1, 30
    li $a2, 2
    li $a3, 10
    move $t0, $s7
    jal fill_rect
   
    li $a0, 48
    li $a1, 30
    li $a2, 2
    li $a3, 10
    move $t0, $s7
    jal fill_rect
   
    li $a0, 42
    li $a1, 32
    li $a2, 2
    li $a3, 2
    move $t0, $s7
    jal fill_rect
   
    li $a0, 44
    li $a1, 34
    li $a2, 2
    li $a3, 2
    move $t0, $s7
    jal fill_rect
   
    li $a0, 46
    li $a1, 36
    li $a2, 2
    li $a3, 2
    move $t0, $s7
    jal fill_rect
   
    li $a0, 56
    li $a1, 40
    li $a2, 4
    li $a3, 4
    lw $t0, COLOR_MARIO_RED
    jal fill_rect
   
    li $a0, 56
    li $a1, 38
    li $a2, 4
    li $a3, 2
    lw $t0, COLOR_MARIO_SKIN
    jal fill_rect
   
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra


    li $s7, 0xFF0000
   
    li $a0, 20
    li $a1, 24
    li $a2, 8
    li $a3, 10
    move $t0, $s7
    jal fill_rect
   
    li $a0, 22
    li $a1, 26
    li $a2, 4
    li $a3, 6
    li $t0, 0x000000
    jal fill_rect
   
    li $a0, 24
    li $a1, 28
    li $a2, 4
    li $a3, 2
    move $t0, $s7
    jal fill_rect
   
    li $a0, 30
    li $a1, 24
    li $a2, 2
    li $a3, 10
    move $t0, $s7
    jal fill_rect
   
    li $a0, 36
    li $a1, 24
    li $a2, 2
    li $a3, 10
    move $t0, $s7
    jal fill_rect
   
    li $a0, 30
    li $a1, 24
    li $a2, 8
    li $a3, 2
    move $t0, $s7
    jal fill_rect
   
    li $a0, 30
    li $a1, 28
    li $a2, 8
    li $a3, 2
    move $t0, $s7
    jal fill_rect
   
    li $a0, 40
    li $a1, 24
    li $a2, 2
    li $a3, 10
    move $t0, $s7
    jal fill_rect
   
    li $a0, 48
    li $a1, 24
    li $a2, 2
    li $a3, 10
    move $t0, $s7
    jal fill_rect
   
    li $a0, 42
    li $a1, 26
    li $a2, 2
    li $a3, 4
    move $t0, $s7
    jal fill_rect
   
    li $a0, 46
    li $a1, 26
    li $a2, 2
    li $a3, 4
    move $t0, $s7
    jal fill_rect
   
    li $a0, 52
    li $a1, 24
    li $a2, 2
    li $a3, 10
    move $t0, $s7
    jal fill_rect
   
    li $a0, 52
    li $a1, 24
    li $a2, 8
    li $a3, 2
    move $t0, $s7
    jal fill_rect
   
    li $a0, 52
    li $a1, 28
    li $a2, 6
    li $a3, 2
    move $t0, $s7
    jal fill_rect
   
    li $a0, 52
    li $a1, 32
    li $a2, 8
    li $a3, 2
    move $t0, $s7
    jal fill_rect
   
    li $a0, 30
    li $a1, 38
    li $a2, 8
    li $a3, 10
    move $t0, $s7
    jal fill_rect
   
    li $a0, 32
    li $a1, 40
    li $a2, 4
    li $a3, 6
    li $t0, 0x000000
    jal fill_rect
   
    li $a0, 40
    li $a1, 38
    li $a2, 2
    li $a3, 6
    move $t0, $s7
    jal fill_rect
   
    li $a0, 48
    li $a1, 38
    li $a2, 2
    li $a3, 6
    move $t0, $s7
    jal fill_rect
   
    li $a0, 42
    li $a1, 44
    li $a2, 2
    li $a3, 2
    move $t0, $s7
    jal fill_rect
   
    li $a0, 46
    li $a1, 44
    li $a2, 2
    li $a3, 2
    move $t0, $s7
    jal fill_rect
   
    li $a0, 44
    li $a1, 46
    li $a2, 2
    li $a3, 2
    move $t0, $s7
    jal fill_rect
   
    li $a0, 52
    li $a1, 38
    li $a2, 2
    li $a3, 10
    move $t0, $s7
    jal fill_rect
   
    li $a0, 52
    li $a1, 38
    li $a2, 8
    li $a3, 2
    move $t0, $s7
    jal fill_rect
   
    li $a0, 52
    li $a1, 42
    li $a2, 6
    li $a3, 2
    move $t0, $s7
    jal fill_rect
   
    li $a0, 52
    li $a1, 46
    li $a2, 8
    li $a3, 2
    move $t0, $s7
    jal fill_rect
   
    li $a0, 62
    li $a1, 38
    li $a2, 2
    li $a3, 10
    move $t0, $s7
    jal fill_rect
   
    li $a0, 62
    li $a1, 38
    li $a2, 6
    li $a3, 2
    move $t0, $s7
    jal fill_rect
   
    li $a0, 62
    li $a1, 42
    li $a2, 6
    li $a3, 2
    move $t0, $s7
    jal fill_rect
   
    li $a0, 68
    li $a1, 38
    li $a2, 2
    li $a3, 6
    move $t0, $s7
    jal fill_rect
   
    li $a0, 66
    li $a1, 44
    li $a2, 2
    li $a3, 4
    move $t0, $s7
    jal fill_rect
   
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

delay:
    move $t0, $a0
delay_outer:
    li $t1, 2000           # Era 5000, ahora 2000 (más rápido)
delay_inner:
    addi $t1, $t1, -1
    bgtz $t1, delay_inner
    addi $t0, $t0, -1
    bgtz $t0, delay_outer
    jr $ra
