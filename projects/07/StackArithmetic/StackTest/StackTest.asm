@17
D=A
@SP
A=M
M=D
@SP
M=M+1
@17
D=A
@SP
A=M
M=D
@SP
M=M+1
@$0
D=A
@R13
M=D
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
D=M-D
@true0
D;JEQ
@false0
0;JMP
(true0)
@SP
A=M
M=-1
@R13
A=M
0;JMP
(false0)
@SP
A=M
M=0
@R13
A=M
0;JMP
($0)
@SP
M=M+1
@17
D=A
@SP
A=M
M=D
@SP
M=M+1
@16
D=A
@SP
A=M
M=D
@SP
M=M+1
@$1
D=A
@R13
M=D
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
D=M-D
@true1
D;JEQ
@false1
0;JMP
(true1)
@SP
A=M
M=-1
@R13
A=M
0;JMP
(false1)
@SP
A=M
M=0
@R13
A=M
0;JMP
($1)
@SP
M=M+1
@16
D=A
@SP
A=M
M=D
@SP
M=M+1
@17
D=A
@SP
A=M
M=D
@SP
M=M+1
@$2
D=A
@R13
M=D
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
D=M-D
@true2
D;JEQ
@false2
0;JMP
(true2)
@SP
A=M
M=-1
@R13
A=M
0;JMP
(false2)
@SP
A=M
M=0
@R13
A=M
0;JMP
($2)
@SP
M=M+1
@892
D=A
@SP
A=M
M=D
@SP
M=M+1
@891
D=A
@SP
A=M
M=D
@SP
M=M+1
@$3
D=A
@R13
M=D
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
D=M-D
@true3
D;JLT
@false3
0;JMP
(true3)
@SP
A=M
M=-1
@R13
A=M
0;JMP
(false3)
@SP
A=M
M=0
@R13
A=M
0;JMP
($3)
@SP
M=M+1
@891
D=A
@SP
A=M
M=D
@SP
M=M+1
@892
D=A
@SP
A=M
M=D
@SP
M=M+1
@$4
D=A
@R13
M=D
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
D=M-D
@true4
D;JLT
@false4
0;JMP
(true4)
@SP
A=M
M=-1
@R13
A=M
0;JMP
(false4)
@SP
A=M
M=0
@R13
A=M
0;JMP
($4)
@SP
M=M+1
@891
D=A
@SP
A=M
M=D
@SP
M=M+1
@891
D=A
@SP
A=M
M=D
@SP
M=M+1
@$5
D=A
@R13
M=D
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
D=M-D
@true5
D;JLT
@false5
0;JMP
(true5)
@SP
A=M
M=-1
@R13
A=M
0;JMP
(false5)
@SP
A=M
M=0
@R13
A=M
0;JMP
($5)
@SP
M=M+1
@32767
D=A
@SP
A=M
M=D
@SP
M=M+1
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1
@$6
D=A
@R13
M=D
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
D=M-D
@true6
D;JGT
@false6
0;JMP
(true6)
@SP
A=M
M=-1
@R13
A=M
0;JMP
(false6)
@SP
A=M
M=0
@R13
A=M
0;JMP
($6)
@SP
M=M+1
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1
@32767
D=A
@SP
A=M
M=D
@SP
M=M+1
@$7
D=A
@R13
M=D
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
D=M-D
@true7
D;JGT
@false7
0;JMP
(true7)
@SP
A=M
M=-1
@R13
A=M
0;JMP
(false7)
@SP
A=M
M=0
@R13
A=M
0;JMP
($7)
@SP
M=M+1
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1
@$8
D=A
@R13
M=D
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
D=M-D
@true8
D;JGT
@false8
0;JMP
(true8)
@SP
A=M
M=-1
@R13
A=M
0;JMP
(false8)
@SP
A=M
M=0
@R13
A=M
0;JMP
($8)
@SP
M=M+1
@57
D=A
@SP
A=M
M=D
@SP
M=M+1
@31
D=A
@SP
A=M
M=D
@SP
M=M+1
@53
D=A
@SP
A=M
M=D
@SP
M=M+1
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
M=M+D
@SP
M=M+1
@112
D=A
@SP
A=M
M=D
@SP
M=M+1
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
M=M-D
@SP
M=M+1
@SP
M=M-1
A=M
M=-M
@SP
M=M+1
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
M=M&D
@SP
M=M+1
@82
D=A
@SP
A=M
M=D
@SP
M=M+1
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
M=M|D
@SP
M=M+1
@SP
M=M-1
A=M
M=!M
@SP
M=M+1
