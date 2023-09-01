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

      def optional_group(gnr, _boxes, _xmax, cells)
        # set_block_group(gnr, _boxes, _group_width, _group_hight, _xmax, waku)
        cell_id = -1
        while cell_id < @size
          line = gets_skip_comment(infile)
          line.chop.split(sep).each do |block|
            next if /\d+/ !~ block

            cell_id = cell_c_is_on_block(gnr, cells, cell_id, block)
          end
        end
        (gnr..gnr + game_scale - 1).each { |g| @groups[g] = Number::Group.new(self, g, @count, :block) }
        gnr += game_scale
        gnr
      end

      def cell_c_is_on_block(gnr, cells, cell_id, block)
        cell_id += 1
        cell_id += 1 if cells[cell_id].nil? ##
        cells[cell_id].group_ids << block.to_i + gnr - 1
        cell_id
      end
    end
  end
end
