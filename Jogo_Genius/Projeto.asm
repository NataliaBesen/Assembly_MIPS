.macro cria_rb (%nome, %dsize)
.data
.align 2
%nome:
	.word  
	.word 
	.word 
	.space %dsize
.end_macro

.data 
MAX_SIZE: .word 16
ativar_cor_jump_table: .word  ativar_cor_case_0, ativar_cor_case_1, ativar_cor_case_2, ativar_cor_case_3
confere_resposta_jump_table:  .word  confere_resposta_case_0, confere_resposta_case_1, confere_resposta_case_2, confere_resposta_case_3
string1: .asciiz "Carregando...\n"
string2: .asciiz "Escolha uma opção:\n"
string3: .asciiz "1- Iniciar Jogo\n"
string4: .asciiz "2- Encerrar o programa\n"
string5: .asciiz "1- Fácil\n"
string6: .asciiz "2- Normal\n"
string7: .asciiz "3- Difícil\n"
opcao1: .asciiz "1"
opcao2: .asciiz "2"
opcao3: .asciiz "3"
resposta0: .asciiz "I"
resposta1: .asciiz "O"
resposta2: .asciiz "K"
resposta3: .asciiz "L"
obs: .asciiz "Utilize as teclas I, O, K, L em letra maiúscula para responder:\n"
fim1: .asciiz "Parabéns! Você ganhou!"
fim2: .asciiz "Você perdeu..."
.align 2
sequencia: .space 40
def_facil: .word 3, 1225
def_normal: .word 5, 1000
def_dificil: .word 7, 500
cria_rb(ringbuffer,16)

.text
#void init()
init:
#Configurar o bitmap display 256x256 resolução 8x8
	
	li $sp, 0x7fffeffc
	
	la $a0, string1
	jal print_string
	
	la $t0, ringbuffer
	sw $zero, 0($t0)
	sw $zero, 4($t0)
	sw $zero, 8($t0)
	
	jal draw_genius
	jal main
	
	jal exit

#------------------------------------------------------
	


#user program
main:	
	#som
	li $v0, 33 
	li $a0 75     #nota
	li $a1, 500  #tempo
	li $a2, 7  #instrumento
	li $a3, 126    #volume
	syscall
	
	li $v0, 33 
	li $a0 77     #nota
	li $a1, 500  #tempo
	li $a2, 5 #instrumento
	li $a3, 126    #volume
	syscall
	
	li $v0, 33 
	li $a0 79     #nota
	li $a1, 500  #tempo
	li $a2, 5   #instrumento
	li $a3, 126    #volume
	syscall
	
		
	jal menu
	jal dificuldade
 	lw $s0, ($v0)      #numero de ativações
 	lw $s1,4($v0)      #tempo de ativação
 	
 	la $a0, obs
 	jal print_string
 	
 	move $s3, $zero
 	li $s4, 5         #numero de rodadas para ganhar
 main_L0:
 	beq  $s3, $s4, main_L0_exit
 	move $a0, $s0
 	move $a1, $s1
 	jal ativar_sequencia
 	
	la $a0, ringbuffer
	move $a1, $s0
	jal ler_resposta
	
	la $a0, sequencia
	move $a1, $s0
	la $a2, ringbuffer
	jal confere_resposta
	beqz $v0, fim_do_jogo
	addiu $s3, $s3, 1
	j main_L0
	
main_L0_exit:	
	 
	 la $a0, fim1
	 jal print_string
	 #som
	li $v0, 33 
	li $a0 77    #nota
	li $a1, 500  #tempo
	li $a2, 5   #instrumento
	li $a3, 126    #volume
	syscall
	
	li $v0, 33 
	li $a0 83    #nota
	li $a1, 500 #tempo
	li $a2, 5  #instrumento
	li $a3, 126    #volume
	syscall
	
	li $v0, 33 
	li $a0 85    #nota
	li $a1, 500 #tempo
	li $a2, 5  #instrumento
	li $a3, 126    #volume
	syscall
	
	
	
	 jal main
	 
fim_do_jogo:

	la $a0, fim2
	jal print_string
	
	li $v0, 33 
	li $a0 65     #nota
	li $a1, 500  #tempo
	li $a2, 5   #instrumento
	li $a3, 126    #volume
	syscall
	
	li $v0, 33 
	li $a0 64     #nota
	li $a1, 500  #tempo
	li $a2, 5   #instrumento
	li $a3, 126    #volume
	syscall
	
	li $v0, 33 
	li $a0 63     #nota
	li $a1, 500  #tempo
	li $a2, 5  #instrumento
	li $a3, 126    #volume
	syscall
	jal main

#-----------------------------------------------	
# void exit 
exit:
	li      $v0, 10	
	syscall

#----------------------------------------------	
# void print_char(char a);
print_char:
	la $t0, 0xffff0008
	
print_char_L0:
	lw $t1, 0($t0)   # load Control register
	andi $t1, $t1, 1 # Isolo bit 0 
	beq $t1, $zero, print_char_L0
	
	sb $a0, 4($t0)   # Enviando o char para o display
	
        jr $ra
# --------------------------------------------
# void print_string (char *a);
print_string:
	addiu $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	
	move $s0, $a0
print_string_L0:
	lb $s1, ($s0) 
	move $a0, $s1
	jal print_char
	addiu $s0, $s0, 1
	bnez $s1, print_string_L0 
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addiu $sp, $sp, 16
	
        jr $ra
# ----------------------------------------------
# char getchar()
getchar:
	la $t0, 0xffff0000
	
getchar_L0:
	lw $t1, 0($t0)   # Load Control register
	andi $t1, $t1, 1 # Isolo o bit 0 do registrador control
	beq $t1, $zero, getchar_L0
	
	lb $v0, 4($t0)
	jr $ra

#------------------------------------------------
#void draw_genius()

draw_genius:
	addiu $sp, $sp, -8
	sw $s0, 0($sp)
	sw $ra, 4($sp)
	
	li $s0, 255
	
	#retangulo verde
	li $a0, 4
	li $a1, 4
	li $a2, 16
	li $a3, 16
	sll $t0, $s0, 8
	addiu $sp, $sp, -8
	sw  $t0, 0($sp)
	jal draw_rectangle
	addiu $sp, $sp, 8
	
	#retangulo vermelho
	li $a0, 4
	li $a1, 16
	li $a2, 16
	li $a3, 28
	sll $t0, $s0, 16
	addiu $sp, $sp, -8
	sw  $t0, 0($sp)
	jal draw_rectangle
	addiu $sp, $sp, 8
	
	#retangulo amarelo
	li $a0, 16
	li $a1, 4
	li $a2, 28
	li $a3, 16
	sll  $t0, $s0, 8
	add  $t0, $t0, $s0
	sll  $t0, $t0, 8
	addiu $sp, $sp, -8
	sw  $t0, 0($sp)
	jal draw_rectangle
	addiu $sp, $sp, 8
	
	#retangulo azul
	li $a0, 16
	li $a1, 16
	li $a2, 28
	li $a3, 28
	addiu $sp, $sp, -8
	sw  $s0, 0($sp)
	jal draw_rectangle
	addiu $sp, $sp, 8
	
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addiu $sp, $sp, 8
	
	jr $ra
#----------------------------------------------------------
	
#void drawRectangle(int x0, int y0, int x1, int y1, int color);
# x0<x1 e y0<y1
draw_rectangle:
	
	lw $t0, 0($sp)
	
	addiu $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $ra, 20($sp)
	
	move $s4, $t0
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
draw_rectangle_for1:
	beq $s0, $s2, draw_rectangle_for1_end
	move $t1, $s1
	draw_rectangle_for2:
		beq $t1, $s3, draw_rectangle_for2_end
		
		move $a0, $s0
		move $a1, $t1
		move $a2, $s4
		jal set_pixel
		
		addi $t1, $t1, 1
		j draw_rectangle_for2
		draw_rectangle_for2_end:
	addi $s0, $s0, 1  
	j draw_rectangle_for1
	draw_rectangle_for1_end:
	
	lw $ra, 20($sp)
	lw $s4, 16($sp)
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addiu $sp, $sp, 24
	
	jr $ra

#---------------------------------------------------------
# void setPixel(int x, int y, int color);
set_pixel:
	addiu $sp, $sp, -16
	sw    $s0, 0($sp)
	sw    $s1, 4($sp)
	sw    $ra, 8($sp)
	
	la $s0, 0x10008000
	li $s1, 32
	mul $t0, $a1, $s1  # idx_linha * numero_elementos
	add $t0, $t0, $a0  # (idx_linha * numero_elementos) + idx_coluna
	sll $t0, $t0, 2
	add $t0, $t0, $s0	  
	sw $a2, 0($t0)
	
	lw    $ra, 8($sp)
	lw    $s1, 4($sp)
	lw    $s0, 0($sp)
	addiu $sp, $sp, 16
	jr $ra
	
#-------------------------------------------------------------------------
# void menu(int opção)
menu:
	addiu $sp, $sp, -8
	sw $s0, 0($sp)
	sw $ra, 4($sp)
	
	la $a0, string2
	jal print_string
	
	la $a0, string3
	jal print_string
	
	la $a0, string4
	jal print_string
	
menu_L0:
	jal getchar
	move $s0, $v0
	bnez $s0, menu_L0_exit 
	
	j menu_L0
	
menu_L0_exit:
	
	la $t0, opcao1
	lb $t0, ($t0)
	la $t1, opcao2
	lb $t1, ($t1)
	beq $t1, $s0, exit
	bne $t0, $s0, menu
	
	lw $ra, 4($sp)
	lw $s0, 0($sp)
	addiu $sp, $sp, 8
	jr $ra

#---------------------------------------------------
#int dificuldade()       
#retorna o numero de ativações
dificuldade:
	addiu $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)
	
	la $a0, string2
	jal print_string
	
	la $a0, string5
	jal print_string
	
	la $a0, string6
	jal print_string
	
	la $a0, string7
	jal print_string
	
dificuldade_L0:
	jal getchar
	move $s0, $v0
	bnez $s0, dificuldade_L0_exit 
	
	j menu_L0
	
dificuldade_L0_exit:

	la $s1, opcao1
	lb $s1, ($s1)
	la $s2, opcao2
	lb $s2, ($s2)
	la $s3, opcao3
	lb $s3, ($s3)

	beq $s1, $s0, facil
	beq $s2, $s0, normal
	beq $s3, $s0, dificil
	j dificuldade
facil:
	la $v0, def_facil
	j dificuldade_end
normal:
	la $v0, def_normal
	j dificuldade_end
dificil:
	la $v0, def_dificil
dificuldade_end:
	
	lw $ra, 16($sp)
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addiu $sp, $sp, 24
	
	jr $ra

#------------------------------------------------------	
#void ativar_sequencia(int n_ativacoes, int tempo)
ativar_sequencia:	
	addiu $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)

	move $s0, $a0      #numero de ativações
	move $s1, $a1
	li $s3, 0
	la $s2, sequencia
ativar_sequencia_L0:
	beq $s0, $s3, ativar_sequencia_L0_exit 
	jal gerar_numero
	sw $v0, ($s2)
	move $a0, $v0  
	move $a1, $s1     #tempo da ativação  
	jal ativar_cor
	addiu $s2, $s2, 4
	addiu $s3, $s3, 1
	j ativar_sequencia_L0
ativar_sequencia_L0_exit:

	lw $ra, 16($sp)
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addiu $sp, $sp, 24
	
	jr $ra

#---------------------------------------------------------	
#int gerar_numero ()	
#gera um numero aleatorio de 0 a 3 
gerar_numero:
	
	addiu $sp, $sp, -8
	sw $s0, 0($sp)
	sw $ra, 4($sp)
	
	addi $v0, $zero, 30        # Syscall 30: System Time syscall
	syscall                  # $a0 will contain the 32 LS bits of the system time
	add $s0, $zero, $a0     # Save $a0 value in $t0 

	addi $v0, $zero, 40        # Syscall 40: Random seed
	add $a0, $zero, $zero   # Set RNG ID to 0
	add $a1, $zero, $s0     # Set Random seed to
	syscall

	addi $v0, $zero, 42        # Syscall 42: Random int range
	add $a0, $zero, $zero   # Set RNG ID to 0
	addi $a1, $zero, 4     # Set upper bound to 4 (exclusive)
	syscall                  # Generate a random number and put it in $a0
	
	
	move $v0, $a0
	
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addiu $sp, $sp, 8
	
	jr $ra

#----------------------------------------------------------------	
#void ativar_cor (int numero, int tempo)
#ativa a cor correspondente ao numero aleatorio 
	
ativar_cor:

	addiu $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	
	move $s0, $a0
	move $s1, $a1


	la   $t0, ativar_cor_jump_table
	sll  $s0, $s0, 2
	add  $s0, $s0, $t0
	lw   $s0, 0($s0)
	jr   $s0
	
    	  ativar_cor_case_0: 
    	  move $a0, $s1
	  jal acender_verde
	  j ativar_cor_switch_end
   
   	  ativar_cor_case_1:
   	  move $a0, $s1
	  jal acender_amarelo
          j ativar_cor_switch_end
          
      	  ativar_cor_case_2:
      	  move $a0, $s1
          jal acender_vermelho
  	  j ativar_cor_switch_end
  	  
    	  ativar_cor_case_3:
    	  move $a0, $s1
    	  jal acender_azul
 	  
 
ativar_cor_switch_end:

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addiu $sp, $sp, 16
	
	jr $ra

#------------------------------------------------------	
#void acender_verde(int tempo)

acender_verde:
	addiu $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	
	move $s1, $a0 #tempo de ativação
	
	#acender
	
	li $s0, 127 
	
	li $a0, 4
	li $a1, 4
	li $a2, 16
	li $a3, 16
	sll $t0, $s0, 8
	addiu $sp, $sp, -8
	sw  $t0, 0($sp)
	jal draw_rectangle
	addiu $sp, $sp, 8
	
	#som
	li $v0, 33
	li $a0 65     #nota
	move $a1, $s1  #tempo
	li $a2, 2  #instrumento
	li $a3, 126  #volume
	syscall

	#apagar
	li $s0, 255 
	
	li $a0, 4
	li $a1, 4
	li $a2, 16
	li $a3, 16
	sll $t0, $s0, 8
	addiu $sp, $sp, -8
	sw  $t0, 0($sp)
	jal draw_rectangle
	addiu $sp, $sp, 8
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addiu $sp, $sp, 12
	
	jr $ra

#-----------------------------------------------------------------	
#void acender_vermelho(int tempo)

acender_vermelho: 

	addiu $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	
	move $s1, $a0 #tempo de ativação
	
	#acender
	li $s0, 127 
	
	li $a0, 4
	li $a1, 16
	li $a2, 16
	li $a3, 28
	sll $t0, $s0, 16
	addiu $sp, $sp, -8
	sw  $t0, 0($sp)
	jal draw_rectangle
	addiu $sp, $sp, 8
	
	#som
	li $v0, 33
	li $a0, 67   #nota
	move $a1, $s1  #tempo
	li $a2, 2  #instrumento
	li $a3, 126  #volume
	syscall
	
	#apagar
	li $s0, 255
	
	li $a0, 4
	li $a1, 16
	li $a2, 16
	li $a3, 28
	sll $t0, $s0, 16
	addiu $sp, $sp, -8
	sw  $t0, 0($sp)
	jal draw_rectangle
	addiu $sp, $sp, 8
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addiu $sp, $sp, 12
	
	jr $ra

#----------------------------------------------------------	
#void acender_amarelo(int tempo)

acender_amarelo:
	addiu $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	
	move $s1, $a0 #tempo de ativação
	
	#acender
	li $s0, 127 
	
	li $a0, 16
	li $a1, 4
	li $a2, 28
	li $a3, 16
	sll  $t0, $s0, 8
	add  $t0, $t0, $s0
	sll  $t0, $t0, 8
	addiu $sp, $sp, -8
	sw  $t0, 0($sp)
	jal draw_rectangle
	addiu $sp, $sp, 8
	
	#som
	li $v0, 33
	li $a0 69    #nota
	move $a1, $s1  #tempo
	li $a2, 2  #instrumento
	li $a3, 126  #volume
	syscall
	
	#apagar
	li $s0, 255 
	
	li $a0, 16
	li $a1, 4
	li $a2, 28
	li $a3, 16
	sll  $t0, $s0, 8
	add  $t0, $t0, $s0
	sll  $t0, $t0, 8
	addiu $sp, $sp, -8
	sw  $t0, 0($sp)
	jal draw_rectangle
	addiu $sp, $sp, 8
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addiu $sp, $sp, 12
	
	jr $ra

#-----------------------------------------------------------	
# void acender_azul(int tempo)

acender_azul:
	addiu $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	
	move $s1, $a0 #tempo de ativação
	
	#acender
	li $s0, 127 
	
	li $a0, 16
	li $a1, 16
	li $a2, 28
	li $a3, 28
	addiu $sp, $sp, -8
	sw  $s0, 0($sp)
	jal draw_rectangle
	addiu $sp, $sp, 8
	
	#som
	li $v0, 33 
	li $a0 71      #nota
	move $a1, $s1  #tempo
	li $a2, 2    #instrumento
	li $a3, 126    #volume
	syscall
	
	#apagar
	li $s0, 255 
	
	li $a0, 16
	li $a1, 16
	li $a2, 28
	li $a3, 28
	addiu $sp, $sp, -8
	sw  $s0, 0($sp)
	jal draw_rectangle
	addiu $sp, $sp, 8
	
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addiu $sp, $sp, 12
	
	jr $ra
	

	
#-------------------------------------------------------------------------
#ler_resposta( t_ringbuffer * rbuf, int n_ativacoes)
ler_resposta:
	addiu $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)

	move $s0, $a0
	move $s1, $a1
	
	jal enable_keyboard_int              #libera interrupções do teclado
	
					
ler_resposta_L0:
	lw $s2, ($s0)                        # size ringbuffer
	beq $s2, $s1, ler_resposta_L0_exit   #para de ler o teclado quando o tamanho do rb for igual ao n° de interações
	j  ler_resposta_L0
ler_resposta_L0_exit:	

	lw $ra, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addiu $sp, $sp, 16

	jr $ra
	

	

#--------------------------------------------------------------------------	
# Global Interrupt Handle Routines
enable_int:
        mfc0	$t0, $12	 # record interrupt state
	ori	$t0, $t0, 0x0001 # set int enable flag
	mtc0    $t0, $12	 # Turn interrupts on.
	jr      $ra
	
disable_int:
	mfc0	$t0, $12	 # record interrupt state
	andi	$t0, $t0, 0xFFFE # clear int enable flag
	mtc0    $t0, $12         # Turn interrupts off.
	jr      $ra
#-------------------------------------------------------------------

# RX Interrupts Enable (Keyboard)
enable_keyboard_int:
	addi $sp, $sp, -8
	sw   $ra, 0($sp)
	
	jal  disable_int
	lui  $t0,0xffff
	lw   $t1,0($t0)      # read rcv ctrl
	ori  $t1,$t1,0x0002  # set the input interupt enable
	sw   $t1,0($t0)	     # update rcv ctrl
	jal  enable_int
	
	lw   $ra, 0($sp)
	addi $sp, $sp, 8
	jr   $ra

#----------------------------------------------------------------------
#bool confere_resposta(int *sequencia, int n_ativacoes, t_ringbuffer * rbuf)	
#retorna 1 para certo e 0 para errado
confere_resposta:
	addiu $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)
	
	move $s0, $a0 
	move $s1, $a1
	move $s2, $zero
	move $s3, $a2
	
confere_resposta_switch:
	beq $s1, $s2, confere_resposta_switch_end    #desvia quando acabar as ativações para verificar
	lw $t0 ($s0)                         #obtem a sequencia aleatoria mostrada
	addiu $s0, $s0, 4                    
	addiu $s2, $s2, 1
	la   $t1, confere_resposta_jump_table   
	sll  $t0, $t0, 2
	add  $t0, $t0, $t1                  
	lw   $t0, 0($t0)		   #obtem a opção do switch respectiva ao numero aleatorio
	jr   $t0
	
    	  confere_resposta_case_0: 
    	  move $a0, $s3
    	  jal rb_read                    #retorna a resposta do usuário em $v0
    	  la $t2, resposta0              
    	  lb $t2, ($t2)                  # I
    	  beq $v0, $t2, confere_resposta_switch  #se a resposta estiver correta, retorna para o inicio do switch para verificar o proximo valor
	  j confere_resposta_switch_end
   
   	  confere_resposta_case_1:
   	  move $a0, $s3
    	  jal rb_read 
    	  la $t2, resposta1
    	  lb $t2, ($t2)			# O
    	  beq $v0, $t2, confere_resposta_switch 
	  j confere_resposta_switch_end
	 
          
      	  confere_resposta_case_2:
      	  move $a0, $s3
    	  jal rb_read
    	  la $t2, resposta2
    	  lb $t2, ($t2)			# K
    	  beq $v0, $t2, confere_resposta_switch 
 	  j confere_resposta_switch_end
 	  
 	  confere_resposta_case_3:
 	  move $a0, $s3
    	  jal rb_read
    	  la $t2, resposta3
    	  lb $t2, ($t2)			# L
    	  beq $v0, $t2, confere_resposta_switch 
 	  
 	
confere_resposta_switch_end:
	seq  $v0, $s2, $s1
	
	lw $ra, 16($sp)
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addiu $sp, $sp, 24

	jr $ra


#----------------------------------------------------	
# bool rbuf_empty(t_ringbuffer * rbuf)	
rb_empty:
	lw $t0, 0($a0)
	bnez  $t0, rb_empty_else
	li $v0, 1
	jr $ra
rb_empty_else:
	li $v0, 0
	jr $ra
	
#---------------------------------------------
	
#bool rbuf_full(t_ringbuffer * rbuf)	
rb_full:
	lw $t0, 0($a0)
	la $t1, MAX_SIZE
	lw $t1,0($t1)
	bne $t0, $t1, rb_full_else
	li $v0, 1
	jr $ra
rb_full_else:
	li $v0, 0
	jr $ra
	
#---------------------------------------------

#char read(t_ringbuffer * rbuf)
# Stack size - 16b
# -----------------------
# |  old stack |  16($sp) 
# -----------------------
# |   $ra      |  12($sp)
# -----------------------
# |   $s2      |  8($sp)
# -----------------------
# |   $s1      |  4($sp)
# -----------------------
# |   $s0      |  0($sp)  
# -----------------------
#alocação   rbuf->size: $s0    rbuf->rd: $s1  MAX_SIZE: $s2 tmp: $t0   

rb_read:
	addiu $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $ra, 12($sp)
	
	jal rb_empty
	move $t0, $zero
	bnez $v0, rb_read_else
	lw $s0, 0($a0)
	lw $s1, 4($a0)
	
	sub $s0, $s0, 1
	sw $s0, 0($a0)
	add $t1, $s1, $a0
	lb $t0, 12($t1)
	
	addiu $t2, $s1, 1
	la $s2, MAX_SIZE
	lw $s2,0($s2)
	
	div $t3, $t2, $s2
	mfhi $s1
	sw $s1, 4($a0)
	
rb_read_else:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $ra, 12($sp)
	addiu $sp, $sp, 16
	move $v0, $t0
	jr $ra
	
#---------------------------------------
	
#bool write(t_ringbuffer * rbuf, char byte)
# Stack size - 16b
# -----------------------
# |  old stack |  16($sp) 
# -----------------------
# |   $ra      |  12($sp)
# -----------------------
# |   $s2      |  8($sp)
# -----------------------
# |   $s1      |  4($sp)
# -----------------------
# |   $s0      |  0($sp)  
# -----------------------
# alocação  rbuf->size: $s0    rbuf->wr: $s1   MAX_SIZE: $s2    
rb_write:

	addiu $sp, $sp, -16
	sw $ra, 12($sp)
	
	jal rb_full
	bnez $v0, rb_write_else
	
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	lw $s0, 0($a0)
	lw $s1, 8($a0)
	
	addiu $s0, $s0, 1
	sw $s0, 0($a0)
	add $t1, $a0, $s1
	sb $a1, 12($t1)
	
	addiu $t2, $s1, 1
	la $s2, MAX_SIZE
	lw $s2,0($s2)
	
	div $t3, $t2, $s2
	mfhi $s1
	sw $s1, 8($a0)
	li $t0, 1
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $ra, 12($sp)
	addiu $sp, $sp, 16
	move $v0, $t0
	jr $ra
	
	
rb_write_else:
	lw $ra, 12($sp)
	addiu $sp, $sp, 16
	move $v0, $zero
	jr $ra



#------------------------------------------------------------------

.ktext 0x80000180
interrupt:
	addiu	$sp,$sp,-16
	sw	$at,12($sp)
	sw	$t2,8($sp)
	sw	$t1,4($sp)
	sw	$t0,0($sp)

	lui     $t0,0xffff     # get address of control regs
	lw	$t1,0($t0)     # read rcv ctrl
	andi	$t1,$t1,0x0001 # extract ready bit
	beq	$t1,$0,intDone #
	lb	$t1,4($t0)     # read key
	la $a0, ringbuffer
	move $a1, $t1
	la $t3, rb_write
	jalr $t3

intDone:
	## Clear Cause register
	mfc0	$t0,$13			# get Cause register, then clear it
	mtc0	$0, $13

	## restore registers
	lw	$t0,0($sp)
	lw	$t1,4($sp)
	lw	$t2,8($sp)
	lw 	$at,12($sp)
	addiu	$sp,$sp,16
	eret			       # rtn from int and reenable ints

			
	

	
