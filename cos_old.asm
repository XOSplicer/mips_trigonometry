# First SPIM Assignment

# Start with data declarations
#
.data
dbl_const_1: .double 1.0
dbl_const_0: .double 0.0
dbl_2pi:	.double 6.28318530717958647692528676655900576
dbl_pi:		.double 3.14159265358979323846264338327950288
dbl_half_pi:.double 1.57079632679489661923132169163975144
dbl_max_uint:.double 4294967296.0

.align 2

.globl main
.text

main:
	li $v0, 7
	syscall
	jal tan.d
	mov.d $f12, $f2
	li $v0, 3
	syscall
	li $v0, 10
	syscall

	

tan.d:
	move $s4, $ra
	mov.d $f14, $f0
	jal sin.d
	mov.d $f0, $f14
	mov.d $f14, $f2
	jal cos.d
	div.d $f2, $f14, $f2
	move $ra, $s4
	jr $ra
sin.d:
	l.d $f2, dbl_half_pi
	sub.d $f0, $f0, $f2
	j cos.d
#Prepares the value for the cos.raw function
#x: ($f0, $f1)
#return: ($f2, $f3)
#Accurate for 0 <= x <= pi/2
cos.d:
	move $s3, $ra
	l.d $f2, dbl_const_0
	c.lt.d $f0, $f2
	bc1t cos_pos
		neg.d $f0, $f0
	cos_pos:
	l.d $f2, dbl_2pi
	div.d $f4, $f0, $f2
	cvt.w.d $f4, $f4
	cvt.d.w $f4, $f4
	mul.d $f4, $f4, $f2
	sub.d $f0, $f0, $f4 #f0 is now in [0;2pi)
	#Manipulating $f0 so that cos.raw gets $f0 [0;pi/2) for higher precision
	l.d $f2, dbl_half_pi
	c.lt.d $f0, $f2
	bc1t cos_lower_half_pi
	l.d $f2, dbl_pi
	c.lt.d $f0, $f2
	bc1t cos_lower_pi
		sub.d $f0, $f0, $f2
		jal cos.raw
		neg.d $f0, $f0
		j cos_end
	cos_lower_pi:
		jal cos.raw
		neg.d $f2, $f2
		j cos_end
	cos_lower_half_pi:
		jal cos.raw
		j cos_end
	l.d $f4, dbl_pi
	cos_end:
	move $ra, $s3
	jr $ra
#x: ($f0, $f1)
#return: ($f2, $f3)
#Accurate for 0 <= x <= pi/2
cos.raw:
	move $s2, $ra
	l.d $f12, dbl_const_0
	mov.d $f4, $f0
	li $s0, 6 					#value of n, counting down to 0 (inclusive)
	l.d $f10, dbl_const_1		#the value of (-1)^n
	and $t0, $s0, 1
	beq $t0, $zero, cos_loop_start
		neg.d $f10, $f10
	cos_loop_start:
	blt $s0, $zero, cos_loop_end
		mov.d $f2, $f4
		li $t0, 2
		multu $s0, $t0
		mflo $s1				#2n
		move $a0, $s1
		jal fac
		mtc1.d $v1, $f6
		mtc1.d $v0, $f8			#v0 is irrelevant if n <= 6 (which should give us enough precision)
		cvt.d.w $f6, $f6		#lower part of (2n)! -> $f6
		move $a0, $s1
		jal exp.d				#x^(2n) -> $f0
		div.d $f8, $f0, $f6		#x^(2n)/(2n)! -> $f8
		mul.d $f8, $f10, $f8	#(-1)^n * x^(2n)/(2n)! -> $f8
		add.d $f12, $f12, $f8	#Add this iteration
		neg.d $f10, $f10
		addi $s0, $s0, -1
	j cos_loop_start
	cos_loop_end:
	mov.d $f2, $f12
	move $ra, $s2
	jr $ra
#Calculates n!
#Return: ($v0, $v1)
#n: $a0
#Accurate for n <= 20
fac:
	li $v1, 1
	move $v0, $zero
	move $t0, $v1
	fac_loop_start:
	ble $a0, $t0, fac_loop_end
		multu $v1, $a0
		mflo $v1
		mfhi $t2
		multu $v0, $a0
		mflo $t3
		mfhi $t4
		add $v0, $t2, $t3
		addi $a0, -1
	j fac_loop_start
	fac_loop_end:
	jr $ra

#Using $f2, $f4
#Calculates x^n, a is double, n is integer
#Reference: https://en.wikipedia.org/wiki/Exponentiation_by_squaring
#Return: $f0
#x: $f2
#n: $a0
exp.d:
	li $t0, 1 				#In this routine, $t0 is 1
	l.d $f0, dbl_const_1	#$f0 is y, and also the constant 1 at the beginning
	bne $a0, $zero, exp_not_zero
		jr $ra
	exp_not_zero:
	bgt $a0, $zero, exp_greater_zero
		addi $t1, $zero, -1
		xor $a0, $a0, $t1
		div.d $f2, $f0, $f2
	exp_greater_zero:
	exp_loop_start:
	ble $a0, $t0 exp_loop_end
		and $t2, $a0, $t0
		li $t3, 2
		bne $t2, $zero, exp_not_even
			mul.d $f2, $f2, $f2
			j exp_even_end
		exp_not_even:
			mul.d $f0, $f2, $f0
			mul.d $f2, $f2, $f2
			addi $a0, $a0, -1
		exp_even_end:
		div $a0, $a0, $t3
	j exp_loop_start
	exp_loop_end:
	mul.d $f0, $f2, $f0
	jr $ra
	

