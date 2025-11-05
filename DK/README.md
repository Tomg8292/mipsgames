Donkey Kong (MIPS Assembly)

A simplified implementation of Donkey Kong written in MIPS assembly language, designed to run under the MARS or SPIM simulator. This project demonstrates real-time game mechanics including sprite rendering, collision detection, and physics simulation using low-level system calls and memory-mapped I/O.
Technical Specifications
Execution Environment

    Simulator: MARS 4.5 or SPIM

    Display: Bitmap Display (512x1024 pixels, 8x8 unit size)

    Base Address: 0x10008000 ($gp)

    Input: Keyboard and Display MMIO Simulator

Memory Layout
Data Segment (.data)

    Color Definitions: 32-bit ARGB values for rendering

    Game State Variables: Player position, velocity, collision flags

    Object Arrays: Barrel data structures (position, velocity, active status)

    Level Geometry: Platform and ladder coordinate definitions

Key Memory Symbols
Label	Type	Purpose
playerX, playerY	word	Player coordinates (pixels)
playerVelX, playerVelY	word	Player velocity components
barrels	array	Active barrel objects (20 bytes each)
onGround, onLadder	word	Collision state flags
gameOver, playerWon	word	Game state flags
Rendering System
Display Configuration

    Resolution: 64x128 logical units (512x1024 physical pixels)

    Pixel Drawing: System call 0x20 with coordinates in $a0, $a1, color in $a2

    Coordinate System: Origin at top-left, positive Y downward

Core Rendering Procedures

draw_pixel
mips

 Parameters: $a0 = x, $a1 = y, $a2 = color
 Clips coordinates to display bounds
 Uses: $t0 for address calculation

draw_rect
mips

 Parameters: $a0 = x, $a1 = y, $a2 = width, $a3 = height
 Stack: color at 24($sp)
 Fills rectangular region with specified color

draw_barrel (Circular Sprite)
mips

 Parameters: $a0 = centerX, $a1 = centerY  
 Renders 4x4 circular barrel using barrel_brown color
 Pattern: approximates circle with symmetric pixel placement

Physics and Movement System
Player Physics

    Gravity: Constant acceleration (1 pixel/frame²)

    Jump Force: -4 pixels/frame (upward impulse)

    Terminal Velocity: 3 pixels/frame (maximum fall speed)

    Coyote Time: 5-frame window for late jumps after leaving platform

Collision Detection

    AABB (Axis-Aligned Bounding Box): 2x2 pixel hitbox for player and barrels

    Platform Collision: Line segment intersection tests

    Ladder Collision: Point-in-vertical-range detection

Game Object Management
Barrel System

Each barrel occupies 20 bytes in memory:

    0($s2): X position

    4($s2): Y position

    8($s2): Vertical velocity

    12($s2): Horizontal velocity

    16($s2): Active flag (0 = inactive, 1 = active)

Barrel behavior includes:

    Periodic spawning from Donkey Kong's position

    Platform collision and bouncing

    Gravity application

    Screen boundary handling

Level Geometry

Platforms defined as (x1, x2, y) tuples:
mips

plat0: .word 0, 60, 8     Top platform
plat1: .word 4, 63, 28    Second platform
 ... etc

Ladders defined as (x, y1, y2) tuples:
mips

ladder0: .word 56, 10, 26    Right-side ladder
ladder1: .word 4, 30, 46     Left-side ladder  
 ... etc

Input Handling
Control Scheme

    A: Move left

    D: Move right

    W: Jump (ground) / Climb up (ladder)

    S: Climb down (ladder only)

    Q: Quit game

Input Processing
mips

check_input:
    li $t0, 0xffff0000     MMIO control address
    lw $t1, 0($t0)         Check if key available
    beq $t1, $zero, no_key_pressed
    
    li $t0, 0xffff0004     MMIO data address  
    lw $t1, 0($t0)         Read key code
     Process key and update game state

Main Game Loop Architecture
mips

game_loop:
    jal clear_screen           Frame buffer reset
    jal draw_platforms         Static level geometry
    jal draw_ladders           Climbing structures
    jal draw_dk                Donkey Kong sprite
    jal check_input            Player controls
    jal apply_horizontal_movement   X-axis physics
    jal check_ladder_collision      Ladder interaction
    jal check_platform_collision    Ground detection
    jal apply_gravity               Y-axis physics
    jal update_spawn_timer          Barrel generation
    jal update_all_barrels          Barrel physics
    jal check_barrel_platform_collision   Barrel-ground interaction
    jal draw_all_barrels            Barrel rendering
    jal draw_player                 Player sprite
    jal check_all_collisions        Player-barrel collision
    jal check_victory               Win condition
    
    li $v0, 32                     Delay for frame rate control
    li $a0, 50                     50ms delay (~20 FPS)
    syscall
    
    j game_loop                    Next frame

Sprite Designs
Player (Mario)

    Dimensions: 6x8 pixels

    Hitbox: 2x2 pixels at feet (bottom-center)

    Color Scheme: Red cap, blue overalls, skin tones

    Rendering: Multi-layer composition with precise pixel placement

Barrel

    Dimensions: 4x4 pixels (circular approximation)

    Color: Light brown (0x00CD853F)

    Pattern: Symmetric arrangement for circular appearance

Collision System Details
Platform Collision
mips

check_single_platform:
     Check if player feet (y+2) are within 3 pixels of platform
     Verify player X range overlaps platform X range
     If collision: set onGround, reset velocity, position player on platform

Barrel-Player Collision
mips

check_all_collisions:
     For each active barrel:
     Test AABB overlap between player (2x2) and barrel (2x2)
     If collision detected: set gameOver = 1, playerWon = 0

Victory Conditions
Win Condition

Player reaches Donkey Kong's platform and makes contact:

    Player Y position between 4-10

    Horizontal overlap with Donkey Kong sprite

    Triggers victory screen with "YOU WON!" message

Loss Condition

Player collides with any active barrel:

    Immediate game over

    Triggers defeat screen with "GAME OVER" message

Performance Considerations

    Frame Rate: Target 20 FPS with 50ms delays

    Rendering Optimization: Selective redraw of changed elements

    Collision Optimization: Early termination on first collision detection

    Memory Usage: Efficient packing of game state in data segment

Extension Points

    Multiple simultaneous barrels with independent physics

    Animated sprite frames for character movement

    Sound effects using MARS system calls

    Score tracking and level progression

    Enhanced AI for barrel pathfinding

This implementation demonstrates complete game development in assembly language, showcasing low-level graphics programming, real-time input handling, and physics simulation within the constraints of the MIPS architecture and MARS simulator environment.