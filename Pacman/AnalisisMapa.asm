.data
.text
.macro block
	next_Block()
	beqz $s4,skip
	la $s7,Posicao
	lw $t3,40($s7)
	beq $s3,$t3,parar # Si el comando actual es igual al anterior, detenerse, si es diferente, volver al comando anterior.
		addi $s3,$t3,0
		next_Block()
		beq $s4,1,parar
		j skip
	parar:
		addi $s3,$zero,0
	skip:
.end_macro
.macro next_Block #comando s1 x, s2 y, s3, s4 devuelve 1 para pared y 0 en caso contrario
	bne $s3,119,salida1
	subi $s2,$s2,2
	carga()
	#devuelve los valores de s2 y s1
	addi $s2,$s2,2
	j recall

	salida1:
	bne $s3,115,salida2
	addi $s2,$s2,2
	carga()
	#devuelve los valores de s2 y s1
	subi $s2,$s2,2	
	j recall
	
	salida2:
	bne $s3,97,salida3
	subi $s1,$s1,2
	carga()
	#devuelve los valores de s2 y s1
	addi $s1,$s1,2
	
	j recall
	
	salida3:
	bne $s3,100,recall
	addi $s1,$s1,2
	carga()
	#devuelve los valores de s2 y s1
	subi $s1,$s1,2
	
	recall:
		beq $s4,255,return_1 #blue = 255
		addi $s4,$zero,0
		j exit1
		return_1:
		addi $s4,$zero,1
	exit1:
.end_macro

.macro next_Block_punto #comando s1 x, s2 y, s3, s4 devuelve 1 para el punto y 0 en caso contrario
	bne $s3,119,salida1
	subi $s2,$s2,3
	carga()
	#devuelve los valores de s2 y s1
	addi $s2,$s2,3
	j recall

	salida1:
	bne $s3,115,salida2
	addi $s2,$s2,3
	carga()
	#devuelve los valores de s2 y s1
	subi $s2,$s2,3	
	j recall
	
	salida2:
	bne $s3,97,salida3
	subi $s1,$s1,3
	carga()
	#devuelve los valores de s2 y s1
	addi $s1,$s1,3
	
	j recall
	
	salida3:
	bne $s3,100,recall
	addi $s1,$s1,3
	carga()
	#devuelve los valores de s2 y s1
	subi $s1,$s1,3
	
	recall:
		beq $s4,16776960,return_1 #yellow=16776960
		addi $s4,$zero,0
		j exit1
		return_1:
		addi $s4,$zero,1
		
	exit1:
.end_macro

.macro next_Block_fruta #comando s1 x, s2 y, s3, s4 devuelve 1 para fruta y 0 en caso contrario
	
	bne $s3,119,salida1
	subi $s2,$s2,3
	carga()
	#devuelve los valores de s2 y s1
	addi $s2,$s2,3
	j recall

	salida1:
	bne $s3,115,salida2
	addi $s2,$s2,3
	carga()
	#devuelve los valores de s2 y s1
	subi $s2,$s2,3	
	j recall
	
	salida2:
	bne $s3,97,salida3
	subi $s1,$s1,3
	carga()
	#devuelve los valores de s2 y s1
	addi $s1,$s1,3
	
	j recall
	
	salida3:
	bne $s3,100,recall
	addi $s1,$s1,3
	carga()
	#devuelve los valores de s2 y s1
	subi $s1,$s1,3
	
	recall:
		beq $s4,16711680,return_1 #red=16711680
		addi $s4,$zero,0
		j exit1
		return_1:
		addi $s4,$zero,1

	exit1:
.end_macro

.macro carga #s4 con valor de color en (s1,s2)
	lw $t0, BaseAddress
	#multiplica por 4
	add $t1,$s1,$s1
	add $t1,$t1,$t1
	
	#pasar al heap
	add $t0,$t1,$t0
	
	addi $t1,$zero,0
	addi $t2,$zero,0	
	#multiplica y
	beq $s2,$zero,exit
	loop_y:
		addi $t1,$t1,256
		addi $t2,$t2,1
		bne $t2,$s2,loop_y
	
	add $t0,$t0,$t1
	lw $s4,($t0)
	exit:
.end_macro

.macro bifurcacion #input s1,s2 devuelve 1 en s4 si lo es y 0 en caso contrario
#suma en t4 cada punto que no sea un muro
	addi $t4,$zero,0
	addi $t5,$s3,0 #guarda s3
	#arriba
	addi $s3,$zero,119
	next_Block()
	beq $s4,1,next1
	addi $t4,$t4,1
	next1:
	#abajo
	addi $s3,$zero,115
	next_Block()
	beq $s4,1,next2
	addi $t4,$t4,1
	next2:
	#izq
	addi $s3,$zero,97
	next_Block()
	beq $s4,1,next3
	addi $t4,$t4,1
	next3:
	#der
	addi $s3,$zero,100
	next_Block()
	beq $s4,1,exit1
	addi $t4,$t4,1
	
	exit1:
	addi $s3,$t5,0
	bge $t4,3,si
	addi $s4,$zero,0
	j exit2
	si:
	addi $s4,$zero,1
	exit2:
.end_macro

.macro victoria
	la $t0,pontos
	lw $t1, ($t0)
	beq $t1,218,gano
	j exit
	
	gano:
	sw $zero, ($t0)
	apagar()
	j Seta
	
	exit:
.end_macro

.macro tiempo_de_powerup

	lw $t4, 60($s7)
	blt $t4,45,cont
	addi $t8, $zero, 0
	j exit
	cont: 
		addi $t4, $t4,1
		sw $t4, 60($s7)
		addi $t8,$zero,1
	exit:
.end_macro