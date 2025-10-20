.include "constants.asm"
.include "render.asm"
.include "input.asm"
.include "physics.asm"
.include "collision.asm"
.include "objects.asm"
.include "level.asm"

#==============================================================================
# main.asm - Complete Mario Platformer Game
#==============================================================================
# MARIO PLATFORMER - A complete 2D platformer game written in MIPS Assembly
# for the MARS 4.5 simulator.
#
# FEATURES:
#   ? Side-scrolling 2048-pixel wide level
#   ? Camera follows player
#   ? 12 platforms at various heights
#   ? 8 Goomba enemies with patrol AI
#   ? 14 collectible coins
#   ? Score tracking and lives system
#   ? Win condition (collect all coins)
#   ? Lose condition (lose all lives)
#   ? Invincibility frames after damage
#   ? Smooth 30 FPS gameplay
#
# DEPENDENCIES: ALL previous modules (constants, render, input, physics,
#               collision, objects, level)
#
# CONTROLS:
#   A or Left  = Move left
#   D or Right = Move right
#   W or Space = Jump
#   ESC        = Return to menu / Quit
#   R          = Restart (after game over/win)
#
# AUTHOR: Created for MARS 4.5 MIPS Simulator
# VERSION: 1.0 - Complete Release
#==============================================================================

.data

#------------------------------------------------------------------------------
# Game State Machine
#------------------------------------------------------------------------------
# States: 0=menu, 1=playing, 2=paused, 3=game_over, 4=win
game_state:         .word 0

#------------------------------------------------------------------------------
# Player Statistics
#------------------------------------------------------------------------------
player_lives:       .word 3
player_score:       .word 0
player_start_x:     .word 100
player_start_y:     .word 100

#------------------------------------------------------------------------------
# Game Flags
#------------------------------------------------------------------------------
is_on_ground:       .word 0
is_on_platform:     .word 0
invincibility_timer: .word 0        # Frames of invincibility after hit
frame_counter:      .word 0

#------------------------------------------------------------------------------
# UI Messages
#------------------------------------------------------------------------------
.align 2
msg_title1:     .asciiz "\n??????????????????????????????????????????????\n"
msg_title2:     .asciiz "?                                            ?\n"
msg_title3:     .asciiz "?       MARIO PLATFORMER IN MIPS ASSEMBLY    ?\n"
msg_title4:     .asciiz "?                                            ?\n"
msg_title5:     .asciiz "?           Press SPACE to Start!            ?\n"
msg_title6:     .asciiz "?                                            ?\n"
msg_border:     .asciiz "??????????????????????????????????????????????\n\n"

msg_controls:   .asciiz "CONTROLS:\n"
msg_ctrl1:      .asciiz "  A/D     = Move Left/Right\n"
msg_ctrl2:      .asciiz "  W/Space = Jump\n"
msg_ctrl3:      .asciiz "  ESC     = Pause/Menu\n\n"

msg_objective:  .asciiz "OBJECTIVE:\n"
msg_obj1:       .asciiz "  • Collect all coins to win!\n"
msg_obj2:       .asciiz "  • Jump on Goombas to defeat them\n"
msg_obj3:       .asciiz "  • Don't touch Goombas from the side!\n"
msg_obj4:       .asciiz "  • You have 3 lives\n\n"

msg_ready:      .asciiz "Good luck!\n\n"

# In-game HUD messages
msg_score:      .asciiz "Score: "
msg_lives:      .asciiz " | Lives: "
msg_coins:      .asciiz " | Coins: "
msg_slash:      .asciiz "/"

# Game over messages
msg_game_over1: .asciiz "\n??????????????????????????????????????????????\n"
msg_game_over2: .asciiz "?              GAME OVER!                    ?\n"
msg_game_over3: .asciiz "??????????????????????????????????????????????\n"

msg_you_win1:   .asciiz "\n??????????????????????????????????????????????\n"
msg_you_win2:   .asciiz "?           ? YOU WIN! ?                   ?\n"
msg_you_win3:   .asciiz "??????????????????????????????????????????????\n"

msg_final_score: .asciiz "\nFinal Score: "
msg_coins_collected: .asciiz "Coins Collected: "
msg_goombas_defeated: .asciiz "Goombas Defeated: "
msg_restart_prompt: .asciiz "\nPress R to play again or ESC to quit\n"

msg_loading:    .asciiz "Loading level...\n"
msg_newline:    .asciiz "\n"

.text
.globl main

#==============================================================================
# MAIN ENTRY POINT
#==============================================================================
main:
    # Initialize stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Initialize all game systems
    jal render_init
    jal input_init
    jal physics_init
    jal objects_init
    jal level_init
    
    # Show title screen
    jal show_title_screen
    
#==============================================================================
# MAIN GAME STATE MACHINE
#==============================================================================
game_state_machine:
    la $t0, game_state
    lw $t1, 0($t0)
    
    # Branch based on state
    
    
    beqz $t1, state_menu        # 0 = menu
    li $t2, 1
    beq $t1, $t2, state_playing # 1 = playing
    li $t2, 3
    beq $t1, $t2, state_game_over # 3 = game over
    li $t2, 4
    beq $t1, $t2, state_win     # 4 = win
    
    # Default: go to menu
    j state_menu

#==============================================================================
# STATE: MENU
#==============================================================================
state_menu:
    jal input_poll
    
    # Wait for space to start
    jal input_is_jump_pressed
    bnez $v0, start_new_game
    
    # Check for ESC to quit
    jal input_is_escape_pressed
    bnez $v0, exit_game
    
    # Small delay
    li $v0, 32
    li $a0, 50
    syscall
    
    j game_state_machine

start_new_game:
    jal initialize_new_game
    
    # DEBUG: Check if player exists
    jal objects_get_player
    move $t9, $v0
    la $t0, ENTITY_ACTIVE_OFFSET
    lw $t0, 0($t0)
    add $t0, $t9, $t0
    lw $t1, 0($t0)
    beqz $t1, exit_game         # If player not active, quit
    
    # Set state to playing
    la $t0, game_state
    li $t1, 1
    sw $t1, 0($t0)
    
    j game_state_machine
#==============================================================================
# STATE: PLAYING (Main Game Loop)
#==============================================================================
state_playing:
    # Increment frame counter
    la $t0, frame_counter
    lw $t1, 0($t0)
    addi $t1, $t1, 1
    sw $t1, 0($t0)
    
    #--------------------------------------------------------------------------
    # INPUT PHASE
    #--------------------------------------------------------------------------
    jal input_poll
    
    # Check for ESC (back to menu)
    jal input_is_escape_pressed
    bnez $v0, return_to_menu
    
    # Get player pointer
    jal objects_get_player
    move $s7, $v0               # $s7 = player pointer
    
    # Horizontal movement
    jal input_get_horizontal_axis
    beqz $v0, no_horizontal_movement
    
    bltz $v0, move_left_key
    
    move $a0, $s7
    jal physics_move_right
    j check_jump_key

move_left_key:
    move $a0, $s7
    jal physics_move_left
    j check_jump_key

no_horizontal_movement:
    move $a0, $s7
    jal physics_apply_friction

check_jump_key:
    # Jump if on ground or platform
    jal input_is_jump_pressed
    beqz $v0, no_jump_key
    
    la $t0, is_on_ground
    lw $t1, 0($t0)
    la $t0, is_on_platform
    lw $t2, 0($t0)
    or $t3, $t1, $t2
    beqz $t3, no_jump_key
    
    move $a0, $s7
    jal physics_jump
    jal input_consume_jump

no_jump_key:
    
    #--------------------------------------------------------------------------
    # UPDATE PHASE
    #--------------------------------------------------------------------------
    
    # Update player physics
    move $a0, $s7
    jal physics_apply_gravity
    
    move $a0, $s7
    jal physics_update_position
    
    move $a0, $s7
    jal physics_check_screen_bounds
    
    # Update camera based on player position
    # Get player world X (screen X + camera X)
    la $t0, ENTITY_X_OFFSET
    lw $t0, 0($t0)
    add $t0, $s7, $t0
    lw $t1, 0($t0)              # Player screen X
    
    jal level_get_camera_x
    add $a0, $t1, $v0           # Player world X = screen X + camera X
    jal level_update_camera
    
    # Update Goombas (world coordinates)
    jal level_get_ground_y
    move $a0, $v0
    jal objects_update_goombas
    
    # Check ground collision
    la $t0, is_on_ground
    sw $zero, 0($t0)
    la $t0, is_on_platform
    sw $zero, 0($t0)
    
    move $a0, $s7
    jal level_get_ground_y
    move $a1, $v0
    jal physics_check_ground_collision
    
    la $t0, is_on_ground
    sw $v0, 0($t0)
    
    # Check platform collisions (level handles this with camera)
    move $a0, $s7
    jal level_check_platform_collision
    
    beqz $v0, no_platform_landing
    
    # Land on platform
    move $a0, $s7
    move $a1, $v1               # Platform Y
    jal collision_land_on_platform
    
    la $t0, is_on_platform
    li $t1, 1
    sw $t1, 0($t0)

no_platform_landing:
    
    # Update invincibility timer
    la $t0, invincibility_timer
    lw $t1, 0($t0)
    beqz $t1, no_invincibility_update
    addi $t1, $t1, -1
    sw $t1, 0($t0)
no_invincibility_update:
    
    # Check entity collisions
    jal objects_check_player_collisions
    beqz $v0, no_damage
    
    # Player was hit - check invincibility
    la $t0, invincibility_timer
    lw $t1, 0($t0)
    bnez $t1, no_damage         # Still invincible
    
    # Take damage
    la $t0, player_lives
    lw $t1, 0($t0)
    addi $t1, $t1, -1
    sw $t1, 0($t0)
    
    # Set invincibility (60 frames = 2 seconds)
    la $t0, invincibility_timer
    li $t1, 60
    sw $t1, 0($t0)
    
    # Check if dead
    la $t0, player_lives
    lw $t1, 0($t0)
    blez $t1, player_died_state

no_damage:
    
    # Update score
    la $t0, total_coins_collected
    lw $t1, 0($t0)
    la $t0, POINTS_PER_COIN
    lw $t0, 0($t0)
    mul $t2, $t1, $t0
    
    la $t0, total_goombas_defeated
    lw $t1, 0($t0)
    la $t0, POINTS_PER_GOOMBA
    lw $t0, 0($t0)
    mul $t3, $t1, $t0
    
    add $t4, $t2, $t3
    la $t0, player_score
    sw $t4, 0($t0)
    
    # Check win condition (all coins collected)
    jal objects_count_active_coins
    beqz $v0, player_won_state
    
    # Check alternate win condition (reached goal)
    la $t0, ENTITY_X_OFFSET
    lw $t0, 0($t0)
    add $t0, $s7, $t0
    lw $t1, 0($t0)              # Player screen X
    
    jal level_get_camera_x
    add $a0, $t1, $v0           # Player world X
    jal level_is_at_goal
    bnez $v0, player_won_state
    
    #--------------------------------------------------------------------------
    # RENDER PHASE
    #--------------------------------------------------------------------------
    
    # Clear screen
    la $t0, COLOR_SKY_BLUE
    lw $a0, 0($t0)
    jal render_clear_screen
    
    # Draw ground
    li $a0, 0
    jal level_get_ground_y
    move $a1, $v0
    li $a2, 512
    li $a3, 62
    la $t0, COLOR_GROUND_BROWN
    lw $t0, 0($t0)
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    jal render_draw_rect
    addi $sp, $sp, 4
    
    # Draw ground line
    li $a0, 0
    jal level_get_ground_y
    move $a1, $v0
    addi $a1, $a1, -1
    li $a2, 512
    la $t0, COLOR_WHITE
    lw $a3, 0($t0)
    jal render_draw_line_horizontal
    
    # Draw platforms (level handles camera offset)
    jal level_draw_platforms
    
    # Draw entities (objects module handles this)
    jal objects_render_all
    
    # Draw UI
    jal draw_hud
    
    #--------------------------------------------------------------------------
    # CONSOLE OUTPUT (every 60 frames)
    #--------------------------------------------------------------------------
    la $t0, frame_counter
    lw $t1, 0($t0)
    li $t2, 60
    div $t1, $t2
    mfhi $t3
    bnez $t3, skip_status_print
    
    jal print_game_status

skip_status_print:
    
    #--------------------------------------------------------------------------
    # FRAME DELAY
    #--------------------------------------------------------------------------
    li $v0, 32
    la $t0, FRAME_DELAY_MS
    lw $a0, 0($t0)
    syscall
    
    j game_state_machine

player_died_state:
    la $t0, game_state
    li $t1, 3                   # State = game over
    sw $t1, 0($t0)
    jal print_game_over
    j game_state_machine

player_won_state:
    la $t0, game_state
    li $t1, 4                   # State = win
    sw $t1, 0($t0)
    jal print_you_win
    j game_state_machine

return_to_menu:
    la $t0, game_state
    sw $zero, 0($t0)
    jal show_title_screen
    j game_state_machine

#==============================================================================
# STATE: GAME OVER
#==============================================================================
state_game_over:
    jal input_poll
    
    # Check for R to restart
    jal input_is_restart_pressed
    bnez $v0, restart_game
    
    # Check for ESC to quit
    jal input_is_escape_pressed
    bnez $v0, return_to_menu
    
    li $v0, 32
    li $a0, 50
    syscall
    
    j game_state_machine

#==============================================================================
# STATE: WIN
#==============================================================================
state_win:
    jal input_poll
    
    # Check for R to restart
    jal input_is_restart_pressed
    bnez $v0, restart_game
    
    # Check for ESC to menu
    jal input_is_escape_pressed
    bnez $v0, return_to_menu
    
    li $v0, 32
    li $a0, 50
    syscall
    
    j game_state_machine

restart_game:
    jal initialize_new_game
    la $t0, game_state
    li $t1, 1
    sw $t1, 0($t0)
    j game_state_machine

#==============================================================================
# INITIALIZATION FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# initialize_new_game - Set up a new game
#------------------------------------------------------------------------------
initialize_new_game:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Reset systems
    jal objects_init
    jal level_init
    
    # Reset game state
    la $t0, player_lives
    li $t1, 3
    sw $t1, 0($t0)
    
    la $t0, player_score
    sw $zero, 0($t0)
    
    la $t0, invincibility_timer
    sw $zero, 0($t0)
    
    la $t0, frame_counter
    sw $zero, 0($t0)
    
    # Create player
    la $t0, player_start_x
    lw $a0, 0($t0)
    la $t0, player_start_y
    lw $a1, 0($t0)
    jal objects_create_player
    
    # Spawn all entities from level data
    li $v0, 4
    la $a0, msg_loading
    syscall
    
    jal level_spawn_all_entities
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

#==============================================================================
# UI FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# show_title_screen - Display title and controls
#------------------------------------------------------------------------------
show_title_screen:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $v0, 4
    la $a0, msg_title1
    syscall
    la $a0, msg_title2
    syscall
    la $a0, msg_title3
    syscall
    la $a0, msg_title4
    syscall
    la $a0, msg_title5
    syscall
    la $a0, msg_title6
    syscall
    la $a0, msg_border
    syscall
    
    la $a0, msg_controls
    syscall
    la $a0, msg_ctrl1
    syscall
    la $a0, msg_ctrl2
    syscall
    la $a0, msg_ctrl3
    syscall
    
    la $a0, msg_objective
    syscall
    la $a0, msg_obj1
    syscall
    la $a0, msg_obj2
    syscall
    la $a0, msg_obj3
    syscall
    la $a0, msg_obj4
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

#------------------------------------------------------------------------------
# draw_hud - Draw in-game HUD (lives, score, etc.)
#------------------------------------------------------------------------------
draw_hud:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Draw lives (hearts)
    la $t0, player_lives
    lw $t1, 0($t0)
    li $t2, 0
    li $t3, 10

draw_hearts_loop:
    bge $t2, $t1, hearts_done
    
    move $a0, $t3
    li $a1, 10
    li $a2, 10
    li $a3, 10
    la $t0, COLOR_MARIO_RED
    lw $t0, 0($t0)
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    jal render_draw_rect
    addi $sp, $sp, 4
    
    addi $t3, $t3, 15
    addi $t2, $t2, 1
    j draw_hearts_loop

hearts_done:
    
    # Draw invincibility indicator (flashing yellow)
    la $t0, invincibility_timer
    lw $t1, 0($t0)
    beqz $t1, no_invincibility_indicator
    
    andi $t2, $t1, 0x8
    beqz $t2, no_invincibility_indicator
    
    li $a0, 70
    li $a1, 10
    li $a2, 25
    li $a3, 10
    la $t0, COLOR_COIN_YELLOW
    lw $t0, 0($t0)
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    jal render_draw_rect
    addi $sp, $sp, 4

no_invincibility_indicator:
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

#------------------------------------------------------------------------------
# print_game_status - Print status to console
#------------------------------------------------------------------------------
print_game_status:
    li $v0, 4
    la $a0, msg_score
    syscall
    
    la $t0, player_score
    lw $a0, 0($t0)
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, msg_lives
    syscall
    
    la $t0, player_lives
    lw $a0, 0($t0)
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, msg_coins
    syscall
    
    jal objects_count_active_coins
    move $a0, $v0
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, msg_newline
    syscall
    
    jr $ra

#------------------------------------------------------------------------------
# print_game_over - Display game over message
#------------------------------------------------------------------------------
print_game_over:
    li $v0, 4
    la $a0, msg_game_over1
    syscall
    la $a0, msg_game_over2
    syscall
    la $a0, msg_game_over3
    syscall
    
    jal print_final_stats
    jr $ra

#------------------------------------------------------------------------------
# print_you_win - Display victory message
#------------------------------------------------------------------------------
print_you_win:
    li $v0, 4
    la $a0, msg_you_win1
    syscall
    la $a0, msg_you_win2
    syscall
    la $a0, msg_you_win3
    syscall
    
    jal print_final_stats
    jr $ra

#------------------------------------------------------------------------------
# print_final_stats - Display final score and stats
#------------------------------------------------------------------------------
print_final_stats:
    li $v0, 4
    la $a0, msg_final_score
    syscall
    
    la $t0, player_score
    lw $a0, 0($t0)
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, msg_newline
    syscall
    
    la $a0, msg_coins_collected
    syscall
    
    la $t0, total_coins_collected
    lw $a0, 0($t0)
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, msg_newline
    syscall
    
    la $a0, msg_goombas_defeated
    syscall
    
    la $t0, total_goombas_defeated
    lw $a0, 0($t0)
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, msg_newline
    syscall
    la $a0, msg_restart_prompt
    syscall
    
    jr $ra

#==============================================================================
# EXIT GAME
#==============================================================================
exit_game:
    li $v0, 4
    la $a0, msg_newline
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    li $v0, 10
    syscall

#==============================================================================
# END OF MAIN PROGRAM
#==============================================================================
