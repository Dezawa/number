# frozen_string_literal: true

# module Optional
# 重要：このバージョンからKIKAのデータ順変更。初期値より先に構造を載せる。
#
# module KIKA
require 'English'
module Number
  module GameTypes
    module GameType
      def game
        'KIKA'
      end

      def set_block_group(gnr, _boxes, _bx, _by, _xmax, w)
        c = -1
        while c < @size
          while infile.gets && ($LAST_READ_LINE =~ /^\s*#/ || $LAST_READ_LINE =~ /^\s*$/); end
          puts $LAST_READ_LINE if $dbg
          $LAST_READ_LINE.chop.split(sep).each do |d|
            next if /\d+/ !~ d

            c += 1
            c += 1 if w[c].nil? ##
            puts "c=#{c} d=#{d}  @size=#{@size} " if $dbg
            puts "$kika: w[c] of c is #{c}, cell=#{w[c][0]},w[c][1]=#{w[c][1]}" if $dbg
            w[c][1] << d.to_i + gnr - 1
          end
        end
        (gnr..gnr + game_scale - 1).each { |g| @groups[g] = Number::Group.new(self, g, :block, @count) }
        gnr += game_scale
        gnr
      end
    end
  end
end
