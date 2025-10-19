#==============================================================================
# collision.asm - Advanced Collision Detection System
#==============================================================================
# This module provides comprehensive collision detection and resolution for
# the Mario platformer game. It handles entity-entity and entity-platform
# collisions with proper axis-separated resolution.
#
# DEPENDENCIES: constants.asm, physics.asm
# EXPORTS: All collision functions via .globl
#
# COLLISION MODEL:
#   - AABB (Axis-Aligned Bounding Box) collision detection
#   - Separate X and Y axis collision resolution
#   - Platform detection with "top surface" semantics
#   - Entity interaction (player vs enemy, player vs coin)
#
# CALLING CONVENTIONS:
#   - Standard MIPS conventions followed
#   - Entity pointers passed in $a0, $a1, etc.
#   - Return collision result in $v0
#==============================================================================

.data

#------------------------------------------------------------------------------
# Collision tolerance constants
#------------------------------------------------------------------------------
COLLISION_EPSILON:      .word 1     # Minimum overlap to count as collision
PLATFORM_TOLERANCE:     .word 4     # Pixels above platform to snap down

.text

#==============================================================================
# BASIC COLLISION DETECTION FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# collision_aabb - Axis-Aligned Bounding Box collision test
#------------------------------------------------------------------------------
# Tests if two rectangles overlap using AABB collision detection.
# Returns true if rectangles intersect.
#
# Arguments:
#   $a0 = rect1_x (left edge)
#   $a1 = rect1_y (top edge)
#   $a2 = rect1_width
#   $a3 = rect1_height
#   Stack: rect2_x, rect2_y, rect2_width, rect2_height
# Returns:
#   $v0 = 1 if collision, 0 if no collision
# Modifies: $t0-$t9, $v0
#------------------------------------------------------------------------------
.globl collision_aabb
collision_aabb:
    # Load rect2 parameters from stack
    lw $t0, 0($sp)              # rect2_x
    lw $t1, 4($sp)              # rect2_y
    lw $t2, 8($sp)              # rect2_width
    lw $t3, 12($sp)             # rect2_height
    
    # Calculate rect1 bounds
    # rect1_right = rect1_x + rect1_width
    add $t4, $a0, $a2           # $t4 = rect1_right
    # rect1_bottom = rect1_y + rect1_height
    add $t5, $a1, $a3           # $t5 = rect1_bottom
    
    # Calculate rect2 bounds
    # rect2_right = rect2_x + rect2_width
    add $t6, $t0, $t2           # $t6 = rect2_right
    # rect2_bottom = rect2_y + rect2_height
    add $t7, $t1, $t3           # $t7 = rect2_bottom
    
    # AABB collision test:
    # Collision if:
    #   rect1_x < rect2_right AND
    #   rect1_right > rect2_x AND
    #   rect1_y < rect2_bottom AND
    #   rect1_bottom > rect2_y
    
    # Test: rect1_x < rect2_right
    bge $a0, $t6, no_collision
    
    # Test: rect1_right > rect2_x
    ble $t4, $t0, no_collision
    
    # Test: rect1_y < rect2_bottom
    bge $a1, $t7, no_collision
    
    # Test: rect1_bottom > rect2_y
    ble $t5, $t1, no_collision
    
    # All tests passed - collision detected
    li $v0, 1
    jr $ra

no_collision:
    li $v0, 0
    jr $ra


#------------------------------------------------------------------------------
# collision_entities - Check collision between two entities
#------------------------------------------------------------------------------
# Tests if two entities are colliding based on their bounding boxes.
#
# Arguments:
#   $a0 = entity1 address
#   $a1 = entity2 address
# Returns:
#   $v0 = 1 if collision, 0 if no collision
# Modifies: $t0-$t9, $s0-$s2, $v0
#------------------------------------------------------------------------------
.globl collision_entities
collision_entities:
    addi $sp, $sp, -28
    sw $ra, 24($sp)
    sw $s0, 20($sp)
    sw $s1, 16($sp)
    sw $s2, 12($sp)
    
    move $s0, $a0               # $s0 = entity1
    move $s1, $a1               # $s1 = entity2
    
    # Check if both entities are active
    la $t0, ENTITY_ACTIVE_OFFSET
    lw $t0, 0($t0)
    add $t1, $s0, $t0
    lw $t1, 0($t1)              # entity1 active?
    beqz $t1, entities_no_collision
    
    add $t1, $s1, $t0
    lw $t1, 0($t1)              # entity2 active?
    beqz $t1, entities_no_collision
    
    # Load entity1 bounds
    la $t0, ENTITY_X_OFFSET
    lw $t0, 0($t0)
    add $t0, $s0, $t0
    lw $t1, 0($t0)              # entity1_x
    
    la $t0, ENTITY_Y_OFFSET
    lw $t0, 0($t0)
    add $t0, $s0, $t0
    lw $t2, 0($t0)              # entity1_y
    
    la $t0, ENTITY_WIDTH_OFFSET
    lw $t0, 0($t0)
    add $t0, $s0, $t0
    lw $t3, 0($t0)              # entity1_width
    
    la $t0, ENTITY_HEIGHT_OFFSET
    lw $t0, 0($t0)
    add $t0, $s0, $t0
    lw $t4, 0($t0)              # entity1_height
    
    # Load entity2 bounds
    la $t0, ENTITY_X_OFFSET
    lw $t0, 0($t0)
    add $t0, $s1, $t0
    lw $t5, 0($t0)              # entity2_x
    
    la $t0, ENTITY_Y_OFFSET
    lw $t0, 0($t0)
    add $t0, $s1, $t0
    lw $t6, 0($t0)              # entity2_y
    
    la $t0, ENTITY_WIDTH_OFFSET
    lw $t0, 0($t0)
    add $t0, $s1, $t0
    lw $t7, 0($t0)              # entity2_width
    
    la $t0, ENTITY_HEIGHT_OFFSET
    lw $t0, 0($t0)
    add $t0, $s1, $t0
    lw $t8, 0($t0)              # entity2_height
    
    # Call AABB collision with parameters
    move $a0, $t1               # entity1_x
    move $a1, $t2               # entity1_y
    move $a2, $t3               # entity1_width
    move $a3, $t4               # entity1_height
    
    # Push entity2 bounds to stack
    addi $sp, $sp, -16
    sw $t5, 0($sp)              # entity2_x
    sw $t6, 4($sp)              # entity2_y
    sw $t7, 8($sp)              # entity2_width
    sw $t8, 12($sp)             # entity2_height
    
    jal collision_aabb
    
    addi $sp, $sp, 16           # Clean up stack
    # $v0 now contains collision result
    
    lw $s2, 12($sp)
    lw $s1, 16($sp)
    lw $s0, 20($sp)
    lw $ra, 24($sp)
    addi $sp, $sp, 28
    jr $ra

entities_no_collision:
    li $v0, 0
    lw $s2, 12($sp)
    lw $s1, 16($sp)
    lw $s0, 20($sp)
    lw $ra, 24($sp)
    addi $sp, $sp, 28
    jr $ra


#==============================================================================
# PLATFORM COLLISION FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# collision_check_platform - Check if entity is on top of a platform
#------------------------------------------------------------------------------
# Checks if an entity's bottom edge is touching the top of a platform.
# This uses special "top surface" collision semantics for platforms.
#
# Arguments:
#   $a0 = entity address
#   $a1 = platform_x
#   $a2 = platform_y (top edge)
#   $a3 = platform_width
#   Stack: platform_height
# Returns:
#   $v0 = 1 if on platform, 0 if not
#   $v1 = platform_y (top surface) if collision
# Modifies: $t0-$t9, $v0, $v1
#------------------------------------------------------------------------------
.globl collision_check_platform
collision_check_platform:
    # Load platform height from stack
    lw $t0, 0($sp)              # platform_height
    
    # Load entity position and dimensions
    la $t1, ENTITY_X_OFFSET
    lw $t1, 0($t1)
    add $t1, $a0, $t1
    lw $t2, 0($t1)              # entity_x
    
    la $t1, ENTITY_Y_OFFSET
    lw $t1, 0($t1)
    add $t1, $a0, $t1
    lw $t3, 0($t1)              # entity_y
    
    la $t1, ENTITY_WIDTH_OFFSET
    lw $t1, 0($t1)
    add $t1, $a0, $t1
    lw $t4, 0($t1)              # entity_width
    
    la $t1, ENTITY_HEIGHT_OFFSET
    lw $t1, 0($t1)
    add $t1, $a0, $t1
    lw $t5, 0($t1)              # entity_height
    
    # Calculate entity bottom edge
    add $t6, $t3, $t5           # entity_bottom = entity_y + height
    
    # Calculate platform bounds
    add $t7, $a1, $a3           # platform_right = platform_x + width
    add $t8, $a2, $t0           # platform_bottom = platform_y + height
    
    # Check horizontal overlap (entity must be above platform horizontally)
    # entity_x < platform_right AND entity_right > platform_x
    add $t9, $t2, $t4           # entity_right = entity_x + width
    
    bge $t2, $t7, not_on_platform   # entity_x >= platform_right
    ble $t9, $a1, not_on_platform   # entity_right <= platform_x
    
    # Check if entity bottom is near platform top
    # We allow a tolerance for "stepping down" onto platforms
    la $t0, PLATFORM_TOLERANCE
    lw $t0, 0($t0)
    sub $t1, $t6, $a2           # distance = entity_bottom - platform_top
    
    # Entity is on platform if distance is small and positive
    bltz $t1, not_on_platform   # entity is above platform
    bgt $t1, $t0, not_on_platform # entity is too far below
    
    # Check if entity is falling (vy >= 0) - can't land on platform while rising
    la $t0, ENTITY_VY_OFFSET
    lw $t0, 0($t0)
    add $t0, $a0, $t0
    lw $t0, 0($t0)              # vy
    bltz $t0, not_on_platform   # Moving up, not landing
    
    # Entity is on platform!
    li $v0, 1
    move $v1, $a2               # Return platform top Y
    jr $ra

not_on_platform:
    li $v0, 0
    li $v1, 0
    jr $ra


#------------------------------------------------------------------------------
# collision_land_on_platform - Make entity land on platform
#------------------------------------------------------------------------------
# Snaps entity to platform top and stops downward velocity.
#
# Arguments:
#   $a0 = entity address
#   $a1 = platform_y (top surface)
# Returns: None
# Modifies: $t0-$t3
#------------------------------------------------------------------------------
.globl collision_land_on_platform
collision_land_on_platform:
    # Calculate correct Y position (platform_y - entity_height)
    la $t0, ENTITY_HEIGHT_OFFSET
    lw $t0, 0($t0)
    add $t0, $a0, $t0
    lw $t1, 0($t0)              # entity_height
    
    sub $t2, $a1, $t1           # correct_y = platform_y - height
    
    # Set entity Y position
    la $t0, ENTITY_Y_OFFSET
    lw $t0, 0($t0)
    add $t0, $a0, $t0
    sw $t2, 0($t0)
    
    # Stop downward velocity
    la $t0, ENTITY_VY_OFFSET
    lw $t0, 0($t0)
    add $t0, $a0, $t0
    sw $zero, 0($t0)            # vy = 0
    
    jr $ra


#==============================================================================
# COLLISION RESOLUTION FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# collision_resolve_x - Resolve horizontal collision
#------------------------------------------------------------------------------
# Pushes entity out of collision in X direction and stops horizontal velocity.
#
# Arguments:
#   $a0 = entity address (the one being pushed)
#   $a1 = obstacle entity address (or platform)
# Returns: None
# Modifies: $t0-$t9
#------------------------------------------------------------------------------
.globl collision_resolve_x
collision_resolve_x:
    # Load entity positions
    la $t0, ENTITY_X_OFFSET
    lw $t0, 0($t0)
    add $t1, $a0, $t0
    lw $t2, 0($t1)              # entity_x
    
    add $t3, $a1, $t0
    lw $t4, 0($t3)              # obstacle_x
    
    # Load widths
    la $t0, ENTITY_WIDTH_OFFSET
    lw $t0, 0($t0)
    add $t5, $a0, $t0
    lw $t5, 0($t5)              # entity_width
    
    add $t6, $a1, $t0
    lw $t6, 0($t6)              # obstacle_width
    
    # Determine which side entity hit obstacle
    # If entity center < obstacle center, push left
    add $t7, $t2, $t5
    srl $t7, $t7, 1             # entity_center_x = (x + width) / 2
    
    add $t8, $t4, $t6
    srl $t8, $t8, 1             # obstacle_center_x
    
    blt $t7, $t8, resolve_push_left

resolve_push_right:
    # Push entity to right of obstacle
    add $t9, $t4, $t6           # new_x = obstacle_x + obstacle_width
    sw $t9, 0($t1)
    j resolve_x_stop_velocity

resolve_push_left:
    # Push entity to left of obstacle
    sub $t9, $t4, $t5           # new_x = obstacle_x - entity_width
    sw $t9, 0($t1)

resolve_x_stop_velocity:
    # Stop horizontal velocity
    la $t0, ENTITY_VX_OFFSET
    lw $t0, 0($t0)
    add $t0, $a0, $t0
    sw $zero, 0($t0)
    
    jr $ra


#------------------------------------------------------------------------------
# collision_resolve_y - Resolve vertical collision
#------------------------------------------------------------------------------
# Pushes entity out of collision in Y direction and stops vertical velocity.
#
# Arguments:
#   $a0 = entity address
#   $a1 = obstacle entity address
# Returns:
#   $v0 = 1 if resolved from above (landed), 0 if from below (hit head)
# Modifies: $t0-$t9, $v0
#------------------------------------------------------------------------------
.globl collision_resolve_y
collision_resolve_y:
    # Load entity positions
    la $t0, ENTITY_Y_OFFSET
    lw $t0, 0($t0)
    add $t1, $a0, $t0
    lw $t2, 0($t1)              # entity_y
    
    add $t3, $a1, $t0
    lw $t4, 0($t3)              # obstacle_y
    
    # Load heights
    la $t0, ENTITY_HEIGHT_OFFSET
    lw $t0, 0($t0)
    add $t5, $a0, $t0
    lw $t5, 0($t5)              # entity_height
    
    add $t6, $a1, $t0
    lw $t6, 0($t6)              # obstacle_height
    
    # Determine which side entity hit obstacle
    # If entity center < obstacle center, push up
    add $t7, $t2, $t5
    srl $t7, $t7, 1             # entity_center_y
    
    add $t8, $t4, $t6
    srl $t8, $t8, 1             # obstacle_center_y
    
    blt $t7, $t8, resolve_push_up

resolve_push_down:
    # Entity hit from below - push down
    add $t9, $t4, $t6           # new_y = obstacle_y + obstacle_height
    sw $t9, 0($t1)
    li $v0, 0                   # Return 0 (hit from below)
    j resolve_y_stop_velocity

resolve_push_up:
    # Entity hit from above - push up (landing)
    sub $t9, $t4, $t5           # new_y = obstacle_y - entity_height
    sw $t9, 0($t1)
    li $v0, 1                   # Return 1 (landed)

resolve_y_stop_velocity:
    # Stop vertical velocity
    la $t0, ENTITY_VY_OFFSET
    lw $t0, 0($t0)
    add $t0, $a0, $t0
    sw $zero, 0($t0)
    
    jr $ra


#==============================================================================
# ENTITY INTERACTION FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# collision_check_stomp - Check if entity1 stomped on entity2
#------------------------------------------------------------------------------
# Special check for Mario jumping on top of enemy (Goomba).
# Returns true only if entity1 is falling and hits entity2 from above.
#
# Arguments:
#   $a0 = entity1 address (e.g., Mario)
#   $a1 = entity2 address (e.g., Goomba)
# Returns:
#   $v0 = 1 if stomp occurred, 0 if not
# Modifies: $t0-$t8, $s0-$s1, $v0
#------------------------------------------------------------------------------
.globl collision_check_stomp
collision_check_stomp:
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    
    move $s0, $a0
    move $s1, $a1
    
    # First check if entities are colliding at all
    move $a0, $s0
    move $a1, $s1
    jal collision_entities
    beqz $v0, no_stomp          # No collision, no stomp
    
    # Check if entity1 is falling (vy > 0)
    la $t0, ENTITY_VY_OFFSET
    lw $t0, 0($t0)
    add $t0, $s0, $t0
    lw $t1, 0($t0)              # entity1_vy
    blez $t1, no_stomp          # Not falling, can't stomp
    
    # Check if entity1 bottom is near entity2 top
    la $t0, ENTITY_Y_OFFSET
    lw $t0, 0($t0)
    add $t2, $s0, $t0
    lw $t3, 0($t2)              # entity1_y
    
    la $t0, ENTITY_HEIGHT_OFFSET
    lw $t0, 0($t0)
    add $t4, $s0, $t0
    lw $t4, 0($t4)              # entity1_height
    
    add $t5, $t3, $t4           # entity1_bottom = y + height
    
    # Get entity2 top
    la $t0, ENTITY_Y_OFFSET
    lw $t0, 0($t0)
    add $t6, $s1, $t0
    lw $t7, 0($t6)              # entity2_y (top)
    
    # Check if entity1 bottom is above entity2 center
    la $t0, ENTITY_HEIGHT_OFFSET
    lw $t0, 0($t0)
    add $t0, $s1, $t0
    lw $t0, 0($t0)              # entity2_height
    srl $t8, $t0, 1             # half_height
    add $t8, $t7, $t8           # entity2_center_y
    
    bge $t5, $t8, no_stomp      # entity1 bottom >= entity2 center, not a stomp
    
    # Valid stomp!
    li $v0, 1
    j stomp_done

no_stomp:
    li $v0, 0

stomp_done:
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra


#------------------------------------------------------------------------------
# collision_check_coin - Check if entity collected a coin
#------------------------------------------------------------------------------
# Checks collision from any direction (not just top).
#
# Arguments:
#   $a0 = entity address (e.g., Mario)
#   $a1 = coin address
# Returns:
#   $v0 = 1 if collected, 0 if not
# Modifies: $t0-$t9, $s0-$s1, $v0
#------------------------------------------------------------------------------
.globl collision_check_coin
collision_check_coin:
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    
    move $s0, $a0
    move $s1, $a1
    
    # Check if coin is active
    la $t0, ENTITY_ACTIVE_OFFSET
    lw $t0, 0($t0)
    add $t0, $s1, $t0
    lw $t1, 0($t0)
    beqz $t1, no_coin_collision
    
    # Check standard AABB collision
    move $a0, $s0
    move $a1, $s1
    jal collision_entities
    # $v0 contains result
    
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra

no_coin_collision:
    li $v0, 0
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra


#==============================================================================
# UTILITY FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# collision_get_overlap - Calculate overlap distance between two entities
#------------------------------------------------------------------------------
# Returns the amount of overlap in both X and Y directions.
#
# Arguments:
#   $a0 = entity1 address
#   $a1 = entity2 address
# Returns:
#   $v0 = overlap_x (negative if separated)
#   $v1 = overlap_y (negative if separated)
# Modifies: $t0-$t9, $v0, $v1
#------------------------------------------------------------------------------
.globl collision_get_overlap
collision_get_overlap:
    # Load entity1 bounds
    la $t0, ENTITY_X_OFFSET
    lw $t0, 0($t0)
    add $t0, $a0, $t0
    lw $t1, 0($t0)              # e1_x
    
    la $t0, ENTITY_WIDTH_OFFSET
    lw $t0, 0($t0)
    add $t0, $a0, $t0
    lw $t2, 0($t0)              # e1_width
    
    add $t3, $t1, $t2           # e1_right = e1_x + e1_width
    
    # Load entity2 bounds
    la $t0, ENTITY_X_OFFSET
    lw $t0, 0($t0)
    add $t0, $a1, $t0
    lw $t4, 0($t0)              # e2_x
    
    la $t0, ENTITY_WIDTH_OFFSET
    lw $t0, 0($t0)
    add $t0, $a1, $t0
    lw $t5, 0($t0)              # e2_width
    
    add $t6, $t4, $t5           # e2_right = e2_x + e2_width
    
    # Calculate X overlap
    # overlap_x = min(e1_right, e2_right) - max(e1_x, e2_x)
    blt $t3, $t6, x_min_is_e1_right
    move $t7, $t6               # min = e2_right
    j x_min_done
x_min_is_e1_right:
    move $t7, $t3               # min = e1_right
x_min_done:
    
    bgt $t1, $t4, x_max_is_e1_x
    move $t8, $t4               # max = e2_x
    j x_max_done
x_max_is_e1_x:
    move $t8, $t1               # max = e1_x
x_max_done:
    
    sub $v0, $t7, $t8           # overlap_x
    
    # Now do Y axis
    la $t0, ENTITY_Y_OFFSET
    lw $t0, 0($t0)
    add $t0, $a0, $t0
    lw $t1, 0($t0)              # e1_y
    
    la $t0, ENTITY_HEIGHT_OFFSET
    lw $t0, 0($t0)
    add $t0, $a0, $t0
    lw $t2, 0($t0)              # e1_height
    
    add $t3, $t1, $t2           # e1_bottom
    
    la $t0, ENTITY_Y_OFFSET
    lw $t0, 0($t0)
    add $t0, $a1, $t0
    lw $t4, 0($t0)              # e2_y
    
    la $t0, ENTITY_HEIGHT_OFFSET
    lw $t0, 0($t0)
    add $t0, $a1, $t0
    lw $t5, 0($t0)              # e2_height
    
    add $t6, $t4, $t5           # e2_bottom
    
    # Calculate Y overlap
    blt $t3, $t6, y_min_is_e1_bottom
    move $t7, $t6
    j y_min_done
y_min_is_e1_bottom:
    move $t7, $t3
y_min_done:
    
    bgt $t1, $t4, y_max_is_e1_y
    move $t8, $t4
    j y_max_done
y_max_is_e1_y:
    move $t8, $t1
y_max_done:
    
    sub $v1, $t7, $t8           # overlap_y
    
    jr $ra


#==============================================================================
# END OF COLLISION MODULE
#==============================================================================