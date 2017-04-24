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
newline:    .asciiz "\n"
.align 2

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

  # calculate step size
  # TODO maybe divide by n-1 here to get x_max into the table
  sub.d $f16, $f16, $f20  # temp_f = x_max - x_min
  mtc1.d  $s0, $f18
  cvt.d.w $f18, $f18      # tempf2 = n
  div.d $f22, $f16, $f18  # delta_x = (x_max - x_min) / n

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
  li    $v0, 10     # code 10 terminates the program
  syscall
# end main ##########################################


sin.d:
  mov.d $f0, $f12   # just a dummy
  jr $ra

cos.d:
  mov.d $f0, $f12   # just a dummy
  jr $ra

tan.d:
  mov.d $f0, $f12   # just a dummy
  jr $ra
