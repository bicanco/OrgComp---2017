
######################################################
#GRUPO 3
#nUSP	 NOME
#4471070 Fernanda Tostes Marana
#4461180 David Souza Rodrigues
#9019790 Kairo Luiz dos Santos Bonicenha
#9039292 Vinicius Volponi Ferreira
#####################################################


.data
.align 2
.word 
hash:	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1 

.align 0
#textos do menu
menu: .asciiz "Escolha a instrucao que deseja realizar\n1.Inserir\n2.Remover\n3.Buscar\n4.Imprimir\n5.Sair\n"
erromenu: .asciiz "O número não se encontra no menu\n"
inserido: .asciiz "Digite um numero para ser inserido ou -1 para voltar ao menu\n"
removido:  .asciiz "Digite um numero para ser removido ou -1 para voltar ao menu\n"
procurado: .asciiz "Digite um numero para ser procurado ou -1 para voltar ao menu\n"
imprimir: .asciiz "Tabela Hash:\n"
strntem: .asciiz "O valor digitado nao esta presente na lista. \n"
strachei: .asciiz "O valor digitado existe na lista. \n"
strerror: .asciiz "O Valor nao pode ser negativo!!\n"
stresp: .asciiz " "
strlinha: .asciiz "\n"

.text 
.globl main
	
main:

loopMain: 
	li $v0, 4
	la $a0, menu
	syscall
	
	li $v0, 5 #le um inteiro para selecionar a opção escolhida no menu
	syscall
	move $t0, $v0
	
	#verifica qual a opcao do menu escolhida
	#se a pessoa nao escolher um número dentro do menu da erro
	bltz  $t0,errom
	bgeu $t0,6,errom
	beq $t0, 1, inserir_hash
	beq $t0, 2, remover_hash
	beq $t0, 3, buscar_hash
	beq $t0, 4, imprimir_hash
	beq $t0, 5, sair
errom:
	#se o valor nao estiver no menu, printar a mensagem e voltar ao comeco do codigo
	li $v0, 4
	la $a0, erromenu
	syscall
	j loopMain
	
inserir_hash:
	li $v0, 4
	la $a0, inserido
	syscall
	
	li $v0, 5 #le um inteiro
	syscall
	
	beq $v0, -1, loopMain
	bltz $v0, numero_invalido_inserir
	
	#procedimento MOD
	#a0 eh o numero no qual vai ser calculado o mod
	move $a0, $v0 #calcula o mod
	jal mod 
	
	la $t6, hash	#le a primeira posicao da hash
	
	#calcula a poscao que vai ser inserida a nova informacao
	#i.e. posicao_inserida = pos_inicial_da_hash + 4*MOD
	mul $t5, $v0, 4	
	add $t5, $t6, $t5 
	
	#procedimento adicionar
	#$a1 posicao a ser adicionada na hash
	#$a2 informacao (valor)
	move $a1, $t5
	move $a2, $a0		
	jal adicionar
	
	
	j inserir_hash

numero_invalido_inserir:

	li $v0, 4
	la $a0, strerror
	syscall
	
	j inserir_hash
	
remover_hash:
	li $v0, 4
	la $a0, removido
	syscall	
	
	# encontrar o valor na lista
	# colocar o endereco do proximo e do anterior dentro de registradores auxiliares
	# no endereco do anterior mais 8 colocar o endereco do proximo
	# no endereco do proximo mais 0 colocar o endereco do anterior

	li $v0,5 #le o numero a ser excluido
	syscall
	
	beq $v0, -1, loopMain
	bltz $v0, numero_invalido_remover
	
	move $a0, $v0 #calcula o mod
	jal mod 
	move $a1,$a0
	
	la $t6, hash
	
	#pega a posição do numero na tabela hash
	mul $t5, $v0, 4	
	add $t5, $t6, $t5
	 

	
	#procedimento remover
	#a1 numero a ser removido
	#a2 posicao na tabela hash
	move $a2, $t5
	jal remover
	
	j remover_hash
	
remover:
	#empilha
	addi $sp, $sp, -12
	sw $a2, 8($sp)
	sw $a1, 4($sp)
	sw $ra, 0($sp)
	
	lw $t5, 0($a2)
	#percorre o vetor até achar o numero a ser removido
	beq $t5, -1, empty
	loopfind:
		lw $t3,4($t5)
		beq $t3, $a1,remove #caso o numero é encontrado vá para remove
		lw $t5, 8($t5)
		bne $t5,-1,loopfind #se o numero não for encontrado i.e. se for igual a -1
	
	
	empty:
		li $v0,4
		la $a0,strntem
		syscall
	
		j retorna_remover


	
remove:
	#pega o endereço do prox e do anterior do numero a ser excluido
	lw $a1,0($t5)
	lw $t1,8($t5)
	
	beq $a1,-1,primeiro #caso seja o primeiro da lista vá para primeiroo
	beq $t1,-1,ultimo #caso seja o ultimo da lista vá para ultimo
	#se não for nem o primeiro nem o ultimo
	#atualiza os enderecos do proximo e do anterior
	sw $t1,8($a1)
	sw $a1,0($t1)
	
	j retorna_remover
	
ultimo: #se for o ultimo apenas add o -1
	li $t2,-1
	sw $t2,8($a1)
	j retorna_remover
	
primeiro: #se for o primeiro
	  #apenas add -1 para o anterior e o proximo endereco no prox
	beq $t1,-1,unico #se o numero for o unico existente na lista
	li $t2, -1
	sw $t2, 0($t1)
	sw $t1,0($a2)
	j retorna_remover
		
unico: #se o numero for unico
	li $t7,-1
	sw $t7,0($a2)
	j retorna_remover
	
retorna_remover:
	#desempilha e retorna
	lw $a2, 8($sp)
	lw $a1, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 12
	jr $ra
numero_invalido_remover:
	li $v0, 4
	la $a0, strerror
	syscall
	j remover_hash
buscar_hash:
	li $v0, 4
	la $a0, procurado
	syscall
	
	li $v0, 5 #le um inteiro, que será buscado
	syscall
	
	beq $v0, -1, loopMain
	bltz $v0,numero_invalido_buscar
	#procedimento MOD
	#a0 eh numero no qual vai ser calculado o mod
	move $a0, $v0
	jal mod 
	move $a1,$a0
	
	#calcula a posição na tabela hash
	la $t6, hash
	mul $t5, $v0, 4	
	add $t5, $t6, $t5 
	lw $t5, 0($t5)
	
	#procedimento buscar
	#$a1 eh o numero que sera procurado na hash
	#O valor é renornado no regisrador $v1
	jal buscar
	
	j buscar_hash

buscar: #empilha
	addi $sp, $sp, -8
	sw $a1, 4($sp)
	sw $ra, 0($sp)
	
	beq $t5, -1, notfind #verifico se a lista nao esta vazia
	
	loopfind1:
		# carrego o primeiro valor da lista em $s2
		lw $s2,4($t5)
		# vejo se eh o valor que o usuario digitou
		# se for o valor eu vou para encontrei
		beq $s2, $a1,encontrei
		# se nao for o valor digitado, eu vou para a proxima posicao da lista 
		lw $t5, 8($t5)
		# se essa posicao for -1, a lista acabou 
		bne $t5,-1,loopfind1
		# se a lista acabou, nao tem o valor que o usuario digitou
	notfind:
		li $v0,1
		li $a0,-1
		syscall
		li $v1, -1
		
		# pulando uma linha
		li $v0, 4
		la $a0,strlinha
		syscall
		
		li $v0,-1
		j retorna_buscar
	encontrei:
		# preguica, se encontrar soh vou dizer que o valor esta la 
		li $v0,1
		move $a0, $a1
		syscall
		move $v1, $a0
		
		# pulando uma linha
		li $v0, 4
		la $a0,strlinha
		syscall
		move $v0,$a0
		j retorna_buscar
	
	j loopMain
retorna_buscar: #desempilha
	lw $a1, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	jr $ra
	
numero_invalido_buscar:
	li $v0, 4
	la $a0, strerror
	syscall
	j buscar_hash

imprimir_hash:
	li $v0, 4
	la $a0, imprimir
	syscall
	
	la $t0, hash
	li $t5, 0
	
loopImprimir:#imprime cada lista da hash

	beq $t5, 16, endLoopImprimir #fica no loop ate o final da hash i.e. posicao 15
	lw $t1, 0($t0)#le o primeiro enderecao da lista
	beq $t1, -1, pulaLinha
	
	#procedimento printar
	#a1 eh o primeiro endereco da lista
	move $a1, $t1
	jal printar
	
ifImprimir: #proxima lista da hash
	addi $t0, $t0, 4
	addi $t5, $t5, 1
	j loopImprimir
endLoopImprimir:#volta para a main
	j loopMain
pulaLinha:#imprime uma linha
	li $v0, 4
	la $a0, strlinha
	syscall
	j ifImprimir
	

sair:#encerra o programa
	li $v0, 10
	syscall
	
adicionar:
	addi $sp, $sp, -12 #empilha os argumentos (3 palavras)
	sw $a2, 8($sp)
	sw $a1, 4($sp)
	sw $ra, 0($sp)
	
	#ja que o sw precisa ser um registrado
	lw $s0, ($a1)
	li $t1,-1
	move $t0, $a2
	
	beq $s0,-1,addfirst # se $s0 eh -1, nao tenho nada na lista
	# encontrar o ultimo valor da lista
	move $s1,$s0
	
	#indo ate o final da lista
	loopfim:
		move $s3,$s1
		lw $s6, 4($s1)
		# se o valor da minha lista for maior que o que quero adicionar, eu troco eles
		# no final, se o primeiro valor adicionado for o maior da lista, sera como se eu adicionasse apenas ele no final varias vezes
		bgt $s6,$t0,trocaval 
continua:
		lw $s1, 8($s1)
		bne $s1,-1,loopfim

	# alocar memoria, 3 espacos
	li $v0,9
	la $a0,12
	syscall
	move $s2,$v0
	# colocar na ultima palavra do outro cara o endereco alocado sw $t1,$v0(8)
	sw $s2,8($s3)
	# colocar no primeiro espaco o valor do anterior a ele
	sw $s3,0($s2)
	# colocar no do meio o valor dele (4)
	sw $t0,4($s2)
	# colocar no ultimo o valor -1 (8)
	sw $t1,8($s2)
	j retorna_adiciona

	addfirst:
		# alocar 12 bytes de memoria
		li $v0,9
		la $a0,12
		syscall
		#salvar o endereco de memoria dessa aocacao em s0
		move $s0, $v0	
		# colocar -1 na posicao mais 0
		sw $t1, 0($s0)
		# colocar o valor digitado na posicao mais 4
		sw $t0, 4($s0)
		# colocar -1 na posicao mais 8
		sw $t1, 8($s0)
		
		sw $s0, 0($a1)
		j retorna_adiciona
	
retorna_adiciona:
	lw $a2, 8($sp)
	lw $a1, 4($sp)	#desempilha
	lw $ra, 0($sp)
	addi $sp, $sp, 8 #atualiza o valor da pilha
	jr $ra #retorna para a main
	
	
	
printar:
	addi $sp, $sp, -8 #empilha os argumentos
	sw $a1, 4($sp)
	sw $ra, 0($sp)
	
	# pegando o endereco do primeira cara da lista e pasando para s1 
	move $s1,$a1

	looprint:
		# pegando o primeiro valor registrado em s1
		lw $a0, 4($s1)
		li $v0, 1
		syscall
		# printando um espaco em branco
		li $v0, 4
		la $a0,stresp
		syscall
		# pegando o valor da proxima posicao da lista
		lw $s1, 8($s1)
		# se nao for -1 volta la pra looprint 
		bne $s1,-1,looprint

	# pulando uma linha
	li $v0, 4
	la $a0,strlinha
	syscall
	j retorna_printar

retorna_printar:
	lw $a1, 4($sp)	#desempilha
	lw $ra, 0($sp)
	addi $sp, $sp, 8 #atualiza o valor da pilha
	jr $ra #retorna para a main

mod:	addi $sp, $sp, -8 #empilha os argumentos e o endereï¿½o de retorno
	sw $a0, 4($sp)
	sw $ra, 0($sp)
	
	# $a0 Dividendo
	# $t0 quociente
	# O divisor eh fixo em 16
	#r = D - q*d ($a0 - $t0*16)
	div $t0, $a0, 16 
	mul $t0, $t0, 16
	mul $t0, $t0, -1
	add $t0, $a0, $t0
	
	move $v0, $t0 #coloca o valor de retorno do procedimento em $v0
	
	j retorna_mod
	
retorna_mod:
	lw $a0, 4($sp)	#desempilha
	lw $ra, 0($sp)
	addi $sp, $sp, 8 #atualiza o valor da pilha
	
	jr $ra #retorna
	
trocaval:
	sw $t0, 4($s1)
	move $t0,$s6
	j continua
