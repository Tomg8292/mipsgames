#==============================================================================
# input.asm - Keyboard Input Handler Module
#==============================================================================
# This module handles all keyboard input using MARS memory-mapped I/O (MMIO).
# It provides efficient polling-based input checking for game controls.
#
# DEPENDENCIES: constants.asm
# EXPORTS: All input functions via .globl
#
# MEMORY-MAPPED I/O ADDRESSES:
#   0xFFFF0000 - Receiver Control Register (bit 0 = ready flag)
#   0xFFFF0004 - Receiver Data Register (ASCII code when ready)
#
# CALLING CONVENTIONS:
#   - Standard MIPS conventions followed
#   - All functions preserve $s0-$s7
#   - Return values in $v0
#==============================================================================

.data

#------------------------------------------------------------------------------
# MMIO Constants (Keyboard Input)
#------------------------------------------------------------------------------
MMIO_KEYBOARD_CONTROL:  .word 0xFFFF0000    # Receiver control register
MMIO_KEYBOARD_DATA:     .word 0xFFFF0004    # Receiver data register
MMIO_READY_BIT:         .word 0x00000001    # Bit 0 indicates key ready

#------------------------------------------------------------------------------
# Input State Variables
#------------------------------------------------------------------------------
# These track which keys are currently pressed (1) or not pressed (0)
#------------------------------------------------------------------------------
.globl key_left_pressed
.globl key_right_pressed
.globl key_up_pressed
.globl key_space_pressed
.globl key_escape_pressed
.globl key_r_pressed

key_left_pressed:       .word 0             # 'a' key state
key_right_pressed:      .word 0             # 'd' key state
key_up_pressed:         .word 0             # 'w' key state
key_space_pressed:      .word 0             # Space key state
key_escape_pressed:     .word 0             # ESC key state
key_r_pressed:          .word 0             # 'r' key state

#------------------------------------------------------------------------------
# Last key pressed (for debugging/menu navigation)
#------------------------------------------------------------------------------
.globl last_key_code
last_key_code:          .word 0             # ASCII code of last key

.text

#==============================================================================
# INITIALIZATION FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# input_init - Initialize the input system
#------------------------------------------------------------------------------
# Clears all key states to ensure clean startup.
#
# Arguments: None
# Returns: None
# Modifies: $t0-$t1
#------------------------------------------------------------------------------
.globl input_init
input_init:
    # Clear all key pressed states
    la $t0, key_left_pressed
    sw $zero, 0($t0)
    
    la $t0, key_right_pressed
    sw $zero, 0($t0)
    
    la $t0, key_up_pressed
    sw $zero, 0($t0)
    
    la $t0, key_space_pressed
    sw $zero, 0($t0)
    
    la $t0, key_escape_pressed
    sw $zero, 0($t0)
    
    la $t0, key_r_pressed
    sw $zero, 0($t0)
    
    la $t0, last_key_code
    sw $zero, 0($t0)
    
    jr $ra


#==============================================================================
# CORE INPUT POLLING FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# input_poll - Poll keyboard and update all key states
#------------------------------------------------------------------------------
# This should be called once per frame in the main game loop.
# It checks if a key is available and updates the corresponding state variable.
#
# IMPORTANT: MARS MMIO is non-blocking. If no key is pressed, ready bit is 0.
# Reading the data register consumes the key (it won't be there next poll).
#
# Arguments: None
# Returns: 
#   $v0 = ASCII code of key pressed (0 if no key)
# Modifies: $t0-$t5, $v0
#------------------------------------------------------------------------------
.globl input_poll
input_poll:
    # Check if keyboard has data ready
    la $t0, MMIO_KEYBOARD_CONTROL
    lw $t0, 0($t0)              # $t0 = control register address
    lw $t1, 0($t0)              # $t1 = control register value
    
    la $t2, MMIO_READY_BIT
    lw $t2, 0($t2)              # $t2 = ready bit mask (0x00000001)
    
    and $t3, $t1, $t2           # $t3 = control & ready_bit
    beqz $t3, input_poll_no_key # If bit 0 is 0, no key available
    
    # Key is available - read it
    la $t0, MMIO_KEYBOARD_DATA
    lw $t0, 0($t0)              # $t0 = data register address
    lw $t4, 0($t0)              # $t4 = ASCII code of key
    
    # Store as last key pressed
    la $t5, last_key_code
    sw $t4, 0($t5)
    
    # Update key state based on which key was pressed
    # Compare with each game key and set corresponding flag
    
    # Check for 'a' (left)
    la $t5, KEY_LEFT
    lw $t5, 0($t5)              # $t5 = 'a' ASCII code
    bne $t4, $t5, input_check_right
    la $t5, key_left_pressed
    li $t0, 1
    sw $t0, 0($t5)
    j input_poll_done
    
input_check_right:
    # Check for 'd' (right)
    la $t5, KEY_RIGHT
    lw $t5, 0($t5)              # $t5 = 'd' ASCII code
    bne $t4, $t5, input_check_up
    la $t5, key_right_pressed
    li $t0, 1
    sw $t0, 0($t5)
    j input_poll_done
    
input_check_up:
    # Check for 'w' (up/jump)
    la $t5, KEY_UP
    lw $t5, 0($t5)              # $t5 = 'w' ASCII code
    bne $t4, $t5, input_check_space
    la $t5, key_up_pressed
    li $t0, 1
    sw $t0, 0($t5)
    j input_poll_done
    
input_check_space:
    # Check for space (alternate jump)
    la $t5, KEY_SPACE
    lw $t5, 0($t5)              # $t5 = space ASCII code
    bne $t4, $t5, input_check_escape
    la $t5, key_space_pressed
    li $t0, 1
    sw $t0, 0($t5)
    j input_poll_done
    
input_check_escape:
    # Check for ESC (quit)
    la $t5, KEY_ESCAPE
    lw $t5, 0($t5)              # $t5 = ESC ASCII code
    bne $t4, $t5, input_check_r
    la $t5, key_escape_pressed
    li $t0, 1
    sw $t0, 0($t5)
    j input_poll_done
    
input_check_r:
    # Check for 'r' (restart)
    la $t5, KEY_R
    lw $t5, 0($t5)              # $t5 = 'r' ASCII code
    bne $t4, $t5, input_poll_done
    la $t5, key_r_pressed
    li $t0, 1
    sw $t0, 0($t5)
    j input_poll_done

input_poll_no_key:
    li $t4, 0                   # No key pressed

input_poll_done:
    move $v0, $t4               # Return key code (or 0)
    jr $ra


#------------------------------------------------------------------------------
# input_clear_key_state - Clear a specific key's pressed state
#------------------------------------------------------------------------------
# Used after processing a key press to prevent it from being processed
# multiple times (e.g., for single-press actions like jump).
#
# Arguments:
#   $a0 = key code (ASCII value) to clear
# Returns: None
# Modifies: $t0-$t2
#------------------------------------------------------------------------------
.globl input_clear_key_state
input_clear_key_state:
    # Check which key to clear
    la $t0, KEY_LEFT
    lw $t0, 0($t0)
    bne $a0, $t0, clear_check_right
    la $t1, key_left_pressed
    sw $zero, 0($t1)
    jr $ra

clear_check_right:
    la $t0, KEY_RIGHT
    lw $t0, 0($t0)
    bne $a0, $t0, clear_check_up
    la $t1, key_right_pressed
    sw $zero, 0($t1)
    jr $ra

clear_check_up:
    la $t0, KEY_UP
    lw $t0, 0($t0)
    bne $a0, $t0, clear_check_space
    la $t1, key_up_pressed
    sw $zero, 0($t1)
    jr $ra

clear_check_space:
    la $t0, KEY_SPACE
    lw $t0, 0($t0)
    bne $a0, $t0, clear_check_escape
    la $t1, key_space_pressed
    sw $zero, 0($t1)
    jr $ra

clear_check_escape:
    la $t0, KEY_ESCAPE
    lw $t0, 0($t0)
    bne $a0, $t0, clear_check_r
    la $t1, key_escape_pressed
    sw $zero, 0($t1)
    jr $ra

clear_check_r:
    la $t0, KEY_R
    lw $t0, 0($t0)
    bne $a0, $t0, clear_done
    la $t1, key_r_pressed
    sw $zero, 0($t1)

clear_done:
    jr $ra


#------------------------------------------------------------------------------
# input_clear_all_keys - Clear all key pressed states
#------------------------------------------------------------------------------
# Useful for transitioning between game states (menu -> gameplay, etc.)
# or after processing all input for the frame.
#
# Arguments: None
# Returns: None
# Modifies: $t0
#------------------------------------------------------------------------------
.globl input_clear_all_keys
input_clear_all_keys:
    la $t0, key_left_pressed
    sw $zero, 0($t0)
    
    la $t0, key_right_pressed
    sw $zero, 0($t0)
    
    la $t0, key_up_pressed
    sw $zero, 0($t0)
    
    la $t0, key_space_pressed
    sw $zero, 0($t0)
    
    la $t0, key_escape_pressed
    sw $zero, 0($t0)
    
    la $t0, key_r_pressed
    sw $zero, 0($t0)
    
    jr $ra


#==============================================================================
# CONVENIENCE QUERY FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# input_is_left_pressed - Check if left key is pressed
#------------------------------------------------------------------------------
# Arguments: None
# Returns: $v0 = 1 if pressed, 0 if not
# Modifies: $t0, $v0
#------------------------------------------------------------------------------
.globl input_is_left_pressed
input_is_left_pressed:
    la $t0, key_left_pressed
    lw $v0, 0($t0)
    jr $ra


#------------------------------------------------------------------------------
# input_is_right_pressed - Check if right key is pressed
#------------------------------------------------------------------------------
# Arguments: None
# Returns: $v0 = 1 if pressed, 0 if not
# Modifies: $t0, $v0
#------------------------------------------------------------------------------
.globl input_is_right_pressed
input_is_right_pressed:
    la $t0, key_right_pressed
    lw $v0, 0($t0)
    jr $ra


#------------------------------------------------------------------------------
# input_is_jump_pressed - Check if either jump key is pressed
#------------------------------------------------------------------------------
# Returns true if EITHER 'w' OR space is pressed.
#
# Arguments: None
# Returns: $v0 = 1 if pressed, 0 if not
# Modifies: $t0-$t1, $v0
#------------------------------------------------------------------------------
.globl input_is_jump_pressed
input_is_jump_pressed:
    # Check 'w' key
    la $t0, key_up_pressed
    lw $t0, 0($t0)
    bnez $t0, input_jump_yes
    
    # Check space key
    la $t0, key_space_pressed
    lw $t0, 0($t0)
    bnez $t0, input_jump_yes
    
    # Neither pressed
    li $v0, 0
    jr $ra

input_jump_yes:
    li $v0, 1
    jr $ra


#------------------------------------------------------------------------------
# input_is_escape_pressed - Check if escape key is pressed
#------------------------------------------------------------------------------
# Arguments: None
# Returns: $v0 = 1 if pressed, 0 if not
# Modifies: $t0, $v0
#------------------------------------------------------------------------------
.globl input_is_escape_pressed
input_is_escape_pressed:
    la $t0, key_escape_pressed
    lw $v0, 0($t0)
    jr $ra


#------------------------------------------------------------------------------
# input_is_restart_pressed - Check if restart key ('r') is pressed
#------------------------------------------------------------------------------
# Arguments: None
# Returns: $v0 = 1 if pressed, 0 if not
# Modifies: $t0, $v0
#------------------------------------------------------------------------------
.globl input_is_restart_pressed
input_is_restart_pressed:
    la $t0, key_r_pressed
    lw $v0, 0($t0)
    jr $ra


#------------------------------------------------------------------------------
# input_get_last_key - Get the ASCII code of the last key pressed
#------------------------------------------------------------------------------
# Useful for debugging or menu navigation where you need the actual key.
#
# Arguments: None
# Returns: $v0 = ASCII code (0 if no key pressed yet)
# Modifies: $t0, $v0
#------------------------------------------------------------------------------
.globl input_get_last_key
input_get_last_key:
    la $t0, last_key_code
    lw $v0, 0($t0)
    jr $ra


#==============================================================================
# ADVANCED INPUT FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# input_get_horizontal_axis - Get horizontal movement direction
#------------------------------------------------------------------------------
# Returns -1 for left, +1 for right, 0 for neither or both pressed.
# This is useful for direct velocity/movement calculations.
#
# Arguments: None
# Returns: $v0 = -1 (left), 0 (none), +1 (right)
# Modifies: $t0-$t2, $v0
#------------------------------------------------------------------------------
.globl input_get_horizontal_axis
input_get_horizontal_axis:
    # Check left key
    la $t0, key_left_pressed
    lw $t0, 0($t0)              # $t0 = left pressed (0 or 1)
    
    # Check right key
    la $t1, key_right_pressed
    lw $t1, 0($t1)              # $t1 = right pressed (0 or 1)
    
    # Calculate: right - left
    sub $v0, $t1, $t0           # $v0 = right - left
    # Result: -1 if only left, +1 if only right, 0 if both or neither
    
    jr $ra


#------------------------------------------------------------------------------
# input_consume_jump - Clear jump key states after processing
#------------------------------------------------------------------------------
# Call this after handling a jump to prevent multiple jumps from one press.
# Clears both 'w' and space keys.
#
# Arguments: None
# Returns: None
# Modifies: $t0
#------------------------------------------------------------------------------
.globl input_consume_jump
input_consume_jump:
    la $t0, key_up_pressed
    sw $zero, 0($t0)
    
    la $t0, key_space_pressed
    sw $zero, 0($t0)
    
    jr $ra


#------------------------------------------------------------------------------
# input_wait_for_key - Block until any key is pressed
#------------------------------------------------------------------------------
# WARNING: This is a blocking function. Use only in menus or game over screens.
# The main game loop should NEVER call this.
#
# Arguments: None
# Returns: $v0 = ASCII code of key pressed
# Modifies: $t0-$t3, $v0
#------------------------------------------------------------------------------
.globl input_wait_for_key
input_wait_for_key:
input_wait_loop:
    # Check if keyboard has data ready
    la $t0, MMIO_KEYBOARD_CONTROL
    lw $t0, 0($t0)
    lw $t1, 0($t0)              # $t1 = control register value
    
    la $t2, MMIO_READY_BIT
    lw $t2, 0($t2)
    and $t3, $t1, $t2           # Check ready bit
    beqz $t3, input_wait_loop   # Keep waiting if no key
    
    # Key available - read it
    la $t0, MMIO_KEYBOARD_DATA
    lw $t0, 0($t0)
    lw $v0, 0($t0)              # $v0 = ASCII code
    
    jr $ra


#==============================================================================
# DEBUGGING FUNCTIONS
#==============================================================================

#------------------------------------------------------------------------------
# input_print_state - Print current input state to console (for debugging)
#------------------------------------------------------------------------------
# Prints which keys are currently pressed. Useful for testing.
#
# Arguments: None
# Returns: None
# Modifies: $t0-$t3, $v0, $a0
#------------------------------------------------------------------------------
.globl input_print_state
input_print_state:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Print header
    li $v0, 4
    la $a0, debug_input_header
    syscall
    
    # Check and print each key
    la $t0, key_left_pressed
    lw $t1, 0($t0)
    beqz $t1, debug_skip_left
    li $v0, 4
    la $a0, debug_left_msg
    syscall
debug_skip_left:
    
    la $t0, key_right_pressed
    lw $t1, 0($t0)
    beqz $t1, debug_skip_right
    li $v0, 4
    la $a0, debug_right_msg
    syscall
debug_skip_right:
    
    la $t0, key_up_pressed
    lw $t1, 0($t0)
    beqz $t1, debug_skip_up
    li $v0, 4
    la $a0, debug_up_msg
    syscall
debug_skip_up:
    
    la $t0, key_space_pressed
    lw $t1, 0($t0)
    beqz $t1, debug_skip_space
    li $v0, 4
    la $a0, debug_space_msg
    syscall
debug_skip_space:
    
    # Print last key code
    li $v0, 4
    la $a0, debug_lastkey_msg
    syscall
    
    la $t0, last_key_code
    lw $a0, 0($t0)
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, debug_newline
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra


#==============================================================================
# DEBUG DATA
#==============================================================================
.data
debug_input_header: .asciiz "Input State: "
debug_left_msg:     .asciiz "LEFT "
debug_right_msg:    .asciiz "RIGHT "
debug_up_msg:       .asciiz "UP "
debug_space_msg:    .asciiz "SPACE "
debug_lastkey_msg:  .asciiz "| Last Key Code: "
debug_newline:      .asciiz "\n"

#==============================================================================
# END OF INPUT MODULE
#==============================================================================