  or    $t0, $0, $0
  ori   $t1, $0, 32
  ori   $t4, $0, 0xcaca
  ori   $t5, $0, 0xcafe
LOOP:
  sb    $t5,  0($t0)
  sb    $t5,  1($t0)
  sb    $t4,  2($t0)
	sb    $t4,  3($t0)
  addi  $t0, $t0, 4
  #slt   $t2, $t0, $t1
  bne   $t1, $t0, LOOP

	or    $at, $0, $0
	or    $v0, $0, $0
	or    $v1, $0, $0
	or    $a0, $0, $0
	or    $a1, $0, $0
	or    $a2, $0, $0
	or    $a3, $0, $0
	or    $t0, $0, $0
	or    $t1, $0, $0
	or    $t2, $0, $0
	or    $t3, $0, $0
	or    $t4, $0, $0
	or    $t5, $0, $0
	or    $t6, $0, $0
	or    $t7, $0, $0
	or    $s0, $0, $0
	or    $s1, $0, $0
	or    $s2, $0, $0
	or    $s3, $0, $0
	or    $s4, $0, $0
	or    $s5, $0, $0
	or    $s6, $0, $0
	or    $s7, $0, $0
	or    $t8, $0, $0
	or    $t9, $0, $0
	or    $k0, $0, $0
	or    $k1, $0, $0
	or    $gp, $0, $0
	or    $sp, $0, $0
	or    $fp, $0, $0
	or    $ra, $0, $0

  hlt
