# Super Mario Bros - MIPS Assembly for MARS 4.5
# BITMAP DISPLAY SETUP:
#    Tools -> Bitmap Display:
#    Unit Width: 8, Unit Height: 8
#    Display Width: 512, Display Height: 256
#    Base: 0x10008000 ($gp)
# KEYBOARD MMIO:
#    Tools -> Keyboard MMIO -> Connect to MIPS

.data
    # Screen dimensions (512/8 = 64, 256/8 = 32)
    SCREEN_WIDTH: .word 64
    SCREEN_HEIGHT: .word 32
    
    # Colors
    COLOR_SKY: .word 0x5C94FC
    COLOR_GROUND: .word 0x8B4513
    COLOR_BRICK: .word 0xFF8800
    COLOR_MARIO_RED: .word 0xFF0000
    COLOR_MARIO_BLUE: .word 0x0000FF
    COLOR_MARIO_SKIN: .word 0xFFE4B5
    COLOR_GOOMBA_BROWN: .word 0x8B4513
    COLOR_GOOMBA_BODY: .word 0xD2691E
    COLOR_GOOMBA_EYES: .word 0x000000
    COLOR_CLOUD: .word 0xFFFFFF
    COLOR_COIN: .word 0xFFD700
    
    # Game state
    mario_x: .word 5
    mario_y: .word 25
    mario_vy: .word 0
    mario_vx: .word 0
    mario_on_ground: .word 1
    mario_lives: .word 3
    score: .word 0
    coins: .word 0
    
    # Mario dimensions
    MARIO_WIDTH: .word 2
    MARIO_HEIGHT: .word 3
    
    # Ground level
    GROUND_Y: .word 28
    GROUND_HEIGHT: .word 4
    
    # Physics
    GRAVITY: .word 1
    JUMP_VELOCITY: .word -6
    BOUNCE_VELOCITY: .word -4
    MAX_FALL_SPEED: .word 8
    ACCELERATION: .word 1
    MAX_SPEED: .word 3
    FRICTION: .word 1
    
    # Platform (más larga)
    platform_x: .word 18
    platform_y: .word 18
    platform_width: .word 16
    platform_height: .word 2
    
    # Goomba
    goomba_x: .word 45
    goomba_alive: .word 1
    goomba_direction: .word 1
    goomba_patrol_left: .word 35
    goomba_patrol_right: .word 60
    goomba_move_counter: .word 0
    goomba_move_delay: .word 3
    
    GOOMBA_WIDTH: .word 3
    GOOMBA_HEIGHT: .word 3
    
    # Coins - 5 monedas en total
    coin1_x: .word 20
    coin1_y: .word 15
    coin1_collected: .word 0
    
    coin2_x: .word 25
    coin2_y: .word 15
    coin2_collected: .word 0
    
    coin3_x: .word 30
    coin3_y: .word 15
    coin3_collected: .word 0
    
    coin4_x: .word 10
    coin4_y: .word 24
    coin4_collected: .word 0
    
    coin5_x: .word 55
    coin5_y: .word 22
    coin5_collected: .word 0
    
    COIN_WIDTH: .word 2
    COIN_HEIGHT: .word 2
    
    # Clouds (x, y, width)
    clouds: .word
        10, 5, 4,
        35, 7, 5,
        55, 4, 4,
        0, 0, 0
    
    # Messages
    msg_lives: .asciiz "Lives: "
    msg_score: .asciiz " Score: "
    msg_coins: .asciiz " Coins: "
    msg_start: .asciiz "\nSUPER MARIO - Press SPACE to start\n"
    msg_gameover: .asciiz "\n\nGAME OVER\n"

.text
.globl main

main:
    jal clear_screen
    jal show_start_screen
    
wait_for_start:
    li $t0, 0xffff0000
    lw $t1, 0($t0)
    andi $t1, $t1, 1
    beqz $t1, wait_for_start
    
    lw $t1, 4($t0)
    li $t2, 0x20
    bne $t1, $t2, wait_for_start
    
    li $v0, 4
    la $a0, msg_start
    syscall

# ==================== MAIN GAME LOOP ====================
game_loop:
    lw $t0, mario_lives
    blez $t0, game_over
    
    jal process_input
    jal update_mario_physics
    jal update_goomba
    jal check_goomba_collision
    jal check_coin_collisions
    jal render_frame
    
    li $a0, 10
    jal delay
    
    j game_loop

game_over:
    jal show_game_over_screen
    
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
    li $t0, 5
    sw $t0, mario_x
    li $t0, 25
    sw $t0, mario_y
    sw $zero, mario_vy
    sw $zero, mario_vx
    li $t0, 1
    sw $t0, mario_on_ground
    li $t0, 3
    sw $t0, mario_lives
    sw $zero, score
    sw $zero, coins
    li $t0, 45
    sw $t0, goomba_x
    li $t0, 1
    sw $t0, goomba_alive
    sw $t0, goomba_direction
    sw $zero, goomba_move_counter
    sw $zero, coin1_collected
    sw $zero, coin2_collected
    sw $zero, coin3_collected
    sw $zero, coin4_collected
    sw $zero, coin5_collected
    j main

exit_program:
    li $v0, 10
    syscall

# ==================== INPUT PROCESSING ====================
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
    beqz $t0, apply_friction
    
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

# ==================== MARIO PHYSICS ====================
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
    li $t2, 62
    bge $t1, $t2, clamp_x_right
    sw $t1, mario_x
    j check_platform
    
clamp_x_left:
    sw $zero, mario_x
    sw $zero, mario_vx
    j check_platform
    
clamp_x_right:
    li $t3, 62
    sw $t3, mario_x
    sw $zero, mario_vx

check_platform:
    move $a0, $s0
    jal check_platform_collision
    
    lw $t0, mario_y
    lw $t1, MARIO_HEIGHT
    add $t0, $t0, $t1
    lw $t2, GROUND_Y
    blt $t0, $t2, physics_done
    
    sub $t3, $t2, $t1
    sw $t3, mario_y
    sw $zero, mario_vy
    li $t4, 1
    sw $t4, mario_on_ground

physics_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

# ==================== PLATFORM COLLISION ====================
check_platform_collision:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    
    lw $s0, mario_x
    lw $s1, mario_y
    move $s2, $a0
    lw $s3, mario_vy
    
    lw $t0, MARIO_WIDTH
    lw $t1, MARIO_HEIGHT
    
    lw $t2, platform_x
    lw $t3, platform_y
    lw $t4, platform_width
    lw $t5, platform_height
    
    add $t6, $s0, $t0
    add $t7, $t2, $t4
    
    blt $t6, $t2, no_platform_hit
    bge $s0, $t7, no_platform_hit
    
    bgtz $s3, check_landing
    bltz $s3, check_hitting_bottom
    j no_platform_hit

check_landing:
    add $t6, $s1, $t1
    add $t7, $s2, $t1
    
    blt $t6, $t3, no_platform_hit
    bgt $t7, $t3, no_platform_hit
    
    sub $t8, $t6, $t3
    li $t9, 5
    bgt $t8, $t9, no_platform_hit
    
    sub $t6, $t3, $t1
    sw $t6, mario_y
    sw $zero, mario_vy
    li $t7, 1
    sw $t7, mario_on_ground
    j platform_hit_done

check_hitting_bottom:
    add $t6, $t3, $t5
    
    bgt $s1, $t6, no_platform_hit
    blt $s2, $t6, no_platform_hit
    
    sub $t8, $t6, $s1
    li $t9, 5
    bgt $t8, $t9, no_platform_hit
    
    sw $t6, mario_y
    sw $zero, mario_vy
    sw $zero, mario_on_ground
    j platform_hit_done

no_platform_hit:
    lw $t0, mario_y
    lw $t1, MARIO_HEIGHT
    add $t0, $t0, $t1
    lw $t2, GROUND_Y
    blt $t0, $t2, set_in_air
    j platform_collision_done

set_in_air:
    sw $zero, mario_on_ground

platform_hit_done:
platform_collision_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra

# ==================== GOOMBA UPDATE ====================
update_goomba:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, goomba_alive
    beqz $t0, goomba_update_done
    
    lw $t0, goomba_move_counter
    addi $t0, $t0, 1
    lw $t1, goomba_move_delay
    
    blt $t0, $t1, save_counter_only
    
    sw $zero, goomba_move_counter
    
    lw $t1, goomba_x
    lw $t2, goomba_direction
    lw $t3, goomba_patrol_left
    lw $t4, goomba_patrol_right
    
    bgtz $t2, move_goomba_right
    
move_goomba_left:
    addi $t1, $t1, -1
    ble $t1, $t3, reverse_to_right
    j save_goomba_position

move_goomba_right:
    addi $t1, $t1, 1
    bge $t1, $t4, reverse_to_left
    j save_goomba_position

reverse_to_left:
    li $t2, -1
    sw $t2, goomba_direction
    j save_goomba_position

reverse_to_right:
    li $t2, 1
    sw $t2, goomba_direction
    j save_goomba_position

save_counter_only:
    sw $t0, goomba_move_counter
    j goomba_update_done

save_goomba_position:
    sw $t1, goomba_x

goomba_update_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ==================== GOOMBA COLLISION (CORREGIDA CON HITBOX INVISIBLE) ====================
check_goomba_collision:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Verificar si Goomba está vivo
    lw $t0, goomba_alive
    beqz $t0, end_goomba_check
    
    # ===== CARGAR DATOS DE MARIO =====
    lw $s0, mario_x           # s0 = mario_x
    lw $s1, mario_y           # s1 = mario_y
    lw $s2, MARIO_WIDTH       # s2 = 2
    lw $s3, MARIO_HEIGHT      # s3 = 3
    add $s4, $s0, $s2         # s4 = mario_right
    add $s5, $s1, $s3         # s5 = mario_bottom
    
    # ===== CARGAR DATOS DE GOOMBA =====
    lw $s6, goomba_x          # s6 = goomba_x
    lw $t0, GROUND_Y          # t0 = 28
    lw $t1, GOOMBA_HEIGHT     # t1 = 3
    sub $s7, $t0, $t1         # s7 = goomba_y = 25
    lw $t2, GOOMBA_WIDTH      # t2 = 3
    add $t3, $s6, $t2         # t3 = goomba_right
    add $t4, $s7, $t1         # t4 = goomba_bottom = 28
    
    # ===== HITBOX INVISIBLE ARRIBA DEL GOOMBA =====
    # Posición: (goomba_x, goomba_y - 2, GOOMBA_WIDTH, 2)
    
    addi $t5, $s7, -2         # t5 = head_y = goomba_y - 2 = 23
    
    # Verificar overlap horizontal con hitbox invisible
    bge $s0, $t3, check_body_collision    # mario_x >= goomba_right
    ble $s4, $s6, check_body_collision    # mario_right <= goomba_x
    
    # Verificar overlap vertical con hitbox invisible
    bge $s1, $s7, check_body_collision    # mario_y >= head_bottom (25)
    ble $s5, $t5, check_body_collision    # mario_bottom <= head_y (23)
    
    # ¡MARIO TOCÓ LA HITBOX INVISIBLE! - Goomba muere
    j kill_goomba
    
check_body_collision:
    # ===== HITBOX DEL CUERPO VISIBLE DEL GOOMBA (3x3) =====
    
    # Verificar overlap horizontal con cuerpo
    bge $s0, $t3, end_goomba_check        # mario_x >= goomba_right
    ble $s4, $s6, end_goomba_check        # mario_right <= goomba_x
    
    # Verificar overlap vertical con cuerpo
    bge $s1, $t4, end_goomba_check        # mario_y >= goomba_bottom (28)
    ble $s5, $s7, end_goomba_check        # mario_bottom <= goomba_y (25)
    
    # ¡MARIO TOCÓ EL CUERPO! - Mario muere
    j mario_dies

kill_goomba:
    # Mario pisó la hitbox invisible - Goomba muere
    sw $zero, goomba_alive
    
    # Sumar 100 puntos
    lw $t0, score
    addi $t0, $t0, 100
    sw $t0, score
    
    # Hacer rebotar a Mario
    lw $t1, BOUNCE_VELOCITY
    sw $t1, mario_vy
    
    j end_goomba_check

mario_dies:
    # Mario tocó el cuerpo del Goomba - Mario pierde vida
    jal mario_hit

end_goomba_check:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ==================== COIN COLLISIONS ====================
check_coin_collisions:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, coin1_collected
    bnez $t0, check_coin2
    lw $a0, coin1_x
    lw $a1, coin1_y
    jal check_single_coin
    beqz $v0, check_coin2
    li $t0, 1
    sw $t0, coin1_collected
    jal collect_coin
    
check_coin2:
    lw $t0, coin2_collected
    bnez $t0, check_coin3
    lw $a0, coin2_x
    lw $a1, coin2_y
    jal check_single_coin
    beqz $v0, check_coin3
    li $t0, 1
    sw $t0, coin2_collected
    jal collect_coin
    
check_coin3:
    lw $t0, coin3_collected
    bnez $t0, check_coin4
    lw $a0, coin3_x
    lw $a1, coin3_y
    jal check_single_coin
    beqz $v0, check_coin4
    li $t0, 1
    sw $t0, coin3_collected
    jal collect_coin

check_coin4:
    lw $t0, coin4_collected
    bnez $t0, check_coin5
    lw $a0, coin4_x
    lw $a1, coin4_y
    jal check_single_coin
    beqz $v0, check_coin5
    li $t0, 1
    sw $t0, coin4_collected
    jal collect_coin

check_coin5:
    lw $t0, coin5_collected
    bnez $t0, coins_done
    lw $a0, coin5_x
    lw $a1, coin5_y
    jal check_single_coin
    beqz $v0, coins_done
    li $t0, 1
    sw $t0, coin5_collected
    jal collect_coin

coins_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ==================== CHECK SINGLE COIN ====================
check_single_coin:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    move $t6, $a0
    move $t7, $a1
    
    lw $t0, mario_x
    lw $t1, mario_y
    lw $t2, MARIO_WIDTH
    lw $t3, MARIO_HEIGHT
    
    add $t4, $t0, $t2
    add $t5, $t1, $t3
    
    lw $t8, COIN_WIDTH
    lw $t9, COIN_HEIGHT
    
    add $s0, $t6, $t8
    add $s1, $t7, $t9
    
    bgt $t0, $s0, no_coin_collision
    blt $t4, $t6, no_coin_collision
    bgt $t1, $s1, no_coin_collision
    blt $t5, $t7, no_coin_collision
    
    li $v0, 1
    j end_check_coin
    
no_coin_collision:
    li $v0, 0

end_check_coin:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ==================== COLLECT COIN ====================
collect_coin:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, coins
    addi $t0, $t0, 1
    sw $t0, coins
    
    lw $t0, score
    addi $t0, $t0, 10
    sw $t0, score
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ==================== MARIO HIT ====================
mario_hit:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, mario_lives
    addi $t0, $t0, -1
    sw $t0, mario_lives
    
    blez $t0, hit_done
    
    li $t1, 5
    sw $t1, mario_x
    li $t1, 25
    sw $t1, mario_y
    sw $zero, mario_vy
    sw $zero, mario_vx
    li $t1, 1
    sw $t1, mario_on_ground
    
    li $t1, 45
    sw $t1, goomba_x
    li $t1, 1
    sw $t1, goomba_alive
    sw $t1, goomba_direction
    sw $zero, goomba_move_counter
    
    li $a0, 50
    jal delay

hit_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ==================== RENDERING ====================
render_frame:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal clear_screen
    jal draw_clouds
    jal draw_ground
    jal draw_platform
    jal draw_coins
    jal draw_mario
    jal draw_goomba
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

clear_screen:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $t0, 0x10008000
    lw $t1, COLOR_SKY
    li $t2, 2048
    
clear_loop:
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    addi $t2, $t2, -1
    bgtz $t2, clear_loop
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

draw_clouds:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    
    la $s0, clouds
    
draw_cloud_loop:
    lw $s1, 0($s0)
    beqz $s1, clouds_done
    lw $s2, 4($s0)
    lw $t0, 8($s0)
    
    move $a0, $s1
    move $a1, $s2
    move $a2, $t0
    li $a3, 2
    lw $t0, COLOR_CLOUD
    jal fill_rect
    
    addi $a0, $s1, 1
    addi $a1, $s2, -1
    lw $t1, 8($s0)
    addi $a2, $t1, -2
    li $a3, 1
    lw $t0, COLOR_CLOUD
    jal fill_rect
    
    addi $s0, $s0, 12
    j draw_cloud_loop

clouds_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra

draw_ground:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $a0, 0
    lw $a1, GROUND_Y
    li $a2, 64
    lw $a3, GROUND_HEIGHT
    lw $t0, COLOR_GROUND
    jal fill_rect
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

draw_platform:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $a0, platform_x
    lw $a1, platform_y
    lw $a2, platform_width
    lw $a3, platform_height
    lw $t0, COLOR_BRICK
    jal fill_rect
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ==================== DRAW COINS ====================
draw_coins:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, coin1_collected
    bnez $t0, draw_coin2
    lw $a0, coin1_x
    lw $a1, coin1_y
    lw $a2, COIN_WIDTH
    lw $a3, COIN_HEIGHT
    lw $t0, COLOR_COIN
    jal fill_rect
    
draw_coin2:
    lw $t0, coin2_collected
    bnez $t0, draw_coin3
    lw $a0, coin2_x
    lw $a1, coin2_y
    lw $a2, COIN_WIDTH
    lw $a3, COIN_HEIGHT
    lw $t0, COLOR_COIN
    jal fill_rect
    
draw_coin3:
    lw $t0, coin3_collected
    bnez $t0, draw_coin4
    lw $a0, coin3_x
    lw $a1, coin3_y
    lw $a2, COIN_WIDTH
    lw $a3, COIN_HEIGHT
    lw $t0, COLOR_COIN
    jal fill_rect

draw_coin4:
    lw $t0, coin4_collected
    bnez $t0, draw_coin5
    lw $a0, coin4_x
    lw $a1, coin4_y
    lw $a2, COIN_WIDTH
    lw $a3, COIN_HEIGHT
    lw $t0, COLOR_COIN
    jal fill_rect

draw_coin5:
    lw $t0, coin5_collected
    bnez $t0, coins_draw_done
    lw $a0, coin5_x
    lw $a1, coin5_y
    lw $a2, COIN_WIDTH
    lw $a3, COIN_HEIGHT
    lw $t0, COLOR_COIN
    jal fill_rect

coins_draw_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

draw_mario:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $s0, mario_x
    lw $s1, mario_y
    
    move $a0, $s0
    addi $a1, $s1, 1
    li $a2, 2
    li $a3, 2
    lw $t0, COLOR_MARIO_RED
    jal fill_rect
    
    move $a0, $s0
    move $a1, $s1
    li $a2, 2
    li $a3, 1
    lw $t0, COLOR_MARIO_SKIN
    jal fill_rect
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

draw_goomba:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, goomba_alive
    beqz $t0, goomba_draw_done
    
    lw $t1, GROUND_Y
    lw $t2, GOOMBA_HEIGHT
    sub $s1, $t1, $t2
    
    lw $s0, goomba_x
    
    move $a0, $s0
    move $a1, $s1
    li $a2, 3
    li $a3, 3
    lw $t0, COLOR_GOOMBA_BODY
    jal fill_rect
    
    move $a0, $s0
    move $a1, $s1
    li $a2, 1
    li $a3, 1
    lw $t0, COLOR_GOOMBA_EYES
    jal fill_rect
    
    addi $a0, $s0, 2
    move $a1, $s1
    li $a2, 1
    li $a3, 1
    lw $t0, COLOR_GOOMBA_EYES
    jal fill_rect

goomba_draw_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
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
    li $t0, 64
    bge $a0, $t0, pixel_skip
    li $t0, 32
    bge $a1, $t0, pixel_skip
    
    li $t0, 0x10008000
    sll $t1, $a1, 6
    add $t1, $t1, $a0
    sll $t1, $t1, 2
    add $t0, $t0, $t1
    sw $a2, 0($t0)
pixel_skip:
    jr $ra

show_start_screen:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $v0, 4
    la $a0, msg_start
    syscall
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ==================== SHOW GAME OVER SCREEN (VISUAL) ====================
show_game_over_screen:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Pintar toda la pantalla de negro
    li $t0, 0x10008000
    li $t1, 0x000000
    li $t2, 2048
    
gameover_clear:
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    addi $t2, $t2, -1
    bgtz $t2, gameover_clear
    
    # Color blanco para el texto
    li $s7, 0xFFFFFF
    
    # ===== LETRA G (posición x=10, y=12) =====
    li $a0, 10
    li $a1, 12
    li $a2, 4
    li $a3, 5
    move $t0, $s7
    jal fill_rect
    
    li $a0, 11
    li $a1, 13
    li $a2, 2
    li $a3, 3
    li $t0, 0x000000
    jal fill_rect
    
    li $a0, 12
    li $a1, 14
    li $a2, 2
    li $a3, 1
    move $t0, $s7
    jal fill_rect
    
    # ===== LETRA A (posición x=15, y=12) =====
    li $a0, 15
    li $a1, 12
    li $a2, 1
    li $a3, 5
    move $t0, $s7
    jal fill_rect
    
    li $a0, 18
    li $a1, 12
    li $a2, 1
    li $a3, 5
    move $t0, $s7
    jal fill_rect
    
    li $a0, 15
    li $a1, 12
    li $a2, 4
    li $a3, 1
    move $t0, $s7
    jal fill_rect
    
    li $a0, 15
    li $a1, 14
    li $a2, 4
    li $a3, 1
    move $t0, $s7
    jal fill_rect
    
    # ===== LETRA M (posición x=20, y=12) =====
    li $a0, 20
    li $a1, 12
    li $a2, 1
    li $a3, 5
    move $t0, $s7
    jal fill_rect
    
    li $a0, 24
    li $a1, 12
    li $a2, 1
    li $a3, 5
    move $t0, $s7
    jal fill_rect
    
    li $a0, 21
    li $a1, 13
    li $a2, 1
    li $a3, 2
    move $t0, $s7
    jal fill_rect
    
    li $a0, 23
    li $a1, 13
    li $a2, 1
    li $a3, 2
    move $t0, $s7
    jal fill_rect
    
    # ===== LETRA E (posición x=26, y=12) =====
    li $a0, 26
    li $a1, 12
    li $a2, 1
    li $a3, 5
    move $t0, $s7
    jal fill_rect
    
    li $a0, 26
    li $a1, 12
    li $a2, 4
    li $a3, 1
    move $t0, $s7
    jal fill_rect
    
    li $a0, 26
    li $a1, 14
    li $a2, 3
    li $a3, 1
    move $t0, $s7
    jal fill_rect
    
    li $a0, 26
    li $a1, 16
    li $a2, 4
    li $a3, 1
    move $t0, $s7
    jal fill_rect
    
    # ===== LETRA O (posición x=15, y=19) =====
    li $a0, 15
    li $a1, 19
    li $a2, 4
    li $a3, 5
    move $t0, $s7
    jal fill_rect
    
    li $a0, 16
    li $a1, 20
    li $a2, 2
    li $a3, 3
    li $t0, 0x000000
    jal fill_rect
    
    # ===== LETRA V (posición x=20, y=19) =====
    li $a0, 20
    li $a1, 19
    li $a2, 1
    li $a3, 3
    move $t0, $s7
    jal fill_rect
    
    li $a0, 24
    li $a1, 19
    li $a2, 1
    li $a3, 3
    move $t0, $s7
    jal fill_rect
    
    li $a0, 21
    li $a1, 22
    li $a2, 1
    li $a3, 1
    move $t0, $s7
    jal fill_rect
    
    li $a0, 23
    li $a1, 22
    li $a2, 1
    li $a3, 1
    move $t0, $s7
    jal fill_rect
    
    li $a0, 22
    li $a1, 23
    li $a2, 1
    li $a3, 1
    move $t0, $s7
    jal fill_rect
    
    # ===== LETRA E (posición x=26, y=19) =====
    li $a0, 26
    li $a1, 19
    li $a2, 1
    li $a3, 5
    move $t0, $s7
    jal fill_rect
    
    li $a0, 26
    li $a1, 19
    li $a2, 4
    li $a3, 1
    move $t0, $s7
    jal fill_rect
    
    li $a0, 26
    li $a1, 21
    li $a2, 3
    li $a3, 1
    move $t0, $s7
    jal fill_rect
    
    li $a0, 26
    li $a1, 23
    li $a2, 4
    li $a3, 1
    move $t0, $s7
    jal fill_rect
    
    # ===== LETRA R (posición x=31, y=19) =====
    li $a0, 31
    li $a1, 19
    li $a2, 1
    li $a3, 5
    move $t0, $s7
    jal fill_rect
    
    li $a0, 31
    li $a1, 19
    li $a2, 3
    li $a3, 1
    move $t0, $s7
    jal fill_rect
    
    li $a0, 31
    li $a1, 21
    li $a2, 3
    li $a3, 1
    move $t0, $s7
    jal fill_rect
    
    li $a0, 34
    li $a1, 19
    li $a2, 1
    li $a3, 3
    move $t0, $s7
    jal fill_rect
    
    li $a0, 33
    li $a1, 22
    li $a2, 1
    li $a3, 2
    move $t0, $s7
    jal fill_rect
    
    # Mostrar estadísticas en consola
    li $v0, 4
    la $a0, msg_gameover
    syscall
    
    li $v0, 4
    la $a0, msg_lives
    syscall
    li $v0, 1
    lw $a0, mario_lives
    syscall
    
    li $v0, 4
    la $a0, msg_score
    syscall
    li $v0, 1
    lw $a0, score
    syscall
    
    li $v0, 4
    la $a0, msg_coins
    syscall
    li $v0, 1
    lw $a0, coins
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

delay:
    move $t0, $a0
delay_outer:
    li $t1, 10000
delay_inner:
    addi $t1, $t1, -1
    bgtz $t1, delay_inner
    addi $t0, $t0, -1
    bgtz $t0, delay_outer
    jr $ra