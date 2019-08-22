  ori $t0, $0, 0xcaca
  sb $t0, 0($0)
  sb $t0, 1($0)
  lhu $t1, 0($0)
  #slt $t3, $t0, $t1
  bne $t3, $0, ACA
  ori $t2, $0, 0xfafa
  sw $t2, 4($0)
ACA:
  hlt
