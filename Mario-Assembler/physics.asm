#==============================================================================
# physics.asm - Game Physics Engine Module
#==============================================================================
# This module handles all physics calculations including gravity, velocity,
# acceleration, and basic movement for all game entities.
#
# DEPENDENCIES: constants.asm
# EXPORTS: All physics functions via .globl
#
# PHYSICS MODEL:
#   - Velocity-based movement (position += velocity each frame)
#   - Gravity constantly accelerates entities downward
#   - Jump applies instant upward velocity
#   - Collision response zeroes velocity in collision direction
#
# CALLING CONVENTIONS:
#   - Standard MIPS conventions followed
#   - Entity passed as pointer in $a0
#   - All functions preserve $s0-$s7
#==============================================================================

.data

#------------------------------------------------------------------------------
# Physics Constants (cached for performance)
#------------------------------------------------------------------------------
gravity_cache:        .word 1         # Gravity acceleration (pixels/frame²)
max_fall_speed_cache: .word 8         # Terminal velocity
jump_velocity_cache:  .word -12       # Initial jump velocity (negative = up)
walk_speed_cache:     .word 3         # Horizontal walk speed

.text

#==============================================================================
# INITIALIZATION FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# physics_init - Initialize the physics system
#------------------------------------------------------------------------------
# Loads physics constants into cache for fast access.
#
# Arguments: None
# Returns: None
# Modifies: $t0-$t2
#------------------------------------------------------------------------------
.globl physics_init
physics_init:
    # Cache gravity
    la $t0, GRAVITY
    lw $t1, 0($t0)
    la $t2, gravity_cache
    sw $t1, 0($t2)
    
    # Cache max fall speed
    la $t0, MAX_FALL_SPEED
    lw $t1, 0($t0)
    la $t2, max_fall_speed_cache
    sw $t1, 0($t2)
    
    # Cache jump velocity
    la $t0, JUMP_VELOCITY
    lw $t1, 0($t0)
    la $t2, jump_velocity_cache
    sw $t1, 0($t2)
    
    # Cache walk speed
    la $t0, WALK_SPEED
    lw $t1, 0($t0)
    la $t2, walk_speed_cache
    sw $t1, 0($t2)
    
    jr $ra


#==============================================================================
# GRAVITY AND VELOCITY FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# physics_apply_gravity - Apply gravity to an entity
#------------------------------------------------------------------------------
# Increases entity's Y velocity by gravity constant (downward acceleration).
# Clamps velocity to maximum fall speed to prevent infinite acceleration.
#
# Arguments:
#   $a0 = entity address (pointer to entity structure)
# Returns: None
# Modifies: $t0-$t4
#------------------------------------------------------------------------------
.globl physics_apply_gravity
physics_apply_gravity:
    # Load current Y velocity
    la $t0, ENTITY_VY_OFFSET
    lw $t0, 0($t0)
    add $t1, $a0, $t0           # $t1 = address of vy
    lw $t2, 0($t1)              # $t2 = current vy
    
    # Add gravity
    la $t3, gravity_cache
    lw $t3, 0($t3)              # $t3 = gravity
    add $t2, $t2, $t3           # $t2 = vy + gravity
    
    # Clamp to max fall speed
    la $t4, max_fall_speed_cache
    lw $t4, 0($t4)              # $t4 = max fall speed
    ble $t2, $t4, gravity_not_clamped
    move $t2, $t4               # Clamp to max

gravity_not_clamped:
    # Store updated velocity
    sw $t2, 0($t1)
    jr $ra


#------------------------------------------------------------------------------
# physics_update_position - Update entity position based on velocity
#------------------------------------------------------------------------------
# Adds velocity to position (X += VX, Y += VY).
# This is the core integration step of physics simulation.
#
# Arguments:
#   $a0 = entity address
# Returns: None
# Modifies: $t0-$t5
#------------------------------------------------------------------------------
.globl physics_update_position
physics_update_position:
    # Update X position
    la $t0, ENTITY_X_OFFSET
    lw $t0, 0($t0)
    add $t1, $a0, $t0           # $t1 = address of x
    lw $t2, 0($t1)              # $t2 = current x
    
    la $t0, ENTITY_VX_OFFSET
    lw $t0, 0($t0)
    add $t3, $a0, $t0           # $t3 = address of vx
    lw $t4, 0($t3)              # $t4 = vx
    
    add $t2, $t2, $t4           # $t2 = x + vx
    sw $t2, 0($t1)              # Store new x
    
    # Update Y position
    la $t0, ENTITY_Y_OFFSET
    lw $t0, 0($t0)
    add $t1, $a0, $t0           # $t1 = address of y
    lw $t2, 0($t1)              # $t2 = current y
    
    la $t0, ENTITY_VY_OFFSET
    lw $t0, 0($t0)
    add $t3, $a0, $t0           # $t3 = address of vy
    lw $t4, 0($t3)              # $t4 = vy
    
    add $t2, $t2, $t4           # $t2 = y + vy
    sw $t2, 0($t1)              # Store new y
    
    jr $ra


#------------------------------------------------------------------------------
# physics_set_velocity - Set entity velocity directly
#------------------------------------------------------------------------------
# Directly sets the X and Y velocity of an entity.
#
# Arguments:
#   $a0 = entity address
#   $a1 = new vx
#   $a2 = new vy
# Returns: None
# Modifies: $t0-$t1
#------------------------------------------------------------------------------
.globl physics_set_velocity
physics_set_velocity:
    # Set vx
    la $t0, ENTITY_VX_OFFSET
    lw $t0, 0($t0)
    add $t0, $a0, $t0
    sw $a1, 0($t0)
    
    # Set vy
    la $t0, ENTITY_VY_OFFSET
    lw $t0, 0($t0)
    add $t0, $a0, $t0
    sw $a2, 0($t0)
    
    jr $ra


#------------------------------------------------------------------------------
# physics_get_velocity - Get entity velocity
#------------------------------------------------------------------------------
# Retrieves the X and Y velocity of an entity.
#
# Arguments:
#   $a0 = entity address
# Returns:
#   $v0 = vx
#   $v1 = vy
# Modifies: $t0, $v0, $v1
#------------------------------------------------------------------------------
.globl physics_get_velocity
physics_get_velocity:
    # Get vx
    la $t0, ENTITY_VX_OFFSET
    lw $t0, 0($t0)
    add $t0, $a0, $t0
    lw $v0, 0($t0)
    
    # Get vy
    la $t0, ENTITY_VY_OFFSET
    lw $t0, 0($t0)
    add $t0, $a0, $t0
    lw $v1, 0($t0)
    
    jr $ra


#==============================================================================
# MOVEMENT FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# physics_move_left - Move entity left at walk speed
#------------------------------------------------------------------------------
# Sets entity's X velocity to negative walk speed.
#
# Arguments:
#   $a0 = entity address
# Returns: None
# Modifies: $t0-$t2
#------------------------------------------------------------------------------
.globl physics_move_left
physics_move_left:
    la $t0, walk_speed_cache
    lw $t1, 0($t0)              # $t1 = walk speed
    sub $t1, $zero, $t1         # $t1 = -walk_speed
    
    la $t0, ENTITY_VX_OFFSET
    lw $t0, 0($t0)
    add $t2, $a0, $t0           # $t2 = address of vx
    sw $t1, 0($t2)              # vx = -walk_speed
    
    jr $ra


#------------------------------------------------------------------------------
# physics_move_right - Move entity right at walk speed
#------------------------------------------------------------------------------
# Sets entity's X velocity to positive walk speed.
#
# Arguments:
#   $a0 = entity address
# Returns: None
# Modifies: $t0-$t2
#------------------------------------------------------------------------------
.globl physics_move_right
physics_move_right:
    la $t0, walk_speed_cache
    lw $t1, 0($t0)              # $t1 = walk speed
    
    la $t0, ENTITY_VX_OFFSET
    lw $t0, 0($t0)
    add $t2, $a0, $t0           # $t2 = address of vx
    sw $t1, 0($t2)              # vx = +walk_speed
    
    jr $ra


#------------------------------------------------------------------------------
# physics_stop_horizontal - Stop horizontal movement
#------------------------------------------------------------------------------
# Sets entity's X velocity to zero (used for stopping or landing).
#
# Arguments:
#   $a0 = entity address
# Returns: None
# Modifies: $t0-$t1
#------------------------------------------------------------------------------
.globl physics_stop_horizontal
physics_stop_horizontal:
    la $t0, ENTITY_VX_OFFSET
    lw $t0, 0($t0)
    add $t1, $a0, $t0
    sw $zero, 0($t1)            # vx = 0
    
    jr $ra


#------------------------------------------------------------------------------
# physics_stop_vertical - Stop vertical movement
#------------------------------------------------------------------------------
# Sets entity's Y velocity to zero (used for landing on ground/platform).
#
# Arguments:
#   $a0 = entity address
# Returns: None
# Modifies: $t0-$t1
#------------------------------------------------------------------------------
.globl physics_stop_vertical
physics_stop_vertical:
    la $t0, ENTITY_VY_OFFSET
    lw $t0, 0($t0)
    add $t1, $a0, $t0
    sw $zero, 0($t1)            # vy = 0
    
    jr $ra


#------------------------------------------------------------------------------
# physics_jump - Make entity jump
#------------------------------------------------------------------------------
# Sets entity's Y velocity to the jump velocity constant (negative = upward).
# ONLY call this when entity is on the ground, or implement coyote time.
#
# Arguments:
#   $a0 = entity address
# Returns: None
# Modifies: $t0-$t2
#------------------------------------------------------------------------------
.globl physics_jump
physics_jump:
    la $t0, jump_velocity_cache
    lw $t1, 0($t0)              # $t1 = jump velocity (negative)
    
    la $t0, ENTITY_VY_OFFSET
    lw $t0, 0($t0)
    add $t2, $a0, $t0           # $t2 = address of vy
    sw $t1, 0($t2)              # vy = jump_velocity
    
    jr $ra


#==============================================================================
# BOUNDARY COLLISION FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# physics_check_ground_collision - Check if entity hit ground
#------------------------------------------------------------------------------
# Checks if entity's bottom edge has reached or passed the ground level.
# If so, clamps position and stops downward movement.
#
# Arguments:
#   $a0 = entity address
#   $a1 = ground Y position (typically 450)
# Returns:
#   $v0 = 1 if on ground, 0 if not
# Modifies: $t0-$t5, $v0
#------------------------------------------------------------------------------
.globl physics_check_ground_collision
physics_check_ground_collision:
    # Load entity Y position
    la $t0, ENTITY_Y_OFFSET
    lw $t0, 0($t0)
    add $t1, $a0, $t0           # $t1 = address of y
    lw $t2, 0($t1)              # $t2 = entity y
    
    # Load entity height
    la $t0, ENTITY_HEIGHT_OFFSET
    lw $t0, 0($t0)
    add $t3, $a0, $t0
    lw $t3, 0($t3)              # $t3 = entity height
    
    # Calculate bottom edge: y + height
    add $t4, $t2, $t3           # $t4 = bottom edge
    
    # Compare with ground
    blt $t4, $a1, not_on_ground # If bottom < ground, not colliding
    
    # Entity is on or below ground - fix it
    sub $t2, $a1, $t3           # $t2 = ground - height (correct y position)
    sw $t2, 0($t1)              # Store corrected y
    
    # Stop downward velocity
    la $t0, ENTITY_VY_OFFSET
    lw $t0, 0($t0)
    add $t5, $a0, $t0
    lw $t0, 0($t5)              # $t0 = current vy
    
    # Only stop if moving down (vy > 0)
    blez $t0, ground_already_stopped
    sw $zero, 0($t5)            # vy = 0

ground_already_stopped:
    li $v0, 1                   # Return 1 (on ground)
    jr $ra

not_on_ground:
    li $v0, 0                   # Return 0 (not on ground)
    jr $ra


#------------------------------------------------------------------------------
# physics_check_screen_bounds - Keep entity within screen boundaries
#------------------------------------------------------------------------------
# Clamps entity position to stay within the visible screen area.
# Prevents entity from going off-screen left/right/top.
#
# Arguments:
#   $a0 = entity address
# Returns: None
# Modifies: $t0-$t7
#------------------------------------------------------------------------------
.globl physics_check_screen_bounds
physics_check_screen_bounds:
    # Load entity dimensions
    la $t0, ENTITY_WIDTH_OFFSET
    lw $t0, 0($t0)
    add $t1, $a0, $t0
    lw $t1, 0($t1)              # $t1 = width
    
    la $t0, ENTITY_HEIGHT_OFFSET
    lw $t0, 0($t0)
    add $t2, $a0, $t0
    lw $t2, 0($t2)              # $t2 = height
    
    # Check X bounds
    la $t0, ENTITY_X_OFFSET
    lw $t0, 0($t0)
    add $t3, $a0, $t0           # $t3 = address of x
    lw $t4, 0($t3)              # $t4 = x position
    
    # Check left bound (x >= 0)
    bgez $t4, check_right_bound
    li $t4, 0                   # Clamp to 0
    sw $t4, 0($t3)
    
    # Stop leftward movement
    la $t0, ENTITY_VX_OFFSET
    lw $t0, 0($t0)
    add $t5, $a0, $t0
    lw $t6, 0($t5)
    bgez $t6, check_right_bound # Only stop if moving left (vx < 0)
    sw $zero, 0($t5)

check_right_bound:
    # Check right bound (x + width <= screen_width)
    lw $t4, 0($t3)              # Reload x (might have been clamped)
    add $t5, $t4, $t1           # $t5 = x + width
    
    la $t6, SCREEN_WIDTH
    lw $t6, 0($t6)              # $t6 = screen width (512)
    
    ble $t5, $t6, check_y_bounds
    sub $t4, $t6, $t1           # $t4 = screen_width - width
    sw $t4, 0($t3)              # Clamp x
    
    # Stop rightward movement
    la $t0, ENTITY_VX_OFFSET
    lw $t0, 0($t0)
    add $t5, $a0, $t0
    lw $t6, 0($t5)
    blez $t6, check_y_bounds    # Only stop if moving right (vx > 0)
    sw $zero, 0($t5)

check_y_bounds:
    # Check top bound (y >= 0)
    la $t0, ENTITY_Y_OFFSET
    lw $t0, 0($t0)
    add $t3, $a0, $t0           # $t3 = address of y
    lw $t4, 0($t3)              # $t4 = y position
    
    bgez $t4, bounds_done
    li $t4, 0                   # Clamp to 0
    sw $t4, 0($t3)
    
    # Stop upward movement
    la $t0, ENTITY_VY_OFFSET
    lw $t0, 0($t0)
    add $t5, $a0, $t0
    lw $t6, 0($t5)
    bgez $t6, bounds_done       # Only stop if moving up (vy < 0)
    sw $zero, 0($t5)

bounds_done:
    jr $ra


#==============================================================================
# ENTITY STATE QUERIES
#==============================================================================

#------------------------------------------------------------------------------
# physics_is_moving - Check if entity is moving
#------------------------------------------------------------------------------
# Returns true if entity has any non-zero velocity.
#
# Arguments:
#   $a0 = entity address
# Returns:
#   $v0 = 1 if moving, 0 if stationary
# Modifies: $t0-$t2, $v0
#------------------------------------------------------------------------------
.globl physics_is_moving
physics_is_moving:
    # Check vx
    la $t0, ENTITY_VX_OFFSET
    lw $t0, 0($t0)
    add $t0, $a0, $t0
    lw $t1, 0($t0)              # $t1 = vx
    bnez $t1, entity_is_moving
    
    # Check vy
    la $t0, ENTITY_VY_OFFSET
    lw $t0, 0($t0)
    add $t0, $a0, $t0
    lw $t2, 0($t0)              # $t2 = vy
    bnez $t2, entity_is_moving
    
    # Both zero - not moving
    li $v0, 0
    jr $ra

entity_is_moving:
    li $v0, 1
    jr $ra


#------------------------------------------------------------------------------
# physics_is_falling - Check if entity is falling (vy > 0)
#------------------------------------------------------------------------------
# Arguments:
#   $a0 = entity address
# Returns:
#   $v0 = 1 if falling, 0 if not
# Modifies: $t0-$t1, $v0
#------------------------------------------------------------------------------
.globl physics_is_falling
physics_is_falling:
    la $t0, ENTITY_VY_OFFSET
    lw $t0, 0($t0)
    add $t0, $a0, $t0
    lw $t1, 0($t0)              # $t1 = vy
    
    bgtz $t1, entity_falling
    li $v0, 0                   # vy <= 0, not falling
    jr $ra

entity_falling:
    li $v0, 1                   # vy > 0, falling
    jr $ra


#------------------------------------------------------------------------------
# physics_is_rising - Check if entity is rising (vy < 0)
#------------------------------------------------------------------------------
# Arguments:
#   $a0 = entity address
# Returns:
#   $v0 = 1 if rising, 0 if not
# Modifies: $t0-$t1, $v0
#------------------------------------------------------------------------------
.globl physics_is_rising
physics_is_rising:
    la $t0, ENTITY_VY_OFFSET
    lw $t0, 0($t0)
    add $t0, $a0, $t0
    lw $t1, 0($t0)              # $t1 = vy
    
    bltz $t1, entity_rising
    li $v0, 0                   # vy >= 0, not rising
    jr $ra

entity_rising:
    li $v0, 1                   # vy < 0, rising
    jr $ra


#==============================================================================
# ADVANCED PHYSICS FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# physics_apply_friction - Slow down horizontal movement
#------------------------------------------------------------------------------
# Reduces horizontal velocity toward zero by the friction constant.
# Used for smooth deceleration when player releases movement keys.
#
# Arguments:
#   $a0 = entity address
# Returns: None
# Modifies: $t0-$t4
#------------------------------------------------------------------------------
.globl physics_apply_friction
physics_apply_friction:
    # Load friction constant
    la $t0, FRICTION
    lw $t0, 0($t0)              # $t0 = friction amount
    
    # Load current vx
    la $t1, ENTITY_VX_OFFSET
    lw $t1, 0($t1)
    add $t2, $a0, $t1           # $t2 = address of vx
    lw $t3, 0($t2)              # $t3 = vx
    
    # If vx is 0, nothing to do
    beqz $t3, friction_done
    
    # Determine direction and reduce velocity
    bltz $t3, friction_negative
    
    # Positive velocity - reduce by friction
    sub $t3, $t3, $t0
    bltz $t3, friction_zero     # If went negative, set to 0
    sw $t3, 0($t2)
    jr $ra

friction_negative:
    # Negative velocity - increase (toward zero)
    add $t3, $t3, $t0
    bgtz $t3, friction_zero     # If went positive, set to 0
    sw $t3, 0($t2)
    jr $ra

friction_zero:
    sw $zero, 0($t2)

friction_done:
    jr $ra


#------------------------------------------------------------------------------
# physics_full_update - Complete physics update for an entity
#------------------------------------------------------------------------------
# Performs a full physics simulation step:
#   1. Apply gravity
#   2. Update position based on velocity
#   3. Check screen bounds
#   4. Check ground collision
#
# This is a convenience function that combines common physics operations.
#
# Arguments:
#   $a0 = entity address
#   $a1 = ground Y position
# Returns:
#   $v0 = 1 if on ground, 0 if airborne
# Modifies: $t0-$t7, $s0-$s1, $v0
#------------------------------------------------------------------------------
.globl physics_full_update
physics_full_update:
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    
    move $s0, $a0               # Save entity address
    move $s1, $a1               # Save ground position
    
    # Step 1: Apply gravity
    move $a0, $s0
    jal physics_apply_gravity
    
    # Step 2: Update position
    move $a0, $s0
    jal physics_update_position
    
    # Step 3: Check screen bounds
    move $a0, $s0
    jal physics_check_screen_bounds
    
    # Step 4: Check ground collision
    move $a0, $s0
    move $a1, $s1
    jal physics_check_ground_collision
    # $v0 now contains ground collision result
    
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra


#==============================================================================
# END OF PHYSICS MODULE
#==============================================================================