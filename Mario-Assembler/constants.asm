#==============================================================================
# constants.asm - Mario Platformer Game Constants and Sprite Data
#==============================================================================
# This file contains all shared constants, colors, and sprite definitions
# used throughout the game. No executable code, only data declarations.
#
# DEPENDENCIES: None (foundation file)
# EXPORTS: All constants and data structures via .globl
#
# MEMORY LAYOUT:
#   - Display buffer: 0x10008000 (MMIO bitmap display base)
#   - Static data: Starting at 0x10010000
#==============================================================================

.data

#------------------------------------------------------------------------------
# DISPLAY CONSTANTS
#------------------------------------------------------------------------------
.globl DISPLAY_BASE_ADDR
.globl SCREEN_WIDTH
.globl SCREEN_HEIGHT
.globl SCREEN_TOTAL_PIXELS
.globl BYTES_PER_PIXEL

DISPLAY_BASE_ADDR:    .word 0x10008000    # Bitmap display MMIO address
SCREEN_WIDTH:         .word 512           # Display width in pixels
SCREEN_HEIGHT:        .word 512           # Display height in pixels
SCREEN_TOTAL_PIXELS:  .word 262144        # 512 * 512 total pixels
BYTES_PER_PIXEL:      .word 4             # 4 bytes per pixel (32-bit color)

#------------------------------------------------------------------------------
# SPRITE DIMENSIONS (8x8 pixels for all entities)
#------------------------------------------------------------------------------
.globl SPRITE_SIZE
.globl SPRITE_SIZE_BYTES

SPRITE_SIZE:          .word 8             # 8x8 pixel sprites
SPRITE_SIZE_BYTES:    .word 256           # 8 * 8 * 4 bytes per sprite

#------------------------------------------------------------------------------
# COLOR PALETTE (32-bit RGBA format: 0xRRGGBB00)
#------------------------------------------------------------------------------
.globl COLOR_SKY_BLUE
.globl COLOR_GROUND_BROWN
.globl COLOR_PLATFORM_GRAY
.globl COLOR_MARIO_RED
.globl COLOR_MARIO_BLUE
.globl COLOR_MARIO_SKIN
.globl COLOR_GOOMBA_BROWN
.globl COLOR_GOOMBA_DARK
.globl COLOR_COIN_GOLD
.globl COLOR_COIN_YELLOW
.globl COLOR_BLACK
.globl COLOR_WHITE
.globl COLOR_GREEN
.globl COLOR_TRANSPARENT

COLOR_SKY_BLUE:       .word 0x5C94FC00    # Sky background
COLOR_GROUND_BROWN:   .word 0x8B4513FF    # Ground/dirt color
COLOR_PLATFORM_GRAY:  .word 0x808080FF    # Platform color
COLOR_MARIO_RED:      .word 0xFF0000FF    # Mario's hat/shirt
COLOR_MARIO_BLUE:     .word 0x0000FFFF    # Mario's overalls
COLOR_MARIO_SKIN:     .word 0xFFDBACFF    # Mario's skin tone
COLOR_GOOMBA_BROWN:   .word 0xA0522DFF    # Goomba body
COLOR_GOOMBA_DARK:    .word 0x654321FF    # Goomba details
COLOR_COIN_GOLD:      .word 0xFFD700FF    # Coin primary
COLOR_COIN_YELLOW:    .word 0xFFFF00FF    # Coin highlight
COLOR_BLACK:          .word 0x000000FF    # Black
COLOR_WHITE:          .word 0xFFFFFFFF    # White
COLOR_GREEN:          .word 0x00FF00FF    # Debug/effects
COLOR_TRANSPARENT:    .word 0x00000000    # Transparent (for masking)

#------------------------------------------------------------------------------
# PHYSICS CONSTANTS
#------------------------------------------------------------------------------
.globl GRAVITY
.globl MAX_FALL_SPEED
.globl JUMP_VELOCITY
.globl WALK_SPEED
.globl FRICTION

GRAVITY:              .word 1             # Pixels/frame² to add to Y velocity
MAX_FALL_SPEED:       .word 8             # Maximum downward velocity
JUMP_VELOCITY:        .word -12           # Initial upward velocity when jumping
WALK_SPEED:           .word 3             # Horizontal movement speed
FRICTION:             .word 1             # Deceleration when not moving

#------------------------------------------------------------------------------
# GAME CONSTANTS
#------------------------------------------------------------------------------
.globl STARTING_LIVES
.globl MAX_COINS
.globl MAX_GOOMBAS
.globl POINTS_PER_COIN
.globl POINTS_PER_GOOMBA
.globl FRAME_DELAY_MS

STARTING_LIVES:       .word 3             # Player starts with 3 lives
MAX_COINS:            .word 20            # Maximum coins in level
MAX_GOOMBAS:          .word 10            # Maximum goombas in level
POINTS_PER_COIN:      .word 100           # Score for collecting a coin
POINTS_PER_GOOMBA:    .word 200           # Score for defeating a goomba
FRAME_DELAY_MS:       .word 33            # ~30 FPS (33ms delay)

#------------------------------------------------------------------------------
# MAP/LEVEL CONSTANTS
#------------------------------------------------------------------------------
.globl MAP_WIDTH
.globl MAP_HEIGHT
.globl TILE_SIZE
.globl VIEWPORT_WIDTH
.globl VIEWPORT_HEIGHT
.globl CAMERA_SCROLL_THRESHOLD

MAP_WIDTH:            .word 2048          # Total level width in pixels
MAP_HEIGHT:           .word 512           # Total level height (matches screen)
TILE_SIZE:            .word 32            # Each tile is 32x32 pixels
VIEWPORT_WIDTH:       .word 512           # Visible area width (full screen)
VIEWPORT_HEIGHT:      .word 512           # Visible area height (full screen)
CAMERA_SCROLL_THRESHOLD: .word 256        # Start scrolling when Mario reaches this X

#------------------------------------------------------------------------------
# INPUT CONSTANTS (ASCII codes for keyboard)
#------------------------------------------------------------------------------
.globl KEY_LEFT
.globl KEY_RIGHT
.globl KEY_UP
.globl KEY_SPACE
.globl KEY_ESCAPE
.globl KEY_R

KEY_LEFT:             .word 0x61          # 'a' key
KEY_RIGHT:            .word 0x64          # 'd' key  
KEY_UP:               .word 0x77          # 'w' key
KEY_SPACE:            .word 0x20          # Space bar (alternate jump)
KEY_ESCAPE:           .word 0x1B          # ESC to quit
KEY_R:                .word 0x72          # 'r' to restart

#------------------------------------------------------------------------------
# ENTITY TYPE IDENTIFIERS
#------------------------------------------------------------------------------
.globl TYPE_NONE
.globl TYPE_MARIO
.globl TYPE_GOOMBA
.globl TYPE_COIN
.globl TYPE_PLATFORM
.globl TYPE_GROUND

TYPE_NONE:            .word 0
TYPE_MARIO:           .word 1
TYPE_GOOMBA:          .word 2
TYPE_COIN:            .word 3
TYPE_PLATFORM:        .word 4
TYPE_GROUND:          .word 5

#------------------------------------------------------------------------------
# ENTITY STRUCTURE OFFSETS (all entities use this layout)
#------------------------------------------------------------------------------
# Each entity is 32 bytes with the following layout:
#   offset 0:  x position (word)
#   offset 4:  y position (word)
#   offset 8:  x velocity (word)
#   offset 12: y velocity (word)
#   offset 16: entity type (word)
#   offset 20: active flag (word, 0=inactive, 1=active)
#   offset 24: width (word)
#   offset 28: height (word)
#------------------------------------------------------------------------------
.globl ENTITY_X_OFFSET
.globl ENTITY_Y_OFFSET
.globl ENTITY_VX_OFFSET
.globl ENTITY_VY_OFFSET
.globl ENTITY_TYPE_OFFSET
.globl ENTITY_ACTIVE_OFFSET
.globl ENTITY_WIDTH_OFFSET
.globl ENTITY_HEIGHT_OFFSET
.globl ENTITY_SIZE

ENTITY_X_OFFSET:      .word 0
ENTITY_Y_OFFSET:      .word 4
ENTITY_VX_OFFSET:     .word 8
ENTITY_VY_OFFSET:     .word 12
ENTITY_TYPE_OFFSET:   .word 16
ENTITY_ACTIVE_OFFSET: .word 20
ENTITY_WIDTH_OFFSET:  .word 24
ENTITY_HEIGHT_OFFSET: .word 28
ENTITY_SIZE:          .word 32            # Total size of entity structure

#------------------------------------------------------------------------------
# SPRITE DATA: 8x8 PIXEL SPRITES (64 pixels each, stored as color indices)
#------------------------------------------------------------------------------
# Each sprite is stored row by row, 8 pixels per row, 8 rows total
# Values are indices into color table: 0=transparent, 1=primary, 2=secondary, etc.
#------------------------------------------------------------------------------

.globl sprite_mario_right
.globl sprite_goomba
.globl sprite_coin

# Mario facing right (8x8)
# Simple iconic Mario sprite
sprite_mario_right:
    .byte 0,0,1,1,1,0,0,0    # Row 0: Hat outline
    .byte 0,1,1,1,1,1,0,0    # Row 1: Red hat
    .byte 0,3,3,3,3,0,0,0    # Row 2: Skin/face
    .byte 0,3,3,3,3,3,0,0    # Row 3: Skin/face
    .byte 0,0,2,2,2,2,0,0    # Row 4: Blue overalls
    .byte 0,2,2,2,2,2,2,0    # Row 5: Blue overalls
    .byte 0,3,2,0,2,3,0,0    # Row 6: Legs (skin/blue)
    .byte 0,3,3,0,3,3,0,0    # Row 7: Feet/shoes
    
# Goomba (8x8)
# Classic enemy design
sprite_goomba:
    .byte 0,0,1,1,1,1,0,0    # Row 0: Top of head
    .byte 0,1,1,1,1,1,1,0    # Row 1: Head
    .byte 1,2,4,1,1,2,4,1    # Row 2: Eyes/eyebrows
    .byte 1,1,1,1,1,1,1,1    # Row 3: Face
    .byte 1,1,1,1,1,1,1,1    # Row 4: Body
    .byte 0,1,1,1,1,1,1,0    # Row 5: Body narrowing
    .byte 0,0,1,0,0,1,0,0    # Row 6: Feet gap
    .byte 0,1,1,0,0,1,1,0    # Row 7: Feet

# Coin (8x8)
# Rotating coin effect (single frame shown)
sprite_coin:
    .byte 0,0,1,1,1,1,0,0    # Row 0: Top edge
    .byte 0,1,2,2,2,2,1,0    # Row 1: Highlight
    .byte 1,2,2,1,1,2,2,1    # Row 2: Gold with shine
    .byte 1,2,1,1,1,1,2,1    # Row 3: Inner detail
    .byte 1,2,1,1,1,1,2,1    # Row 4: Inner detail
    .byte 1,2,2,1,1,2,2,1    # Row 5: Gold with shine
    .byte 0,1,2,2,2,2,1,0    # Row 6: Highlight
    .byte 0,0,1,1,1,1,0,0    # Row 7: Bottom edge

#------------------------------------------------------------------------------
# SPRITE COLOR MAPPING TABLES
#------------------------------------------------------------------------------
# These tables map sprite pixel values (0-4) to actual colors
#------------------------------------------------------------------------------

.globl mario_color_map
.globl goomba_color_map
.globl coin_color_map

mario_color_map:
    .word 0x00000000    # 0 = transparent
    .word 0xFF0000FF    # 1 = red (hat/shirt)
    .word 0x0000FFFF    # 2 = blue (overalls)
    .word 0xFFDBACFF    # 3 = skin tone
    .word 0x000000FF    # 4 = black (outline)

goomba_color_map:
    .word 0x00000000    # 0 = transparent
    .word 0xA0522DFF    # 1 = brown (body)
    .word 0x654321FF    # 2 = dark brown (details)
    .word 0x000000FF    # 3 = black
    .word 0xFFFFFFFF    # 4 = white (eyes)

coin_color_map:
    .word 0x00000000    # 0 = transparent
    .word 0xFFD700FF    # 1 = gold
    .word 0xFFFF00FF    # 2 = yellow (highlight)
    .word 0xFFA500FF    # 3 = orange (shadow)
    .word 0x000000FF    # 4 = black (outline)

#------------------------------------------------------------------------------
# GAME STATE VARIABLES (accessed globally)
#------------------------------------------------------------------------------
.globl game_score
.globl game_lives
.globl game_state_const

game_score:           .word 0             # Current score
game_lives:           .word 3             # Remaining lives
game_state_const:           .word 0             # 0=playing, 1=game_over, 2=win


#------------------------------------------------------------------------------
# STRING CONSTANTS (for UI display)
#------------------------------------------------------------------------------
.globl str_game_over
.globl str_you_win
.globl str_score
.globl str_lives

str_game_over:        .asciiz "GAME OVER"
str_you_win:          .asciiz "YOU WIN!"
str_score:            .asciiz "Score: "
str_lives:            .asciiz "Lives: "

#==============================================================================
# END OF CONSTANTS FILE
#==============================================================================
# All constants are now defined and exported.
# Other modules can reference these with 'la' or 'lw' instructions.
#==============================================================================
