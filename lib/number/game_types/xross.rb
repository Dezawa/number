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

        xross_groups(gnr)
        xross_cells(cells, gnr, xmax)
        gnr + 2
      end

      def xross_groups(gnr)
        @groups[gnr] = Number::Group.new(self, gnr, @count, :xross)
        @groups[gnr + 1] = Number::Group.new(self, gnr + 1, @count, :xross)
      end

      def xross_cells(cells, gnr, xmax)
        (0...game_scale).each do |i|
          cells[(xmax + 1) * i].group_ids << gnr
          cells[game_scale - 1 + (xmax - 1) * i].group_ids << gnr + 1
        end
      end
    end
  end
end
