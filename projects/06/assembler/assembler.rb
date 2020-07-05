require "pry"

class Assembler
  require './parser'
  require './code'
  require './symbol_table'

  include Parser
  include Code

  # ファイル初期化
  def self.file_init
    file = File.open(ARGV[0])
    obj = new(file)
  end

  # 初期化
  def initialize(file)
    @file = file
  end

  # シンボルテーブルの作成
  def symbol_table_create
    @table = SymbolTable.new
    while has_more_commands do
      advance

      if command_type == 'L_COMMAND'
        # ラベルシンボルならテーブルに追加
          @table.add_entry(@label, @table.rom_address) unless @table.contains(@symbol)
      elsif command_type == INVALID_COMMAND
        next
      else
        # ROMアドレスに1加算
        @table.rom_address += 1
      end
    end
    @file.close
    @table
  rescue => e
    puts 'シンボルテーブル作成時にエラーが発生しました。'
    puts "ErrorClass: #{e.class.to_s}, ErrorMessage: #{e.message.to_s}, ErrorBacktrace: #{e.backtrace.to_s}"
  end

  # 機械語作成
  def machine_code_create(symbol_table)
    begin
      @binary_code = []

      while has_more_commands do
        # 次のコマンドを読み、現在のコマンドにセット
        advance
        # 機械語のバイナリコード生成
        if command_type == 'A_COMMAND'
          if @symbol =~ /\A\d+\z/
            # 数字の場合
            symbol = @symbol.to_i
          else
            if symbol_table.contains(@symbol)
              # すでに存在している変数の場合
              symbol = symbol_table.get_address(@symbol)
            else
              # 新しい変数の場合
              symbol_table.add_entry(@symbol, symbol_table.ram_address) 
              symbol_table.ram_address += 1
              symbol = symbol_table.get_address(@symbol)
            end
          end
          @binary_code << sprintf("%016b", symbol)
        elsif command_type == 'C_COMMAND'
          @binary_code << "111#{comp(@comp)}#{dest(@dest)}#{jump(@jump)}"
        end
      end
      @file.close
      @binary_code
    rescue => e
      puts 'コンパイル実行時にエラーが発生しました。'
      puts "ErrorClass: #{e.class.to_s}, ErrorMessage: #{e.message.to_s}, ErrorBacktrace: #{e.backtrace.to_s}"
    end
  end

  def symbol_table
    @table.symbol_table
  end

  def file_name
    dot_position = @file.path.rindex('.')
    @file.path[0, dot_position].strip
  end
end


binding.pry
##############################
# メインプログラム
##############################

# ファイル初期化・読込（1回目）
symbol_table = Assembler.file_init.symbol_table_create
# ファイル初期化・読込（2回目）
binary_code = Assembler.file_init.machine_code_create(symbol_table)

# 機械語書込
out_file = File.open("./#{Assembler.file_init.file_name}.hack", 'w')

binary_code.each do |code|
  out_file.puts(code)
end

out_file.close
