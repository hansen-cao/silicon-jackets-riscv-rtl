_start:
	addi x1, x0, 1
	beq x1, x0, done
	beq x0, x0, done
	addi x2, x0, 5
done:
	ebreak
