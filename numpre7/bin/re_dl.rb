#!/usr/bin/env ruby
require_relative "./numpre7"

# 1) ./ にはdir np1 ~ np7 がある
# 2) np#{i} には file np#{i}?????? がある
# 3) ../numpre7 には ファイル game_number_level#{i} がある
# 4) game_number_level#{i} は head -2 すると次のようなデータ
# 1 101001 101002 101003 101004 101005 101006 101007 101008 101009 101010
# 2 102001 102002 102003 102004 102005 102006 102007 102008 102009 102010
# １カラムは行番号。2カラム以降がデータ
# やりたいこと
# i = 1..7 で loop
# game_number_level#{i} を読み データ 例えば no="101001" に対して
# game = "np#{no}" とし
# ファイル "./np#{i}/game" が有ったら next、ない時は
#   def bord(html_str) で処理し
# 得られた bord_str = bord(html_str) を file "./np#{i}/#{game}"に書き出す
#
#
numpre7 = Numpre7.new
base_dir = File.expand_path('..', __dir__)

(1..7).each do |i|
  level_file = File.join(base_dir, "game_number_level#{i}")
  out_dir    = File.join(base_dir, 'game', "np#{i}")

  File.readlines(level_file).each do |line|
    _row, *nos = line.split

    nos.each do |no|
      game = "np#{no}"
      out_file = "#{out_dir}/#{game}"
      #pp out_file
      # 既にあればスキップ
      next if File.exist?(out_file)

      print "#{game} "
      html_str = numpre7.html(game)
      next unless html_str

      bord_str = numpre7.bord(html_str)
      next unless bord_str

      File.open(out_file, "w") { |f| f.puts bord_str }
      puts "saved #{out_file}"
    end
  end
end

numpre7.close
