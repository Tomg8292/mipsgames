############################################################
# mario.asm
# Lógica avanzada del jugador Mario
# Estados, animaciones y controles mejorados
# Mario Platformer - MARS 4.5
############################################################

.include "constants.asm"

############################################################
# FUNCIÓN: update_mario_state
# Actualiza el estado visual de Mario según su situación
############################################################
.text
.globl update_mario_state
update_mario_state:
    # Verificar si está en el aire
    lw $t0, mario_on_ground
    beqz $t0, mario_in_air
    
    # En el suelo - verificar si se mueve
    lw $t0, mario_velocity_x
    beqz $t0, mario_idle_state
    
    # Se está moviendo
    li $t0, MARIO_STATE_WALK
    sw $t0, mario_state
    jr $ra
    
mario_idle_state:
    li $t0, MARIO_STATE_IDLE
    sw $t0, mario_state
    jr $ra
    
mario_in_air:
    # En el aire - determinar si sube o baja
    lw $t0, mario_velocity_y
    bgtz $t0, mario_jumping
    
    # Cayendo
    li $t0, MARIO_STATE_FALL
    sw $t0, mario_state
    jr $ra
    
mario_jumping:
    li $t0, MARIO_STATE_JUMP
    sw $t0, mario_state
    jr $ra

############################################################
# FUNCIÓN: handle_jump_variable_height
# Implementa salto de altura variable
# Si el jugador suelta W/Space temprano, reduce velocidad
############################################################
.text
.globl handle_jump_variable_height
handle_jump_variable_height:
    # Solo aplicar si está saltando hacia arriba
    lw $t0, mario_velocity_y
    blez $t0, jump_var_return
    
    # Verificar si está en el aire
    lw $t0, mario_on_ground
    bnez $t0, jump_var_return
    
    # Verificar si se soltó la tecla de salto
    li $t0, MMIO_KEYBOARD_READY
    lw $t1, 0($t0)
    andi $t1, $t1, 0x0001
    beqz $t1, cut_jump          # No hay tecla = cortar salto
    
    # Verificar si la tecla actual es W o Space
    li $t0, MMIO_KEYBOARD_DATA
    lw $t2, 0($t0)
    
    li $t3, KEY_W
    beq $t2, $t3, jump_var_return
    li $t3, KEY_SPACE
    beq $t2, $t3, jump_var_return
    
cut_jump:
    # Cortar el salto reduciendo velocidad vertical
    lw $t0, mario_velocity_y
    sra $t0, $t0, 1             # Dividir velocidad por 2
    sw $t0, mario_velocity_y
    
jump_var_return:
    jr $ra

############################################################
# FUNCIÓN: update_mario_direction
# Actualiza la dirección que mira Mario
############################################################
.text
.globl update_mario_direction
update_mario_direction:
    lw $t0, mario_velocity_x
    
    # Si se mueve a la derecha
    bgtz $t0, face_right
    
    # Si se mueve a la izquierda
    bltz $t0, face_left
    
    # Si no se mueve, mantener dirección actual
    jr $ra
    
face_right:
    li $t0, DIR_RIGHT
    sw $t0, mario_direction
    jr $ra
    
face_left:
    li $t0, DIR_LEFT
    sw $t0, mario_direction
    jr $ra

############################################################
# FUNCIÓN: handle_continuous_movement
# Maneja el movimiento continuo mientras se mantiene tecla
# Reemplaza el sistema simple de input
############################################################
.text
.globl handle_continuous_movement
handle_continuous_movement:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Resetear velocidad horizontal por defecto
    # (se activa solo si se presiona tecla)
    
    # Verificar teclado
    li $t0, MMIO_KEYBOARD_READY
    lw $t1, 0($t0)
    andi $t1, $t1, 0x0001
    beqz $t1, apply_friction_move
    
    # Leer tecla
    li $t0, MMIO_KEYBOARD_DATA
    lw $t2, 0($t0)
    
    # Tecla A - Izquierda
    li $t3, KEY_A
    beq $t2, $t3, move_left_continuous
    
    # Tecla D - Derecha
    li $t3, KEY_D
    beq $t2, $t3, move_right_continuous
    
    # Tecla W o Space - Saltar
    li $t3, KEY_W
    beq $t2, $t3, try_jump
    li $t3, KEY_SPACE
    beq $t2, $t3, try_jump
    
    # Otra tecla - aplicar fricción
    j apply_friction_move
    
move_left_continuous:
    # Acelerar hacia la izquierda
    lw $t0, mario_velocity_x
    subi $t0, $t0, 30           # Aceleración
    
    # Limitar velocidad máxima
    li $t1, -MOVE_SPEED
    blt $t0, $t1, clamp_left_speed
    sw $t0, mario_velocity_x
    j handle_move_done
    
clamp_left_speed:
    li $t0, -MOVE_SPEED
    sw $t0, mario_velocity_x
    j handle_move_done
    
move_right_continuous:
    # Acelerar hacia la derecha
    lw $t0, mario_velocity_x
    addi $t0, $t0, 30
    
    # Limitar velocidad máxima
    li $t1, MOVE_SPEED
    bgt $t0, $t1, clamp_right_speed
    sw $t0, mario_velocity_x
    j handle_move_done
    
clamp_right_speed:
    li $t0, MOVE_SPEED
    sw $t0, mario_velocity_x
    j handle_move_done
    
try_jump:
    # Solo saltar si está en el suelo
    lw $t0, mario_on_ground
    beqz $t0, handle_move_done
    
    li $t0, JUMP_VELOCITY
    sw $t0, mario_velocity_y
    li $t0, 0
    sw $t0, mario_on_ground
    j handle_move_done
    
apply_friction_move:
    # Aplicar fricción si no se presiona tecla de movimiento
    lw $t0, mario_velocity_x
    beqz $t0, handle_move_done
    
    bgtz $t0, friction_positive_move
    
friction_negative_move:
    addi $t0, $t0, 25
    bgtz $t0, friction_zero_move
    sw $t0, mario_velocity_x
    j handle_move_done
    
friction_positive_move:
    subi $t0, $t0, 25
    bltz $t0, friction_zero_move
    sw $t0, mario_velocity_x
    j handle_move_done
    
friction_zero_move:
    sw $zero, mario_velocity_x
    
handle_move_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

############################################################
# FUNCIÓN: check_mario_death_conditions
# Verifica condiciones de muerte (caída, aplastamiento, etc)
############################################################
.text
.globl check_mario_death_conditions
check_mario_death_conditions:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Verificar si cayó del mapa
    lw $t0, mario_y
    li $t1, MAP_HEIGHT
    li $t2, TILE_SIZE
    mult $t1, $t2
    mflo $t1
    li $t2, FIXED_SCALE
    mult $t1, $t2
    mflo $t1
    addi $t1, $t1, 500          # Margen de 5 tiles
    
    bge $t0, $t1, mario_died
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
mario_died:
    jal lose_life
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

############################################################
# FUNCIÓN: get_mario_bottom
# Calcula la posición del borde inferior de Mario
# Útil para colisiones precisas
# Retorna: $v0 = bottom_y (fixed-point)
############################################################
.text
.globl get_mario_bottom
get_mario_bottom:
    lw $v0, mario_y
    li $t0, MARIO_HEIGHT
    li $t1, FIXED_SCALE
    mult $t0, $t1
    mflo $t0
    add $v0, $v0, $t0
    jr $ra

############################################################
# FUNCIÓN: get_mario_right
# Calcula la posición del borde derecho de Mario
# Retorna: $v0 = right_x (fixed-point)
############################################################
.text
.globl get_mario_right
get_mario_right:
    lw $v0, mario_x
    li $t0, MARIO_WIDTH
    li $t1, FIXED_SCALE
    mult $t0, $t1
    mflo $t0
    add $v0, $v0, $t0
    jr $ra

############################################################
# FUNCIÓN: get_mario_center_x
# Calcula la posición del centro X de Mario
# Útil para spawn de efectos, etc
# Retorna: $v0 = center_x (fixed-point)
############################################################
.text
.globl get_mario_center_x
get_mario_center_x:
    lw $v0, mario_x
    li $t0, MARIO_WIDTH
    sra $t0, $t0, 1             # width / 2
    li $t1, FIXED_SCALE
    mult $t0, $t1
    mflo $t0
    add $v0, $v0, $t0
    jr $ra

############################################################
# FUNCIÓN: get_mario_center_y
# Calcula la posición del centro Y de Mario
# Retorna: $v0 = center_y (fixed-point)
############################################################
.text
.globl get_mario_center_y
get_mario_center_y:
    lw $v0, mario_y
    li $t0, MARIO_HEIGHT
    sra $t0, $t0, 1             # height / 2
    li $t1, FIXED_SCALE
    mult $t0, $t1
    mflo $t0
    add $v0, $v0, $t0
    jr $ra

############################################################
# FUNCIÓN: is_mario_moving
# Verifica si Mario se está moviendo
# Retorna: $v0 = 1 si se mueve, 0 si está quieto
############################################################
.text
.globl is_mario_moving
is_mario_moving:
    lw $t0, mario_velocity_x
    beqz $t0, not_moving
    
    li $v0, 1
    jr $ra
    
not_moving:
    li $v0, 0
    jr $ra

############################################################
# FUNCIÓN: apply_knockback
# Aplica efecto de knockback cuando Mario es golpeado
# Parámetros:
#   $a0 = dirección del knockback (0=izquierda, 1=derecha)
############################################################
.text
.globl apply_knockback
apply_knockback:
    # Aplicar velocidad horizontal opuesta
    beqz $a0, knockback_left
    
knockback_right:
    li $t0, 300                 # Empuje hacia derecha
    sw $t0, mario_velocity_x
    j knockback_vertical
    
knockback_left:
    li $t0, -300                # Empuje hacia izquierda
    sw $t0, mario_velocity_x
    
knockback_vertical:
    # Pequeño salto hacia arriba
    li $t0, 800
    sw $t0, mario_velocity_y
    li $t0, 0
    sw $t0, mario_on_ground
    
    jr $ra

############################################################
# FUNCIÓN: can_mario_jump
# Verifica si Mario puede saltar actualmente
# Retorna: $v0 = 1 si puede saltar, 0 si no
############################################################
.text
.globl can_mario_jump
can_mario_jump:
    lw $v0, mario_on_ground
    jr $ra

############################################################
# FUNCIÓN: mario_perform_jump
# Ejecuta el salto de Mario (versión limpia)
############################################################
.text
.globl mario_perform_jump
mario_perform_jump:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Verificar si puede saltar
    jal can_mario_jump
    beqz $v0, jump_failed
    
    # Aplicar velocidad de salto
    li $t0, JUMP_VELOCITY
    sw $t0, mario_velocity_y
    
    # Quitar del suelo
    sw $zero, mario_on_ground
    
    # Actualizar estado
    li $t0, MARIO_STATE_JUMP
    sw $t0, mario_state
    
jump_failed:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

############################################################
# FUNCIÓN: reset_mario_for_new_level
# Resetea Mario para un nuevo nivel
# (Diferente a respawn - mantiene vidas y puntos)
############################################################
.text
.globl reset_mario_for_new_level
reset_mario_for_new_level:
    # Posición inicial
    li $t0, 1600
    sw $t0, mario_x
    li $t0, 5000
    sw $t0, mario_y
    
    # Velocidades a cero
    sw $zero, mario_velocity_x
    sw $zero, mario_velocity_y
    
    # Estados
    sw $zero, mario_on_ground
    li $t0, MARIO_STATE_IDLE
    sw $t0, mario_state
    li $t0, DIR_RIGHT
    sw $t0, mario_direction
    
    # Cámara al inicio
    sw $zero, camera_x
    sw $zero, camera_y
    
    jr $ra

############################################################
# FUNCIÓN: debug_print_mario_info
# Imprime información de debug de Mario en consola
# (Útil para testing)
############################################################
.text
.globl debug_print_mario_info
debug_print_mario_info:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Imprimir posición X
    li $v0, 4
    la $a0, debug_str_x
    syscall
    
    lw $a0, mario_x
    li $t0, FIXED_SCALE
    div $a0, $t0
    mflo $a0
    li $v0, 1
    syscall
    
    # Imprimir posición Y
    li $v0, 4
    la $a0, debug_str_y
    syscall
    
    lw $a0, mario_y
    li $t0, FIXED_SCALE
    div $a0, $t0
    mflo $a0
    li $v0, 1
    syscall
    
    # Imprimir velocidad Y
    li $v0, 4
    la $a0, debug_str_vy
    syscall
    
    lw $a0, mario_velocity_y
    li $v0, 1
    syscall
    
    # Imprimir on_ground
    li $v0, 4
    la $a0, debug_str_ground
    syscall
    
    lw $a0, mario_on_ground
    li $v0, 1
    syscall
    
    # Nueva línea
    li $v0, 4
    la $a0, str_newline
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

############################################################
# DATOS DE DEBUG
############################################################
.data
debug_str_x: .asciiz "X: "
debug_str_y: .asciiz " Y: "
debug_str_vy: .asciiz " VelY: "
debug_str_ground: .asciiz " Ground: "

############################################################
# Fin de mario.asm
############################################################