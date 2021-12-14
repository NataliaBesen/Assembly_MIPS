.macro getInt (%dreg)
    li $v0, 5
    syscall
    move %dreg, $v0
.end_macro

.macro getFloat 
   li $v0, 6
   syscall
   .end_macro
   
.macro printCstr (%str)
.data 
mStr: .asciiz %str
.text
    li $v0, 4
    la $a0, mStr
    syscall
.end_macro

.macro exit
    li $v0, 10
    syscall
.end_macro

.data
jump_table: .word  case_0, case_1, case_2, case_3, case_4, case_5, case_6, case_7

.text
main:
	printCstr("\n Escolha uma op��o:\n")
        printCstr("1- Exibir Acumulador\n")
        printCstr("2- Zerar Acumulador\n")
        printCstr("3- Realizar Soma\n")
        printCstr("4- Realizar Subtra��o\n")
        printCstr("5- Realizar Divis�o\n")
        printCstr("6- Realizar Multiplica��o\n")
        printCstr("7- Sair do programa\n")	
 	getInt($s0)
	
	
main_switch:
	slti $t0, $s0, 8
	beq  $t0, $zero, default
	
	la   $s1, jump_table
	sll  $s0, $s0, 2
	add  $s0, $s0, $s1
	lw   $s0, 0($s0)
	jr   $s0
    case_0: 
    j main_switch_end
    case_1:
     printCstr("O resultado �:")
         li $v0, 2
         mov.s $f12, $f1 
         syscall
         j main_switch_end
    case_2:
         li $t0, 0
         mtc1 $t0, $f1
         cvt.s.w $f1, $f1
         j main_switch_end
  
    case_3:
     printCstr("Digite um n�mero:")
     getFloat
     mov.s $f3, $f0
      
      li $t0, 0
      mtc1 $t0, $f2
      c.eq.s $f1,$f2
      bc1f ,end
      printCstr("Digite outro n�mero:")
      getFloat
      add.s $f1,$f0,$f3
      j main_switch_end
      end: 
      add.s $f1, $f1, $f3
      j main_switch_end
      
      
    
    case_4:
      printCstr("Digite um n�mero:")
      getFloat
      mov.s $f3, $f0
      
      li $t0, 0
      mtc1 $t0, $f2
      c.eq.s $f1,$f2
      bc1f ,end1
      printCstr("Digite outro n�mero:")
      getFloat
      sub.s $f1,$f3,$f0
      j main_switch_end
      end1: 
      sub.s $f1, $f1, $f3
      j main_switch_end
      
    case_5:
      printCstr("Digite um n�mero:")
      getFloat
      mov.s $f3, $f0
      
      li $t0, 0
      mtc1 $t0, $f2
      c.eq.s $f1,$f2
      bc1f ,end2
      printCstr("Digite outro n�mero:")
      getFloat
      div.s $f1,$f3,$f0
      j main_switch_end
      end2: 
      div.s $f1, $f1, $f3
      j main_switch_end
    case_6:
      printCstr("Digite um n�mero:")
      getFloat
      mov.s $f3, $f0
      
      li $t0, 0
      mtc1 $t0, $f2
      c.eq.s $f1,$f2
      bc1f ,end3
      printCstr("Digite outro n�mero:")
      getFloat
      mul.s $f1,$f3,$f0
      j main_switch_end
      end3: 
      mul.s $f1, $f1, $f3
      j main_switch_end
    case_7:
       exit
    default:
        printCstr("out of range\n")
main_switch_end:

	j main
	
