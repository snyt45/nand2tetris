require "pry"

INVALID_TOKEN = "invalid_token"
KEYWORD_TOKEN = "keyword_token"
SYMBOL_TOKEN = "symbol_token"
INT_CONST_TOKEN = "int_const_token"
STRING_CONST_TOKEN = "string_const_token"
IDENTIFIER_TOKEN = "identifier_token"

class JackAnalyzer

  def initialize
    @source = ARGV[0]
  end

  # 起動する
  def self.run
    self.new.execute
  end

  # 実行する
  def execute
    puts "=================="
    puts "EXECUTE START."
    puts "=================="

    logic_start

    puts "=================="
    puts "EXECUTE END."
    puts "=================="
  end

  # ロジックを開始する
  def logic_start
    # 1ファイルずつ処理
    target_abspath_list.each do |f|
      in_file = File.open(f, "r")
      out_file_name = "#{File.dirname(f)}/#{File.basename(f, ".jack")}.xml"
      out_file = File.open(out_file_name, 'w')
      engine = CompilationEngine.new(in_file, out_file)
      engine.compile_start
      out_file.close
      in_file.close

      #while tokenizer.has_more_tokens?
      #  tokenizer.advance

      #  token_type = tokenizer.token_type
      #  if token_type == "keyword_token"
      #    puts "#{tokenizer.current_token} => keyword"
      #  elsif token_type == "symbol_token"
      #    puts "#{tokenizer.current_token} => symbol"
      #  elsif token_type == "int_const_token"
      #    puts "#{tokenizer.current_token} => int_const"
      #  elsif token_type == "string_const_token"
      #    puts "#{tokenizer.current_token} => string_const"
      #  elsif token_type == "identifier_token"
      #    puts "#{tokenizer.current_token} => identifier"
      #  elsif token_type == "invalid_token"
      #    puts "#{tokenizer.current_token} => invalid"
      #  end
      #end

      puts "| INPUT_FILENAME  | #{f}"
      puts "| OUTPUT_FILENAME | #{out_file_name}"
    end
  end

  private

  # 処理対象の絶対パスの配列を返す
  def target_abspath_list
    if !File.exist?(@source)
      puts "Invalid file. Please specify the correct file."
      return
    end
    puts "ーーーーーーーーーーーーーーーー"
    puts "| INPUT_SOURCE | #{@source}"
    puts "| FILE_TYPE    | #{File.ftype(@source)}"
    puts "ーーーーーーーーーーーーーーーー"

    target_list = []
    case File.ftype(@source)
    when "file"
      target = File.absolute_path(@source)
      target_list << target
    when "directory"
      file_list = Dir::entries(@source)
      file_list.each do |f|
        next if !(File.extname(f) == ".jack")
        target = File.absolute_path(f)
        target_list << target
      end
    else
      puts "Specify the file name or directory name."
      return
    end
    target_list
  end
end

class JackTokenizer
  KEYWORD_PATTERN = /^class|constructor|function|method|field|static|var|int|char|boolean|void|true|false|null|this|let|do|if|else|while|return$/
  SYMBOL_PATTERN = /^\{|\}|\(|\)|[|]|\.|,|;|\+|-|\*|\/|&|\||<|>|=|~$/
  IDENTIFIER_PATTERN = /^\w+$/
  INT_CONST_PATTERN = /^[1-3]?[0-2]?[0-7]?[0-6]?[0-7]$/
  STRING_CONST_PATTERN = /^\"\w\"$/

  def initialize(file)
    @file = file
  end

  def current_token
    @current_token
  end

  def has_more_tokens?
    @next_token = get_token
    @next_token ? true : false
  end

  def advance
    @current_token = @next_token
    @next_token = nil
  end

  def token_type
    @token_type = INVALID_TOKEN
    if KEYWORD_PATTERN =~ @current_token
      @token_type = KEYWORD_TOKEN
    elsif SYMBOL_PATTERN =~ @current_token
      @token_type = SYMBOL_TOKEN
    elsif IDENTIFIER_PATTERN =~ @current_token
      @token_type = IDENTIFIER_TOKEN
    elsif INT_CONST_PATTERN =~ @current_token
      @token_type = INT_CONST_TOKEN
    elsif STRING_CONST_PATTERN =~ @current_token
      @token_type = STRING_CONST_TOKEN
    end
    @token_type
  end

  private

  def get_token
    is_token = false
    is_comment = false
    is_comment_type_1 = false
    is_comment_type_2 = false
    token = ""
    temp_char = ""

    # 1文字ずつ文字を読み取り、トークン取得
    while !is_token
      if @is_temp_token
        char = @temp_token
        @is_temp_token = false
      else
        char = @file.getc
      end

      return if char.nil?

      # コメントモード中は全ての文字を無視する
      if is_comment
        # 改行がきたらコメント終わりとする
        if is_comment_type_1
          if /\R/ =~ char
            is_comment = false
            is_comment_type_1 = false
          end
        # 連続で*/がきたらコメント終わりとする
        elsif is_comment_type_2
          # *がきたら
          elsif /\*/ =~ char
            temp_char += char
          # *の後に、/がきたらコメント終わりとする
          elsif /\*/ =~ temp_char && /\// =~ char
            is_comment = false
            is_comment_type_2 = false
          else
            # *の後に、/以外の文字がきたら初期化
            temp_char = "" 
        end
      # シンボルなら
      elsif SYMBOL_PATTERN =~ char
        # シンボルがスラッシュなら
        if /\// =~ char
          if temp_char.empty?
            temp_char += char 
            next
          end
          # スラッシュの後にスラッシュが続いたらコメントモードに入る
          if /\// =~ temp_char && /\// =~ char
            is_comment = true
            is_comment_type_1 = true
            temp_char = ""
          # スラッシュの後にアスタリスクが続いたらコメントモードに入る
          elsif /\// =~ temp_char && /\*/ =~ char
            is_comment = true
            is_comment_type_2 = true
            temp_char = ""
          end
        # シンボルがスラッシュ以外なら
        else
          # 一時文字が空でなければ、その文字をトークンとする
          unless temp_char.empty?
            token = temp_char
            # この場合、charがなかったことになるため、一時的に@temp_tokenに保存する
            @temp_token = char
            @is_temp_token = true
            is_token = true
          # 一時文字が空なら、charをトークンとする
          else
            token = char
            @temp_token = ""
            is_token = true
          end
        end
      # アルファベットの小文字、大文字、アンダースコア、数字がきたら
      elsif /\w/ =~ char
        temp_char += char
      # スペースがきたら
      elsif /\s/ =~ char
        # 一時文字が空でなければ、その文字をトークンとする
        unless temp_char.empty?
          token = temp_char
          is_token = true
        end
      end
    end
    token
  end
end

class CompilationEngine
  def initialize(in_file, out_file)
    @tokenizer = JackTokenizer.new(in_file)
    @out_file = out_file
  end

  def compile_start
    next_token
    binding.pry
    if @current_token == 'class'
      compile_class
    else
      puts 'error'
    end
  end

  def compile_class
    write_tag('class')
    write_tag_value('keyword', 'class')
    write_tag('class', true)
  end

  def compile_class_var_dec
  end

  def compile_subroutine
  end

  def compile_parameter_list
  end

  def compile_var_dec
  end

  def compile_statements
  end

  def compile_do
  end

  def compile_let
  end

  def compile_while
  end

  def compile_return
  end

  def compile_if
  end

  def compile_expression
  end

  def compile_term
  end

  def compile_expression_list
  end

  private

  def next_token
    if @tokenizer.has_more_tokens?
      @tokenizer.advance
      @token_type = @tokenizer.token_type
      @current_token = @tokenizer.current_token
    else
      # トークンがnilになったら終了させる処理を書く？
    end
  end

  # タグを出力する
  def write_tag(tag_name, end_tag = false)
    if end_tag
      @out_file.puts "</#{tag_name}>"
    else
      @out_file.puts "<#{tag_name}>"
    end
  end

  def write_tag_value(tag_name, value)
    @out_file.puts  "<#{tag_name}> #{value} </#{tag_name}>"
  end
end

JackAnalyzer.run
