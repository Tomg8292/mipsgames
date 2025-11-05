# Modificación: Barriles circulares de color marrón claro
# 
# PASOS PARA EJECUTAR:
# 1. Tools -> Bitmap Display
# 2. Configurar:
#    - Unit Width: 8
#    - Unit Height: 8
#    - Display Width: 512
#    - Display Height: 1024
#    - Base address: 0x10008000 ($gp)
# 3. Click "Connect to MIPS"
# 4. Tools -> Keyboard and Display MMIO Simulator
# 5. Click "Connect to MIPS"
# 6. Assemblar y ejecutar el programa
#
# Controles:
#   'a' - Mover izquierda
#   'd' - Mover derecha
#   'w' - Saltar / Subir escalera
#   's' - Bajar por escalera
#   'q' - Salir del juego
########################################################################

.data
    # Colores
    red:       .word 0x00FF0000
    blue:      .word 0x000099FF
    brown:     .word 0x00FF6B35
    black:     .word 0x00000000
    pink:      .word 0x00FF1493
    cyan:      .word 0x0000FFFF
    yellow:    .word 0x00FFFF00
    green:     .word 0x0000FF00
    dk_brown:  .word 0x008B4513
    mario_red:      .word 0x00FF0000    # Gorra y camisa
    mario_skin:     .word 0x00FFD4A3    # Piel
    dk_red:    .word 0x00DC143C
    barrel_brown: .word 0x00CD853F  # Color marrón claro para barriles (Peru)
    
    # Jugador
    playerX:   .word 4
    playerY:   .word 106
    playerVelY: .word 0
    playerVelX: .word 0
    onGround:  .word 0
    onLadder:  .word 0
    
    # Input
    leftPressed:  .word 0
    rightPressed: .word 0
    
    # Física
    jumpForce: .word -4
    gravity:   .word 1
    maxFallSpeed: .word 3
    coyoteTime: .word 0
    maxCoyote:  .word 5
    
    # Donkey Kong
    dkX:       .word 2
    dkY:       .word 4
    dkFrame:   .word 0
    dkAnimTimer: .word 0
    dkAnimSpeed: .word 20
    
    # Barriles (x, y, velY, velX, active) = 5 words * 5 barrels
    barrels:   .space 100
    spawnTimer: .word 0
    spawnDelay: .word 80
    
    # Plataformas (x1, x2, y)
    plat0:     .word 0, 60, 8
    plat1:     .word 4, 63, 28
    plat2:     .word 0, 59, 48
    plat3:     .word 4, 63, 68
    plat4:     .word 0, 59, 88
    plat5:     .word 0, 63, 108
    
    # Escaleras (x, y1, y2)
    ladder0:   .word 56, 10, 26
    ladder1:   .word 4, 30, 46
    ladder2:   .word 56, 50, 66
    ladder3:   .word 4, 70, 86
    ladder4:   .word 56, 90, 106
    
    # Estado del juego
    gameOver:  .word 0
    playerWon: .word 0
    onTopPlatform: .word 0

.text
.globl main

main:
    li $s0, 0x10008000
    jal init_barrels

game_loop:
    lw $t1, gameOver
    bne $t1, $zero, end_game
    
    jal clear_screen
    jal draw_platforms
    jal draw_ladders
    jal draw_dk
    jal check_input
    jal apply_horizontal_movement
    jal check_ladder_collision
    jal check_platform_collision
    jal apply_gravity
    jal check_top_platform
    jal update_spawn_timer
    jal update_all_barrels
    jal check_barrel_platform_collision
    jal draw_all_barrels
    jal draw_player
    jal check_all_collisions
    jal check_victory
    
    li $v0, 32
    li $a0, 50
    syscall
    
    j game_loop

end_game:
    lw $t8, playerWon
    beq $t8, 1, victory_screen
    
    # Derrota
    li $t9, 3
flash_defeat:
    beq $t9, 0, exit_game
    jal clear_screen
    li $v0, 32
    li $a0, 200
    syscall
    move $t0, $s0
    lw $t1, red
    li $t2, 8192
fill_red:
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    addi $t2, $t2, -1
    bgt $t2, 0, fill_red
    
    jal draw_game_over
    
    li $v0, 32
    li $a0, 200
    syscall
    addi $t9, $t9, -1
    j flash_defeat

victory_screen:
    li $t9, 4
flash_victory:
    beq $t9, 0, exit_game
    move $t0, $s0
    lw $t1, yellow
    li $t2, 8192
fill_yellow:
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    addi $t2, $t2, -1
    bgt $t2, 0, fill_yellow
    
    jal draw_you_won
    
    li $v0, 32
    li $a0, 300
    syscall
    addi $t9, $t9, -1
    j flash_victory

exit_game:
    li $v0, 10
    syscall

# ============================================
# CLEAR SCREEN
# ============================================
clear_screen:
    move $t0, $s0
    lw $t1, black
    li $t2, 8192
clear_loop:
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    addi $t2, $t2, -1
    bgt $t2, 0, clear_loop
    jr $ra

# ============================================
# DRAW PIXEL - a0=x, a1=y, a2=color
# ============================================
draw_pixel:
    blt $a0, 0, pixel_skip
    blt $a1, 0, pixel_skip
    bge $a0, 64, pixel_skip
    bge $a1, 128, pixel_skip
    
    sll $t0, $a1, 6
    add $t0, $t0, $a0
    sll $t0, $t0, 2
    add $t0, $s0, $t0
    sw $a2, 0($t0)
    
pixel_skip:
    jr $ra

# ============================================
# DRAW FILLED RECT - a0=x, a1=y, a2=w, a3=h, stack=color
# ============================================
draw_rect:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    
    move $s1, $a0      # x
    move $s2, $a1      # y
    move $s3, $a2      # width
    move $s4, $a3      # height
    lw $s5, 24($sp)    # color
    
    li $t8, 0          # row counter
rect_row_loop:
    bge $t8, $s4, rect_done
    
    li $t9, 0          # col counter
rect_col_loop:
    bge $t9, $s3, rect_next_row
    
    add $a0, $s1, $t9
    add $a1, $s2, $t8
    move $a2, $s5
    
    addi $sp, $sp, -8
    sw $t8, 0($sp)
    sw $t9, 4($sp)
    jal draw_pixel
    lw $t8, 0($sp)
    lw $t9, 4($sp)
    addi $sp, $sp, 8
    
    addi $t9, $t9, 1
    j rect_col_loop
    
rect_next_row:
    addi $t8, $t8, 1
    j rect_row_loop
    
rect_done:
    lw $ra, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    addi $sp, $sp, 24
    jr $ra

# ============================================
# DRAW BARREL (CIRCULAR) - a0=centerX, a1=centerY
# Dibuja un barril circular de 4x4 píxeles
# ============================================

draw_barrel:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    
    move $s1, $a0      # centerX
    move $s2, $a1      # centerY
    lw $s3, barrel_brown
    
    # Fila 0 (y-2): dibujar 1 píxel central
    move $a0, $s1
    addi $a1, $s2, -2
    move $a2, $s3
    jal draw_pixel
    
    # Fila 1 (y-1): dibujar 3 píxeles
    addi $a0, $s1, -1
    addi $a1, $s2, -1
    move $a2, $s3
    jal draw_pixel
    
    move $a0, $s1
    addi $a1, $s2, -1
    move $a2, $s3
    jal draw_pixel
    
    addi $a0, $s1, 1
    addi $a1, $s2, -1
    move $a2, $s3
    jal draw_pixel
    
    # Fila 2 (y): dibujar 3 píxeles
    addi $a0, $s1, -1
    move $a1, $s2
    move $a2, $s3
    jal draw_pixel
    
    move $a0, $s1
    move $a1, $s2
    move $a2, $s3
    jal draw_pixel
    
    addi $a0, $s1, 1
    move $a1, $s2
    move $a2, $s3
    jal draw_pixel
    
    # Fila 3 (y+1): dibujar 3 píxeles
    addi $a0, $s1, -1
    addi $a1, $s2, 1
    move $a2, $s3
    jal draw_pixel
    
    move $a0, $s1
    addi $a1, $s2, 1
    move $a2, $s3
    jal draw_pixel
    
    addi $a0, $s1, 1
    addi $a1, $s2, 1
    move $a2, $s3
    jal draw_pixel
    
    # Fila 4 (y+2): dibujar 1 píxel central
    move $a0, $s1
    addi $a1, $s2, 2
    move $a2, $s3
    jal draw_pixel
    
    lw $ra, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    addi $sp, $sp, 20
    jr $ra

# ============================================
# PLATFORMS
# ============================================
draw_platforms:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    la $t0, plat0
    lw $a0, 0($t0)
    lw $a1, 4($t0)
    lw $a2, 8($t0)
    jal draw_platform
    
    la $t0, plat1
    lw $a0, 0($t0)
    lw $a1, 4($t0)
    lw $a2, 8($t0)
    jal draw_platform
    
    la $t0, plat2
    lw $a0, 0($t0)
    lw $a1, 4($t0)
    lw $a2, 8($t0)
    jal draw_platform
    
    la $t0, plat3
    lw $a0, 0($t0)
    lw $a1, 4($t0)
    lw $a2, 8($t0)
    jal draw_platform
    
    la $t0, plat4
    lw $a0, 0($t0)
    lw $a1, 4($t0)
    lw $a2, 8($t0)
    jal draw_platform
    
    la $t0, plat5
    lw $a0, 0($t0)
    lw $a1, 4($t0)
    lw $a2, 8($t0)
    jal draw_platform
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

draw_platform:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    
    move $s1, $a0
    move $s2, $a1
    move $s3, $a2
    lw $s4, brown
    
plat_loop:
    bgt $s1, $s2, plat_done
    
    move $a0, $s1
    move $a1, $s3
    move $a2, $s4
    jal draw_pixel
    
    addi $s1, $s1, 1
    j plat_loop
    
plat_done:
    lw $ra, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    addi $sp, $sp, 20
    jr $ra

# ============================================
# LADDERS
# ============================================
draw_ladders:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    la $t0, ladder0
    lw $a0, 0($t0)
    lw $a1, 4($t0)
    lw $a2, 8($t0)
    jal draw_ladder
    
    la $t0, ladder1
    lw $a0, 0($t0)
    lw $a1, 4($t0)
    lw $a2, 8($t0)
    jal draw_ladder
    
    la $t0, ladder2
    lw $a0, 0($t0)
    lw $a1, 4($t0)
    lw $a2, 8($t0)
    jal draw_ladder
    
    la $t0, ladder3
    lw $a0, 0($t0)
    lw $a1, 4($t0)
    lw $a2, 8($t0)
    jal draw_ladder
    
    la $t0, ladder4
    lw $a0, 0($t0)
    lw $a1, 4($t0)
    lw $a2, 8($t0)
    jal draw_ladder
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

draw_ladder:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    
    move $s1, $a0
    move $s2, $a1
    move $s3, $a2
    lw $s4, cyan
    
ladder_loop:
    bgt $s2, $s3, ladder_done
    
    move $a0, $s1
    move $a1, $s2
    move $a2, $s4
    jal draw_pixel
    
    addi $a0, $s1, 2
    move $a1, $s2
    move $a2, $s4
    jal draw_pixel
    
    andi $t9, $s2, 3
    bne $t9, 0, ladder_skip
    
    addi $a0, $s1, 1
    move $a1, $s2
    move $a2, $s4
    jal draw_pixel
    
ladder_skip:
    addi $s2, $s2, 1
    j ladder_loop
    
ladder_done:
    lw $ra, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    addi $sp, $sp, 20
    jr $ra

# ============================================
# DONKEY KONG
# ============================================
draw_dk:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    lw $t0, dk_brown
    sw $t0, 4($sp)
    
    lw $a0, dkX
    lw $a1, dkY
    li $a2, 3
    li $a3, 2
    jal draw_rect
    
    lw $ra, 0($sp)
    addi $sp, $sp, 8
    jr $ra

# ============================================
# PLAYER
# ============================================
# ============================================
# SPRITE MEJORADO DE MARIO
# ============================================

# ============================================
# DRAW MARIO MEJORADO - 6x8 píxeles
# La hitbox 2x2 está en los PIES (parte inferior)
# ============================================
draw_player:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    
    lw $s1, playerX      # Centro X de la hitbox (pies)
    lw $s2, playerY      # Centro Y de la hitbox (pies)
    
    # Ajustar origen: sprite 6x8, hitbox en pies
    # Offset: -2 en X (centrar), -6 en Y (pies abajo)
    addi $s1, $s1, -2    # Sprite comienza 2 píxeles a la izquierda
    addi $s2, $s2, -6    # Sprite comienza 6 píxeles arriba
    
    # Cargar colores
    lw $s3, mario_red
    lw $s4, blue
    lw $t9, mario_skin
    
    # === FILA 0 (Y+0): Gorra - 4 píxeles rojos ===
    addi $a0, $s1, 1
    move $a1, $s2
    li $a2, 4
    li $a3, 1
    addi $sp, $sp, -4
    sw $s3, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # === FILA 1 (Y+1): Gorra ancha - 6 píxeles rojos ===
    move $a0, $s1
    addi $a1, $s2, 1
    li $a2, 6
    li $a3, 1
    addi $sp, $sp, -4
    sw $s3, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # === FILA 2 (Y+2): Cara - piel centro, rojo lados ===
    # Lado izquierdo (rojo)
    move $a0, $s1
    addi $a1, $s2, 2
    move $a2, $s3
    jal draw_pixel
    
    # Cara (piel - 4 píxeles)
    addi $a0, $s1, 1
    addi $a1, $s2, 2
    li $a2, 4
    li $a3, 1
    addi $sp, $sp, -4
    sw $t9, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # Lado derecho (rojo)
    addi $a0, $s1, 5
    addi $a1, $s2, 2
    move $a2, $s3
    jal draw_pixel
    
    # === FILA 3 (Y+3): Ojos ===
    # Base de piel
    addi $a0, $s1, 1
    addi $a1, $s2, 3
    li $a2, 4
    li $a3, 1
    addi $sp, $sp, -4
    sw $t9, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # Ojo izquierdo (azul)
    addi $a0, $s1, 1
    addi $a1, $s2, 3
    move $a2, $s4
    jal draw_pixel
    
    # Ojo derecho (azul)
    addi $a0, $s1, 4
    addi $a1, $s2, 3
    move $a2, $s4
    jal draw_pixel
    
    # === FILA 4 (Y+4): Camisa roja - 4 píxeles ===
    addi $a0, $s1, 1
    addi $a1, $s2, 4
    li $a2, 4
    li $a3, 1
    addi $sp, $sp, -4
    sw $s3, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # === FILA 5 (Y+5): Overol azul - 4 píxeles ===
    addi $a0, $s1, 1
    addi $a1, $s2, 5
    li $a2, 4
    li $a3, 1
    addi $sp, $sp, -4
    sw $s4, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # Tirantes (2 píxeles rojos)
    addi $a0, $s1, 2
    addi $a1, $s2, 5
    move $a2, $s3
    jal draw_pixel
    
    addi $a0, $s1, 4
    addi $a1, $s2, 5
    move $a2, $s3
    jal draw_pixel
    
    # === FILA 6 (Y+6): Piernas azules - 2 grupos de 2 píxeles ===
    # Pierna izquierda
    addi $a0, $s1, 1
    addi $a1, $s2, 6
    li $a2, 2
    li $a3, 1
    addi $sp, $sp, -4
    sw $s4, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # Pierna derecha
    addi $a0, $s1, 4
    addi $a1, $s2, 6
    li $a2, 2
    li $a3, 1
    addi $sp, $sp, -4
    sw $s4, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # === FILA 7 (Y+7): PIES/ZAPATOS - Esta fila está en playerY ===
    # Zapato izquierdo (rojo)
    addi $a0, $s1, 1
    addi $a1, $s2, 7
    li $a2, 2
    li $a3, 1
    addi $sp, $sp, -4
    sw $s3, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # Zapato derecho (rojo)
    addi $a0, $s1, 4
    addi $a1, $s2, 7
    li $a2, 2
    li $a3, 1
    addi $sp, $sp, -4
    sw $s3, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    lw $ra, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    addi $sp, $sp, 20
    jr $ra

# ============================================
# MOVEMENT
# ============================================
apply_horizontal_movement:
    lw $t0, playerX
    lw $t1, playerVelX
    
    beq $t1, 0, horiz_done
    
    add $t0, $t0, $t1
    blt $t0, 0, clamp_left
    bgt $t0, 62, clamp_right
    
    sw $t0, playerX
    j horiz_done
    
clamp_left:
    sw $zero, playerX
    j horiz_done
    
clamp_right:
    li $t0, 62
    sw $t0, playerX
    
horiz_done:
    jr $ra

apply_gravity:
    lw $t3, onLadder
    beq $t3, 1, grav_done
    
    lw $t2, onGround
    beq $t2, 1, reset_coyote
    
    lw $t4, coyoteTime
    ble $t4, 0, apply_grav
    addi $t4, $t4, -1
    sw $t4, coyoteTime
    j apply_grav
    
reset_coyote:
    lw $t4, maxCoyote
    sw $t4, coyoteTime
    jr $ra
    
apply_grav:
    lw $t0, playerY
    lw $t1, playerVelY
    
    add $t0, $t0, $t1
    lw $t5, gravity
    add $t1, $t1, $t5
    lw $t6, maxFallSpeed
    bgt $t1, $t6, cap_vel
    j store_grav
    
cap_vel:
    move $t1, $t6
    
store_grav:
    bgt $t0, 126, floor_hit
    blt $t0, 0, ceil_hit
    sw $t0, playerY
    sw $t1, playerVelY
    jr $ra
    
floor_hit:
    li $t0, 126
    sw $t0, playerY
    sw $zero, playerVelY
    li $t1, 1
    sw $t1, onGround
    jr $ra
    
ceil_hit:
    sw $zero, playerY
    li $t1, 1
    sw $t1, playerVelY
    jr $ra

grav_done:
    jr $ra

# ============================================
# COLLISIONS
# ============================================
check_platform_collision:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    sw $zero, onGround
    
    la $a0, plat0
    jal check_single_platform
    la $a0, plat1
    jal check_single_platform
    la $a0, plat2
    jal check_single_platform
    la $a0, plat3
    jal check_single_platform
    la $a0, plat4
    jal check_single_platform
    la $a0, plat5
    jal check_single_platform
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

check_single_platform:
    lw $t0, playerX
    lw $t1, playerY
    lw $t8, playerVelY
    
    lw $t3, 0($a0)
    lw $t4, 4($a0)
    lw $t5, 8($a0)
    
    # Solo colisionar si estamos cayendo
    blt $t8, 0, plat_no
    
    # Verificar si los pies del jugador (y+2) están cerca de la plataforma
    addi $t1, $t1, 2
    sub $t6, $t1, $t5
    blt $t6, 0, plat_no
    bgt $t6, 3, plat_no
    
    # Verificar si horizontalmente estamos sobre la plataforma
    addi $t7, $t0, 1
    blt $t7, $t3, plat_no
    bgt $t0, $t4, plat_no
    
    # Colisión detectada - colocar jugador sobre plataforma
    li $t8, 1
    sw $t8, onGround
    sub $t1, $t5, 2
    sw $t1, playerY
    sw $zero, playerVelY
    
plat_no:
    jr $ra

check_ladder_collision:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    la $a0, ladder0
    jal check_single_ladder
    beq $v0, 1, on_ladder_yes
    la $a0, ladder1
    jal check_single_ladder
    beq $v0, 1, on_ladder_yes
    la $a0, ladder2
    jal check_single_ladder
    beq $v0, 1, on_ladder_yes
    la $a0, ladder3
    jal check_single_ladder
    beq $v0, 1, on_ladder_yes
    la $a0, ladder4
    jal check_single_ladder
    beq $v0, 1, on_ladder_yes
    
    sw $zero, onLadder
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

on_ladder_yes:
    li $t9, 1
    sw $t9, onLadder
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

check_single_ladder:
    lw $t0, playerX
    lw $t1, playerY
    
    lw $t2, 0($a0)
    lw $t3, 4($a0)
    lw $t4, 8($a0)
    
    sub $t5, $t0, $t2
    blt $t5, -1, ladder_no
    bgt $t5, 2, ladder_no
    
    blt $t1, $t3, ladder_no
    bgt $t1, $t4, ladder_no
    
    li $v0, 1
    jr $ra
    
ladder_no:
    li $v0, 0
    jr $ra

check_top_platform:
    lw $t0, playerX
    lw $t1, playerY
    
    la $t8, plat0
    lw $t2, 0($t8)
    lw $t3, 4($t8)
    lw $t4, 8($t8)
    
    addi $t7, $t0, 1
    blt $t7, $t2, not_on_top
    bgt $t0, $t3, not_on_top
    
    sub $t5, $t1, $t4
    bgtz $t5, abs_top
    sub $t5, $zero, $t5
abs_top:
    bgt $t5, 3, not_on_top
    
    li $t6, 1
    sw $t6, onTopPlatform
    jr $ra
    
not_on_top:
    sw $zero, onTopPlatform
    jr $ra

check_victory:
    lw $t0, playerX
    lw $t1, playerY
    lw $t2, dkX
    lw $t3, dkY
    
    # Verificar si el jugador está en la misma plataforma que DK
    # DK está en Y=4, plataforma en Y=8
    # Jugador necesita estar cerca de Y=6 (sobre la plataforma)
    
    bgt $t1, 10, no_victory  # Si está muy abajo, no hay victoria
    blt $t1, 4, no_victory   # Si está muy arriba, no hay victoria
    
    # Verificar colisión horizontal con DK
    # Player: (t0, t1) a (t0+2, t1+2)
    # DK: (t2, t3) a (t2+3, t3+2)
    
    addi $t4, $t0, 2
    blt $t4, $t2, no_victory
    
    addi $t5, $t2, 3
    blt $t5, $t0, no_victory
    
    addi $t6, $t1, 2
    blt $t6, $t3, no_victory
    
    addi $t7, $t3, 2
    blt $t7, $t1, no_victory
    
    # ¡VICTORIA!
    li $t8, 1
    sw $t8, gameOver
    sw $t8, playerWon
    
no_victory:
    jr $ra

# ============================================
# BARRELS
# ============================================
init_barrels:
    la $t0, barrels
    li $t2, 0
init_loop:
    beq $t2, 5, init_done
    sw $zero, 16($t0)
    addi $t0, $t0, 20
    addi $t2, $t2, 1
    j init_loop
init_done:
    jr $ra

update_spawn_timer:
    lw $t9, onTopPlatform
    bne $t9, $zero, spawn_done
    
    lw $t0, spawnTimer
    addi $t0, $t0, 1
    sw $t0, spawnTimer
    
    lw $t1, spawnDelay
    blt $t0, $t1, spawn_done
    
    sw $zero, spawnTimer
    
    la $t0, barrels
    li $t2, 0
find_slot:
    beq $t2, 5, spawn_done
    lw $t3, 16($t0)
    beq $t3, $zero, found_slot
    addi $t0, $t0, 20
    addi $t2, $t2, 1
    j find_slot
    
found_slot:
    lw $t3, dkX
    addi $t3, $t3, 3
    sw $t3, 0($t0)
    lw $t3, dkY
    addi $t3, $t3, 2
    sw $t3, 4($t0)
    sw $zero, 8($t0)
    li $t3, 1
    sw $t3, 12($t0)
    sw $t3, 16($t0)
    
spawn_done:
    jr $ra

update_all_barrels:
    la $s2, barrels
    li $s4, 0
    lw $s5, onTopPlatform
    
barrel_loop:
    beq $s4, 5, barrel_done
    
    lw $t3, 16($s2)
    beq $t3, $zero, skip_barrel
    
    bne $s5, $zero, barrel_fall
    
    lw $t0, 4($s2)
    lw $t1, 8($s2)
    add $t0, $t0, $t1
    addi $t1, $t1, 1
    bgt $t1, 3, cap_barrel
    j store_barrel
    
cap_barrel:
    li $t1, 3
    
store_barrel:
    bgt $t0, 126, deactivate
    sw $t0, 4($s2)
    sw $t1, 8($s2)
    
    lw $t0, 0($s2)
    lw $t1, 12($s2)
    add $t0, $t0, $t1
    
    blt $t0, 0, reverse
    bgt $t0, 62, reverse
    sw $t0, 0($s2)
    j skip_barrel
    
reverse:
    lw $t1, 12($s2)
    sub $t1, $zero, $t1
    sw $t1, 12($s2)
    j skip_barrel
    
barrel_fall:
    lw $t0, 4($s2)
    lw $t1, 8($s2)
    add $t0, $t0, $t1
    addi $t1, $t1, 1
    bgt $t1, 3, cap_fall
    j store_fall
    
cap_fall:
    li $t1, 3
    
store_fall:
    bgt $t0, 126, deactivate
    sw $t0, 4($s2)
    sw $t1, 8($s2)
    j skip_barrel
    
deactivate:
    sw $zero, 16($s2)

skip_barrel:
    addi $s2, $s2, 20
    addi $s4, $s4, 1
    j barrel_loop
    
barrel_done:
    jr $ra

draw_all_barrels:
    la $s2, barrels
    li $s4, 0
    
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
draw_barrel_loop:
    beq $s4, 5, draw_barrel_done
    
    lw $t3, 16($s2)
    beq $t3, $zero, skip_draw
    
    addi $sp, $sp, -8
    sw $s2, 0($sp)
    sw $s4, 4($sp)
    
    lw $a0, 0($s2)
    lw $a1, 4($s2)
    jal draw_barrel
    
    lw $s2, 0($sp)
    lw $s4, 4($sp)
    addi $sp, $sp, 8
    
skip_draw:
    addi $s2, $s2, 20
    addi $s4, $s4, 1
    j draw_barrel_loop
    
draw_barrel_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

check_all_collisions:
    lw $t0, playerX
    lw $t1, playerY
    
    la $s2, barrels
    li $s4, 0
    
collision_loop:
    beq $s4, 5, collision_done
    
    lw $t3, 16($s2)
    beq $t3, $zero, skip_coll
    
    lw $t2, 0($s2)
    lw $t3, 4($s2)
    
    # Verificar colisión AABB (Axis-Aligned Bounding Box)
    # Player: (t0, t1) a (t0+2, t1+2)
    # Barrel: (t2, t3) a (t2+2, t3+2)
    
    # Si playerX+2 <= barrelX, no hay colisión
    addi $t4, $t0, 2
    blt $t4, $t2, skip_coll
    
    # Si barrelX+2 <= playerX, no hay colisión
    addi $t5, $t2, 2
    blt $t5, $t0, skip_coll
    
    # Si playerY+2 <= barrelY, no hay colisión
    addi $t6, $t1, 2
    blt $t6, $t3, skip_coll
    
    # Si barrelY+2 <= playerY, no hay colisión
    addi $t7, $t3, 2
    blt $t7, $t1, skip_coll
    
    # ¡COLISIÓN DETECTADA!
    li $t6, 1
    sw $t6, gameOver
    sw $zero, playerWon
    jr $ra

skip_coll:
    addi $s2, $s2, 20
    addi $s4, $s4, 1
    j collision_loop
    
collision_done:
    jr $ra

# ============================================
# BARREL PLATFORM COLLISION
# ============================================
check_barrel_platform_collision:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    la $s2, barrels
    li $s4, 0
    
barrel_plat_loop:
    beq $s4, 5, barrel_plat_done
    
    lw $t3, 16($s2)
    beq $t3, $zero, skip_barrel_plat
    
    # Guardar registros
    addi $sp, $sp, -12
    sw $s2, 0($sp)
    sw $s4, 4($sp)
    sw $ra, 8($sp)
    
    # Cargar posición del barril
    lw $t0, 0($s2)  # barrel X
    lw $t1, 4($s2)  # barrel Y
    lw $t2, 8($s2)  # barrel velY
    
    # Solo verificar si está cayendo
    blt $t2, 1, no_barrel_collision
    
    # Verificar cada plataforma
    la $a0, plat0
    move $a1, $t0
    move $a2, $t1
    jal check_barrel_single_platform
    bne $v0, $zero, barrel_hit_platform
    
    la $a0, plat1
    move $a1, $t0
    move $a2, $t1
    jal check_barrel_single_platform
    bne $v0, $zero, barrel_hit_platform
    
    la $a0, plat2
    move $a1, $t0
    move $a2, $t1
    jal check_barrel_single_platform
    bne $v0, $zero, barrel_hit_platform
    
    la $a0, plat3
    move $a1, $t0
    move $a2, $t1
    jal check_barrel_single_platform
    bne $v0, $zero, barrel_hit_platform
    
    la $a0, plat4
    move $a1, $t0
    move $a2, $t1
    jal check_barrel_single_platform
    bne $v0, $zero, barrel_hit_platform
    
    la $a0, plat5
    move $a1, $t0
    move $a2, $t1
    jal check_barrel_single_platform
    bne $v0, $zero, barrel_hit_platform
    
    j no_barrel_collision

barrel_hit_platform:
    # Restaurar dirección del barril
    lw $s2, 0($sp)
    
    # Obtener Y de la plataforma
    lw $t5, 8($a0)
    
    # Posicionar barril sobre plataforma
    addi $t5, $t5, -2
    sw $t5, 4($s2)
    
    # Resetear velocidad vertical
    sw $zero, 8($s2)
    
    j restore_barrel_plat

no_barrel_collision:
restore_barrel_plat:
    lw $s2, 0($sp)
    lw $s4, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12

skip_barrel_plat:
    addi $s2, $s2, 20
    addi $s4, $s4, 1
    j barrel_plat_loop
    
barrel_plat_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

check_barrel_single_platform:
    # a0 = dirección plataforma, a1 = barrelX, a2 = barrelY
    lw $t3, 0($a0)  # plat x1
    lw $t4, 4($a0)  # plat x2
    lw $t5, 8($a0)  # plat y
    
    # Calcular pies del barril
    addi $t6, $a2, 2
    
    # Verificar distancia vertical
    sub $t7, $t6, $t5
    blt $t7, 0, barrel_plat_no
    bgt $t7, 3, barrel_plat_no
    
    # Verificar posición horizontal
    addi $t8, $a1, 1
    blt $t8, $t3, barrel_plat_no
    bgt $a1, $t4, barrel_plat_no
    
    li $v0, 1
    jr $ra
    
barrel_plat_no:
    li $v0, 0
    jr $ra

# ============================================
# DRAW TEXT FUNCTIONS
# ============================================

# Dibuja "YOU WON!" centrado
draw_you_won:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $s7, black
    
    # Y
    li $a0, 10
    li $a1, 50
    li $a2, 2
    li $a3, 3
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 12
    li $a1, 50
    li $a2, 2
    li $a3, 3
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 11
    li $a1, 53
    li $a2, 1
    li $a3, 4
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # O
    li $a0, 16
    li $a1, 50
    li $a2, 1
    li $a3, 7
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 20
    li $a1, 50
    li $a2, 1
    li $a3, 7
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 17
    li $a1, 50
    li $a2, 3
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 17
    li $a1, 56
    li $a2, 3
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # U
    li $a0, 24
    li $a1, 50
    li $a2, 1
    li $a3, 7
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 28
    li $a1, 50
    li $a2, 1
    li $a3, 7
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 25
    li $a1, 56
    li $a2, 3
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # W
    li $a0, 34
    li $a1, 50
    li $a2, 1
    li $a3, 7
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 36
    li $a1, 53
    li $a2, 1
    li $a3, 4
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 38
    li $a1, 50
    li $a2, 1
    li $a3, 7
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # O
    li $a0, 42
    li $a1, 50
    li $a2, 1
    li $a3, 7
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 46
    li $a1, 50
    li $a2, 1
    li $a3, 7
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 43
    li $a1, 50
    li $a2, 3
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 43
    li $a1, 56
    li $a2, 3
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # N
    li $a0, 50
    li $a1, 50
    li $a2, 1
    li $a3, 7
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 51
    li $a1, 51
    li $a2, 1
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 52
    li $a1, 52
    li $a2, 1
    li $a3, 2
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 53
    li $a1, 54
    li $a2, 1
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 54
    li $a1, 50
    li $a2, 1
    li $a3, 7
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Dibuja "GAME OVER" centrado
draw_game_over:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $s7, black
    
    # G
    li $a0, 8
    li $a1, 50
    li $a2, 1
    li $a3, 7
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 9
    li $a1, 50
    li $a2, 3
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 9
    li $a1, 56
    li $a2, 3
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 12
    li $a1, 53
    li $a2, 1
    li $a3, 4
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 10
    li $a1, 53
    li $a2, 2
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # A
    li $a0, 15
    li $a1, 50
    li $a2, 1
    li $a3, 7
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 19
    li $a1, 50
    li $a2, 1
    li $a3, 7
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 16
    li $a1, 50
    li $a2, 3
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 16
    li $a1, 53
    li $a2, 3
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # M
    li $a0, 22
    li $a1, 50
    li $a2, 1
    li $a3, 7
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 23
    li $a1, 51
    li $a2, 1
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 24
    li $a1, 52
    li $a2, 1
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 25
    li $a1, 51
    li $a2, 1
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 26
    li $a1, 50
    li $a2, 1
    li $a3, 7
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # E
    li $a0, 29
    li $a1, 50
    li $a2, 1
    li $a3, 7
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 30
    li $a1, 50
    li $a2, 3
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 30
    li $a1, 53
    li $a2, 2
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 30
    li $a1, 56
    li $a2, 3
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # O
    li $a0, 37
    li $a1, 50
    li $a2, 1
    li $a3, 7
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 41
    li $a1, 50
    li $a2, 1
    li $a3, 7
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 38
    li $a1, 50
    li $a2, 3
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 38
    li $a1, 56
    li $a2, 3
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # V
    li $a0, 44
    li $a1, 50
    li $a2, 1
    li $a3, 5
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 45
    li $a1, 55
    li $a2, 1
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 46
    li $a1, 56
    li $a2, 1
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 47
    li $a1, 55
    li $a2, 1
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 48
    li $a1, 50
    li $a2, 1
    li $a3, 5
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # E
    li $a0, 51
    li $a1, 50
    li $a2, 1
    li $a3, 7
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 52
    li $a1, 50
    li $a2, 3
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 52
    li $a1, 53
    li $a2, 2
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 52
    li $a1, 56
    li $a2, 3
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    # R
    li $a0, 56
    li $a1, 50
    li $a2, 1
    li $a3, 7
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 57
    li $a1, 50
    li $a2, 3
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 60
    li $a1, 51
    li $a2, 1
    li $a3, 2
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 57
    li $a1, 53
    li $a2, 3
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 59
    li $a1, 54
    li $a2, 1
    li $a3, 1
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    li $a0, 60
    li $a1, 55
    li $a2, 1
    li $a3, 2
    addi $sp, $sp, -4
    sw $s7, 0($sp)
    jal draw_rect
    addi $sp, $sp, 4
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
# ============================================
# INPUT
# ============================================
check_input:
    li $t0, 0xffff0000
    lw $t1, 0($t0)
    beq $t1, $zero, no_key_pressed
    
    li $t0, 0xffff0004
    lw $t1, 0($t0)
    
    beq $t1, 113, quit_game      # q
    beq $t1, 97, press_left      # a
    beq $t1, 100, press_right    # d
    beq $t1, 119, press_jump     # w
    beq $t1, 115, press_down     # s
    jr $ra

press_left:
    li $t2, -1
    sw $t2, playerVelX
    jr $ra

press_right:
    li $t2, 1
    sw $t2, playerVelX
    jr $ra

press_jump:
    lw $t3, onLadder
    beq $t3, 1, climb_up
    
    lw $t3, onGround
    lw $t4, coyoteTime
    beq $t3, 1, do_jump
    bgt $t4, 0, do_jump
    jr $ra
    
do_jump:
    lw $t4, jumpForce
    sw $t4, playerVelY
    sw $zero, onGround
    sw $zero, coyoteTime
    jr $ra

climb_up:
    lw $t4, playerY
    ble $t4, 0, no_key_pressed
    addi $t4, $t4, -1
    sw $t4, playerY
    sw $zero, playerVelY
    sw $zero, onGround
    jr $ra

press_down:
    lw $t3, onLadder
    bne $t3, 1, no_key_pressed
    lw $t4, playerY
    bge $t4, 126, no_key_pressed
    addi $t4, $t4, 1
    sw $t4, playerY
    sw $zero, playerVelY
    sw $zero, onGround
    jr $ra

quit_game:
    li $t6, 1
    sw $t6, gameOver
    sw $zero, playerWon
    jr $ra

no_key_pressed:
    # Si no hay tecla presionada, detener movimiento horizontal en el suelo
    lw $t3, onGround
    beq $t3, $zero, no_input_done
    sw $zero, playerVelX

no_input_done:
    jr $ra