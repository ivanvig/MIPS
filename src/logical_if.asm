      ori    $t3, 
	    lw     $t0, 0($gp)        # fetch i
	    lw     $t1, 4($gp)        # fetch N
	    slt    $t1, $t0, $t1      # set $t1 to 1 if $t0 < $t1, to 0 otherwise
	    beq    $t1, $zero, skip   # branch if result of slt is 0 (i.e., !(i<N))
	    sll    $t0, $t0, 2        # i as a byte offset
	    add    $t0, $t0, $gp      # &A[i] - 28
	    sw     $0, 28($t0)     # A[i] = 0
skip:
      hlt
