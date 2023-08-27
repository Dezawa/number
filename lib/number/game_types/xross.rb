# frozen_string_literal: true

# module Optional
module Number
  module GameTypes
    # XROSSのextend
    module GameType
      def game
        'XROSS'
      end

      def optional_group(gnr, boxes, xmax, waku)
        # def add_xross_group(boxes,xmax,n,w,gsize)
        return 0 if boxes.size != 1

        # base1 = game_scale - 1
        [gnr, gnr + 1].each { |g| @groups[g] = Number::Group.new(self, g, @count, :xross) }
        # @groups[gnr] = Number::Group.new(self, gnr, @count, :xross)
        # @groups[gnr + 1] = Number::Group.new(self, gnr + 1, @count, :xross)
        (0..game_scale - 1).each do |i|
          waku.cells[(xmax + 1) * i].group_ids << gnr
          waku.cells[game_scale - 1 + (xmax - 1) * i].group_ids << gnr + 1
        end
        gnr + 2
      end
    end
  end
end
