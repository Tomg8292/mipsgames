# Donkey Kong (MIPS Assembly)

A simplified version of **Donkey Kong** implemented in **MIPS assembly**, running under the MARS or SPIM simulator.  
This project demonstrates game logic, sprite rendering, and collision handling using low-level system calls and memory-mapped graphics.

---

## 🧠 Overview

The game runs a main loop that:
1. Clears the display buffer.
2. Draws static elements (platforms, ladders, walls).
3. Updates the position of the player (Mario) based on user input.
4. Updates barrels’ positions and animations.
5. Handles gravity and collisions.
6. Checks for win/lose conditions.

All rendering is performed on a **pixel grid** drawn using system call `0x20` (MARS bitmap display).  
Each pixel is represented by a **32-bit word** in ARGB format.

---

## 🧱 Memory Layout

| Section | Description |
|----------|--------------|
| `.data`  | Contains all color definitions, sprite dimensions, and object state variables. |
| `.text`  | Contains executable instructions, subdivided into labeled procedures. |
| Display Buffer | Controlled by MARS; pixels are drawn using system call `0x20`. |

### Important Symbols

| Label | Purpose |
|--------|----------|
| `barrel_brown` | 32-bit color constant (0x00CD853F) used for rendering barrels. |
| `player_x`, `player_y` | Player coordinates in pixels. |
| `barrel_x`, `barrel_y` | Active barrel coordinates. |
| `gravity_speed` | Constant for vertical motion due to gravity. |
| `screen_width`, `screen_height` | Display resolution used for drawing and bounds checking. |

---

## 🎨 Rendering System

### `draw_pixel`
Draws a single pixel at `(x, y)` with a color in `$a2`.

```asm
# a0 = x
# a1 = y
# a2 = color
draw_pixel:
    li $v0, 0x20      # MARS draw pixel syscall
    syscall
    jr $ra

draw_barrel

Draws a circular barrel sprite centered on (x, y) using a symmetric pattern.
The sprite uses barrel_brown for its color and a fixed pattern of pixel offsets.

# a0 = center X
# a1 = center Y
draw_barrel:
    la $t0, barrel_pattern
    lw $t1, barrel_brown
    ...

The pattern approximates a 4×4 circle:

 .X.
 XXX
 XXX
 .X.

🕹️ Input Handling

Input is read using syscall 12 (read_char):

li $v0, 12
syscall

Accepted keys:

    'a': Move left

    'd': Move right

    'w': Jump (apply upward velocity)

    'q': Quit

The input is non-blocking; when no key is pressed, the previous state persists until the next iteration.
⚙️ Physics & Collisions
Gravity

A constant downward velocity (gravity_speed) is applied each frame to both the player and barrels.
When the next Y position would intersect a platform, movement is stopped.
Collision Model

Each object uses axis-aligned bounding boxes (AABB) for simple detection.

    Player: 8×8 region

    Barrel: 8×8 region

    Platforms: Flat surfaces defined as line segments in data memory

The routine check_collision returns:

    $v0 = 1 if collision detected

    $v0 = 0 otherwise

🔄 Game Loop Structure

main_loop:
    jal clear_screen
    jal draw_platforms
    jal update_player
    jal update_barrels
    jal check_collisions
    jal draw_player
    jal draw_barrels
    j main_loop

Each subroutine manages a specific subsystem.
The game runs indefinitely until 'q' is pressed.
🧩 Key Procedures
Procedure	Description
clear_screen	Fills the display with background color.
draw_platforms	Renders the static level layout.
update_player	Applies input, gravity, and collisions.
update_barrels	Moves barrels, applies physics, and respawns them.
draw_player	Draws Mario sprite at (player_x, player_y).
draw_barrels	Iterates over active barrels and calls draw_barrel.
🧱 Barrel System

Barrels are spawned periodically and roll across platforms.

Each barrel has:

barrel_x: .word <x>
barrel_y: .word <y>
barrel_vx: .word <horizontal velocity>
barrel_vy: .word <vertical velocity>

The update logic includes:

    Apply gravity to vy.

    Add vx and vy to position.

    Check for collisions with platforms or walls.

    Invert velocity if hitting a wall.

    Remove barrel if off-screen.

📈 Performance Notes

    The rendering loop is CPU-bound due to syscall overhead.

    Optimizations can be achieved by batching draws or limiting refresh rate.

    No interrupts are used — everything runs in a polling-based infinite loop.

🔧 Future Improvements

    Add multiple simultaneous barrels.

    Implement enemy collision and lives system.

    Add a simple scoring and level progression system.

    Replace MARS syscalls with memory-mapped display writes for speed.

    Introduce sound using syscall 31 (play tone).