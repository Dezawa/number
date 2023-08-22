# frozen_string_literal: true

# module Optional
# 重要：このバージョンからKIKAのデータ順変更。初期値より先に構造を載せる。
#
# module KIKA
require 'English'
module Number
  module GameTypes
    # 幾何のextend
    module GameType
      def game
        'KIKA'
      end

      def optional_group(gnr, _boxes, _xmax, waku)
        # set_block_group(gnr, _boxes, _group_width, _group_hight, _xmax, waku)
        c = -1
        while c < @size
          while infile.gets && ($LAST_READ_LINE =~ /^\s*#/ || $LAST_READ_LINE =~ /^\s*$/); end
          puts $LAST_READ_LINE if $dbg
          $LAST_READ_LINE.chop.split(sep).each do |d|
            next if /\d+/ !~ d

            c += 1
            c += 1 if waku.cells[c].nil? ##
            puts "c=#{c} d=#{d}  @size=#{@size} " if $dbg
            puts "$kika: waku.cells[c] of c is #{c}, cell=#{w[c][0]},waku.cells[c].group_ids=#{w[c][1]}" if $dbg
            waku.cells[c].group_ids << d.to_i + gnr - 1
          end
        end
        (gnr..gnr + game_scale - 1).each { |g| @groups[g] = Number::Group.new(self, g, @count, :block) }
        gnr += game_scale
        gnr
      end
    end
  end
end
