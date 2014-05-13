
;----- Instruction Registers -----------------------------------------------------
PC equ 0x110 ; Program counter (Bank2)
INSTR1 equ 0x111 ; Memory location of MSB of instruction (Bank2)
INSTR2 equ 0x112 ; Memory location of LSB of instruction (Bank2)

;---- Instructions -----------------------------------------------------
NOP2 equ H'0000' ; 0000 xxxx xxxx xxxx
ADD equ H'0001' ; 0001 aaaa bbbb cccc    Z,C     Ra = Rb + Rc
SUB equ H'0010' ; 0010 aaaa bbbb cccc    Z,C     Ra = Rb ­ Rc
AND equ H'0011' ; 0011 aaaa bbbb cccc    Z,C     Ra = Rb & Rc
IOR equ H'0100' ; 0100 aaaa bbbb cccc    Z,C     Ra = Rb | Rc
XOR equ H'0101' ; 0101 aaaa bbbb cccc    Z,C     Ra = Rb ^ Rc
RRL equ H'0110' ; 0110 aaaa 0xxx bbbb    C       Ra = Rb rotated left by 1 thru C
RRR equ H'0110' ; 0110 aaaa 1xxx bbbb    C       Ra = Rb rotated right by 1 thru C
NOT equ H'0111' ; 0111 aaaa xxxx bbbb    Z       Ra = ~Rb
MOV equ H'1000' ; 1000 aaaa 1xxx bbbb    Z       Ra = Rb
MOV equ H'1000' ; 1000 aaaa 0xxx kkkk    Z       Ra = k
LOD equ H'1001' ; 1001 aaaa 0kkk kkkk    Z       Ra = [k]
LOD equ H'1001' ; 1001 aaaa 1xxx bbbb    Z       Ra = [Rb(3:1) Rb+1]
STO equ H'1010' ; 1010 aaaa 0kkk kkkk    Z       [k] = Ra
STO equ H'1010' ; 1010 aaaa 1xxx bbbb    Z       [Ra(3:1) Ra+1] = Rb
TSC equ H'1011' ; 1011 aaaa 0xxx xxbb    -       skip next if Ra(b) = 0
TSS equ H'1011' ; 1011 aaaa 1xxx xxbb    -       skip next if Ra(b) = 1
JMP equ H'1100' ; 1100 0kkk kkkk kkkk    -       PC=k<<1 // since instructions are two bytes
JMP equ H'1100' ; 1100 1xxx xxxx aaaa    -       PC=[Ra(3:1) Ra+1]<<1
JSR equ H'1101' ; 1101 0kkk kkkk kkkk    -       PC+2->STACK_TOP; PC=k<<1
JSR equ H'1101' ; 1101 1xxx xxxx aaaa    -       PC+2->STACK_TOP; PC=[Ra(3:1) Ra+1]<<1
RET equ H'1102' ; 1110 xxxx xxxx xxxx    -       PC <- STACK_TOP





;----- Register Files -----------------------------------------------------

R15 equ 0x113 ; STATUS register [- - Z C] (bank0)
R14 equ 0x114 ; BANK SELECT register