# Fibonacci Casero papa
# Mira como estan esos comentarios
  ORI   $t0, $0, 10 # podes comentar aca si te pinta tambien
#OR    $t1, $0, $0
  ORI   $t2, $0, 1
  OR    $t4, $0, $0
  OR    $t3, $0, $0
  ADDU  $t1, $t2, $t4
  		HLT
  OR    $t4, $0, $t2
  OR    $t2, $0, $t1
  SW    $t1, 0($t3)
  ADDI  $t3, $t3, 1
  BNE   $t0, $t3, LOOP #lo comento porke me pinta
  J     22
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
  J     128
LOOP:
  ORI   $t5, $0, 16 # que onda
  JR    $t5
