// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed. 
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

// countを初期化
@8192 // 512 * 256 / 16
D = A
@count
M = D

// iを初期化
@i
M = 0

(WHITE)
  @i
  D = M
  @SCREEN
  A = A + D
  // スクリーンを白
  M = 0
  // indexをインクリメント
  @i
  M = M + 1

  // スクリーン全体描画完了時、処理を抜ける
  @i
  D = M
  @count
  A = D - M
  @LOOP
  A;JEQ

  @KBD
  D = M
  @WHITE
  D;JEQ // キー非押下中(Dが0なら)は、WHITEへJUMP

(BLACK)
  @i
  D = M
  @SCREEN
  A = A + D
  // スクリーンを黒
  M = -1
  // indexをインクリメント
  @i
  M = M + 1

  // スクリーン全体描画完了時、処理を抜ける
  @i
  D = M
  @count
  A = D - M
  @LOOP
  A;JEQ

  @KBD
  D = M
  @BLACK
  D;JNE // キー押下中(Dが0以外なら)は、BLACKへJUMP
(END)

@WHITE
0;JMP // 無条件で、LOOPへJUMP

(LOOP)
@LOOP
0;JMP // 無限ループで処理を終了
