#!/usr/bin/env ruby
# ナンプレ７のサイトに行き、DL した htmlから ゲームの盤情報をfileに書き出す
#  L 1~7, NN 01~
# 
require "./numpre7"

  def get_cells(game)
    puts game

    html = @numpre7.html(game)
    return false unless html
    cells =  html.split("</div>").select{|line| /eg-obj eg-np x/ =~ line}
    cells = cells.map{|cell| v=cell.sub(/.*>/,""); v =~ /\d/ ? v :"."}
    cells = cells.each_slice(9).to_a.transpose.flatten.join
    cells.size < 9 ? false : cells
  end
  
@numpre7 = Nampre7.new
("1".."7").each{|lvl|
  ("01".."99").each{|no|
    game = "np#{lvl}#{no}001"
    cells = get_cells(game)
    break unless cells
    open(game,"w"){|f| f.puts cells}
    
    while game.succ!
      cells = get_cells(game)
      break unless cells
      
      open(game,"w"){|f| f.puts cells}
    end
  }
}
