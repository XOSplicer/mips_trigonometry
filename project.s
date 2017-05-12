# System Programming Project
# Trigonomitry functions approximation

.data
ask_n:      .asciiz "Number of values n (int): "
ask_x_min:  .asciiz "Minimal value x_min (double): "
ask_x_max:  .asciiz "Maximal value x_max (double): "
tbl_header: .ascii  "| x | sin(x) | cos(x) | tan(x) |\n"
            .asciiz "| ------- | ------- | ------- | ------- |\n"
tbl_sep_l:  .asciiz "| "
tbl_sep_m:  .asciiz " | "
tbl_sep_r:  .asciiz " |\n"
wrong_msg:  .asciiz "Incorrect input, make sure n > 0 and x_min <= x_max\n"
restart_msg: .asciiz "Restarting programm ...\n"
newline:    .asciiz "\n"
.align 2
dbl_const_0: .double 0.0
dbl_2pi:	 .double 6.28318530717958647692528676655900576
dbl_pi:	 .double 3.14159265358979323846264338327950288
dbl_half_pi: .double 1.57079632679489661923132169163975144

.globl main
.text

# main #########################################
# no arguments
# no return value
# $s0 n (loop counter)
# $f20 x_i
# $f22 delta_x
# $f16 temp_f
# $f18 temp_f2
main:

  # ask for n
  li    $v0, 4      # systemcall print string
  la    $a0, ask_n
  syscall
  li    $v0, 5      # systemcall read int
  syscall
  move  $s0, $v0    # s0 = n

  # ask for x_min
  li    $v0, 4      # systemcall print string
  la    $a0, ask_x_min
  syscall
  li    $v0, 7      # systemcall read double
  syscall
  mov.d $f20, $f0   # x_i = x_min

  # ask for x_max
  li    $v0, 4      # systemcall print string
  la    $a0, ask_x_max
  syscall
  li    $v0, 7      # systemcall read double
  syscall
  mov.d $f16, $f0   # temp_f = x_max

  # test if !(x_min <= x_max) then goto error
  c.le.d $f20, $f16
  bc1f  reenter

  # test if n <= 0 then goto error
  ble   $s0, $zero, reenter

  # calculate step size
  # divide by n-1 if n>1 here to get x_max into the table
  sub.d $f16, $f16, $f20  # temp_f = x_max - x_min
  move  $t0, $s0          # t0 = n
  li    $t1, 1            # const 1
  # if (n!=1) then t0--, which is when n>1
  beq   $t0, $t1, not_dec_n
  addi  $t0, $t0, -1      # t0 = n-1
  not_dec_n:
  mtc1.d  $t0, $f18
  cvt.d.w $f18, $f18      # tempf2 = (n or n-1)
  div.d $f22, $f16, $f18  # delta_x = (x_max - x_min) / (n or n-1)

  # print table header
  li    $v0, 4      # systemcall print string
  la    $a0, tbl_header
  syscall

  loop: # loop from n down to 0

    # print table border left
    li    $v0, 4      # systemcall print string
    la    $a0, tbl_sep_l
    syscall

    # print x_i
    li    $v0, 3      # systemcall print double
    mov.d $f12, $f20
    syscall

    # print table border middle
    li    $v0, 4      # systemcall print string
    la    $a0, tbl_sep_m
    syscall

    # calc sin(x)
    mov.d $f12, $f20
    jal sin.d

    # print sin(x)
    li    $v0, 3      # systemcall print double
    mov.d $f12, $f0
    syscall

    # print table border middle
    li    $v0, 4      # systemcall print string
    la    $a0, tbl_sep_m
    syscall

    # calc cos(x)
    mov.d $f12, $f20
    jal cos.d

    # print cos(x)
    li    $v0, 3      # systemcall print double
    mov.d $f12, $f0
    syscall

    # print table border middle
    li    $v0, 4      # systemcall print string
    la    $a0, tbl_sep_m
    syscall

    # calc tan(x)
    mov.d $f12, $f20
    jal tan.d

    # print tan(x)
    li    $v0, 3      # systemcall print double
    mov.d $f12, $f0
    syscall

    # print table border rigth
    li    $v0, 4      # systemcall print string
    la    $a0, tbl_sep_r
    syscall

    add.d $f20, $f20, $f22  # x_i += delta_x
    addi  $s0, $s0, -1      # n--
    bne   $s0, $zero, loop  # loop downto 0

  #terminate program
  #li    $v0, 10     # code 10 terminates the program
  #syscall
  j restart

reenter:
  # print error message
  li    $v0, 4      # systemcall print string
  la    $a0, wrong_msg
  syscall
  # fall trough restart

restart:
  # print restart message
  li    $v0, 4      # systemcall print string
  la    $a0, restart_msg
  syscall
  j     main

# end main ##########################################
#####################################################

# tan.d #########################################
# calculate tan(x) using sin(x) / cos(x)
# argument: x: ($f12, $f13)
# return: (f0, f1)
# $f20: save x, sin(x) between calls
tan.d:
  # save $ra, ($f20, $f21) on stack
	addi 	$sp, $sp, -12
	sw		$ra, 0($sp)
	s.d		$f20, 4($sp)

  # calculate tan(x)
	mov.d $f20, $f12   # f20 = x
	jal sin.d          # calc sin(x) in f0
	mov.d $f12, $f20   # arg = x
	mov.d $f20, $f0    # f20 = sin(x)
	jal cos.d          # calc cos(x) in f0
	div.d $f0, $f20, $f0 # f0 = sin(x) / cos(x)

  # restore $ra, ($f20, $f21) from stack
	lw		$ra, 0($sp)
	l.d		$f20, 4($sp)
	addi	$sp, 12

	jr $ra
# tan.d end #########################################
#####################################################

# sin.d #########################################
# calculate sin(x) using cos(x-pi/2)
# argument x: ($f12, $f13)
# return: ($f0, $f1) (using cos.d)
# ($f2, $f3) = pi/2
sin.d:
	l.d $f2, dbl_half_pi
	sub.d $f12, $f12, $f2  # x = x-pi/2
	j cos.d                 # don't change $ra
# sin.d end #########################################
#####################################################

# cos.d #########################################
# Prepares the value for the cos0 (raw taylor) function
# argument: x: ($f12, $f13)
# return: ($f0, $f1)
# $f2: various multiples of pi
# $f4: lowest 2pi multiple of $f12
cos.d:
  # save $ra on stack
	addi 	$sp, $sp, -4
	sw		$ra, 0($sp)

	l.d $f2, dbl_const_0   # f2 = 0.0
	c.lt.d $f2, $f12       # if x<0.0 then x=-x
	bc1t cos_pos
		neg.d $f12, $f12
	cos_pos:
	l.d $f2, dbl_2pi       # f2 = 2*pi
	div.d $f4, $f12, $f2   # f4 = x / (2*pi)
	cvt.w.d $f4, $f4       # f4 = floor(x / (2*pi))
	cvt.d.w $f4, $f4
	mul.d $f4, $f4, $f2    # f4 = floor(x / (2*pi)) * 2*pi
	sub.d $f12, $f12, $f4  # x = x - floor(x / (2*pi)) * 2*pi,
                         # so f12 is now in [0;2pi)
	# Manipulating $f0 so that cos.raw gets $f0 [0;pi/2) for higher precision
	# therefore find the correct quadrant, calculate cos0 and adjust the value
	# see documentation for details
	l.d $f2, dbl_half_pi
	c.lt.d $f12, $f2
	bc1t cos_lower_half_pi
	l.d $f2, dbl_pi
	c.lt.d $f12, $f2
	bc1t cos_lower_pi
		sub.d $f12, $f12, $f2
		jal cos0
		neg.d $f0, $f0
		j cos_end
	cos_lower_pi:
    sub.d $f12, $f2, $f12
		jal cos0
		neg.d $f0, $f0
		j cos_end
	cos_lower_half_pi:
		jal cos0
	cos_end:

  # restore $ra from stack
	lw		$ra, 0($sp)
	addi	$sp, 4

	jr $ra
# cos.d end #########################################
#####################################################

# cos0 #########################################
# calculate the taylor expension of cos
# Accurate for 0 <= x <= pi/2
# argument x: ($f12, $f13)
# return: ($f0, $f1)
# $t0 = amount of approx. terms
# ($f0, $f1) = current value of cos
# ($f2, $f3) = last taylor series element without (-1)^n
# ($f4, $f5) = (-1)^n
# ($f6, $f7) = ($f0, $f1)^2
# ($f8, $f9) = n
# ($f10, $f11) = n * (n - 1)
# ($f12, $f13) = $f4 * $f6/$f10
# ($f14, $f15) = 1.0
# ($f16, $f16) = 3.0
cos0:
	li.d	$f14, 1.0   # const 1.0
	li.d	$f16, 3.0   # const 3.0
	li 		$t0, 40     # number of taylor loops, adjust here for precision vs speed
	mov.d $f0, $f14   # f0 = 1.0
	mov.d	$f2, $f0    # f2 = 1.0
	li.d 	$f4, -1.0   # f4 = -1.0
	mul.d	$f6, $f12, $f12 # f6 = x^2
	li.d 	$f8, 2.0    # f8 = n = 2.0
	cos0_loop_start:
		mov.d 	$f10, $f8        # f10 = n
		sub.d 	$f8 , $f8, $f14  # f8 = n - 1.0
		mul.d 	$f10, $f10, $f8  # f10 = n * (n-1)
		div.d 	$f2, $f2, $f10   # f2 = prev_taylor / (n*(n-1))
		mul.d 	$f2, $f2, $f6    # f2 = prev_taylor * x^2 / (n*(n-1))
		mul.d 	$f12, $f2, $f4   # x = prev_taylor * f4 * x^2 / (n*(n-1))
		add.d 	$f0, $f0, $f12   # f0 += x
		neg.d 	$f4, $f4         # f4 = -f4
		add.d 	$f8, $f8, $f16   # f8 = n + 2.0
		addi 	$t0, $t0, -2       # decrease loop variable
	bge $t0, $zero, cos0_loop_start
	jr $ra
# cos0 end #########################################
##################################################
