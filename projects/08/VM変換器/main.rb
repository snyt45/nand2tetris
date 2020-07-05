require "pry"

C_ARITHMETIC =  'arithmetic'
C_PUSH = 'push'
C_POP =  'pop'
C_LABEL =  'label'
C_GOTO =  'goto'
C_IF =  'if'
C_CALL =  'call'
C_FUNCTION =  'function'
C_RETURN =  'return'
INVALID_COMMAND = 'invalid_command'

class Parser

  attr_reader :current_command, :arg1, :arg2

  C_ARITHMETIC_PATTERN = /^(add|sub|neg|eq|gt|lt|and|or|not)$/
  C_PUSH_PATTERN = /^push +(constant|local|argument|this|that|temp|pointer|static) ([0-9]{1,5})$/
  C_POP_PATTERN = /^pop +(constant|local|argument|this|that|temp|pointer|static) ([0-9]{1,5})$/
  C_LABEL_PATTERN = /^label ([\w|.|$|:]+)$/
  C_GOTO_PATTERN = /^goto ([\w|.|$|:]+)$/
  C_IF_PATTERN = /^if-goto ([\w|.|$|:]+)$/
  C_CALL_PATTERN = /^call ([\w|.|$|:]+) ([0-9])$/
  C_FUNCTION_PATTERN = /^function ([\w|.|$|:]+) ([0-9])$/
  C_RETURN_PATTERN = /^return$/

  def initialize(file)
    @file = file
    @next_command = nil
    @current_command = nil
    @command_type = nil
    @arg1 = nil
    @arg2 = nil
  end


  def has_more_commands?
    next_command_set ? true : false
  end

  def advance
    current_command_set
    @next_command = nil
  end

  def command_type
    @command_type = INVALID_COMMAND
    if C_ARITHMETIC_PATTERN =~ @current_command
      @command_type = C_ARITHMETIC
      @arg1 = @current_command
    elsif C_PUSH_PATTERN =~ @current_command
      @command_type = C_PUSH
      @arg1 = $1
      @arg2 = $2
    elsif C_POP_PATTERN =~ @current_command
      @command_type = C_POP
      @arg1 = $1
      @arg2 = $2
    elsif C_LABEL_PATTERN =~ @current_command
      @command_type = C_LABEL
      @arg1 = $1
    elsif C_GOTO_PATTERN =~ @current_command
      @command_type = C_GOTO
      @arg1 = $1
    elsif C_IF_PATTERN =~ @current_command
      @command_type = C_IF
      @arg1 = $1
    elsif C_CALL_PATTERN =~ @current_command
      @command_type = C_CALL
      @arg1 = $1
      @arg2 = $2
    elsif C_FUNCTION_PATTERN =~ @current_command
      @command_type = C_FUNCTION
      @arg1 = $1
      @arg2 = $2
    elsif C_RETURN_PATTERN =~ @current_command
      @command_type = C_RETURN
    end
    @command_type
  end

  private
    def next_command_set
      @next_command = trim_return_command(@file.gets)
    end

    def current_command_set
      @current_command = @next_command
    end

    def trim_return_command(line)
      return if line.nil?
      comment_position = line.index('//')

      if comment_position
        line[0, comment_position].strip
      else
        line.strip
      end
    end
end

class CodeWriter
  SEGMENT_MAP = {
    'local' => 'LCL',
    'argument' => 'ARG',
    'this' => 'THIS',
    'that' => 'THAT',
    'pointer' => 'R3',
    'temp' => 'R5',
  }

  def initialize(filename)
    @file = nil
    @filename = nil
    @line_number = 0
    @func_call_counter = 0
  end

  def set_file(filename)
    return unless filename
    @file = File.open(filename, 'w')
  end

  def set_filename(filename)
    return unless filename
    @filename = filename
  end

  def write_init
    # SP初期化
    write('@256')
    write('D=A')
    write('@SP')
    write('M=D')
    # Sys.init実行
    write_call('Sys.init', 0)
  end

  def write_arithmetic(command)
    case command
    when 'add', 'sub'
      # 1つ目のデータをM、2つ目のデータをDに入れる
      stack_pointer_decrement
      write('A=M')
      write('D=M')
      stack_pointer_decrement
      write('A=M')
      # 1つ目のデータと2つ目のデータを計算し、結果をスタックに戻す
      if command == 'add'
        write('M=M+D')
      elsif command == 'sub'
        write('M=M-D')
      end
      stack_pointer_increment
    when 'neg'
      # 1つ前のデータをマイナスにする
      stack_pointer_decrement
      write('A=M')
      write('M=-M')
      stack_pointer_increment
    when 'eq', 'gt', 'lt'
      comp(command)
    when 'and'
      # 1つ目のデータをM、2つ目のデータをDに入れる
      stack_pointer_decrement
      write('A=M')
      write('D=M')
      stack_pointer_decrement
      write('A=M')
      # M and D
      write('M=M&D')
      stack_pointer_increment
    when 'or'
      # 1つ目のデータをM、2つ目のデータをDに入れる
      stack_pointer_decrement
      write('A=M')
      write('D=M')
      stack_pointer_decrement
      write('A=M')
      # M or D
      write('M=M|D')
      stack_pointer_increment
    when 'not'
      # 1つ前のデータを否定する
      stack_pointer_decrement
      write('A=M')
      write('M=!M')
      stack_pointer_increment
    end
  end

  def write_pushpop(command, segment, index)
    if command == C_PUSH
      case segment
      when 'constant'
        write("@#{index}")
        write('D=A')
        write('@SP')
        write('A=M')
        write('M=D')
        stack_pointer_increment
      when 'local', 'argument', 'this', 'that'
        write("@#{SEGMENT_MAP[segment]}")
        write('D=M')
        write("@#{index}")
        write('A=D+A')
        write('D=M')
        write('@SP')
        write('A=M')
        write('M=D')
        stack_pointer_increment
      when 'pointer', 'temp'
        write("@#{SEGMENT_MAP[segment]}")
        write('D=A')
        write("@#{index}")
        write('A=D+A')
        write('D=M')
        write('@SP')
        write('A=M')
        write('M=D')
        stack_pointer_increment
      when 'static'
        write("@#{@filename}.#{index}")
        write('D=M')
        write('@SP')
        write('A=M')
        write('M=D')
        stack_pointer_increment
      end
    elsif command = C_POP
      case segment
      when 'local', 'argument', 'this', 'that'
        # R13にbase+indexを保存
        write("@#{SEGMENT_MAP[segment]}")
        write('D=M')
        write("@#{index}")
        write('D=D+A')
        write('@R13')
        write('M=D')
        # R13の位置にスタックから値を格納
        stack_pointer_decrement
        write('A=M')
        write('D=M')
        write('@R13')
        write('A=M')
        write('M=D')
      when 'pointer', 'temp'
        # R13に5+indexを保存
        write("@#{SEGMENT_MAP[segment]}")
        write('D=A')
        write("@#{index}")
        write('D=D+A')
        write('@R13')
        write('M=D')
        # R13の位置にスタックから値を格納
        stack_pointer_decrement
        write('A=M')
        write('D=M')
        write('@R13')
        write('A=M')
        write('M=D')
      when 'static'
        stack_pointer_decrement
        write('A=M')
        write('D=M')
        write("@#{@filename}.#{index}")
        write('M=D')
      end
    end
  end

  def write_label(label)
    write("(#{label})")
  end

  def write_goto(label)
    write("@#{label}")
    write('0;JMP')
  end

  def write_if(label)
    stack_pointer_decrement
    write('A=M')
    write('D=M')
    write("@#{label}")
    write('D;JNE')
  end

  def write_call(function_name, num_args)
    @func_call_counter += 1
    # スタックに呼び出し側のリターンアドレスをセット
    write("@#{@filename}.#{function_name}.#{@func_call_counter}")
    write('D=A')
    write('@SP')
    write('A=M')
    write('M=D')
    stack_pointer_increment
    # スタックに呼び出し側のLCLをセット
    write('@LCL')
    write('D=M')
    write('@SP')
    write('A=M')
    write('M=D')
    stack_pointer_increment
    # スタックに呼び出し側のARGをセット
    write('@ARG')
    write('D=M')
    write('@SP')
    write('A=M')
    write('M=D')
    stack_pointer_increment
    # スタックに呼び出し側のTHISをセット
    write('@THIS')
    write('D=M')
    write('@SP')
    write('A=M')
    write('M=D')
    stack_pointer_increment
    # スタックに呼び出し側のTHATをセット
    write('@THAT')
    write('D=M')
    write('@SP')
    write('A=M')
    write('M=D')
    stack_pointer_increment
    # ARGの位置を呼び出される側の引数の最初の位置へ
    write("@#{num_args}")
    write('D=A')
    write('@5')
    write('D=D+A')
    write('@SP')
    write('D=M-D')
    write('@ARG')
    write('M=D')
    # LCLの位置を呼び出し側のTHATの次の位置へ
    write('@SP')
    write('D=M')
    write('@LCL')
    write('M=D')
    # 制御を呼び出される側の関数に移す
    write("@#{function_name}")
    write('0;JMP')
    # リターンアドレスのためのラベルを宣言
    write("(#{@filename}.#{function_name}.#{@func_call_counter})")
  end

  def write_function(function_name, num_locals)
    # 関数開始位置セット
    write("(#{function_name})")
    # ローカル変数の数をセット
    write("@#{num_locals}")
    write('D=A')
    # ローカル変数の数だけメモリ確保
    write("(#{function_name}.local_init_start)")
    write("@#{function_name}.local_init_end")
    write('D;JEQ') # ローカル変数が0なら処理終了
    write('@SP')
    write('A=M')
    write('M=0') # スタックに0セット
    stack_pointer_increment
    write('D=D-1')
    write("@#{function_name}.local_init_start")
    write('0;JMP') # 処理を繰り返す
    write("(#{function_name}.local_init_end)")
  end

  def write_return
    # R13をFRAMEとして使う
    # FRAME=LCL
    write('@LCL')
    write('D=M')
    write('@R13')
    write('M=D')
    # R14をRETとして使う
    # RET=FRAME-5
    write('@LCL')
    write('D=M')
    write('@5')
    write('D=D-A')
    write('A=D')
    write('D=M')
    write('@R14')
    write('M=D')
    # ARGの位置にスタックから結果を格納
    # *ARG=POP()
    stack_pointer_decrement
    write('A=M')
    write('D=M')
    write('@ARG')
    write('A=M')
    write('M=D')
    # SP=ARG+1
    write('@ARG')
    write('D=M')
    write('@SP')
    write('M=D+1')
    # THAT=*(FRAME-1)
    write('@R13')
    write('D=M')
    write('@1')
    write('D=D-A')
    write('A=D')
    write('D=M')
    write('@THAT')
    write('M=D')
    # THIS=*(FRAME-2)
    write('@R13')
    write('D=M')
    write('@2')
    write('D=D-A')
    write('A=D')
    write('D=M')
    write('@THIS')
    write('M=D')
    # ARG=*(FRAME-3)
    write('@R13')
    write('D=M')
    write('@3')
    write('D=D-A')
    write('A=D')
    write('D=M')
    write('@ARG')
    write('M=D')
    # LCL=*(FRAME-4)
    write('@R13')
    write('D=M')
    write('@4')
    write('D=D-A')
    write('A=D')
    write('D=M')
    write('@LCL')
    write('M=D')
    # GOTO RET
    write('@R14')
    write('A=M')
    write('0;JMP')
  end

  private
    def write(str)
      @file.puts(str)
    end

    def stack_pointer_increment
      write('@SP')
      write('M=M+1') # SP=SP+1
    end

    def stack_pointer_decrement
      write('@SP')
      write('M=M-1') # SP=SP-1
    end

    def comp(command)
      # 戻ってくるアドレスを保存
      write("@$#{@line_number}")
      write('D=A')
      write('@R13')
      write('M=D')
      # 1つ目のデータ - 2つ目のデータの結果をスタックに戻す
      stack_pointer_decrement
      write('A=M')
      write('D=M')
      stack_pointer_decrement
      write('A=M')
      write('D=M-D')
      write("@true#{@line_number}")
      # true条件に合致したら、@trueにジャンプ
      if command == 'eq'
        write('D;JEQ')
      elsif command == 'gt'
        write('D;JGT')
      elsif command == 'lt'
        write('D;JLT')
      end
      write("@false#{@line_number}")
      write('0;JMP') # true条件にマッチしなければ、強制的に@falseにジャンプ
      # 比較結果をスタックに戻して、アドレスに戻る
      # (true)
      write("(true#{@line_number})")
      write('@SP')
      write('A=M')
      write('M=-1') # trueを表す-1
      write('@R13')
      write('A=M')
      write('0;JMP') # $1にジャンプ
      # (false)
      write("(false#{@line_number})")
      write('@SP')
      write('A=M')
      write('M=0') # falseを表す0
      write('@R13')
      write('A=M')
      write('0;JMP') # $1にジャンプ
      # ($1)
      write("($#{@line_number})")
      stack_pointer_increment

      @line_number += 1
    end

end 


# メインルーチン

# VMtranslator usage
#   $ ruby main.rb source
#   source = Xxx.vim (1つの.vmファイル)
#     => Xxx.asm
#   source = Xxx (1つ以上の.vmファイルを含んだディレクトリ)
#     => Xxx
#         └Xxx.asm


ARGV.each do |filename|
  if !File.exist?(filename)
    puts "ファイルまたはディレクトリではありません"
  end

  # 出力ファイル名取得
  out_filename = "#{filename[0, filename.length - File.extname(filename).length]}.asm"

  filename_array = []
  # ファイル
  if File.file?(filename)
    filename_array << filename
  # ディレクトリ
  else
    Dir.foreach(filename) do |f_name|
      next if !(f_name =~ /^*.vm$/)
      filename_array << "#{filename}/#{f_name}"
    end
  end

  code_writer = CodeWriter.new(nil)
  code_writer.set_file(out_filename)

  is_first = true

  filename_array.each do |filename|
    file = File.open(filename, 'r')
    # ファイル名加工
    dir_position = filename.index('/')
    if dir_position
      filename = filename[(dir_position + 1)..-1]
    end

    code_writer.set_filename(filename)
    # VMの初期化
    code_writer.write_init if is_first

    parser = Parser.new(file)

    while parser.has_more_commands?
      parser.advance

      case parser.command_type
      when 'arithmetic'
        code_writer.write_arithmetic(parser.arg1)
      when 'push', 'pop'
        code_writer.write_pushpop(parser.command_type, parser.arg1, parser.arg2)
      when 'label'
        code_writer.write_label(parser.arg1)
      when 'goto'
        code_writer.write_goto(parser.arg1)
      when 'if'
        code_writer.write_if(parser.arg1)
      when 'call'
        code_writer.write_call(parser.arg1, parser.arg2)
      when 'function'
        code_writer.write_function(parser.arg1, parser.arg2)
      when 'return'
        code_writer.write_return
      else
        puts 'invalid_command'
      end
    end

    file.close
    is_first = false
  end
end

