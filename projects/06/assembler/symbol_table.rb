# シンボルとメモリアドレスの対応テーブルを作成するクラス
class SymbolTable

  attr_accessor :symbol_table, :ram_address, :rom_address

  # 初期化
  def initialize
    @symbol_table = {}
    @symbol_table['SP']     = 0
    @symbol_table['LCL']    = 1
    @symbol_table['ARG']    = 2
    @symbol_table['THIS']   = 3
    @symbol_table['THAT']   = 4
    @symbol_table['R0']     = 0
    @symbol_table['R1']     = 1
    @symbol_table['R2']     = 2
    @symbol_table['R3']     = 3
    @symbol_table['R4']     = 4
    @symbol_table['R5']     = 5
    @symbol_table['R6']     = 6
    @symbol_table['R7']     = 7
    @symbol_table['R8']     = 8
    @symbol_table['R9']     = 9
    @symbol_table['R10']    = 10
    @symbol_table['R11']    = 11
    @symbol_table['R12']    = 12
    @symbol_table['R13']    = 13
    @symbol_table['R14']    = 14
    @symbol_table['R15']    = 15
    @symbol_table['SCREEN'] = 16384
    @symbol_table['KBD']    = 24576
    @ram_address             = 16
    @rom_address             = 0
  end

  # シンボルとメモリアドレスのハッシュを追加
  def add_entry(symbol, address)
    @symbol_table[symbol] = address
  end

  # 与えられたシンボルと一致するか？
  def contains(symbol)
    @symbol_table.include?(symbol)
  end

  # シンボルに対応するメモリアドレスを返す
  def get_address(symbol)
    @symbol_table[symbol]
  end
end
