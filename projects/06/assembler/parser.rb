# 構文解析を行うモジュール
module Assembler::Parser
  A_COMMAND_PATTERN = /\A@(?<symbol>[\w|.|$|:]+)\z/
  C_COMMAND_PATTERN = /\A((?<dest>[M|D|A]|MD|AM|AD|AMD)=){0,1}(?<comp>[0|1|D|A|M|\-|!][1|D|A|M|+|\-|&]{0,1}[1|A|M|D]{0,1})(;(?<jump>JGT|JEQ|JGE|JLT|JNE|JLE|JMP)){0,1}\z/
  L_COMMAND_PATTERN = /\A\((?<label>[\w|.|$|:]+)\)\z/
  INVALID_COMMAND = 'invalid_command'

  # 入力にまだコマンドが存在するか？
  # @return [bool]
  def has_more_commands
    @next_line = trim(@file.gets)
    @next_line ? true : false
  end

  # 次のコマンドを読み、現在のコマンドにセット
  def advance
    @current_line = @next_line
    @next_line = nil
  end

  # 現在のコマンドの種類を返す
  def command_type
    @command_type = INVALID_COMMAND
    @symbol = nil
    @dest = nil
    @comp = nil
    @jump = nil
    @label = nil
    if @match_obj = A_COMMAND_PATTERN.match(@current_line)
      @symbol = @match_obj[:symbol]
      @command_type = 'A_COMMAND'
    elsif @match_obj = C_COMMAND_PATTERN.match(@current_line)
      @dest = @match_obj[:dest]
      @comp = @match_obj[:comp]
      @jump = @match_obj[:jump]
      @command_type = 'C_COMMAND'
    elsif @match_obj = L_COMMAND_PATTERN.match(@current_line)
      @label = @match_obj[:label]
      @command_type = 'L_COMMAND'
    end
    @command_type
  end

  private
    def trim(line)
      return if line.nil?
      comment_position = line.index('//')
    
      if comment_position
        line[0, comment_position].strip
      else
        line.strip
      end
    end
end
