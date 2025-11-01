#Dimensiones de píxeles: pantalla de 8x8, 512x1024, comienza en 0x10040000 (heap)

.include "Disenio/mov.asm"
.include "AnalisisMapa.asm"
.include "mapa.asm"
.include "desicion_Ghost.asm"
.include "comer.asm"
.include "punto.asm"

.data	
	#Address IO - CORREGIDO
	KeyboardControl: .word 0xFFFF0000
	KeyboardData: .word 0xFFFF0004
	
	#Vector de posición de personaje
	Posicao: .space 80# 5 caracteres 2 valores, x e y. 40-60 bytes son para conocer el último comando, 60-80 para encender pacman y los fantasmas del tiempo muerto
	pontos: .space 4 #Recuento de puntos
	#colores
	white: .word 0xFFFFFF
	black: .word 0x000000
 	yellow: .word 0xFFFF00
 	red: .word 0xFF0000
 	pink: .word 0xFF1493
 	green:.word 0x00FF00
 	blue: .word 0x0000FF
 	blue_ghost: .word 0x80CEE1

.text
###############inicio juego
Seta:

la $s7,Posicao
#pacman
addi $t1,$zero,31 #posicion x inicial
sw $t1,($s7)
addi $t1,$zero,61 #posicion y inicial
sw $t1,4($s7)
#fantasma 1
addi $t1,$zero,4 #posicion x inicial
sw $t1,8($s7)
addi $t1,$zero,4 #posicion y inicial
sw $t1,12($s7)
#fantasma 2
addi $t1,$zero,58 #posicion x inicial
sw $t1,16($s7)
addi $t1,$zero,4 #posicion y inicial
sw $t1,20($s7)
#fantasma 3
addi $t1,$zero,4 #posicion x inicial
sw $t1,24($s7)
addi $t1,$zero,76 #posicion y inicial
sw $t1,28($s7)
#fantasma 4
addi $t1,$zero,58 #posicion x inicial
sw $t1,32($s7)
addi $t1,$zero,76 #posicion y inicial
sw $t1,36($s7)

#movimiento inicial dos fantasmas + estado vivo
#fantasma1
addi $s3,$zero,115
sw $s3,44($s7)
addi $s3,$zero,15
sw $s3,64($s7)

#fantasma2
addi $s3,$zero,115
sw $s3,48($s7)
addi $s3,$zero,10
sw $s3,68($s7)

#fantasma3
addi $s3,$zero,100
sw $s3,52($s7)
addi $s3,$zero,5
sw $s3,72($s7)

#fantasma4
addi $s3,$zero,97
sw $s3,56($s7)
addi $s3,$zero,0
sw $s3,76($s7)


set_mapa()
set_puntos()
#dibujar personajes
addi $s1,$zero,31
addi $s2,$zero,61
addi $s3,$zero,97
draw_Pac_Man()
	
#pink, green, red, white
#fantasma1
addi $s1, $zero, 4
addi $s2, $zero, 4
lw $s0, pink
draw_Ghost()

#fantasma2
addi $s1, $zero, 58
addi $s2, $zero, 4
lw $s0, green
draw_Ghost()

#fantasma3
addi $s1, $zero, 4
addi $s2, $zero, 76
lw $s0, red
draw_Ghost()

#fantasma4
addi $s1, $zero, 58
addi $s2, $zero, 76
lw $s0, white
draw_Ghost()

#zera keyboard - CORREGIDO: limpiar ambos registros
lui $t0, 0xFFFF
sw $zero, 0($t0)  # Limpiar control
sw $zero, 4($t0)  # Limpiar data

addi $t0, $zero, 45
sw $t0, 60($s7)


#Espera para empezar - CORREGIDO CON DELAY
Espera:
	# Agregar delay para no saturar el procesador
	li $v0, 32
	li $a0, 50      # 50ms de delay
	syscall
	
	# Leer del teclado correctamente
	lui $t0, 0xFFFF
	lw $t1, 0($t0)      # Leer receiver control
	andi $t1, $t1, 1    # Chequear bit ready
	beqz $t1, Espera    # Si no hay tecla, seguir esperando
	
	lw $s3, 4($t0)      # Leer tecla
	beq $s3,97,Pac_Man
	beq $s3,100,Pac_Man
	beq $s3,115,Pac_Man
	beq $s3,119,Pac_Man
	j Espera
	
Pac_Man:
	tiempo_de_powerup()
	
	# Leer teclado correctamente - CORREGIDO
	lui $t0, 0xFFFF
	lw $t1, 0($t0)      # Leer receiver control
	andi $t1, $t1, 1    # Chequear bit ready
	beqz $t1, no_key    # Si no hay tecla, usar el comando anterior
	
	lw $s3, 4($t0)      # Leer tecla
	beq $s3,112,Espera  # Pausa
	j process_movement
	
no_key:
	# No hay tecla nueva, cargar el último comando
	la $s7,Posicao
	lw $s3,40($s7)      # Cargar último comando
	
process_movement:
	la $s7,Posicao
	lw $s1,($s7) #carga x
	lw $s2,4($s7)#carga y
	block()
	mov_Pac_Man()
	sw $s3,40($s7)#Posición de almacenamiento del Pacman
	sw $s1,0($s7)
	sw $s2,4($s7)
	comer()
	victoria()

Fantasma_1:
	la $s7,Posicao
	lw $s1,8($s7)#carga x
	lw $s2,12($s7)#carga y;
	#valor a pasar a la función
	addi $s6,$zero,44
	reaparecer()
	beqz $s5, Fantasma_2
	decidir_el_color()
	decidir_Ghost()
	mov_Ghost()
	sw $s3,44($s7)
	sw $s1,8($s7)
	sw $s2,12($s7)
	comer()

Fantasma_2:
	la $s7,Posicao
	lw $s1,16($s7)#carga x
	lw $s2,20($s7)#carga y
	addi $s6,$zero,48
	reaparecer()
	beqz $s5, Fantasma_3
	decidir_el_color()
	decidir_Ghost()
	mov_Ghost()
	sw $s3,48($s7)
	sw $s1,16($s7)
	sw $s2,20($s7)
	comer()

Fantasma_3:
	la $s7,Posicao
	lw $s1,24($s7)#carga x
	lw $s2,28($s7)#carga y
	addi $s6,$zero,52
	reaparecer()
	beqz $s5, Fantasma_4
	decidir_el_color()
	decidir_Ghost()
	mov_Ghost()
	sw $s3,52($s7)
	sw $s1,24($s7)
	sw $s2,28($s7)
	comer()

Fantasma_4:
	la $s7,Posicao
	lw $s1,32($s7)#carga x
	lw $s2,36($s7)#carga y
	addi $s6,$zero,56
	reaparecer()
	beqz $s5, fimmov
	decidir_el_color()
	decidir_Ghost()
	mov_Ghost()
	sw $s3,56($s7)
	sw $s1,32($s7)
	sw $s2,36($s7)
	comer()

fimmov:
	# DELAY OBLIGATORIO - CORREGIDO: Ahora siempre se ejecuta
	li $v0,32
	li $a0,75
	syscall
	
	j Pac_Man
