# Super Mario Bros - MIPS Assembly with SCROLLING
# BITMAP DISPLAY SETUP:
#    Tools -> Bitmap Display:
#    Unit Width: 8, Unit Height: 8
#    Display Width: 512, Display Height: 256
#    Base: 0x10008000 ($gp)
# KEYBOARD MMIO:
#    Tools -> Keyboard MMIO -> Connect to MIPS

.data
    # Screen dimensions
    SCREEN_WIDTH: .word 64
    SCREEN_HEIGHT: .word 32
    WORLD_WIDTH: .word 200
    
    # Colors
    COLOR_SKY: .word 0x5C94FC
    COLOR_GROUND: .word 0x8B4513
    COLOR_BRICK: .word 0xFF8800
    COLOR_MARIO_RED: .word 0xFF0000
    COLOR_MARIO_SKIN: .word 0xFFE4B5
    COLOR_GOOMBA: .word 0x8B4513
    COLOR_CLOUD: .word 0xFFFFFF
    COLOR_COIN: .word 0xFFD700
    
    # Camera
    camera_x: .word 0
    
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
    JUMP_VELOCITY: .word -7
    BOUNCE_VELOCITY: .word -5
    MAX_FALL_SPEED: .word 5
    ACCELERATION: .word 1
    MAX_SPEED: .word 2
    FRICTION: .word 1
    
    # Platforms (x, y, width, height) - world coordinates
    platforms: .word
        18, 18, 12, 2,
        45, 20, 10, 2,
        70, 16, 14, 2,
        95, 22, 8, 2,
        120, 18, 12, 2,
        145, 15, 10, 2,
        170, 20, 12, 2,
        -1, -1, -1, -1
    
    # Goombas (x, alive, direction, patrol_left, patrol_right)
    goombas: .word
        45, 1, 1, 35, 60,
        80, 1, -1, 68, 85,
        130, 1, 1, 118, 145,
        -1, -1, -1, -1, -1
    
    goomba_move_counter: .word 0
    goomba_move_delay: .word 3
    
    GOOMBA_WIDTH: .word 3
    GOOMBA_HEIGHT: .word 3
    
    # Coins (x, y, collected) - world coordinates
    coins_data: .word
        20, 15, 0,
        25, 15, 0,
        30, 15, 0,
        50, 17, 0,
        75, 13, 0,
        100, 19, 0,
        125, 15, 0,
        150, 12, 0,
        175, 17, 0,
        190, 20, 0,
        -1, -1, -1
    
    COIN_WIDTH: .word 2
    COIN_HEIGHT: .word 2
    
    # Messages
    msg_lives: .asciiz "Lives: "
    msg_score: .asciiz " Score: "
    msg_coins: .asciiz " Coins: "
    msg_start: .asciiz "\nSUPER MARIO SCROLLING - Press SPACE to start\nCollect coins and avoid Goombas!\n"
    msg_gameover: .asciiz "\n\nGAME OVER\n"
    msg_win: .asciiz "\n\nYOU WIN! Reached the end!\n"

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

# ==================== MAIN GAME LOOP ====================
game_loop:
    lw $t0, mario_lives
    blez $t0, game_over
    
    # Check win condition (reached end of world)
    lw $t0, mario_x
    li $t1, 195
    bge $t0, $t1, game_win
    
    jal process_input
    jal update_mario_physics
    jal update_camera
    jal update_goombas
    jal check_goomba_collisions
    jal check_coin_collisions
    jal render_frame
    
    li $a0, 10
    jal delay
    
    j game_loop

game_win:
    jal show_win_screen
    j wait_for_restart

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
    sw $zero, camera_x
    sw $zero, goomba_move_counter
    
    # Reset goombas
    la $t0, goombas
reset_goombas_loop:
    lw $t1, 0($t0)
    li $t2, -1
    beq $t1, $t2, reset_coins_start
    li $t3, 1
    sw $t3, 4($t0)
    addi $t0, $t0, 20
    j reset_goombas_loop
    
reset_coins_start:
    # Reset coins
    la $t0, coins_data
reset_coins_loop:
    lw $t1, 0($t0)
    li $t2, -1
    beq $t1, $t2, reset_done
    sw $zero, 8($t0)
    addi $t0, $t0, 12
    j reset_coins_loop
    
reset_done:
    j main

exit_program:
    li $v0, 10
    syscall

# ==================== CAMERA UPDATE ====================
update_camera:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, mario_x
    lw $t1, camera_x
    
    # Camera follows Mario when he's past x=40 on screen
    sub $t2, $t0, $t1
    li $t3, 40
    ble $t2, $t3, camera_bounds_check
    
    # Move camera to keep Mario at x=40 on screen
    sub $t1, $t0, $t3
    
camera_bounds_check:
    # Don't let camera go below 0
    bltz $t1, camera_clamp_left
    
    # Don't let camera show past world end
    lw $t4, WORLD_WIDTH
    li $t5, 64
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
    lw $t2, WORLD_WIDTH
    addi $t2, $t2, -2
    bge $t1, $t2, clamp_x_right
    sw $t1, mario_x
    j check_platforms
    
clamp_x_left:
    sw $zero, mario_x
    sw $zero, mario_vx
    j check_platforms
    
clamp_x_right:
    sw $t2, mario_x
    sw $zero, mario_vx

check_platforms:
    move $a0, $s0
    jal check_platform_collisions
    
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

# ==================== PLATFORM COLLISIONS ====================
check_platform_collisions:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    
    move $s4, $a0
    la $s0, platforms
    
platform_loop:
    lw $s1, 0($s0)
    li $t0, -1
    beq $s1, $t0, platform_check_done
    
    lw $s2, 4($s0)
    lw $s3, 8($s0)
    
    lw $t0, mario_x
    lw $t1, MARIO_WIDTH
    add $t2, $t0, $t1
    
    add $t3, $s1, $s3
    
    bge $t0, $t3, next_platform
    ble $t2, $s1, next_platform
    
    lw $t0, mario_vy
    bgtz $t0, check_platform_landing
    bltz $t0, check_platform_bottom
    j next_platform

check_platform_landing:
    lw $t1, mario_y
    lw $t2, MARIO_HEIGHT
    add $t1, $t1, $t2
    
    add $t3, $s4, $t2
    
    blt $t1, $s2, next_platform
    bgt $t3, $s2, next_platform
    
    sub $t4, $t1, $s2
    li $t5, 5
    bgt $t4, $t5, next_platform
    
    sub $t1, $s2, $t2
    sw $t1, mario_y
    sw $zero, mario_vy
    li $t6, 1
    sw $t6, mario_on_ground
    j platform_check_done

check_platform_bottom:
    lw $t4, 12($s0)
    add $t1, $s2, $t4
    
    lw $t2, mario_y
    bgt $t2, $t1, next_platform
    blt $s4, $t1, next_platform
    
    sub $t3, $t1, $t2
    li $t5, 5
    bgt $t3, $t5, next_platform
    
    sw $t1, mario_y
    sw $zero, mario_vy
    sw $zero, mario_on_ground
    j platform_check_done

next_platform:
    addi $s0, $s0, 16
    j platform_loop

platform_check_done:
    lw $t0, mario_y
    lw $t1, MARIO_HEIGHT
    add $t0, $t0, $t1
    lw $t2, GROUND_Y
    blt $t0, $t2, set_in_air
    j platforms_done

set_in_air:
    sw $zero, mario_on_ground

platforms_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    addi $sp, $sp, 24
    jr $ra

# ==================== GOOMBA UPDATE ====================
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
    
    bgtz $t2, move_goomba_right
    
move_goomba_left:
    addi $t0, $t0, -1
    ble $t0, $t3, reverse_goomba_right
    j save_goomba_pos

move_goomba_right:
    addi $t0, $t0, 1
    bge $t0, $t4, reverse_goomba_left
    j save_goomba_pos

reverse_goomba_left:
    li $t2, -1
    sw $t2, 8($s0)
    j save_goomba_pos

reverse_goomba_right:
    li $t2, 1
    sw $t2, 8($s0)

save_goomba_pos:
    sw $t0, 0($s0)

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

# ==================== GOOMBA COLLISIONS ====================
check_goomba_collisions:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    la $s0, goombas
    
check_goomba_loop:
    lw $s1, 0($s0)
    li $t0, -1
    beq $s1, $t0, goombas_collision_done
    
    lw $t0, 4($s0)
    beqz $t0, next_goomba_check
    
    lw $t1, mario_x
    lw $t2, MARIO_WIDTH
    add $t3, $t1, $t2
    
    lw $t4, GOOMBA_WIDTH
    add $t5, $s1, $t4
    
    bge $t1, $t5, next_goomba_check
    ble $t3, $s1, next_goomba_check
    
    lw $t1, mario_y
    lw $t2, MARIO_HEIGHT
    add $t3, $t1, $t2
    
    lw $t4, GROUND_Y
    lw $t5, GOOMBA_HEIGHT
    sub $t6, $t4, $t5
    
    addi $t7, $t6, -2
    bge $t1, $t4, next_goomba_check
    ble $t3, $t7, next_goomba_check
    
    bge $t1, $t6, mario_dies_goomba
    
    sw $zero, 4($s0)
    lw $t0, score
    addi $t0, $t0, 100
    sw $t0, score
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

# ==================== COIN COLLISIONS ====================
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
    sw $zero, camera_x
    
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
    jal draw_ground
    jal draw_platforms
    jal draw_coins
    jal draw_mario
    jal draw_goombas
    
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
    li $t1, 64
    bge $a0, $t1, skip_platform
    
    lw $a1, 4($s0)
    lw $a2, 8($s0)
    lw $a3, 12($s0)
    lw $t0, COLOR_BRICK
    jal fill_rect

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

draw_coins:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    
    la $s0, coins_data
    
draw_coin_loop:
    lw $t0, 0($s0)
    li $t1, -1
    beq $t0, $t1, coins_draw_done
    
    lw $t1, 8($s0)
    bnez $t1, skip_coin
    
    lw $t1, camera_x
    sub $a0, $t0, $t1
    
    li $t2, -3
    blt $a0, $t2, skip_coin
    li $t2, 64
    bge $a0, $t2, skip_coin
    
    lw $a1, 4($s0)
    lw $a2, COIN_WIDTH
    lw $a3, COIN_HEIGHT
    lw $t0, COLOR_COIN
    jal fill_rect

skip_coin:
    addi $s0, $s0, 12
    j draw_coin_loop

coins_draw_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

draw_mario:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, mario_x
    lw $t1, camera_x
    sub $s0, $t0, $t1
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

draw_goombas:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    
    la $s0, goombas
    
draw_goomba_loop:
    lw $t0, 0($s0)
    li $t1, -1
    beq $t0, $t1, goombas_draw_done
    
    lw $t1, 4($s0)
    beqz $t1, skip_goomba
    
    lw $t1, camera_x
    sub $a0, $t0, $t1
    
    li $t2, -4
    blt $a0, $t2, skip_goomba
    li $t2, 64
    bge $a0, $t2, skip_goomba
    
    lw $t3, GROUND_Y
    lw $t4, GOOMBA_HEIGHT
    sub $a1, $t3, $t4
    
    li $a2, 3
    li $a3, 3
    lw $t0, COLOR_GOOMBA
    jal fill_rect
    
    lw $t0, 0($s0)
    lw $t1, camera_x
    sub $t2, $t0, $t1
    move $a0, $t2
    lw $t3, GROUND_Y
    lw $t4, GOOMBA_HEIGHT
    sub $a1, $t3, $t4
    li $a2, 1
    li $a3, 1
    li $t0, 0x000000
    jal fill_rect
    
    lw $t0, 0($s0)
    lw $t1, camera_x
    sub $t2, $t0, $t1
    addi $a0, $t2, 2
    lw $t3, GROUND_Y
    lw $t4, GOOMBA_HEIGHT
    sub $a1, $t3, $t4
    li $a2, 1
    li $a3, 1
    li $t0, 0x000000
    jal fill_rect

skip_goomba:
    addi $s0, $s0, 20
    j draw_goomba_loop

goombas_draw_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
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

show_win_screen:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal clear_screen
    
    li $v0, 4
    la $a0, msg_win
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

show_game_over_screen:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal clear_screen
    
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