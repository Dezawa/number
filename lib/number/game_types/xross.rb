# frozen_string_literal: true

# module Optional
module Number
  module GameTypes
    # XROSSのextend
    module GameType
      def game
        'XROSS'
      end

      def optional_group(gnr, boxes, xmax, cells)
        return 0 if boxes.size != 1

        @groups[gnr] = Number::Group.new(self, gnr, @count, :xross)
        @groups[gnr + 1] = Number::Group.new(self, gnr + 1, @count, :xross)
        (0..game_scale - 1).each do |i|
          cells[(xmax + 1) * i].group_ids << gnr
          cells[game_scale - 1 + (xmax - 1) * i].group_ids << gnr + 1
        end
        gnr + 2
      end
    end
  end
end
