// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

 // sum = 0
@R2
M = 0

(LOOP)
  @R1
  D = M
  // R1 が 0 なら(END)へJUMP。そうでないならスルー
  @END
  D;JEQ
  @R2
  D = M
  // sum + R0
  @R0
  D = D + M
  // sumに格納
  @R2
  M = D
  // R1 - 1
  @R1
  D = M - 1
  // R1に格納
  @R1
  M = D
  // 無条件で(LOOP)へJUMP
  @LOOP
  0;JMP
(END)
// 無条件で(END)へJUMP 無限ループでプログラム終了
@END
D;JEQ
