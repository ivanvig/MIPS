# Fibonacci Casero papa
# Mira como estan esos comentarios
  ORI   $t0, $0, 8 # podes comentar aca si te pinta tambien
#OR    $t1, $0, $0
  ORI   $t2, $0, 1
  ORI   $t6, $0, 256

  OR    $t4, $0, $0
  OR    $t3, $0, $0
  ADDU  $t1, $t2, $t4
  OR    $t4, $0, $t2
  OR    $t2, $0, $t1
  SW    $t1, 0($t3)
  ADDI  $t3, $t3, 1
  BNE   $t0, $t3, LOOP #lo comento porke me pinta
  OR    $0, $0, $0
  OR    $0, $0, $0
  OR    $0, $0, $0
  OR    $0, $0, $0
  OR    $0, $0, $0
  OR    $0, $0, $0
	OR    $0, $0, $0
	OR    $0, $0, $0
	OR    $0, $0, $0
	OR    $0, $0, $0
	OR    $0, $0, $0
  JR    $t6
LOOP:
  ORI   $t5, $0, 20 # que onda
  JR    $t5
