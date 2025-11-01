.data
.text
.macro decidir_Ghost
	beq $t8,1,huir
	decision_Persigue()
	j exit
	huir:
	decision_huir()
	exit:
.end_macro
.macro decision_Persigue #s1 x ghost s2 y ghost devuelve el comando s3 s6 valor del vector donde se almacena el comando anterior
#Sistema: primero elige si moverte en x o y 50/50, luego sigue a Pac-Man 4/5 o ve en la derecci�n opuesta 1/5
#Solo toma una decisi�n para una bifurcaci�n
	bifurcacion()
	beqz $s4,anterior
	#Cargar PacMan
	la $t0,Posicao
	lw $t1,($t0)
	lw $t2,4($t0)
	##
	comeco:
	#genera un n�mero aleatorio
	li $v0,42
	li $a1,2
	syscall
	beqz $a0,irX
	#va a Y
	li $v0,42
	li $a1,5
	syscall
	beqz $a0,segueY
	beq $a0,1,segueY
	beq $a0,2,segueY
	beq $a0,3,segueY
	#va en la derecci�n opuesta
	bgt $t2,$s2,arriba
		#abajo
		addi $s3,$zero,115
		j exit
		arriba:
		addi $s3,$zero,119
		j exit
	
	segueY:
	bgt $t2,$s2,abajo
		#arriba
		addi $s3,$zero,119
		j exit
		abajo:
		addi $s3,$zero,115
		j exit	
	irX:
	li $v0,42
	li $a1,3
	syscall
	beqz $a0,segue
	beq $a0,1,segue
	beq $a0,2,segue
	beq $a0,3,segue
	#va en la derecci�n opuesta
	bgt $t1,$s1,izq
		#Der
		addi $s3,$zero,100
		j exit
		izq:
		addi $s3,$zero,97
		j exit
	
	segue:
	bgt $t1,$s1,der
		#izq
		addi $s3,$zero,97
		j exit
		der:
		addi $s3,$zero,100
		j exit
	#####
	anterior:
	add $t0,$s7,$s6
	lw $s3,($t0)
	esquina()
	j exitfunc
	########
	exit:
	#Si $s3 no es v�lido, busque otro.
	next_Block()
	beq $s4,1,comeco
	exitfunc:
.end_macro
.macro decision_huir #s1 x ghost s2 y ghost devuelve el comando s3 s6 valor del vector donde se almacena el comando anterior
#Sistema: primero elige si te mueves en x o y 50/50, luego si huyes de Pac-Man 4/5 o vas en la derecci�n 1/5
#Solo toma una decisi�n para una bifurcaci�n
	bifurcacion()
	beqz $s4,anterior
	#Cargar PacMan
	la $t0,Posicao
	lw $t1,($t0)
	lw $t2,4($t0)
	##
	comeco:
	#genera un n�mero aleatorio
	li $v0,42
	li $a1,2
	syscall
	beqz $a0,irX
	#va a Y
	li $v0,42
	li $a1,5
	syscall
	beqz $a0,huirY
	beq $a0,1,huirY
	beq $a0,2,huirY
	beq $a0,3,huirY
	#Va hacia Pac-Man
	bgt $t2,$s2,abajo
		#arriba
		addi $s3,$zero,119
		j exit
		abajo:
		addi $s3,$zero,115
		j exit	
	
	huirY:
	bgt $t2,$s2,arriba
		#abajo
		addi $s3,$zero,115
		j exit
		arriba:
		addi $s3,$zero,119
		j exit
	irX:
	li $v0,42
	li $a1,3
	syscall
	beqz $a0,huir
	beq $a0,1,huir
	beq $a0,2,huir
	beq $a0,3,huir
	#Va hacia Pac-Man
	bgt $t1,$s1,der
		#izq
		addi $s3,$zero,97
		j exit
		der:
		addi $s3,$zero,100
		j exit
	huir:
	bgt $t1,$s1,izq
		#Der
		addi $s3,$zero,100
		j exit
		izq:
		addi $s3,$zero,97
		j exit
	
	#####
	anterior:
	add $t0,$s7,$s6
	lw $s3,($t0)
	esquina()
	j exitfunc
	########
	exit:
	#Si $s3 no es v�lido, busque otro.
	next_Block()
	beq $s4,1,comeco
	exitfunc:
.end_macro
.macro esquina #Comando s1 s2,s3 usado, devuelve en s3 un nuevo comando
#Si hay una pared al frente y no es una bifurcaci�n, esto �ltimo se garantiza en la funci�n decisao_Ghost
	next_Block()
	beqz $s4,exit
	#Si viene en y, retorna en x v�lido
	beq $s3,115,MoveX
	beq $s3,119,MoveX
	
		addi $s3,$zero,115
		next_Block()
		beqz $s4,va115
			addi $s3,$zero,119
			j exit
		va115:
			addi $s3,$zero,115
			j exit
	MoveX:
		addi $s3,$zero,100
		next_Block()
		beqz $s4,va100
			addi $s3,$zero,97
			j exit
		va100:
			addi $s3,$zero,100
			j exit
	exit:
.end_macro

.macro decidir_el_color #s6 el fantasma, s5 power up
	beq $t8,1,powered
	#fantasma1
	bne $s6,44,fantasma2
		lw $s0,pink
		j exit
	fantasma2:
	bne $s6,48,fantasma3
		lw $s0,green
		j exit
	fantasma3:
	bne $s6,52,fantasma4
		lw $s0,red
		j exit
	fantasma4:
	bne $s6,56, exit
		lw $s0,white
		j exit
	powered:
	lw $s0,blue_ghost
	exit:
.end_macro
