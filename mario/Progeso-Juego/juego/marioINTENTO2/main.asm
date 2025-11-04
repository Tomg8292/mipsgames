############################################################
# main.asm
# Punto de entrada y game loop principal
# Mario Platformer - MARS 4.5
############################################################

.include "constants.asm"
.include "display.asm"
.include "physics.asm"

.data
# === VARIABLES GLOBALES DEL JUEGO ===
game_state: .word STATE_PLAYING     # Estado actual del juego
score: .word 0                      # Puntuación
lives: .word INITIAL_LIVES          # Vidas restantes
camera_x: .word 0                   # Posición X de la cámara
camera_y: .word 0                   # Posición Y de la cámara

# === DATOS DE MARIO ===
mario_x: .word 1600                 # Posición X (fixed-point: 16.00 tiles)
mario_y: .word 5000                 # Posición Y (fixed-point: 50.00 tiles)
mario_velocity_x: .word 0           # Velocidad horizontal
mario_velocity_y: .word 0           # Velocidad vertical
mario_on_ground: .word 0            # 1 si está en el suelo, 0 en el aire
mario_state: .word MARIO_STATE_IDLE # Estado de animación
mario_direction: .word DIR_RIGHT    # Dirección que mira

# === ARRAYS DE ENTIDADES (punteros a heap) ===
goombas_array: .word 0              # Puntero al array de Goombas
coins_array: .word 0                # Puntero al array de monedas
map_data: .word 0                   # Puntero al mapa de tiles

# === CONTADORES ===
active_goombas: .word 0             # Cantidad de Goombas activos
active_coins: .word 0               # Cantidad de monedas activas
total_coins: .word 0                # Total de monedas en el nivel

# === STRINGS PARA UI ===
str_game_over: .asciiz "GAME OVER\n"
str_you_win: .asciiz "YOU WIN!\n"
str_score: .asciiz "Score: "
str_lives: .asciiz " Lives: "
str_newline: .asciiz "\n"

.text
.globl main

############################################################
# MAIN - Punto de entrada del juego
############################################################
main:
    # === INICIALIZACIÓN ===
    jal initialize_game
    
    # === GAME LOOP PRINCIPAL ===
game_loop:
    # 1. Verificar estado del juego
    lw $t0, game_state
    li $t1, STATE_PLAYING
    bne $t0, $t1, check_end_states
    
    # 2. Procesar entrada del jugador
    jal process_input
    
    # 3. Actualizar física del juego
    jal update_physics
    
    # 4. Actualizar enemigos
    jal update_enemies
    
    # 5. Verificar colisiones
    jal check_all_collisions
    
    # 6. Actualizar cámara
    jal update_camera
    
    # 7. Renderizar frame
    jal render_frame
    
    # 8. Delay para mantener frame rate
    li $v0, SYSCALL_SLEEP
    li $a0, FRAME_DELAY
    syscall
    
    # 9. Repetir loop
    j game_loop

check_end_states:
    # Verificar si es Game Over
    li $t1, STATE_GAME_OVER
    beq $t0, $t1, show_game_over
    
    # Verificar si es Victoria
    li $t1, STATE_WIN
    beq $t0, $t1, show_win
    
    j game_loop

show_game_over:
    jal render_game_over
    j wait_restart

show_win:
    jal render_win
    j wait_restart

wait_restart:
    # Esperar tecla R para reiniciar o Q para salir
    jal check_restart_input
    j wait_restart

############################################################
# INITIALIZE_GAME - Inicializa todas las estructuras
############################################################
initialize_game:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # === ALOCAR MEMORIA HEAP ===
    # Goombas: MAX_GOOMBAS * GOOMBA_SIZE
    li $a0, 200                 # 10 * 20 = 200 bytes
    li $v0, SYSCALL_SBRK
    syscall
    sw $v0, goombas_array
    
    # Coins: MAX_COINS * COIN_SIZE
    li $a0, 240                 # 20 * 12 = 240 bytes
    li $v0, SYSCALL_SBRK
    syscall
    sw $v0, coins_array
    
    # Map: MAP_WIDTH * MAP_HEIGHT * 4
    li $a0, 32768               # 128 * 64 * 4 = 32768 bytes
    li $v0, SYSCALL_SBRK
    syscall
    sw $v0, map_data
    
    # === INICIALIZAR MAPA ===
    jal init_map
    
    # === INICIALIZAR ENEMIGOS Y MONEDAS ===
    jal spawn_initial_enemies
    jal spawn_initial_coins
    
    # === LIMPIAR PANTALLA ===
    jal clear_screen
    
    # === RESTAURAR Y RETORNAR ===
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

############################################################
# PROCESS_INPUT - Lee teclado y actualiza controles
############################################################
process_input:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Cargar dirección del receptor de teclado
    li $t0, MMIO_KEYBOARD_READY
    lw $t1, 0($t0)
    
    # Verificar si hay tecla presionada
    andi $t1, $t1, 0x0001
    beqz $t1, no_key_pressed
    
    # Leer código ASCII de la tecla
    li $t0, MMIO_KEYBOARD_DATA
    lw $t2, 0($t0)
    
    # === PROCESAR TECLAS ===
    # Tecla 'A' - Mover izquierda
    li $t3, KEY_A
    beq $t2, $t3, move_left
    
    # Tecla 'D' - Mover derecha
    li $t3, KEY_D
    beq $t2, $t3, move_right
    
    # Tecla 'W' o SPACE - Saltar
    li $t3, KEY_W
    beq $t2, $t3, jump
    li $t3, KEY_SPACE
    beq $t2, $t3, jump
    
    # Tecla 'Q' - Salir
    li $t3, KEY_Q
    beq $t2, $t3, quit_game
    
    j no_key_pressed

move_left:
    li $t0, -MOVE_SPEED
    sw $t0, mario_velocity_x
    li $t0, DIR_LEFT
    sw $t0, mario_direction
    j no_key_pressed

move_right:
    li $t0, MOVE_SPEED
    sw $t0, mario_velocity_x
    li $t0, DIR_RIGHT
    sw $t0, mario_direction
    j no_key_pressed

jump:
    # Solo saltar si está en el suelo
    lw $t0, mario_on_ground
    beqz $t0, no_key_pressed
    
    li $t0, JUMP_VELOCITY
    sw $t0, mario_velocity_y
    li $t0, 0
    sw $t0, mario_on_ground
    j no_key_pressed

quit_game:
    li $v0, SYSCALL_EXIT
    syscall

no_key_pressed:
    # Aplicar fricción si no se presiona tecla de movimiento
    # (Esto se puede mejorar con lógica más sofisticada)
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

############################################################
# CHECK_RESTART_INPUT - Verifica R o Q en pantallas finales
############################################################
check_restart_input:
    li $t0, MMIO_KEYBOARD_READY
    lw $t1, 0($t0)
    andi $t1, $t1, 0x0001
    beqz $t1, restart_return
    
    li $t0, MMIO_KEYBOARD_DATA
    lw $t2, 0($t0)
    
    # R para reiniciar
    li $t3, KEY_R
    beq $t2, $t3, restart_game
    
    # Q para salir
    li $t3, KEY_Q
    beq $t2, $t3, quit_game
    
restart_return:
    jr $ra

restart_game:
    # Resetear variables del juego
    li $t0, STATE_PLAYING
    sw $t0, game_state
    li $t0, 0
    sw $t0, score
    li $t0, INITIAL_LIVES
    sw $t0, lives
    li $t0, 1600
    sw $t0, mario_x
    li $t0, 5000
    sw $t0, mario_y
    li $t0, 0
    sw $t0, mario_velocity_x
    sw $t0, mario_velocity_y
    sw $t0, camera_x
    
    j game_loop

############################################################
# STUBS TEMPORALES (se implementarán en fases siguientes)
############################################################

############################################################
# UPDATE_PHYSICS - Actualiza física del juego
############################################################
update_physics:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # 1. Aplicar gravedad a Mario
    jal apply_gravity
    
    # 2. Actualizar posición basada en velocidad
    jal update_mario_position
    
    # 3. Verificar colisiones con el mapa
    jal check_mario_map_collisions
    
    # 4. Verificar límites del mundo
    jal check_world_bounds
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

############################################################
# CHECK_WORLD_BOUNDS - Previene que Mario salga del mapa
############################################################
check_world_bounds:
    # Verificar límite izquierdo
    lw $t0, mario_x
    bltz $t0, clamp_left
    
    # Verificar límite derecho (MAP_WIDTH * TILE_SIZE * FIXED_SCALE)
    li $t1, MAP_WIDTH
    li $t2, TILE_SIZE
    mult $t1, $t2
    mflo $t1
    li $t2, FIXED_SCALE
    mult $t1, $t2
    mflo $t1
    
    bge $t0, $t1, clamp_right
    
    # Verificar si cayó al vacío (muerte)
    lw $t0, mario_y
    li $t1, MAP_HEIGHT
    li $t2, TILE_SIZE
    mult $t1, $t2
    mflo $t1
    li $t2, FIXED_SCALE
    mult $t1, $t2
    mflo $t1
    
    bge $t0, $t1, mario_fell_off
    
    jr $ra

clamp_left:
    li $t0, 0
    sw $t0, mario_x
    sw $t0, mario_velocity_x
    jr $ra

clamp_right:
    sw $t1, mario_x
    sw $zero, mario_velocity_x
    jr $ra

mario_fell_off:
    # Mario cayó - perder vida
    jal lose_life
    jr $ra

############################################################
# LOSE_LIFE - Reduce vidas y verifica Game Over
############################################################
lose_life:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Reducir vidas
    lw $t0, lives
    subi $t0, $t0, 1
    sw $t0, lives
    
    # Verificar si quedan vidas
    blez $t0, trigger_game_over
    
    # Resetear posición de Mario
    jal respawn_mario
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

trigger_game_over:
    li $t0, STATE_GAME_OVER
    sw $t0, game_state
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

############################################################
# RESPAWN_MARIO - Reposiciona Mario en spawn point
############################################################
respawn_mario:
    li $t0, 1600            # 16.00 en fixed-point
    sw $t0, mario_x
    li $t0, 5000            # 50.00 en fixed-point
    sw $t0, mario_y
    sw $zero, mario_velocity_x
    sw $zero, mario_velocity_y
    sw $zero, mario_on_ground
    jr $ra

############################################################
# UPDATE_ENEMIES - Actualiza IA de enemigos (Fase 6)
############################################################
update_enemies:
    # Se implementará en Fase 6
    jr $ra

############################################################
# CHECK_ALL_COLLISIONS - Verifica colisiones Mario-Entidades
############################################################
check_all_collisions:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Verificar colisiones con Goombas
    jal check_mario_goomba_collisions
    
    # Verificar colisiones con monedas
    jal check_mario_coin_collisions
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

############################################################
# CHECK_MARIO_GOOMBA_COLLISIONS - Colisiones con enemigos
############################################################
check_mario_goomba_collisions:
    # Se implementará completamente en Fase 6
    # Por ahora, stub vacío
    jr $ra

############################################################
# CHECK_MARIO_COIN_COLLISIONS - Colisiones con monedas
############################################################
check_mario_coin_collisions:
    # Se implementará completamente en Fase 7
    # Por ahora, stub vacío
    jr $ra

############################################################
# UPDATE_CAMERA - Actualiza posición de cámara (scrolling)
############################################################
update_camera:
    # Obtener posición X de Mario en tiles
    lw $t0, mario_x
    li $t1, FIXED_SCALE
    div $t0, $t1
    mflo $t0                # mario_x en tiles
    
    # Calcular posición ideal de cámara
    # Queremos a Mario en el centro-izquierda de la pantalla (tile 20)
    subi $t1, $t0, 20
    
    # Limitar cámara al inicio del nivel
    bltz $t1, camera_at_start
    
    # Limitar cámara al final del nivel
    li $t2, MAP_WIDTH
    subi $t2, $t2, VIEWPORT_WIDTH
    bge $t1, $t2, camera_at_end
    
    # Actualizar cámara con smooth follow (interpolación)
    lw $t3, camera_x
    li $t4, FIXED_SCALE
    mult $t1, $t4
    mflo $t1                # target_camera_x en fixed-point
    
    # Interpolación: camera_x += (target - camera_x) / 8
    sub $t2, $t1, $t3
    sra $t2, $t2, 3         # Dividir por 8
    add $t3, $t3, $t2
    sw $t3, camera_x
    
    jr $ra

camera_at_start:
    sw $zero, camera_x
    jr $ra

camera_at_end:
    li $t3, FIXED_SCALE
    mult $t2, $t3
    mflo $t3
    sw $t3, camera_x
    jr $ra

############################################################
# RENDER_FRAME - Dibuja todo el frame actual
############################################################
render_frame:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # 1. Limpiar pantalla con color de cielo
    jal clear_screen
    
    # 2. Renderizar mapa (tiles visibles)
    jal render_map
    
    # 3. Renderizar monedas
    jal render_coins
    
    # 4. Renderizar enemigos
    jal render_goombas
    
    # 5. Renderizar Mario
    jal render_mario
    
    # 6. Renderizar HUD (vidas y puntuación)
    jal render_hud
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

############################################################
# RENDER_MARIO - Dibuja a Mario en su posición actual
############################################################
render_mario:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Convertir posición mundo a pantalla
    lw $a0, mario_x
    lw $a1, camera_x
    jal world_to_screen_x
    move $s0, $v0           # screen_x en $s0
    
    lw $a0, mario_y
    lw $a1, camera_y
    jal world_to_screen_y
    move $s1, $v0           # screen_y en $s1
    
    # Verificar si está en pantalla (culling)
    bltz $s0, mario_offscreen
    li $t0, VIEWPORT_WIDTH
    bge $s0, $t0, mario_offscreen
    bltz $s1, mario_offscreen
    li $t0, VIEWPORT_HEIGHT
    bge $s1, $t0, mario_offscreen
    
    # Dibujar Mario
    lw $t0, mario_direction
    DrawMario($s0, $s1, $t0)
    
mario_offscreen:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

############################################################
# RENDER_GOOMBAS - Dibuja todos los Goombas activos
############################################################
render_goombas:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    lw $s0, goombas_array   # Puntero al array
    lw $s1, active_goombas  # Cantidad de Goombas
    li $s2, 0               # Índice
    
render_goomba_loop:
    bge $s2, $s1, render_goomba_done
    
    # Calcular offset: índice * GOOMBA_SIZE
    move $t0, $s2
    li $t1, GOOMBA_SIZE
    mult $t0, $t1
    mflo $t0
    add $t0, $s0, $t0       # Dirección de este Goomba
    
    # Verificar si está activo
    lw $t1, 12($t0)         # active flag
    beqz $t1, render_goomba_next
    
    # Cargar posición
    lw $a0, 0($t0)          # x
    lw $a1, 4($t0)          # y
    
    # Convertir a coordenadas de pantalla
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    
    lw $a1, camera_x
    jal world_to_screen_x
    move $t2, $v0
    
    lw $t0, 0($sp)
    lw $a0, 4($t0)
    lw $a1, camera_y
    jal world_to_screen_y
    move $t3, $v0
    
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    
    # Culling
    bltz $t2, render_goomba_next
    li $t4, VIEWPORT_WIDTH
    bge $t2, $t4, render_goomba_next
    
    # Dibujar
    DrawGoomba($t2, $t3)
    
render_goomba_next:
    addi $s2, $s2, 1
    j render_goomba_loop
    
render_goomba_done:
    lw $s2, 12($sp)
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 16
    jr $ra

############################################################
# RENDER_COINS - Dibuja todas las monedas activas
############################################################
render_coins:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    lw $s0, coins_array
    lw $s1, active_coins
    li $s2, 0
    
render_coin_loop:
    bge $s2, $s1, render_coin_done
    
    # Calcular offset
    move $t0, $s2
    li $t1, COIN_SIZE
    mult $t0, $t1
    mflo $t0
    add $t0, $s0, $t0
    
    # Verificar si activa
    lw $t1, 8($t0)
    beqz $t1, render_coin_next
    
    # Convertir a pantalla y dibujar
    lw $a0, 0($t0)
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    
    lw $a1, camera_x
    jal world_to_screen_x
    move $t2, $v0
    
    lw $t0, 0($sp)
    lw $a0, 4($t0)
    lw $a1, camera_y
    jal world_to_screen_y
    move $t3, $v0
    
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    
    # Culling y dibujar
    bltz $t2, render_coin_next
    li $t4, VIEWPORT_WIDTH
    bge $t2, $t4, render_coin_next
    
    DrawCoin($t2, $t3)
    
render_coin_next:
    addi $s2, $s2, 1
    j render_coin_loop
    
render_coin_done:
    lw $s2, 12($sp)
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 16
    jr $ra

############################################################
# RENDER_MAP - Dibuja los tiles visibles del mapa
############################################################
render_map:
    # Stub por ahora - se implementará en Fase 5
    jr $ra

############################################################
# RENDER_HUD - Dibuja vidas y puntuación
############################################################
render_hud:
    # Stub por ahora - se implementará en Fase 8
    jr $ra

############################################################
# RENDER_GAME_OVER - Pantalla de Game Over
############################################################
render_game_over:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Limpiar pantalla
    ClearScreen(COLOR_BLACK)
    
    # Dibujar texto "GAME OVER" en forma de píxeles
    # Por ahora solo mensaje en consola
    li $v0, SYSCALL_PRINT_STRING
    la $a0, str_game_over
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

############################################################
# RENDER_WIN - Pantalla de Victoria
############################################################
render_win:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Limpiar pantalla
    ClearScreen(COLOR_GREEN)
    
    # Mensaje en consola
    li $v0, SYSCALL_PRINT_STRING
    la $a0, str_you_win
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

############################################################
# INIT_MAP - Inicializa el mapa del nivel
############################################################
init_map:
    # Se implementará en Fase 5
    jr $ra

############################################################
# SPAWN_INITIAL_ENEMIES - Crea Goombas iniciales
############################################################
spawn_initial_enemies:
    # Se implementará en Fase 6
    jr $ra

############################################################
# SPAWN_INITIAL_COINS - Crea monedas iniciales
############################################################
spawn_initial_coins:
    # Se implementará en Fase 7
    jr $ra

############################################################
# Fin de main.asm
############################################################