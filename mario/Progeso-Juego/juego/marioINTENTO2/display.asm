############################################################
# display.asm
# Sistema de renderizado y dibujo de sprites
# Mario Platformer - MARS 4.5
# Optimizado para Bitmap Display 512x512, unidades 8x8
############################################################

.include "constants.asm"

############################################################
# MACRO: DrawPixel
# Dibuja un píxel individual en coordenadas de pantalla
# Parámetros:
#   %x - coordenada X en unidades (0-63)
#   %y - coordenada Y en unidades (0-63)
#   %color - color en formato 0xRRGGBB
# Registros usados: $t0-$t3
############################################################
.macro DrawPixel(%x, %y, %color)
    # Cargar base address del display
    li $t0, DISPLAY_BASE
    
    # Calcular offset: (y * 64 + x) * 4
    li $t1, %y
    sll $t2, $t1, 6         # y * 64 (shift left 6)
    li $t1, %x
    add $t2, $t2, $t1       # + x
    sll $t2, $t2, 2         # * 4 (shift left 2)
    add $t2, $t0, $t2       # base + offset
    
    # Escribir color
    li $t3, %color
    sw $t3, 0($t2)
.end_macro

############################################################
# MACRO: DrawPixelReg
# Versión con valores en registros (más flexible)
# Parámetros:
#   %xReg - registro con X
#   %yReg - registro con Y
#   %colorReg - registro con color
############################################################
.macro DrawPixelReg(%xReg, %yReg, %colorReg)
    # Verificar límites (culling)
    bltz %xReg, skip_pixel_\@
    li $t8, GRID_WIDTH
    sge $t9, %xReg, $t8
    bnez $t9, skip_pixel_\@
    bltz %yReg, skip_pixel_\@
    li $t8, GRID_HEIGHT
    sge $t9, %yReg, $t8
    bnez $t9, skip_pixel_\@
    
    # Calcular dirección
    li $t0, DISPLAY_BASE
    move $t1, %yReg
    sll $t2, $t1, 6         # y * 64
    add $t2, $t2, %xReg     # + x
    sll $t2, $t2, 2         # * 4
    add $t2, $t0, $t2       # base + offset
    
    # Escribir color
    sw %colorReg, 0($t2)
    
skip_pixel_\@:
.end_macro

############################################################
# MACRO: DrawFilledRect
# Dibuja un rectángulo relleno
# Parámetros:
#   %x, %y - esquina superior izquierda
#   %width, %height - dimensiones
#   %color - color de relleno
############################################################
.macro DrawFilledRect(%x, %y, %width, %height, %color)
    # Guardar registros
    addi $sp, $sp, -24
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    
    # Configurar parámetros
    li $s0, %x              # x inicial
    li $s1, %y              # y inicial
    li $s2, %width          # ancho
    li $s3, %height         # alto
    li $s5, %color          # color
    
    # Calcular límites
    add $s2, $s0, $s2       # end_x = x + width
    add $s3, $s1, $s3       # end_y = y + height
    
    # Loop de filas
    move $t1, $s1           # current_y
rect_row_loop_\@:
    bge $t1, $s3, rect_done_\@
    
    # Loop de columnas
    move $t0, $s0           # current_x
rect_col_loop_\@:
    bge $t0, $s2, rect_row_done_\@
    
    # Dibujar píxel
    DrawPixelReg($t0, $t1, $s5)
    
    addi $t0, $t0, 1        # x++
    j rect_col_loop_\@
    
rect_row_done_\@:
    addi $t1, $t1, 1        # y++
    j rect_row_loop_\@
    
rect_done_\@:
    # Restaurar registros
    lw $s5, 20($sp)
    lw $s4, 16($sp)
    lw $s3, 12($sp)
    lw $s2, 8($sp)
    lw $s1, 4($sp)
    lw $s0, 0($sp)
    addi $sp, $sp, 24
.end_macro

############################################################
# MACRO: ClearScreen
# Limpia toda la pantalla con un color
# Parámetros:
#   %color - color de fondo
############################################################
.macro ClearScreen(%color)
    addi $sp, $sp, -12
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    
    li $t0, DISPLAY_BASE
    li $t1, %color
    li $t2, 16384           # 64*64*4 = 16384 words
    
clear_loop_\@:
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    addi $t2, $t2, -4
    bgtz $t2, clear_loop_\@
    
    lw $t2, 8($sp)
    lw $t1, 4($sp)
    lw $t0, 0($sp)
    addi $sp, $sp, 12
.end_macro

############################################################
# FUNCIÓN: clear_screen
# Limpia pantalla (versión función para main.asm)
############################################################
.text
.globl clear_screen
clear_screen:
    ClearScreen(COLOR_SKY)
    jr $ra

############################################################
# MACRO: DrawMario
# Dibuja sprite de Mario 8x8 con soporte de dirección
# Parámetros:
#   %x, %y - posición en unidades de pantalla
#   %direction - DIR_LEFT (0) o DIR_RIGHT (1)
# Diseño simplificado de Mario:
#   RRR RRR    (Gorra roja)
#   R SSS R    (Cara)
#   BBB BBB    (Overoles azules)
#   B B B B    (Piernas)
############################################################
.macro DrawMario(%x, %y, %direction)
    addi $sp, $sp, -16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    
    li $s0, %x
    li $s1, %y
    li $s3, %direction      # 0=left, 1=right
    
    # Fila 0 - Gorra (3 píxeles rojos en medio)
    addi $t1, $s1, 0
    li $t2, COLOR_MARIO_RED
    
    # Ajustar píxeles según dirección
    beqz $s3, mario_face_left_row0
    # Mirando derecha
    addi $t0, $s0, 2
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    j mario_row1
    
mario_face_left_row0:
    # Mirando izquierda
    addi $t0, $s0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    
mario_row1:
    # Fila 1 - Parte superior gorra
    addi $t1, $s1, 1
    addi $t0, $s0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    
    # Fila 2 - Cara (piel)
    addi $t1, $s1, 2
    li $t2, COLOR_MARIO_RED
    
    beqz $s3, mario_face_left_row2
    # Mirando derecha
    addi $t0, $s0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    li $t2, COLOR_MARIO_SKIN
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    li $t2, COLOR_MARIO_RED
    DrawPixelReg($t0, $t1, $t2)
    j mario_row3
    
mario_face_left_row2:
    # Mirando izquierda (voltear ojos)
    addi $t0, $s0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    li $t2, COLOR_MARIO_SKIN
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    li $t2, COLOR_MARIO_RED
    DrawPixelReg($t0, $t1, $t2)
    
mario_row3:
    # Fila 3 - Cara inferior
    addi $t1, $s1, 3
    addi $t0, $s0, 2
    li $t2, COLOR_MARIO_SKIN
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    
    # Fila 4 - Overol superior
    addi $t1, $s1, 4
    addi $t0, $s0, 1
    li $t2, COLOR_MARIO_BLUE
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    
    # Fila 5 - Overol medio
    addi $t1, $s1, 5
    addi $t0, $s0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    
    # Fila 6 - Piernas separadas (voltear según dirección)
    addi $t1, $s1, 6
    
    beqz $s3, mario_legs_left
    # Mirando derecha
    addi $t0, $s0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 2
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    j mario_row7
    
mario_legs_left:
    # Mirando izquierda
    addi $t0, $s0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 2
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    
mario_row7:
    # Fila 7 - Pies
    addi $t1, $s1, 7
    li $t2, COLOR_MARIO_RED
    
    beqz $s3, mario_feet_left
    # Mirando derecha
    addi $t0, $s0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 2
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    j mario_draw_done
    
mario_feet_left:
    # Mirando izquierda
    addi $t0, $s0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 2
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $t2)
    
mario_draw_done:
    lw $s3, 12($sp)
    lw $s2, 8($sp)
    lw $s1, 4($sp)
    lw $s0, 0($sp)
    addi $sp, $sp, 16
.end_macro

############################################################
# MACRO: DrawGoomba
# Dibuja sprite de Goomba 8x8
# Parámetros:
#   %x, %y - posición en unidades de pantalla
# Diseño: Hongo marrón con ojos
############################################################
.macro DrawGoomba(%x, %y)
    addi $sp, $sp, -12
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    
    li $s0, %x
    li $s1, %y
    li $s2, COLOR_GOOMBA
    
    # Fila 0 - Parte superior
    addi $t1, $s1, 0
    addi $t0, $s0, 2
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    
    # Fila 1 - Expandir
    addi $t1, $s1, 1
    addi $t0, $s0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    
    # Fila 2-3 - Cuerpo con ojos
    addi $t1, $s1, 2
    addi $t0, $s0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    li $t2, COLOR_BLACK  # Ojo
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    move $t2, $s2
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    li $t2, COLOR_BLACK  # Ojo
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, $t0, 1
    move $t2, $s2
    DrawPixelReg($t0, $t1, $s2)
    
    # Fila 4-5 - Cuerpo completo
    addi $t1, $s1, 3
    addi $t0, $s0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    
    # Fila 6 - Base con pies
    addi $t1, $s1, 6
    addi $t0, $s0, 0
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 2
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 2
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    
    lw $s2, 8($sp)
    lw $s1, 4($sp)
    lw $s0, 0($sp)
    addi $sp, $sp, 12
.end_macro

############################################################
# MACRO: DrawCoin
# Dibuja sprite de moneda 6x6 centrado en 8x8
# Parámetros:
#   %x, %y - posición en unidades de pantalla
############################################################
.macro DrawCoin(%x, %y)
    addi $sp, $sp, -12
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    
    li $s0, %x
    li $s1, %y
    li $s2, COLOR_COIN_GOLD
    
    # Offset para centrar (1,1)
    addi $s0, $s0, 1
    addi $s1, $s1, 1
    
    # Fila 0
    addi $t1, $s1, 0
    addi $t0, $s0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    
    # Fila 1-4 - Círculo completo
    addi $t1, $s1, 1
    addi $t0, $s0, 0
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    
    # Repetir para filas 2, 3
    addi $t1, $s1, 2
    addi $t0, $s0, 0
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    
    addi $t1, $s1, 3
    addi $t0, $s0, 0
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    
    # Fila 5 - Inferior
    addi $t1, $s1, 4
    addi $t0, $s0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    addi $t0, $t0, 1
    DrawPixelReg($t0, $t1, $s2)
    
    lw $s2, 8($sp)
    lw $s1, 4($sp)
    lw $s0, 0($sp)
    addi $sp, $sp, 12
.end_macro

############################################################
# MACRO: DrawTile
# Dibuja un tile 8x8 según su tipo
# Parámetros:
#   %x, %y - posición en pantalla
#   %type - tipo de tile (TILE_AIR, TILE_GROUND, etc)
############################################################
.macro DrawTile(%x, %y, %type)
    li $t9, %type
    
    # TILE_AIR - No dibujar nada
    beqz $t9, tile_done_\@
    
    # TILE_GROUND
    li $t8, TILE_GROUND
    beq $t9, $t8, draw_ground_\@
    
    # TILE_BRICK
    li $t8, TILE_BRICK
    beq $t9, $t8, draw_brick_\@
    
    j tile_done_\@

draw_ground_\@:
    DrawFilledRect(%x, %y, 8, 8, COLOR_GROUND)
    j tile_done_\@

draw_brick_\@:
    DrawFilledRect(%x, %y, 8, 8, COLOR_BRICK)
    # Dibujar líneas para dar textura
    addi $t0, %x, 0
    addi $t1, %y, 3
    li $t2, COLOR_BLACK
    DrawPixelReg($t0, $t1, $t2)
    addi $t0, %x, 7
    DrawPixelReg($t0, $t1, $t2)
    j tile_done_\@

tile_done_\@:
.end_macro

############################################################
# FUNCIÓN: world_to_screen_x
# Convierte coordenada X del mundo a pantalla
# Input: $a0 = world_x (fixed-point)
#        $a1 = camera_x (fixed-point)
# Output: $v0 = screen_x en unidades
############################################################
.text
.globl world_to_screen_x
world_to_screen_x:
    sub $v0, $a0, $a1       # world_x - camera_x
    li $t0, FIXED_SCALE
    div $v0, $t0            # Convertir de fixed-point
    mflo $v0
    jr $ra

############################################################
# FUNCIÓN: world_to_screen_y
# Convierte coordenada Y del mundo a pantalla
# Input: $a0 = world_y (fixed-point)
#        $a1 = camera_y (fixed-point)
# Output: $v0 = screen_y en unidades
############################################################
.text
.globl world_to_screen_y
world_to_screen_y:
    sub $v0, $a0, $a1       # world_y - camera_y
    li $t0, FIXED_SCALE
    div $v0, $t0            # Convertir de fixed-point
    mflo $v0
    jr $ra

############################################################
# Fin de display.asm
############################################################