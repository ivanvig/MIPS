  or    $t0, $0, $0
  ori   $t1, $0, 2048
  ori   $t4, $0, 65535
  ori   $t5, $0, 0xaaaa
LOOP:
  sh    $t4,  0($t0)
  sh    $t5,  2($t0)
  addi  $t0, $t0, 4
  slt   $t2, $t0, $t1
  bne   $t2, $0, LOOP

  or    $t0, $0, $0
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
