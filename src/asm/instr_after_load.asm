#instruction after load
#ADD -> LOAD
  ORI $t0, $0, 8
  ORI $t1, $0, 4
  ORI $t2, $0, 4

  SW $t0, 0($t1)
  LW $t3, 0($t2)
  ADDU $t4, $t3, $t2
  HLT
