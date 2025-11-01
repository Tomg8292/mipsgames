#Dimensiones de píxeles: pantalla de 8x8, 512x1024, comienza en 0x10040000 (heap)

.include "Disenio/mov.asm"
.include "AnalisisMapa.asm"
.include "mapa.asm"
.include "desicion_Ghost.asm"
.include "comer.asm"
.include "punto.asm"
.include "control_puntos.asm"

.data	
	#Vector de posición de personaje
	Posicao: .space 80# 5 caracteres 2 valores, x e y. 40-60 bytes son para conocer el último comando, 60-80 para encender pacman y los fantasmas del tiempo muerto
	pontos: .space 4 #Recuento de puntos
	
	#Buffer para leer tecla desde consola
	buffer: .space 2  # 1 byte para el caracter + null terminator
	
	#Mensajes
	msg_inicio: .asciiz "\n=== PAC-MAN ===\nControles: w(arriba) s(abajo) a(izquierda) d(derecha) p(pausa) q(salir)\nPresiona una tecla para comenzar: "
	msg_pausa: .asciiz "\n*** PAUSA *** Presiona una tecla para continuar: "
	msg_comando: .asciiz "\nComando (w/a/s/d/p/q): "
	msg_salir: .asciiz "\n¡Gracias por jugar!\n"
	msg_invalido: .asciiz "\nComando invalido. Usa: w/a/s/d/p/q\n"
	
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

# Mostrar mensaje de inicio
li $v0, 4
la $a0, msg_inicio
syscall

# Inicializar último comando con movimiento por defecto (derecha)
addi $t0, $zero, 100  # 'd' como comando inicial
sw $t0, 40($s7)

#Espera para empezar - USANDO CONSOLA
Espera:
	# Leer un caracter desde la consola (syscall 12)
	li $v0, 12
	syscall
	move $s3, $v0        # Guardar el caracter leído en $s3
	
	# Verificar si es un comando válido para empezar
	beq $s3, 97, Pac_Man   # 'a'
	beq $s3, 100, Pac_Man  # 'd'
	beq $s3, 115, Pac_Man  # 's'
	beq $s3, 119, Pac_Man  # 'w'
	beq $s3, 113, Salir    # 'q' para salir
	
	# Si no es válido, mostrar mensaje y pedir de nuevo
	li $v0, 4
	la $a0, msg_invalido
	syscall
	j Espera

Salir:
	# Mensaje de despedida
	li $v0, 4
	la $a0, msg_salir
	syscall
	
	# Terminar programa
	li $v0, 10
	syscall
	
Pac_Man:
	tiempo_de_powerup()
	
	# Cargar última posición
	la $s7, Posicao
	lw $s1, ($s7)       # carga x
	lw $s2, 4($s7)      # carga y
	
	# Usar el comando guardado (de la lectura anterior o inicial)
	lw $s3, 40($s7)
	
	# Mover Pac-Man
	block()
	mov_Pac_Man()
	sw $s1, 0($s7)
	sw $s2, 4($s7)
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
	beqz $s5, leer_comando
	decidir_el_color()
	decidir_Ghost()
	mov_Ghost()
	sw $s3,56($s7)
	sw $s1,32($s7)
	sw $s2,36($s7)
	comer()

leer_comando:
	# Mostrar prompt para nuevo comando
	li $v0, 4
	la $a0, msg_comando
	syscall
	
	# Leer comando desde consola (BLOQUEANTE)
	li $v0, 12
	syscall
	move $s3, $v0
	
	# Verificar comandos especiales
	beq $s3, 113, Salir        # 'q' salir
	beq $s3, 112, Pausa        # 'p' pausa
	
	# Verificar si es comando válido de movimiento
	beq $s3, 119, guardar_comando  # 'w'
	beq $s3, 97, guardar_comando   # 'a'
	beq $s3, 115, guardar_comando  # 's'
	beq $s3, 100, guardar_comando  # 'd'
	
	# Si no es válido, mostrar mensaje y mantener comando anterior
	li $v0, 4
	la $a0, msg_invalido
	syscall
	j Pac_Man

guardar_comando:
	# Guardar el nuevo comando
	la $s7, Posicao
	sw $s3, 40($s7)
	j Pac_Man

Pausa:
	# Mostrar mensaje de pausa
	li $v0, 4
	la $a0, msg_pausa
	syscall
	
	# Esperar a que presione cualquier tecla
	li $v0, 12
	syscall
	
	# Volver a pedir comando
	j leer_comando