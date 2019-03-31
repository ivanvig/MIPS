# Fibonacci Casero papa
# Mira como estan esos comentarios
  ORI   $t0, $0, 30 # podes comentar aca si te pinta tambien

  OR    $t1, $0, $0
  ORI   $t1, $0, 1

  OR    $t2, $0, $0
  OR    $t3, $0, $0

LOOP:
  ADDU  $t1, $t1, $t2
  OR    $t2, $0, $t1
  SW    $t1, 0($t3)
  ADDI  $t3, $t3, 1
  BNE   $t0, $t3, LOOP
