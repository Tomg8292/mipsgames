#==============================================================================
# level.asm - Level Data and Camera System
#==============================================================================
# This module manages level data including platforms, camera scrolling,
# and entity spawn points for the Mario platformer game.
#
# DEPENDENCIES: constants.asm, objects.asm
# EXPORTS: All level management functions via .globl
#
# LEVEL STRUCTURE:
#   - 2048 pixel wide level (4x screen width)
#   - Camera follows Mario horizontally
#   - Platforms stored as data arrays
#   - Spawn points for enemies and coins
#
# CALLING CONVENTIONS:
#   - Standard MIPS conventions followed
#   - Camera offset in $a0 when needed
#==============================================================================

.data

#------------------------------------------------------------------------------
# Camera State
#------------------------------------------------------------------------------
.globl camera_x
.globl camera_y
camera_x:           .word 0         # Current camera X offset (0 to 1536)
camera_y:           .word 0         # Camera Y offset (always 0 for this game)

#------------------------------------------------------------------------------
# Level Dimensions
#------------------------------------------------------------------------------
.globl level_width
.globl level_height
level_width:        .word 2048      # Total level width in pixels
level_height:       .word 512       # Level height (matches screen)
ground_y:           .word 450       # Ground level Y position

#------------------------------------------------------------------------------
# Platform Data (x, y, width, height)
# Positions are in world coordinates (not screen coordinates)
#------------------------------------------------------------------------------
.globl platform_data
.globl platform_count

platform_count:     .word 12        # Total number of platforms

platform_data:
    # Starting area platforms (screen 1: 0-512)
    .word 50, 400, 120, 16          # Platform 0
    .word 220, 350, 140, 16         # Platform 1
    .word 400, 300, 100, 16         # Platform 2
    
    # Middle area platforms (screen 2: 512-1024)
    .word 550, 380, 100, 16         # Platform 3
    .word 700, 320, 120, 16         # Platform 4
    .word 880, 280, 100, 16         # Platform 5
    
    # Upper area platforms (screen 3: 1024-1536)
    .word 1100, 350, 140, 16        # Platform 6
    .word 1280, 300, 100, 16        # Platform 7
    .word 1420, 250, 120, 16        # Platform 8
    
    # Final area platforms (screen 4: 1536-2048)
    .word 1600, 380, 100, 16        # Platform 9
    .word 1750, 320, 140, 16        # Platform 10
    .word 1920, 280, 80, 16         # Platform 11 (near goal)

#------------------------------------------------------------------------------
# Entity Spawn Points (x, y, type, direction)
# Type: 1=Goomba, 2=Coin
# Direction: -1=left, 1=right (for Goombas only)
#------------------------------------------------------------------------------
.globl spawn_data
.globl spawn_count

spawn_count:        .word 22        # Total spawn points

spawn_data:
    # Screen 1 spawns
    .word 150, 380, 2, 0            # Coin 0
    .word 300, 330, 2, 0            # Coin 1
    .word 450, 280, 2, 0            # Coin 2
    .word 200, 420, 1, 1            # Goomba 0 (moving right)
    .word 350, 420, 1, -1           # Goomba 1 (moving left)
    
    # Screen 2 spawns
    .word 600, 360, 2, 0            # Coin 3
    .word 750, 300, 2, 0            # Coin 4
    .word 900, 260, 2, 0            # Coin 5
    .word 650, 420, 1, 1            # Goomba 2
    .word 800, 420, 1, -1           # Goomba 3
    
    # Screen 3 spawns
    .word 1150, 330, 2, 0           # Coin 6
    .word 1300, 280, 2, 0           # Coin 7
    .word 1450, 230, 2, 0           # Coin 8
    .word 1100, 420, 1, 1           # Goomba 4
    .word 1350, 420, 1, -1          # Goomba 5
    
    # Screen 4 spawns (final area)
    .word 1650, 360, 2, 0           # Coin 9
    .word 1800, 300, 2, 0           # Coin 10
    .word 1950, 260, 2, 0           # Coin 11
    .word 1700, 420, 1, 1           # Goomba 6
    .word 1850, 420, 1, -1          # Goomba 7
    
    # Extra coins for challenge
    .word 1000, 200, 2, 0           # Coin 12 (high up)
    .word 1500, 180, 2, 0           # Coin 13 (high up)

.text

#==============================================================================
# INITIALIZATION FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# level_init - Initialize level system
#------------------------------------------------------------------------------
# Sets camera to starting position and prepares level data.
#
# Arguments: None
# Returns: None
# Modifies: $t0-$t1
#------------------------------------------------------------------------------
.globl level_init
level_init:
    # Reset camera to start
    la $t0, camera_x
    sw $zero, 0($t0)
    
    la $t0, camera_y
    sw $zero, 0($t0)
    
    jr $ra


#------------------------------------------------------------------------------
# level_spawn_all_entities - Spawn all entities from spawn data
#------------------------------------------------------------------------------
# Creates all Goombas and coins based on spawn_data array.
#
# Arguments: None
# Returns: None
# Modifies: $t0-$t9, $s0-$s2, $a0-$a3
#------------------------------------------------------------------------------
.globl level_spawn_all_entities
level_spawn_all_entities:
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)
    
    la $s0, spawn_data          # $s0 = current spawn pointer
    la $s1, spawn_count
    lw $s1, 0($s1)              # $s1 = total spawns
    li $s2, 0                   # $s2 = current index
    
spawn_loop:
    bge $s2, $s1, spawn_done
    
    # Load spawn data (x, y, type, direction)
    lw $t0, 0($s0)              # x
    lw $t1, 4($s0)              # y
    lw $t2, 8($s0)              # type (1=Goomba, 2=Coin)
    lw $t3, 12($s0)             # direction
    
    # Check type
    li $t4, 1
    beq $t2, $t4, spawn_goomba
    
    li $t4, 2
    beq $t2, $t4, spawn_coin
    
    j next_spawn

spawn_goomba:
    move $a0, $t0               # x
    move $a1, $t1               # y
    move $a2, $t3               # direction
    jal objects_create_goomba
    j next_spawn

spawn_coin:
    move $a0, $t0               # x
    move $a1, $t1               # y
    jal objects_create_coin

next_spawn:
    addi $s0, $s0, 16           # Next spawn (4 words)
    addi $s2, $s2, 1
    j spawn_loop

spawn_done:
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra


#==============================================================================
# CAMERA FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# level_update_camera - Update camera position based on player
#------------------------------------------------------------------------------
# Implements smooth camera scrolling that follows Mario.
# Camera starts moving when Mario passes the scroll threshold.
#
# Arguments:
#   $a0 = player X position (world coordinates)
# Returns: None
# Modifies: $t0-$t7
#------------------------------------------------------------------------------
.globl level_update_camera
level_update_camera:
    # Load current camera position
    la $t0, camera_x
    lw $t1, 0($t0)              # $t1 = current camera_x
    
    # Calculate player position on screen
    sub $t2, $a0, $t1           # $t2 = player screen X
    
    # Load scroll threshold (when to start scrolling)
    la $t3, CAMERA_SCROLL_THRESHOLD
    lw $t3, 0($t3)              # $t3 = 256 (middle of screen)
    
    # If player is right of threshold, scroll right
    bgt $t2, $t3, scroll_right
    
    # If player is left of 100 pixels, scroll left
    li $t4, 100
    blt $t2, $t4, scroll_left
    
    # Otherwise, no scrolling needed
    jr $ra

scroll_right:
    # Calculate how far past threshold
    sub $t5, $t2, $t3           # $t5 = distance past threshold
    
    # Move camera right by that amount
    add $t1, $t1, $t5
    
    # Clamp to max scroll (level_width - screen_width)
    la $t6, level_width
    lw $t6, 0($t6)
    la $t7, SCREEN_WIDTH
    lw $t7, 0($t7)
    sub $t6, $t6, $t7           # $t6 = max camera_x (1536)
    
    ble $t1, $t6, camera_clamped_right
    move $t1, $t6               # Clamp to max

camera_clamped_right:
    sw $t1, 0($t0)
    jr $ra

scroll_left:
    # Calculate how far before threshold
    sub $t5, $t4, $t2           # $t5 = distance before 100
    
    # Move camera left by that amount
    sub $t1, $t1, $t5
    
    # Clamp to min scroll (0)
    bgez $t1, camera_clamped_left
    li $t1, 0                   # Clamp to 0

camera_clamped_left:
    sw $t1, 0($t0)
    jr $ra


#------------------------------------------------------------------------------
# level_get_camera_x - Get current camera X offset
#------------------------------------------------------------------------------
# Arguments: None
# Returns: $v0 = camera X offset
# Modifies: $t0, $v0
#------------------------------------------------------------------------------
.globl level_get_camera_x
level_get_camera_x:
    la $t0, camera_x
    lw $v0, 0($t0)
    jr $ra


#------------------------------------------------------------------------------
# level_world_to_screen_x - Convert world X to screen X
#------------------------------------------------------------------------------
# Arguments:
#   $a0 = world X coordinate
# Returns:
#   $v0 = screen X coordinate (or -1 if off-screen)
# Modifies: $t0-$t2, $v0
#------------------------------------------------------------------------------
.globl level_world_to_screen_x
level_world_to_screen_x:
    # screen_x = world_x - camera_x
    la $t0, camera_x
    lw $t1, 0($t0)
    sub $v0, $a0, $t1           # $v0 = screen X
    
    # Check if on screen (0 <= screen_x < 512)
    bltz $v0, off_screen
    la $t2, SCREEN_WIDTH
    lw $t2, 0($t2)
    bge $v0, $t2, off_screen
    
    jr $ra

off_screen:
    li $v0, -1                  # Return -1 for off-screen
    jr $ra


#==============================================================================
# PLATFORM QUERY FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# level_check_platform_collision - Check player vs all platforms
#------------------------------------------------------------------------------
# Checks collision between player and all platforms in the level.
# Only checks platforms that are visible on screen.
#
# Arguments:
#   $a0 = player entity address
# Returns:
#   $v0 = 1 if on platform, 0 if not
#   $v1 = platform Y if on platform
# Modifies: $t0-$t9, $s0-$s3, $v0-$v1
#------------------------------------------------------------------------------
.globl level_check_platform_collision
level_check_platform_collision:
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    
    move $s0, $a0               # Save player pointer
    
    # Get camera offset
    la $t0, camera_x
    lw $s3, 0($t0)              # $s3 = camera_x
    
    # Get player X in world coordinates
    la $t0, ENTITY_X_OFFSET
    lw $t0, 0($t0)
    add $t0, $s0, $t0
    lw $t1, 0($t0)              # $t1 = player screen X
    add $t1, $t1, $s3           # $t1 = player world X
    
    # Loop through all platforms
    la $s1, platform_data
    la $t0, platform_count
    lw $t0, 0($t0)
    li $s2, 0                   # Index

check_platform_loop:
    bge $s2, $t0, no_platform_collision
    
    # Load platform data
    lw $t2, 0($s1)              # platform world X
    lw $t3, 4($s1)              # platform Y
    lw $t4, 8($s1)              # platform width
    lw $t5, 12($s1)             # platform height
    
    # Check if platform is near player (within 100 pixels)
    sub $t6, $t1, $t2           # distance X
    abs $t6, $t6
    li $t7, 100
    bgt $t6, $t7, next_platform_check
    
    # Convert platform X to screen coordinates
    sub $t2, $t2, $s3           # platform screen X
    
    # Check collision with this platform
    move $a0, $s0               # player
    move $a1, $t2               # screen X
    move $a2, $t3               # Y
    move $a3, $t4               # width
    addi $sp, $sp, -4
    sw $t5, 0($sp)              # height
    jal collision_check_platform
    addi $sp, $sp, 4
    
    bnez $v0, found_platform

next_platform_check:
    addi $s1, $s1, 16           # Next platform
    addi $s2, $s2, 1
    j check_platform_loop

found_platform:
    # $v0 already = 1, $v1 already = platform_y
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra

no_platform_collision:
    li $v0, 0
    li $v1, 0
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra


#------------------------------------------------------------------------------
# level_draw_platforms - Draw all visible platforms
#------------------------------------------------------------------------------
# Draws platforms that are currently visible on screen.
#
# Arguments: None
# Returns: None
# Modifies: $t0-$t9, $s0-$s3, $a0-$a3
#------------------------------------------------------------------------------
.globl level_draw_platforms
level_draw_platforms:
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    
    # Get camera offset
    la $t0, camera_x
    lw $s3, 0($t0)              # $s3 = camera_x
    
    # Loop through platforms
    la $s0, platform_data
    la $t0, platform_count
    lw $t0, 0($t0)
    li $s1, 0

draw_platform_loop:
    bge $s1, $t0, draw_platforms_done
    
    # Load platform world coordinates
    lw $t1, 0($s0)              # world X
    lw $t2, 4($s0)              # Y
    lw $t3, 8($s0)              # width
    lw $t4, 12($s0)             # height
    
    # Convert to screen coordinates
    sub $t5, $t1, $s3           # screen X = world X - camera X
    
    # Check if platform is visible (any part on screen)
    # Visible if: screen_x < 512 AND screen_x + width > 0
    li $t6, 512
    bge $t5, $t6, skip_platform_draw
    
    add $t7, $t5, $t3           # right edge
    blez $t7, skip_platform_draw
    
    # Draw platform rectangle
    move $a0, $t5               # screen X
    move $a1, $t2               # Y
    move $a2, $t3               # width
    move $a3, $t4               # height
    
    la $t8, COLOR_PLATFORM_GRAY
    lw $t8, 0($t8)
    addi $sp, $sp, -4
    sw $t8, 0($sp)
    jal render_draw_rect
    addi $sp, $sp, 4
    
    # Draw white top edge
    move $a0, $t5
    move $a1, $t2
    addi $a1, $a1, -1
    move $a2, $t3
    la $t8, COLOR_WHITE
    lw $a3, 0($t8)
    jal render_draw_line_horizontal

skip_platform_draw:
    addi $s0, $s0, 16
    addi $s1, $s1, 1
    j draw_platform_loop

draw_platforms_done:
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
# level_get_ground_y - Get ground level Y position
#------------------------------------------------------------------------------
# Arguments: None
# Returns: $v0 = ground Y position
# Modifies: $t0, $v0
#------------------------------------------------------------------------------
.globl level_get_ground_y
level_get_ground_y:
    la $t0, ground_y
    lw $v0, 0($t0)
    jr $ra


#------------------------------------------------------------------------------
# level_is_at_goal - Check if player reached the goal (end of level)
#------------------------------------------------------------------------------
# Arguments:
#   $a0 = player X position (world coordinates)
# Returns:
#   $v0 = 1 if at goal, 0 if not
# Modifies: $t0-$t2, $v0
#------------------------------------------------------------------------------
.globl level_is_at_goal
level_is_at_goal:
    # Goal is at X = 2000 (near end of level)
    li $t0, 2000
    bge $a0, $t0, at_goal
    
    li $v0, 0
    jr $ra

at_goal:
    li $v0, 1
    jr $ra


#==============================================================================
# END OF LEVEL MODULE
#==============================================================================
