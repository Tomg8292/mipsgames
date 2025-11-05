############################################################
# main.asm
# Punto de entrada y game loop principal
# Mario Platformer - MARS 4.5
############################################################

.include "constants.asm"

.data
# === VARIABLES GLOBALES DEL JUEGO ===
game_state: .word STATE_PLAYING     # Estado actual del juego
score: .word 0                      # Puntuación
lives: .word INITIAL_LIVES          # Vidas restantes
camera_x: .word 0                   # Posición X de la cámara
camera_y: .word 0                   # Posición Y de la cámara

# === DATOS DE MARIO ===
mario_x: .word 1600                 # Posición X (fixed-point: 16.00 tiles)
mario_y: .word 5000                 # Posición Y (fixed-point: 50.00 tiles)
mario_velocity_x: .word 0           # Velocidad horizontal
mario_velocity_y: .word 0           # Velocidad vertical
mario_on_ground: .word 0            # 1 si está en el suelo, 0 en el aire
mario_state: .word MARIO_STATE_IDLE # Estado de animación
mario_direction: .word DIR_RIGHT    # Dirección que mira

# === ARRAYS DE ENTIDADES (punteros a heap) ===
goombas_array: .word 0              # Puntero al array de Goombas
coins_array: .word 0                # Puntero al array de monedas
map_data: .word 0                   # Puntero al mapa de tiles

# === CONTADORES ===
active_goombas: .word 0             # Cantidad de Goombas activos
active_coins: .word 0               # Cantidad de monedas activas
total_coins: .word 0                # Total de monedas en el nivel

# === STRINGS PARA UI ===
str_game_over: .asciiz "GAME OVER\n"
str_you_win: .asciiz "YOU WIN!\n"
str_score: .asciiz "Score: "
str_lives: .asciiz " Lives: "
str_newline: .asciiz "\n"

.text
.globl main
