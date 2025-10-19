#==============================================================================
# render.asm - High-Performance Bitmap Display Rendering Engine
#==============================================================================
# This module handles all rendering operations for the Mario platformer game.
# It provides optimized functions for drawing pixels, sprites, and primitives
# directly to the MARS bitmap display memory.
#
# DEPENDENCIES: constants.asm (for display constants and colors)
# EXPORTS: All rendering functions via .globl
#
# CALLING CONVENTIONS:
#   - Arguments passed in $a0-$a3
#   - Return values in $v0-$v1
#   - $s0-$s7 preserved (callee-saved)
#   - $t0-$t9 may be modified (caller-saved)
#   - $ra preserved if function makes calls
#==============================================================================

.data

#------------------------------------------------------------------------------
# Module-local variables (not exported)
#------------------------------------------------------------------------------
render_buffer_addr:   .word 0x10008000    # Cached display base address
screen_width_cache:   .word 512           # Cached for fast access
screen_height_cache:  .word 512           # Cached for fast access

.text

#==============================================================================
# INITIALIZATION FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# render_init - Initialize the rendering system
#------------------------------------------------------------------------------
# Loads display constants into fast-access cache variables.
# MUST be called before any other render functions.
#
# Arguments: None
# Returns: None
# Modifies: $t0-$t2
#------------------------------------------------------------------------------
.globl render_init
render_init:
    # Load display base address
    la $t0, DISPLAY_BASE_ADDR
    lw $t1, 0($t0)
    la $t2, render_buffer_addr
    sw $t1, 0($t2)
    
    # Cache screen dimensions for performance
    la $t0, SCREEN_WIDTH
    lw $t1, 0($t0)
    la $t2, screen_width_cache
    sw $t1, 0($t2)
    
    la $t0, SCREEN_HEIGHT
    lw $t1, 0($t0)
    la $t2, screen_height_cache
    sw $t1, 0($t2)
    
    jr $ra


#==============================================================================
# CORE RENDERING FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# render_clear_screen - Fill entire screen with a color
#------------------------------------------------------------------------------
# Efficiently clears the screen by writing the same color to all pixels.
# Uses optimized loop with minimal memory operations.
#
# Arguments:
#   $a0 = color (32-bit RGBA value)
# Returns: None
# Modifies: $t0-$t4
#------------------------------------------------------------------------------
.globl render_clear_screen
render_clear_screen:
    # Load base address and total pixels
    la $t0, render_buffer_addr
    lw $t0, 0($t0)              # $t0 = display buffer start address
    
    la $t1, SCREEN_TOTAL_PIXELS
    lw $t1, 0($t1)              # $t1 = 262144 pixels
    sll $t1, $t1, 2             # $t1 = total bytes (pixels * 4)
    add $t1, $t0, $t1           # $t1 = end address
    
    move $t2, $a0               # $t2 = color to fill
    
render_clear_loop:
    sw $t2, 0($t0)              # Write color to current pixel
    addi $t0, $t0, 4            # Move to next pixel
    blt $t0, $t1, render_clear_loop
    
    jr $ra


#------------------------------------------------------------------------------
# render_draw_pixel - Draw a single pixel with bounds checking
#------------------------------------------------------------------------------
# Draws one pixel at (x,y) with the specified color. Includes bounds checking
# to prevent out-of-range writes that could corrupt memory.
#
# Arguments:
#   $a0 = x position (0-511)
#   $a1 = y position (0-511)
#   $a2 = color (32-bit RGBA)
# Returns:
#   $v0 = 1 if drawn, 0 if out of bounds
# Modifies: $t0-$t4, $v0
#------------------------------------------------------------------------------
.globl render_draw_pixel
render_draw_pixel:
    # Bounds check: x >= 0 && x < 512
    bltz $a0, render_draw_pixel_oob    # if x < 0, out of bounds
    la $t0, screen_width_cache
    lw $t0, 0($t0)
    bge $a0, $t0, render_draw_pixel_oob  # if x >= width, out of bounds
    
    # Bounds check: y >= 0 && y < 512
    bltz $a1, render_draw_pixel_oob    # if y < 0, out of bounds
    la $t1, screen_height_cache
    lw $t1, 0($t1)
    bge $a1, $t1, render_draw_pixel_oob  # if y >= height, out of bounds
    
    # Calculate pixel address: base + (y * width + x) * 4
    la $t0, screen_width_cache
    lw $t0, 0($t0)              # $t0 = screen width
    mul $t1, $a1, $t0           # $t1 = y * width
    add $t1, $t1, $a0           # $t1 = y * width + x
    sll $t1, $t1, 2             # $t1 = (y * width + x) * 4 (byte offset)
    
    la $t2, render_buffer_addr
    lw $t2, 0($t2)              # $t2 = display base address
    add $t2, $t2, $t1           # $t2 = final pixel address
    
    sw $a2, 0($t2)              # Write color to pixel
    
    li $v0, 1                   # Return success
    jr $ra

render_draw_pixel_oob:
    li $v0, 0                   # Return failure (out of bounds)
    jr $ra


#------------------------------------------------------------------------------
# render_draw_rect - Draw a filled rectangle
#------------------------------------------------------------------------------
# Draws a filled rectangle from (x,y) with specified width and height.
# Includes clipping to screen boundaries.
#
# Arguments:
#   $a0 = x position (top-left corner)
#   $a1 = y position (top-left corner)
#   $a2 = width (in pixels)
#   $a3 = height (in pixels)
#   Stack: color (at 0($sp) when called)
# Returns: None
# Modifies: $t0-$t9, $s0-$s2
#------------------------------------------------------------------------------
.globl render_draw_rect
render_draw_rect:
    # Save registers
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)
    
    # Load color from stack (passed as 5th parameter)
    lw $s2, 16($sp)             # Color is at offset 16 (after our saved regs)
    
    # Save rectangle parameters
    move $s0, $a0               # $s0 = start x
    move $s1, $a1               # $s1 = start y
    move $t8, $a2               # $t8 = width
    move $t9, $a3               # $t9 = height
    
    # Clip to screen boundaries
    bltz $s0, render_rect_skip  # If x < 0, skip entirely
    bltz $s1, render_rect_skip  # If y < 0, skip entirely
    
    la $t0, screen_width_cache
    lw $t0, 0($t0)
    bge $s0, $t0, render_rect_skip  # If x >= width, skip
    
    la $t0, screen_height_cache
    lw $t0, 0($t0)
    bge $s1, $t0, render_rect_skip  # If y >= height, skip
    
    # Calculate end positions
    add $t6, $s0, $t8           # $t6 = end x
    add $t7, $s1, $t9           # $t7 = end y
    
    # Clip end positions to screen
    la $t0, screen_width_cache
    lw $t0, 0($t0)
    ble $t6, $t0, render_rect_x_ok
    move $t6, $t0               # Clip to screen width
render_rect_x_ok:
    
    la $t0, screen_height_cache
    lw $t0, 0($t0)
    ble $t7, $t0, render_rect_y_ok
    move $t7, $t0               # Clip to screen height
render_rect_y_ok:
    
    # Double loop: for(y = start_y; y < end_y; y++)
    move $t0, $s1               # $t0 = current y
render_rect_y_loop:
    bge $t0, $t7, render_rect_done
    
    # Inner loop: for(x = start_x; x < end_x; x++)
    move $t1, $s0               # $t1 = current x
render_rect_x_loop:
    bge $t1, $t6, render_rect_y_next
    
    # Draw pixel at ($t1, $t0) with color $s2
    move $a0, $t1               # x
    move $a1, $t0               # y
    move $a2, $s2               # color
    
    # Inline pixel drawing for performance (avoid function call overhead)
    la $t2, screen_width_cache
    lw $t2, 0($t2)
    mul $t3, $a1, $t2           # $t3 = y * width
    add $t3, $t3, $a0           # $t3 = y * width + x
    sll $t3, $t3, 2             # $t3 = byte offset
    
    la $t4, render_buffer_addr
    lw $t4, 0($t4)
    add $t4, $t4, $t3           # $t4 = pixel address
    sw $a2, 0($t4)              # Write color
    
    addi $t1, $t1, 1            # x++
    j render_rect_x_loop

render_rect_y_next:
    addi $t0, $t0, 1            # y++
    j render_rect_y_loop

render_rect_done:
render_rect_skip:
    # Restore registers
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra


#------------------------------------------------------------------------------
# render_draw_sprite - Draw an 8x8 sprite with color mapping
#------------------------------------------------------------------------------
# Draws a sprite using indexed color data and a color map lookup table.
# Supports transparency (color index 0).
#
# Arguments:
#   $a0 = x position (top-left corner)
#   $a1 = y position (top-left corner)
#   $a2 = sprite data address (64 bytes, 8x8 pixels)
#   $a3 = color map address (5 words = 20 bytes)
# Returns: None
# Modifies: $t0-$t9, $s0-$s4
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# render_draw_sprite - Draw an 8x8 sprite with color mapping
#------------------------------------------------------------------------------
.globl render_draw_sprite
render_draw_sprite:
    # Save registers
    addi $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    sw $s4, 0($sp)
    
    # Save parameters
    move $s0, $a0               # $s0 = sprite x
    move $s1, $a1               # $s1 = sprite y
    move $s2, $a2               # $s2 = sprite data address
    move $s3, $a3               # $s3 = color map address
    
    # CRITICAL: Validate sprite position is reasonable
    # If X or Y is negative or > 512, skip entirely
    bltz $s0, render_sprite_done
    bltz $s1, render_sprite_done
    li $t0, 512
    bge $s0, $t0, render_sprite_done
    bge $s1, $t0, render_sprite_done
    
    # Validate sprite will fit on screen
    addi $t1, $s0, 8            # right edge = x + 8
    bge $t1, $t0, render_sprite_done
    addi $t1, $s1, 8            # bottom edge = y + 8
    bge $t1, $t0, render_sprite_done
    
    # Validate sprite data pointer is in valid memory range
    # Should be in .data segment (0x10010000 - 0x10040000)
    li $t0, 0x10010000
    blt $s2, $t0, render_sprite_done  # Too low
    li $t0, 0x10040000
    bgt $s2, $t0, render_sprite_done  # Too high
    
    # Loop through 8x8 sprite pixels
    li $s4, 0                   # $s4 = pixel index (0-63)
    
render_sprite_loop:
    bge $s4, 64, render_sprite_done  # All 64 pixels processed
    
    # Calculate pixel row and column
    li $t0, 8
    div $s4, $t0
    mflo $t0                    # $t0 = row (0-7)
    mfhi $t1                    # $t1 = col (0-7)
    
    # Calculate screen position
    add $t2, $s0, $t1           # $t2 = screen_x = sprite_x + col
    add $t3, $s1, $t0           # $t3 = screen_y = sprite_y + row
    
    # Extra bounds check for this specific pixel
    bltz $t2, render_sprite_next
    bltz $t3, render_sprite_next
    li $t4, 512
    bge $t2, $t4, render_sprite_next
    bge $t3, $t4, render_sprite_next
    
    # Load sprite pixel color index
    add $t4, $s2, $s4           # $t4 = sprite data address + pixel index
    lbu $t5, 0($t4)             # $t5 = color index (0-4)
    
    # Skip transparent pixels (index 0)
    beqz $t5, render_sprite_next
    
    # Bounds check color index (must be 0-4)
    li $t6, 5
    bge $t5, $t6, render_sprite_next
    
    # Look up actual color from color map
    sll $t5, $t5, 2             # $t5 = index * 4 (word size)
    add $t5, $s3, $t5           # $t5 = color_map + offset
    lw $t6, 0($t5)              # $t6 = actual RGBA color
    
    # Calculate pixel address safely
    li $t7, 512                 # width
    mul $t8, $t3, $t7           # $t8 = y * width
    add $t8, $t8, $t2           # $t8 = y * width + x
    
    # Bounds check the calculated offset
    li $t7, 262144              # Total pixels (512*512)
    bge $t8, $t7, render_sprite_next  # Skip if out of bounds
    
    sll $t8, $t8, 2             # $t8 = byte offset
    
    # Load base address and add offset
    la $t9, render_buffer_addr
    lw $t9, 0($t9)
    add $t9, $t9, $t8           # $t9 = pixel address
    
    # Final sanity check on address
    li $t7, 0x10008000          # Display buffer start
    blt $t9, $t7, render_sprite_next
    li $t7, 0x10108000          # Display buffer end (0x10008000 + 512*512*4)
    bge $t9, $t7, render_sprite_next
    
    # SAFE TO WRITE
    sw $t6, 0($t9)              # Write color
    
render_sprite_next:
    addi $s4, $s4, 1            # Next pixel
    j render_sprite_loop

render_sprite_done:
    # Restore registers
    lw $s4, 0($sp)
    lw $s3, 4($sp)
    lw $s2, 8($sp)
    lw $s1, 12($sp)
    lw $s0, 16($sp)
    lw $ra, 20($sp)
    addi $sp, $sp, 24
    jr $ra

#------------------------------------------------------------------------------
# render_draw_entity - Draw an entity using its type to select sprite
#------------------------------------------------------------------------------
# High-level function that draws an entity by looking up its type and
# calling the appropriate sprite rendering function.
#
# Arguments:
#   $a0 = entity address (pointer to entity structure)
# Returns: None
# Modifies: $t0-$t9, $a0-$a3
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# render_draw_entity - Draw an entity using its type to select sprite
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# render_draw_entity - Draw an entity using its type to select sprite
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# render_draw_entity - Draw an entity using its type to select sprite (DEBUG)
#------------------------------------------------------------------------------
.globl render_draw_entity
render_draw_entity:
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    
    move $s0, $a0               # $s0 = entity pointer
    
    # Check if entity is active
    la $t0, ENTITY_ACTIVE_OFFSET
    lw $t0, 0($t0)
    add $t0, $s0, $t0
    lw $t1, 0($t0)              # $t1 = active flag
    beqz $t1, render_entity_skip  # Skip if inactive
    
    # Load entity position
    la $t0, ENTITY_X_OFFSET
    lw $t0, 0($t0)
    add $t0, $s0, $t0
    lw $s1, 0($t0)              # $s1 = entity x
    
    la $t0, ENTITY_Y_OFFSET
    lw $t0, 0($t0)
    add $t0, $s0, $t0
    lw $s2, 0($t0)              # $s2 = entity y
    
    # DEBUG: Print position
    li $v0, 4
    la $a0, debug_pos_msg
    syscall
    li $v0, 1
    move $a0, $s1
    syscall
    li $v0, 4
    la $a0, debug_comma
    syscall
    li $v0, 1
    move $a0, $s2
    syscall
    li $v0, 4
    la $a0, debug_newline
    syscall
    
    # Check if on screen (simple bounds check)
    bltz $s1, render_entity_skip        # x < 0
    li $t1, 512
    bge $s1, $t1, render_entity_skip    # x >= 512
    bltz $s2, render_entity_skip        # y < 0
    li $t1, 512
    bge $s2, $t1, render_entity_skip    # y >= 512
    
    # Load entity type
    la $t0, ENTITY_TYPE_OFFSET
    lw $t0, 0($t0)
    add $t0, $s0, $t0
    lw $s3, 0($t0)              # $s3 = entity type
    
    # DEBUG: Print type
    li $v0, 4
    la $a0, debug_type_msg
    syscall
    li $v0, 1
    move $a0, $s3
    syscall
    li $v0, 4
    la $a0, debug_newline
    syscall
    
    # Branch based on type
    la $t0, TYPE_MARIO
    lw $t0, 0($t0)
    beq $s3, $t0, render_entity_mario
    
    la $t0, TYPE_GOOMBA
    lw $t0, 0($t0)
    beq $s3, $t0, render_entity_goomba
    
    la $t0, TYPE_COIN
    lw $t0, 0($t0)
    beq $s3, $t0, render_entity_coin
    
    # Unknown type - print error and skip
    li $v0, 4
    la $a0, debug_unknown_type
    syscall
    j render_entity_skip

render_entity_mario:
    li $v0, 4
    la $a0, debug_drawing_mario
    syscall
    
    move $a0, $s1
    move $a1, $s2
    la $a2, sprite_mario_right
    la $a3, mario_color_map
    jal render_draw_sprite
    j render_entity_skip

render_entity_goomba:
    li $v0, 4
    la $a0, debug_drawing_goomba
    syscall
    
    move $a0, $s1
    move $a1, $s2
    la $a2, sprite_goomba
    la $a3, goomba_color_map
    jal render_draw_sprite
    j render_entity_skip

render_entity_coin:
    li $v0, 4
    la $a0, debug_drawing_coin
    syscall
    
    move $a0, $s1
    move $a1, $s2
    la $a2, sprite_coin
    la $a3, coin_color_map
    jal render_draw_sprite

render_entity_skip:
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra
#==============================================================================
# UTILITY RENDERING FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# render_draw_line_horizontal - Draw a horizontal line
#------------------------------------------------------------------------------
# Optimized for horizontal lines (common for platforms).
#
# Arguments:
#   $a0 = x start position
#   $a1 = y position
#   $a2 = length (in pixels)
#   $a3 = color
# Returns: None
# Modifies: $t0-$t5
#------------------------------------------------------------------------------
.globl render_draw_line_horizontal
render_draw_line_horizontal:
    # Bounds check y
    bltz $a1, render_hline_done
    la $t0, screen_height_cache
    lw $t0, 0($t0)
    bge $a1, $t0, render_hline_done
    
    # Calculate starting address
    la $t0, screen_width_cache
    lw $t0, 0($t0)
    mul $t1, $a1, $t0           # $t1 = y * width
    add $t1, $t1, $a0           # $t1 = y * width + x
    sll $t1, $t1, 2             # $t1 = byte offset
    
    la $t2, render_buffer_addr
    lw $t2, 0($t2)
    add $t2, $t2, $t1           # $t2 = current pixel address
    
    # Calculate end x (clip to screen width)
    add $t3, $a0, $a2           # $t3 = end x
    la $t4, screen_width_cache
    lw $t4, 0($t4)
    ble $t3, $t4, render_hline_clip_ok
    move $t3, $t4               # Clip to screen width
render_hline_clip_ok:
    
    # Draw pixels
    move $t5, $a0               # $t5 = current x
render_hline_loop:
    bge $t5, $t3, render_hline_done
    bltz $t5, render_hline_next  # Skip if x < 0
    
    sw $a3, 0($t2)              # Write color
    
render_hline_next:
    addi $t2, $t2, 4            # Next pixel (4 bytes)
    addi $t5, $t5, 1            # x++
    j render_hline_loop

render_hline_done:
    jr $ra

#==============================================================================
# DEBUG STRINGS
#==============================================================================
.data
debug_pos_msg:      .asciiz "Drawing entity at position: "
debug_comma:        .asciiz ", "
debug_newline:      .asciiz "\n"
debug_type_msg:     .asciiz "Entity type: "
debug_unknown_type: .asciiz "WARNING: Unknown entity type!\n"
debug_drawing_mario: .asciiz "Drawing Mario\n"
debug_drawing_goomba: .asciiz "Drawing Goomba\n"
debug_drawing_coin:  .asciiz "Drawing Coin\n"

#==============================================================================
# END OF RENDER MODULE
#==============================================================================
#==============================================================================
# END OF RENDER MODULE
#==============================================================================
