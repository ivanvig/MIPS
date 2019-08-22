  ori $t0, $0, 0xaaaa
  xori $t1, $t0, 0x5555
  and $t2, $t1, $t0
  lui $t3, 0x00ca
  slti $t4, $t3, 0xcaca
  jal 20
  nor $t5, $0, $t0
  sw $t0, 0($0)
  sw $t1, 4($0)
  sw $t2, 8($0)
  sw $t3, 12($0)
  sw $t4, 16($0)
  sw $t5, 20($0)
  sw $ra, 24($0)
  hlt
  ori $t0, $0, 0x00ff
  jr $ra

