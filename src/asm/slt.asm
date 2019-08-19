sll $0, $0, 0
or  $t0, $0, $0
ori $t3, $0, 0
ori $t1, $0, 5
LOOP:
  addi $t0, $t0, 1
  subu $t2, $t0, $t1
  bne  $t2, $0, LOOP

ori $t1, $0, 5
hlt
