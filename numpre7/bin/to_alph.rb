#!/usr/bin/env ruby
require 'fileutils'
# ...34.....9........6...72.4.2..3.756.........675.8..3.7.39...2........8.....26...
# というgameを
# ...AB.....C........D...EF.B.F..A.EGD.........DEG.H..A.E.AC...F........H.....FD...
# に。出てきた順に ABC...H

# 1) ./ にはdir np1 ~ np7 がある
# 2) np#{i} には file np#{i}?????? がある
# 3) fileを読み、出てきた順に A..Hに置き換え、alpa_game/np#{i}に置く

MAP = [".", nil, nil, nil, nil, nil, nil, nil, nil, nil]
base_dir = File.expand_path('..', __dir__)
dirs = ("np1".."np7").to_a
dirs.each do |dir|
  out_dir = File.join(base_dir, "game", "alpa_game", "#{dir}")
  in_dir = File.join(base_dir, "game", "#{dir}")
  FileUtils.mkdir_p(out_dir)
  
  Dir.glob("#{in_dir}/#{dir}*").each do |game|
    alpha = "@"
    line = File.read(game)
    cells = line.chomp.split("")
    map = MAP.dup
    alph_cells = 
      cells.map do |cell, idx|
      map[cell.to_i] ?  map[cell.to_i] : (alpha.succ!; map[cell.to_i] = alpha.dup)
    end.join
    out_file = game.sub(/game/, "game/alpa_game")

    open(out_file,"w"){|f| f.puts alph_cells}
  end
  #break
end
