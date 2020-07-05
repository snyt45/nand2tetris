require "pry"

C_ARITHMETIC =  'arithmetic'
C_PUSH = 'push'
C_POP =  'pop'
INVALID_COMMAND = 'invalid_command'


class Parser

  attr_reader :current_command, :arg1, :arg2

  C_ARITHMETIC_PATTERN = /^(add|sub|neg|eq|gt|lt|and|or|not)$/
  C_PUSH_PATTERN = /^push +(constant|local|argument|this|that|temp|pointer|static) ([0-9]{1,5})$/ 
  C_POP_PATTERN = /^pop +(constant|local|argument|this|that|temp|pointer|static) ([0-9]{1,5})$/ 

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
    'temp' => 'R5'
  }

  def initialize(filename)
    @file = nil
    @filename = nil
    @line_number = 0
    self.set_filename(filename)
  end

  def set_filename(filename)
    return unless filename
    @file.close if @file
    @file = File.open(filename, 'w')
    @filename = filename
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

code_writer = CodeWriter.new(nil)
ARGV.each do |filename|
  if !File.exist?(filename)
    puts "ファイルまたはディレクトリではありません"
  end

  if !File.file?(filename)
    puts "Argument Error" 
  end

  file = File.open(filename, 'r')
  parser = Parser.new(file)
  out_filename = "#{filename[0, filename.length - File.extname(filename).length]}.asm"
  code_writer.set_filename(out_filename)

  while parser.has_more_commands?
    parser.advance

    case parser.command_type
    when 'arithmetic'
      code_writer.write_arithmetic(parser.arg1)
    when 'push', 'pop'
      code_writer.write_pushpop(parser.command_type, parser.arg1, parser.arg2)
    else
      puts 'invalid_command'
    end
  end

  file.close
end

