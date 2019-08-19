#branch after instr
#BRANCH -> ADD
  ORI $t0, $0, 8
	ORI $t1, $0, 0
  ORI $t2, $0, 1

LOOP:
  SW $t1, 0($t1)
  ADDU $t1, $t1, $t2
  BNE $t1, $t0, LOOP

  HLT
