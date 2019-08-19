#branch after load
#branch -> X -> LOAD
#loop 4 veces restando desde 8 hasta 4
  ORI $t0, $0, 8
	ORI $t1, $0, 4
  ORI $t3, $0, 1
	SW $t1, 0($t1) #mem(7-4) = 4

LOOP:
  SUBU $t0, $t0, $t3 #t0 = t0-1
  LW $t2, 0($t1) #t2 <- 4
	ADDI $t4, $t1, 1 #da igual
	BNE $t2, $t0, LOOP

	HLT
