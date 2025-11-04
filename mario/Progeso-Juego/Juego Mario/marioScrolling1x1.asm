# Super Mario Bros - MIPS Assembly with SCROLLING (1x1)
# BITMAP DISPLAY SETUP:
#    Tools -> Bitmap Display:
#    Unit Width: 1, Unit Height: 1
#    Display Width: 512, Display Height: 256
#    Base: address of framebuffer (see Data Segment for exact value)
# KEYBOARD MMIO:
#    Tools -> Keyboard MMIO -> Connect to MIPS

.data
    .align 2
framebuffer: .space 524288      # 512*256 pixels * 4 bytes

    # Screen dimensions for 1x1 units
    SCREEN_WIDTH: .word 512
    SCREEN_HEIGHT: .word 256
    WORLD_WIDTH: .word 2400
   
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
    mario_x: .word 40
    mario_y: .word 200
    mario_vy: .word 0
    mario_vx: .word 0
    mario_on_ground: .word 1
    mario_lives: .word 3
    score: .word 0
    coins: .word 0
   
    # Mario dimensions (SCALED for 1x1)
    MARIO_WIDTH: .word 16
    MARIO_HEIGHT: .word 24
   
    # Ground level (SCALED for 1x1)
    GROUND_Y: .word 224
    GROUND_HEIGHT: .word 32
   
    # Physics
    GRAVITY: .word 4
    JUMP_VELOCITY: .word -28
    BOUNCE_VELOCITY: .word -20
    MAX_FALL_SPEED: .word 20
    ACCELERATION: .word 4
    MAX_SPEED: .word 8
    FRICTION: .word 4
   
    # Platforms (x, y, width, height) - SCALED for 1x1
    platforms: .word
        144, 160, 80, 16,      # Platform 1
        360, 144, 48, 16,      # Platform 2
        680, 160, 96, 16,     # Platform 3
        800, 128, 56, 16,     # Platform 4
        1080, 152, 64, 16,     # Platform 5
        1240, 120, 80, 16,     # Platform 6
        1600, 160, 48, 16,     # Platform 7
        1760, 136, 72, 16,     # Platform 8
        -1, -1, -1, -1
   
    # Ground segments (x_start, x_end) - SCALED for 1x1
    ground_segments: .word
        0, 520,              # Start area
        640, 960,            # After first gap
        1040, 1440,            # Mid section
        1560, 1960,            # Late section
        2064, 2400,            # Castle island
        -1, -1
   
    # Pipes (x, y, width, height) - SCALED for 1x1
    pipes: .word
        480, 184, 32, 40,       # Pipe 1
        1400, 184, 32, 40,       # Pipe 2
        1920, 184, 32, 40,       # Pipe 3
        -1, -1, -1, -1
   
    # Goombas (x, alive, direction, patrol_left, patrol_right) - SCALED for 1x1
    goombas: .word
        280, 1, 1, 200, 440,       # Goomba 1
        704, 1, -1, 656, 880,    # Goomba 2
        760, 1, 1, 656, 880,     # Goomba 3
        1160, 1, 1, 1056, 1360,     # Goomba 4
        1680, 1, -1, 1576, 1880,    # Goomba 5
        1744, 1, 1, 1576, 1880,     # Goomba 6
        2120, 1, 1, 2080, 2200,     # Goomba 7
        -1, -1, -1, -1, -1
   
    goomba_move_counter: .word 0
    goomba_move_delay: .word 3
   
    GOOMBA_WIDTH: .word 24
    GOOMBA_HEIGHT: .word 24
   
    # Coins (x, y, collected) - SCALED for 1x1
    coins_data: .word
        160, 136, 0,
        184, 136, 0,
        208, 136, 0,
        240, 200, 0,
        320, 200, 0,
        376, 120, 0,
        680, 200, 0,
        720, 200, 0,
        760, 200, 0,
        800, 200, 0,
        696, 136, 0,
        736, 136, 0,
        816, 104, 0,
        848, 104, 0,
        1120, 200, 0,
        1160, 200, 0,
        1096, 128, 0,
        1256, 96, 0,
        1280, 96, 0,
        1304, 96, 0,
        1640, 200, 0,
        1720, 200, 0,
        1616, 136, 0,
        1776, 112, 0,
        1808, 112, 0,
        2096, 200, 0,
        2144, 200, 0,
        2192, 200, 0,
        -1, -1, -1
   
    COIN_WIDTH: .word 16
    COIN_HEIGHT: .word 16
   
    # Pipe dimensions
    PIPE_WIDTH: .word 32
    PIPE_HEIGHT: .word 40
   
    # Castle position - SCALED for 1x1
    CASTLE_X: .word 2256
    CASTLE_Y: .word 144
    CASTLE_WIDTH: .word 96
    CASTLE_HEIGHT: .word 80
   
    FLAG_X: .word 2224
    FLAG_POLE_HEIGHT: .word 120
   
    # Messages
    msg_start: .asciiz "\nSUPER MARIO SCROLLING (1x1) - Press SPACE to start\nCollect coins and avoid Goombas!\nReach the castle to win!\n"

.text
.globl main

main:
    jal init_game_state
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

game_loop:
    lw $t0, mario_lives
    blez $t0, game_over
   
    lw $t0, mario_x
    lw $t1, CASTLE_X
    bge $t0, $t1, game_win
   
    jal process_input
    jal update_mario_physics
    jal update_camera
    jal update_goombas
    jal check_goomba_collisions
    jal check_coin_collisions
    jal check_pit_death
    jal render_frame
   
    li $a0, 10
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
    jal init_game_state
    j main

init_game_state:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    li $t0, 40
    sw $t0, mario_x
    li $t0, 200
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
   
    la $t0, goombas
init_goombas_loop:
    lw $t1, 0($t0)
    li $t2, -1
    beq $t1, $t2, init_coins_start
    li $t3, 1
    sw $t3, 4($t0)
    addi $t0, $t0, 20
    j init_goombas_loop
   
init_coins_start:
    la $t0, coins_data
init_coins_loop:
    lw $t1, 0($t0)
    li $t2, -1
    beq $t1, $t2, init_done
    sw $zero, 8($t0)
    addi $t0, $t0, 12
    j init_coins_loop
   
init_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

exit_program:
    li $v0, 10
    syscall

check_pit_death:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    lw $t0, mario_y
    li $t1, 256
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
    li $t3, 320
    ble $t2, $t3, camera_bounds_check
   
    sub $t1, $t0, $t3
   
camera_bounds_check:
    bltz $t1, camera_clamp_left
   
    lw $t4, WORLD_WIDTH
    li $t5, 512
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
    addi $t2, $t2, -16
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
   
    move $t3, $a0
    la $s0, ground_segments
   
check_segment_loop:
    lw $s1, 0($s0)
    li $t0, -1
    beq $s1, $t0, no_ground_found
   
    lw $t1, 4($s0)
   
    blt $t3, $s1, next_segment
    bge $t3, $t1, next_segment
   
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
    add $t0, $t0, $t1
   
    sub $t1, $t0, $s2
    li $t2, 48
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
    li $t5, 40
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
    li $t5, 40
    bgt $t3, $t5, next_platform
   
    sw $t1, mario_y
    sw $zero, mario_vy
    sw $zero, mario_on_ground
    j platform_check_done

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
   
    add $t7, $t6, $t5
    bge $t1, $t7, next_goomba_check
    ble $t3, $t6, next_goomba_check
   
    lw $t0, mario_vy
    blez $t0, mario_dies_goomba
   
    sub $t1, $t3, $t6
    li $t2, 80
    blt $t1, $t2, kill_goomba_stomp
   
    j mario_dies_goomba

kill_goomba_stomp:
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

mario_hit:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    lw $t0, mario_lives
    addi $t0, $t0, -1
    sw $t0, mario_lives
   
    blez $t0, hit_done
   
    li $t1, 40
    sw $t1, mario_x
    li $t1, 200
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

render_frame:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    jal clear_screen
    jal draw_ground
    jal draw_platforms
    jal draw_pipes
    jal draw_castle
    jal draw_flag
    jal draw_coins
    jal draw_mario
    jal draw_goombas
   
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

clear_screen:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    la $t0, framebuffer
    lw $t1, COLOR_SKY
    li $t2, 131072
   
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
    lw $s1, 0($s0)
    li $t0, -1
    beq $s1, $t0, ground_done
   
    lw $s2, 4($s0)
   
    lw $t0, camera_x
    sub $a0, $s1, $t0
   
    sub $t1, $s2, $s1
    move $a2, $t1
   
    li $t2, -200
    blt $a0, $t2, skip_ground_segment
    li $t2, 512
    bge $a0, $t2, skip_ground_segment
   
    lw $a1, GROUND_Y
    lw $a3, GROUND_HEIGHT
    lw $t0, COLOR_GROUND
    jal fill_rect

skip_ground_segment:
    addi $s0, $s0, 8
    j draw_ground_loop

ground_done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
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
   
    li $t1, -32
    blt $a0, $t1, skip_platform
    li $t1, 512
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
   
    li $t1, -80
    blt $a0, $t1, skip_pipe
    li $t1, 512
    bge $a0, $t1, skip_pipe
   
    lw $a1, 4($s0)
    lw $a2, 8($s0)
    lw $a3, 12($s0)
    lw $t0, COLOR_PIPE
    jal fill_rect
   
    lw $t0, camera_x
    sub $a0, $s1, $t0
    addi $a0, $a0, -8
    lw $a1, 4($s0)
    addi $a1, $a1, -8
    lw $t1, 8($s0)
    addi $a2, $t1, 16
    li $a3, 16
    lw $t0, COLOR_PIPE_DARK
    jal fill_rect
   
    lw $t0, camera_x
    sub $a0, $s1, $t0
    lw $a1, 4($s0)
    li $a2, 8
    lw $a3, 12($s0)
    lw $t0, COLOR_PIPE_DARK
    jal fill_rect

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

draw_castle:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    lw $t0, CASTLE_X
    lw $t1, camera_x
    sub $a0, $t0, $t1
   
    li $t2, -160
    blt $a0, $t2, castle_done
    li $t2, 512
    bge $a0, $t2, castle_done
   
    lw $a1, CASTLE_Y
    lw $a2, CASTLE_WIDTH
    lw $a3, CASTLE_HEIGHT
    lw $t0, COLOR_CASTLE
    jal fill_rect
   
    lw $t0, CASTLE_X
    lw $t1, camera_x
    sub $a0, $t0, $t1
    lw $a1, CASTLE_Y
    addi $a1, $a1, -24
    li $a2, 24
    li $a3, 104
    lw $t0, COLOR_CASTLE_DARK
    jal fill_rect
   
    lw $t0, CASTLE_X
    lw $t1, camera_x
    sub $a0, $t0, $t1
    addi $a0, $a0, 72
    lw $a1, CASTLE_Y
    addi $a1, $a1, -24
    li $a2, 24
    li $a3, 104
    lw $t0, COLOR_CASTLE_DARK
    jal fill_rect
   
    lw $t0, CASTLE_X
    lw $t1, camera_x
    sub $a0, $t0, $t1
    addi $a0, $a0, 32
    lw $a1, CASTLE_Y
    addi $a1, $a1, 40
    li $a2, 32
    li $a3, 40
    li $t0, 0x000000
    jal fill_rect
   
    lw $t0, CASTLE_X
    lw $t1, camera_x
    sub $a0, $t0, $t1
    addi $a0, $a0, 8
    lw $a1, CASTLE_Y
    addi $a1, $a1, -8
    li $a2, 8
    li $a3, 8
    li $t0, 0xFFFF00
    jal fill_rect
   
    lw $t0, CASTLE_X
    lw $t1, camera_x
    sub $a0, $t0, $t1
    addi $a0, $a0, 80
    lw $a1, CASTLE_Y
    addi $a1, $a1, -8
    li $a2, 8
    li $a3, 8
    li $t0, 0xFFFF00
    jal fill_rect

castle_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

draw_flag:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    lw $t0, FLAG_X
    lw $t1, camera_x
    sub $a0, $t0, $t1
   
    li $t2, -40
    blt $a0, $t2, flag_done
    li $t2, 512
    bge $a0, $t2, flag_done
   
    lw $t3, GROUND_Y
    lw $t4, FLAG_POLE_HEIGHT
    sub $a1, $t3, $t4
    li $a2, 8
    move $a3, $t4
    lw $t0, COLOR_FLAG_POLE
    jal fill_rect
   
    lw $t0, FLAG_X
    lw $t1, camera_x
    sub $a0, $t0, $t1
    addi $a0, $a0, 8
    lw $t3, GROUND_Y
    lw $t4, FLAG_POLE_HEIGHT
    sub $a1, $t3, $t4
    addi $a1, $a1, 16
    li $a2, 32
    li $a3, 24
    lw $t0, COLOR_FLAG
    jal fill_rect

flag_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
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
   
    li $t2, -24
    blt $a0, $t2, skip_coin
    li $t2, 512
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
    addi $a1, $s1, 8
    li $a2, 16
    li $a3, 16
    lw $t0, COLOR_MARIO_RED
    jal fill_rect
   
    move $a0, $s0
    move $a1, $s1
    li $a2, 16
    li $a3, 8
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
   
    li $t2, -32
    blt $a0, $t2, skip_goomba
    li $t2, 512
    bge $a0, $t2, skip_goomba
   
    lw $t3, GROUND_Y
    lw $t4, GOOMBA_HEIGHT
    sub $a1, $t3, $t4
   
    li $a2, 24
    li $a3, 24
    lw $t0, COLOR_GOOMBA
    jal fill_rect
   
    lw $t0, 0($s0)
    lw $t1, camera_x
    sub $t2, $t0, $t1
    move $a0, $t2
    lw $t3, GROUND_Y
    lw $t4, GOOMBA_HEIGHT
    sub $a1, $t3, $t4
    li $a2, 8
    li $a3, 8
    li $t0, 0x000000
    jal fill_rect
   
    lw $t0, 0($s0)
    lw $t1, camera_x
    sub $t2, $t0, $t1
    addi $a0, $t2, 16
    lw $t3, GROUND_Y
    lw $t4, GOOMBA_HEIGHT
    sub $a1, $t3, $t4
    li $a2, 8
    li $a3, 8
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
    li $t0, 512
    bge $a0, $t0, pixel_skip
    li $t0, 256
    bge $a1, $t0, pixel_skip
   
    la $t0, framebuffer
    sll $t1, $a1, 9
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

show_win_screen_visual:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    la $t0, framebuffer
    lw $t1, COLOR_SKY
    li $t2, 131072
   
win_clear:
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    addi $t2, $t2, -1
    bgtz $t2, win_clear
   
    li $s7, 0xFFD700
   
    # Letter Y
    li $a0, 80
    li $a1, 64
    li $a2, 8
    li $a3, 40
    move $t0, $s7
    jal fill_rect
   
    li $a0, 112
    li $a1, 64
    li $a2, 8
    li $a3, 40
    move $t0, $s7
    jal fill_rect
   
    li $a0, 88
    li $a1, 80
    li $a2, 8
    li $a3, 16
    move $t0, $s7
    jal fill_rect
   
    li $a0, 104
    li $a1, 80
    li $a2, 8
    li $a3, 16
    move $t0, $s7
    jal fill_rect
   
    li $a0, 96
    li $a1, 88
    li $a2, 8
    li $a3, 16
    move $t0, $s7
    jal fill_rect
   
    # Letter O
    li $a0, 128
    li $a1, 64
    li $a2, 32
    li $a3, 40
    move $t0, $s7
    jal fill_rect
   
    li $a0, 136
    li $a1, 72
    li $a2, 16
    li $a3, 24
    lw $t0, COLOR_SKY
    jal fill_rect
   
    # Letter U
    li $a0, 168
    li $a1, 64
    li $a2, 8
    li $a3, 40
    move $t0, $s7
    jal fill_rect
   
    li $a0, 192
    li $a1, 64
    li $a2, 8
    li $a3, 40
    move $t0, $s7
    jal fill_rect
   
    li $a0, 168
    li $a1, 96
    li $a2, 32
    li $a3, 8
    move $t0, $s7
    jal fill_rect
   
    # Letter W
    li $a0, 80
    li $a1, 120
    li $a2, 8
    li $a3, 40
    move $t0, $s7
    jal fill_rect
   
    li $a0, 112
    li $a1, 120
    li $a2, 8
    li $a3, 40
    move $t0, $s7
    jal fill_rect
   
    li $a0, 88
    li $a1, 144
    li $a2, 8
    li $a3, 16
    move $t0, $s7
    jal fill_rect
   
    li $a0, 104
    li $a1, 144
    li $a2, 8
    li $a3, 16
    move $t0, $s7
    jal fill_rect
   
    li $a0, 96
    li $a1, 152
    li $a2, 8
    li $a3, 8
    move $t0, $s7
    jal fill_rect
   
    # Letter I
    li $a0, 144
    li $a1, 120
    li $a2, 8
    li $a3, 40
    move $t0, $s7
    jal fill_rect
   
    # Letter N
    li $a0, 160
    li $a1, 120
    li $a2, 8
    li $a3, 40
    move $t0, $s7
    jal fill_rect
   
    li $a0, 192
    li $a1, 120
    li $a2, 8
    li $a3, 40
    move $t0, $s7
    jal fill_rect
   
    li $a0, 168
    li $a1, 128
    li $a2, 8
    li $a3, 8
    move $t0, $s7
    jal fill_rect
   
    li $a0, 176
    li $a1, 136
    li $a2, 8
    li $a3, 8
    move $t0, $s7
    jal fill_rect
   
    li $a0, 184
    li $a1, 144
    li $a2, 8
    li $a3, 8
    move $t0, $s7
    jal fill_rect
   
    # Mario sprite
    li $a0, 224
    li $a1, 160
    li $a2, 16
    li $a3, 16
    lw $t0, COLOR_MARIO_RED
    jal fill_rect
   
    li $a0, 224
    li $a1, 152
    li $a2, 16
    li $a3, 8
    lw $t0, COLOR_MARIO_SKIN
    jal fill_rect
   
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

show_game_over_screen_visual:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    la $t0, framebuffer
    li $t1, 0x000000
    li $t2, 131072
   
gameover_clear:
    sw $t1, 0($t0)
    addi $t0, $t0, 4
    addi $t2, $t2, -1
    bgtz $t2, gameover_clear
   
    li $s7, 0xFF0000
   
    # Letter G
    li $a0, 80
    li $a1, 96
    li $a2, 32
    li $a3, 40
    move $t0, $s7
    jal fill_rect
   
    li $a0, 88
    li $a1, 104
    li $a2, 16
    li $a3, 24
    li $t0, 0x000000
    jal fill_rect
   
    li $a0, 96
    li $a1, 112
    li $a2, 16
    li $a3, 8
    move $t0, $s7
    jal fill_rect
   
    # Letter A
    li $a0, 120
    li $a1, 96
    li $a2, 8
    li $a3, 40
    move $t0, $s7
    jal fill_rect
   
    li $a0, 144
    li $a1, 96
    li $a2, 8
    li $a3, 40
    move $t0, $s7
    jal fill_rect
   
    li $a0, 120
    li $a1, 96
    li $a2, 32
    li $a3, 8
    move $t0, $s7
    jal fill_rect
   
    li $a0, 120
    li $a1, 112
    li $a2, 32
    li $a3, 8
    move $t0, $s7
    jal fill_rect
   
    # Letter M
    li $a0, 160
    li $a1, 96
    li $a2, 8
    li $a3, 40
    move $t0, $s7
    jal fill_rect
   
    li $a0, 192
    li $a1, 96
    li $a2, 8
    li $a3, 40
    move $t0, $s7
    jal fill_rect
   
    li $a0, 168
    li $a1, 104
    li $a2, 8
    li $a3, 16
    move $t0, $s7
    jal fill_rect
   
    li $a0, 184
    li $a1, 104
    li $a2, 8
    li $a3, 16
    move $t0, $s7
    jal fill_rect
   
    # Letter E
    li $a0, 208
    li $a1, 96
    li $a2, 8
    li $a3, 40
    move $t0, $s7
    jal fill_rect
   
    li $a0, 208
    li $a1, 96
    li $a2, 32
    li $a3, 8
    move $t0, $s7
    jal fill_rect
   
    li $a0, 208
    li $a1, 112
    li $a2, 24
    li $a3, 8
    move $t0, $s7
    jal fill_rect
   
    li $a0, 208
    li $a1, 128
    li $a2, 32
    li $a3, 8
    move $t0, $s7
    jal fill_rect
   
    # Letter O
    li $a0, 120
    li $a1, 152
    li $a2, 32
    li $a3, 40
    move $t0, $s7
    jal fill_rect
   
    li $a0, 128
    li $a1, 160
    li $a2, 16
    li $a3, 24
    li $t0, 0x000000
    jal fill_rect
   
    # Letter V
    li $a0, 160
    li $a1, 152
    li $a2, 8
    li $a3, 24
    move $t0, $s7
    jal fill_rect
   
    li $a0, 192
    li $a1, 152
    li $a2, 8
    li $a3, 24
    move $t0, $s7
    jal fill_rect
   
    li $a0, 168
    li $a1, 176
    li $a2, 8
    li $a3, 8
    move $t0, $s7
    jal fill_rect
   
    li $a0, 184
    li $a1, 176
    li $a2, 8
    li $a3, 8
    move $t0, $s7
    jal fill_rect
   
    li $a0, 176
    li $a1, 184
    li $a2, 8
    li $a3, 8
    move $t0, $s7
    jal fill_rect
   
    # Letter E
    li $a0, 208
    li $a1, 152
    li $a2, 8
    li $a3, 40
    move $t0, $s7
    jal fill_rect
   
    li $a0, 208
    li $a1, 152
    li $a2, 32
    li $a3, 8
    move $t0, $s7
    jal fill_rect
   
    li $a0, 208
    li $a1, 168
    li $a2, 24
    li $a3, 8
    move $t0, $s7
    jal fill_rect
   
    li $a0, 208
    li $a1, 184
    li $a2, 32
    li $a3, 8
    move $t0, $s7
    jal fill_rect
   
    # Letter R
    li $a0, 248
    li $a1, 152
    li $a2, 8
    li $a3, 40
    move $t0, $s7
    jal fill_rect
   
    li $a0, 248
    li $a1, 152
    li $a2, 24
    li $a3, 8
    move $t0, $s7
    jal fill_rect
   
    li $a0, 248
    li $a1, 168
    li $a2, 24
    li $a3, 8
    move $t0, $s7
    jal fill_rect
   
    li $a0, 272
    li $a1, 152
    li $a2, 8
    li $a3, 24
    move $t0, $s7
    jal fill_rect
   
    li $a0, 264
    li $a1, 176
    li $a2, 8
    li $a3, 16
    move $t0, $s7
    jal fill_rect
   
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