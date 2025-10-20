#==============================================================================
# objects.asm - Entity Management System
#==============================================================================
# This module manages all game entities including the player, enemies (Goombas),
# and collectibles (coins). It handles entity creation, updates, rendering,
# and interactions.
#
# DEPENDENCIES: constants.asm, render.asm, physics.asm, collision.asm
# EXPORTS: All object management functions via .globl
#
# ENTITY ARRAYS:
#   - player_entity: Single Mario entity (32 bytes)
#   - goomba_array: Array of up to 10 Goombas (320 bytes)
#   - coin_array: Array of up to 20 coins (640 bytes)
#
# CALLING CONVENTIONS:
#   - Standard MIPS conventions followed
#   - Entity pointers passed in $a0
#   - Array indices in $a1 when needed
#==============================================================================

.data

#------------------------------------------------------------------------------
# Player Entity (Mario)
#------------------------------------------------------------------------------
.globl player_entity
player_entity:      .word 0:8       # 32 bytes: x, y, vx, vy, type, active, w, h

#------------------------------------------------------------------------------
# Goomba Enemy Array (10 maximum)
#------------------------------------------------------------------------------
.globl goomba_array
.globl goomba_count
goomba_array:       .word 0:80      # 10 goombas × 8 words = 80 words (320 bytes)
goomba_count:       .word 0         # Number of active goombas

# Goomba AI state (each goomba has direction: -1 left, +1 right)
goomba_directions:  .word 0:10      # Direction for each goomba

#------------------------------------------------------------------------------
# Coin Collectible Array (20 maximum)
#------------------------------------------------------------------------------
.globl coin_array
.globl coin_count
coin_array:         .word 0:160     # 20 coins × 8 words = 160 words (640 bytes)
coin_count:         .word 0         # Number of active coins

#------------------------------------------------------------------------------
# Game Statistics
#------------------------------------------------------------------------------
.globl total_coins_collected
.globl total_goombas_defeated
total_coins_collected:  .word 0
total_goombas_defeated: .word 0

.text

#==============================================================================
# INITIALIZATION FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# objects_init - Initialize the entity management system
#------------------------------------------------------------------------------
# Clears all entity arrays and resets counters.
#
# Arguments: None
# Returns: None
# Modifies: $t0-$t4
#------------------------------------------------------------------------------
.globl objects_init
objects_init:
    # Clear goomba count
    la $t0, goomba_count
    sw $zero, 0($t0)
    
    # Clear coin count
    la $t0, coin_count
    sw $zero, 0($t0)
    
    # Clear statistics
    la $t0, total_coins_collected
    sw $zero, 0($t0)
    la $t0, total_goombas_defeated
    sw $zero, 0($t0)
    
    # Deactivate all goombas
    la $t0, goomba_array
    li $t1, 10                  # Max goombas
    la $t2, ENTITY_ACTIVE_OFFSET
    lw $t2, 0($t2)
    
clear_goombas_loop:
    beqz $t1, clear_goombas_done
    add $t3, $t0, $t2           # Address of active flag
    sw $zero, 0($t3)            # Set inactive
    addi $t0, $t0, 32           # Next goomba (32 bytes)
    addi $t1, $t1, -1
    j clear_goombas_loop
clear_goombas_done:
    
    # Deactivate all coins
    la $t0, coin_array
    li $t1, 20                  # Max coins
    la $t2, ENTITY_ACTIVE_OFFSET
    lw $t2, 0($t2)
    
clear_coins_loop:
    beqz $t1, clear_coins_done
    add $t3, $t0, $t2
    sw $zero, 0($t3)
    addi $t0, $t0, 32
    addi $t1, $t1, -1
    j clear_coins_loop
clear_coins_done:
    
    jr $ra


#==============================================================================
# PLAYER CREATION AND MANAGEMENT
#==============================================================================

#------------------------------------------------------------------------------
# objects_create_player - Initialize the player entity (Mario)
#------------------------------------------------------------------------------
# Arguments:
#   $a0 = initial x position
#   $a1 = initial y position
# Returns: None
# Modifies: $t0-$t5
#------------------------------------------------------------------------------
.globl objects_create_player
objects_create_player:
    la $t0, player_entity
    
    # Set position
    sw $a0, 0($t0)              # x
    sw $a1, 4($t0)              # y
    
    # Set velocity (start stationary)
    sw $zero, 8($t0)            # vx = 0
    sw $zero, 12($t0)           # vy = 0
    
    # Set type
    la $t1, TYPE_MARIO
    lw $t1, 0($t1)
    sw $t1, 16($t0)             # type = TYPE_MARIO
    
    # Set active
    li $t1, 1
    sw $t1, 20($t0)             # active = 1
    
    # Set dimensions (8×8 sprite)
    li $t1, 8
    sw $t1, 24($t0)             # width = 8
    sw $t1, 28($t0)             # height = 8
    
    jr $ra


#------------------------------------------------------------------------------
# objects_get_player - Get pointer to player entity
#------------------------------------------------------------------------------
# Arguments: None
# Returns: $v0 = pointer to player entity
# Modifies: $v0
#------------------------------------------------------------------------------
.globl objects_get_player
objects_get_player:
    la $v0, player_entity
    jr $ra


#==============================================================================
# GOOMBA CREATION AND MANAGEMENT
#==============================================================================

#------------------------------------------------------------------------------
# objects_create_goomba - Spawn a new Goomba enemy
#------------------------------------------------------------------------------
# Arguments:
#   $a0 = x position
#   $a1 = y position
#   $a2 = initial direction (-1 left, +1 right)
# Returns:
#   $v0 = pointer to created goomba (or 0 if array full)
# Modifies: $t0-$t7, $v0
#------------------------------------------------------------------------------
.globl objects_create_goomba
objects_create_goomba:
    # Check if we can add more goombas
    la $t0, goomba_count
    lw $t1, 0($t0)              # Current count
    la $t2, MAX_GOOMBAS
    lw $t2, 0($t2)              # Max goombas (10)
    
    bge $t1, $t2, goomba_array_full
    
    # Find the goomba slot (index = current count)
    move $t3, $t1               # $t3 = index
    
    # Calculate address: goomba_array + (index * 32)
    la $t4, goomba_array
    sll $t5, $t3, 5             # index * 32 (shift left 5 = multiply by 32)
    add $t4, $t4, $t5           # $t4 = goomba address
    
    # Set position
    sw $a0, 0($t4)              # x
    sw $a1, 4($t4)              # y
    
    # Set velocity (horizontal movement only)
    la $t5, WALK_SPEED
    lw $t5, 0($t5)
    mul $t5, $t5, $a2           # velocity = speed * direction
    sw $t5, 8($t4)              # vx
    sw $zero, 12($t4)           # vy = 0 (walks on ground)
    
    # Set type
    la $t5, TYPE_GOOMBA
    lw $t5, 0($t5)
    sw $t5, 16($t4)             # type = TYPE_GOOMBA
    
    # Set active
    li $t5, 1
    sw $t5, 20($t4)             # active = 1
    
    # Set dimensions
    li $t5, 8
    sw $t5, 24($t4)             # width = 8
    sw $t5, 28($t4)             # height = 8
    
    # Store direction in separate array
    la $t5, goomba_directions
    sll $t6, $t3, 2             # index * 4 (word size)
    add $t5, $t5, $t6
    sw $a2, 0($t5)              # Store direction
    
    # Increment count
    addi $t1, $t1, 1
    sw $t1, 0($t0)
    
    # Return pointer to goomba
    move $v0, $t4
    jr $ra

goomba_array_full:
    li $v0, 0                   # Return null
    jr $ra


#------------------------------------------------------------------------------
# objects_update_goombas - Update all active Goombas
#------------------------------------------------------------------------------
# Updates position and AI for all Goombas.
#
# Arguments:
#   $a0 = ground_y position
# Returns: None
# Modifies: $t0-$t9, $s0-$s2
#------------------------------------------------------------------------------
.globl objects_update_goombas
objects_update_goombas:
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    
    move $s3, $a0               # Save ground_y
    
    la $s0, goomba_array        # $s0 = current goomba pointer
    la $s1, goomba_count
    lw $s1, 0($s1)              # $s1 = count
    li $s2, 0                   # $s2 = index
    
update_goomba_loop:
    bge $s2, $s1, update_goombas_done
    
    # Check if this goomba is active
    la $t0, ENTITY_ACTIVE_OFFSET
    lw $t0, 0($t0)
    add $t0, $s0, $t0
    lw $t1, 0($t0)
    beqz $t1, next_goomba       # Skip if inactive
    
    # Apply gravity
    move $a0, $s0
    jal physics_apply_gravity
    
    # Update position
    move $a0, $s0
    jal physics_update_position
    
    # Check ground collision
    move $a0, $s0
    move $a1, $s3
    jal physics_check_ground_collision
    
    # Check screen boundaries and reverse direction if hit
    la $t0, ENTITY_X_OFFSET
    lw $t0, 0($t0)
    add $t0, $s0, $t0
    lw $t1, 0($t0)              # x position
    
    # If x <= 0, turn right
    blez $t1, goomba_turn_right
    
    # If x >= 504 (screen_width - sprite_width), turn left
    li $t2, 504
    bge $t1, $t2, goomba_turn_left
    
    j next_goomba

goomba_turn_right:
    # Set velocity to positive (move right)
    la $t0, WALK_SPEED
    lw $t0, 0($t0)
    la $t1, ENTITY_VX_OFFSET
    lw $t1, 0($t1)
    add $t1, $s0, $t1
    sw $t0, 0($t1)
    
    # Update direction array
    la $t2, goomba_directions
    sll $t3, $s2, 2
    add $t2, $t2, $t3
    li $t4, 1
    sw $t4, 0($t2)
    j next_goomba

goomba_turn_left:
    # Set velocity to negative (move left)
    la $t0, WALK_SPEED
    lw $t0, 0($t0)
    sub $t0, $zero, $t0         # Negate
    la $t1, ENTITY_VX_OFFSET
    lw $t1, 0($t1)
    add $t1, $s0, $t1
    sw $t0, 0($t1)
    
    # Update direction array
    la $t2, goomba_directions
    sll $t3, $s2, 2
    add $t2, $t2, $t3
    li $t4, -1
    sw $t4, 0($t2)

next_goomba:
    addi $s0, $s0, 32           # Next goomba (32 bytes)
    addi $s2, $s2, 1            # Increment index
    j update_goomba_loop

update_goombas_done:
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra


#------------------------------------------------------------------------------
# objects_destroy_goomba - Deactivate a Goomba
#------------------------------------------------------------------------------
# Arguments:
#   $a0 = pointer to goomba entity
# Returns: None
# Modifies: $t0-$t1
#------------------------------------------------------------------------------
.globl objects_destroy_goomba
objects_destroy_goomba:
    # Set active flag to 0
    la $t0, ENTITY_ACTIVE_OFFSET
    lw $t0, 0($t0)
    add $t0, $a0, $t0
    sw $zero, 0($t0)
    
    # Increment defeated counter
    la $t0, total_goombas_defeated
    lw $t1, 0($t0)
    addi $t1, $t1, 1
    sw $t1, 0($t0)
    
    jr $ra


#==============================================================================
# COIN CREATION AND MANAGEMENT
#==============================================================================

#------------------------------------------------------------------------------
# objects_create_coin - Spawn a new collectible coin
#------------------------------------------------------------------------------
# Arguments:
#   $a0 = x position
#   $a1 = y position
# Returns:
#   $v0 = pointer to created coin (or 0 if array full)
# Modifies: $t0-$t7, $v0
#------------------------------------------------------------------------------
.globl objects_create_coin
objects_create_coin:
    # Check if we can add more coins
    la $t0, coin_count
    lw $t1, 0($t0)
    la $t2, MAX_COINS
    lw $t2, 0($t2)              # Max coins (20)
    
    bge $t1, $t2, coin_array_full
    
    # Calculate address
    move $t3, $t1               # index
    la $t4, coin_array
    sll $t5, $t3, 5             # index * 32
    add $t4, $t4, $t5           # coin address
    
    # Set position
    sw $a0, 0($t4)              # x
    sw $a1, 4($t4)              # y
    
    # Coins don't move
    sw $zero, 8($t4)            # vx = 0
    sw $zero, 12($t4)           # vy = 0
    
    # Set type
    la $t5, TYPE_COIN
    lw $t5, 0($t5)
    sw $t5, 16($t4)
    
    # Set active
    li $t5, 1
    sw $t5, 20($t4)
    
    # Set dimensions
    li $t5, 8
    sw $t5, 24($t4)
    sw $t5, 28($t4)
    
    # Increment count
    addi $t1, $t1, 1
    sw $t1, 0($t0)
    
    move $v0, $t4
    jr $ra

coin_array_full:
    li $v0, 0
    jr $ra


#------------------------------------------------------------------------------
# objects_collect_coin - Deactivate a coin (when collected)
#------------------------------------------------------------------------------
# Arguments:
#   $a0 = pointer to coin entity
# Returns: None
# Modifies: $t0-$t1
#------------------------------------------------------------------------------
.globl objects_collect_coin
objects_collect_coin:
    # Set active flag to 0
    la $t0, ENTITY_ACTIVE_OFFSET
    lw $t0, 0($t0)
    add $t0, $a0, $t0
    sw $zero, 0($t0)
    
    # Increment collected counter
    la $t0, total_coins_collected
    lw $t1, 0($t0)
    addi $t1, $t1, 1
    sw $t1, 0($t0)
    
    jr $ra


#==============================================================================
# RENDERING FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# objects_render_all - Render all active entities
#------------------------------------------------------------------------------
# Renders player, all goombas, and all coins.
#
# Arguments: None
# Returns: None
# Modifies: $t0-$t9, $s0-$s2, $a0-$a3
#------------------------------------------------------------------------------
.globl objects_render_all
objects_render_all:
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)
    
    # Render player
    la $a0, player_entity
    jal render_draw_entity
    
    # Render all goombas
    la $s0, goomba_array
    la $s1, goomba_count
    lw $s1, 0($s1)
    li $s2, 0

render_goombas_loop:
    bge $s2, $s1, render_goombas_done
    
    move $a0, $s0
    jal render_draw_entity
    
    addi $s0, $s0, 32
    addi $s2, $s2, 1
    j render_goombas_loop

render_goombas_done:
    
    # Render all coins
    la $s0, coin_array
    la $s1, coin_count
    lw $s1, 0($s1)
    li $s2, 0

render_coins_loop:
    bge $s2, $s1, render_coins_done
    
    move $a0, $s0
    jal render_draw_entity
    
    addi $s0, $s0, 32
    addi $s2, $s2, 1
    j render_coins_loop

render_coins_done:
    
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra


#==============================================================================
# COLLISION CHECKING FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# objects_check_player_collisions - Check player vs all entities
#------------------------------------------------------------------------------
# Checks collisions between player and all goombas/coins.
# Handles stomp attacks on goombas and coin collection.
#
# Arguments: None
# Returns:
#   $v0 = 0 (no damage), 1 (player hit by goomba)
# Modifies: $t0-$t9, $s0-$s3, $v0
#------------------------------------------------------------------------------
.globl objects_check_player_collisions
objects_check_player_collisions:
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    
    li $s3, 0                   # $s3 = damage flag (0 = safe, 1 = hit)
    
    # Get player pointer
    la $s0, player_entity
    
    #--------------------------------------------------------------------------
    # Check collisions with goombas
    #--------------------------------------------------------------------------
    la $s1, goomba_array
    la $t0, goomba_count
    lw $t0, 0($t0)
    li $s2, 0

check_goombas_loop:
    bge $s2, $t0, check_goombas_done
    
    # Check if goomba is active
    la $t1, ENTITY_ACTIVE_OFFSET
    lw $t1, 0($t1)
    add $t1, $s1, $t1
    lw $t2, 0($t1)
    beqz $t2, next_goomba_collision
    
    # Check for stomp (player jumping on goomba)
    move $a0, $s0               # player
    move $a1, $s1               # goomba
    jal collision_check_stomp
    
    bnez $v0, player_stomped_goomba
    
    # Check regular collision (player hit by goomba)
    move $a0, $s0
    move $a1, $s1
    jal collision_entities
    
    bnez $v0, player_hit_by_goomba
    
    j next_goomba_collision

player_stomped_goomba:
    # Player defeated goomba - destroy it and bounce player
    move $a0, $s1
    jal objects_destroy_goomba
    
    # Give player a small bounce
    la $t0, ENTITY_VY_OFFSET
    lw $t0, 0($t0)
    add $t0, $s0, $t0
    li $t1, -8                  # Small upward velocity
    sw $t1, 0($t0)
    
    j next_goomba_collision

player_hit_by_goomba:
    # Player was hit - set damage flag
    li $s3, 1

next_goomba_collision:
    addi $s1, $s1, 32
    addi $s2, $s2, 1
    j check_goombas_loop

check_goombas_done:
    
    #--------------------------------------------------------------------------
    # Check collisions with coins
    #--------------------------------------------------------------------------
    la $s1, coin_array
    la $t0, coin_count
    lw $t0, 0($t0)
    li $s2, 0

check_coins_loop:
    bge $s2, $t0, check_coins_done
    
    # Check if coin is active
    la $t1, ENTITY_ACTIVE_OFFSET
    lw $t1, 0($t1)
    add $t1, $s1, $t1
    lw $t2, 0($t1)
    beqz $t2, next_coin_collision
    
    # Check collision with coin
    move $a0, $s0
    move $a1, $s1
    jal collision_check_coin
    
    beqz $v0, next_coin_collision
    
    # Collect the coin
    move $a0, $s1
    jal objects_collect_coin

next_coin_collision:
    addi $s1, $s1, 32
    addi $s2, $s2, 1
    j check_coins_loop

check_coins_done:
    
    # Return damage flag
    move $v0, $s3
    
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra


#==============================================================================
# UTILITY FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# objects_count_active_coins - Count how many coins remain
#------------------------------------------------------------------------------
# Arguments: None
# Returns: $v0 = number of active coins
# Modifies: $t0-$t3, $v0
#------------------------------------------------------------------------------
.globl objects_count_active_coins
objects_count_active_coins:
    la $t0, coin_array
    la $t1, coin_count
    lw $t1, 0($t1)
    li $t2, 0                   # Active count
    li $t3, 0                   # Index
    
    la $t4, ENTITY_ACTIVE_OFFSET
    lw $t4, 0($t4)

count_coins_loop:
    bge $t3, $t1, count_coins_done
    
    add $t5, $t0, $t4
    lw $t6, 0($t5)              # Active flag
    
    beqz $t6, skip_coin_count
    addi $t2, $t2, 1            # Increment active count

skip_coin_count:
    addi $t0, $t0, 32
    addi $t3, $t3, 1
    j count_coins_loop

count_coins_done:
    move $v0, $t2
    jr $ra


#------------------------------------------------------------------------------
# objects_count_active_goombas - Count how many goombas remain
#------------------------------------------------------------------------------
# Arguments: None
# Returns: $v0 = number of active goombas
# Modifies: $t0-$t3, $v0
#------------------------------------------------------------------------------
.globl objects_count_active_goombas
objects_count_active_goombas:
    la $t0, goomba_array
    la $t1, goomba_count
    lw $t1, 0($t1)
    li $t2, 0
    li $t3, 0
    
    la $t4, ENTITY_ACTIVE_OFFSET
    lw $t4, 0($t4)

count_goombas_loop:
    bge $t3, $t1, count_goombas_done
    
    add $t5, $t0, $t4
    lw $t6, 0($t5)
    
    beqz $t6, skip_goomba_count
    addi $t2, $t2, 1

skip_goomba_count:
    addi $t0, $t0, 32
    addi $t3, $t3, 1
    j count_goombas_loop

count_goombas_done:
    move $v0, $t2
    jr $ra


#==============================================================================
# END OF OBJECTS MODULE
#==============================================================================
