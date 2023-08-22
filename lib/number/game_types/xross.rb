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
        pp [boxes.size, gnr]
        return 0 if boxes.size != 1

        x, y = boxes[0].p
        base0 = y * xmax + x
        base1 = base0 + game_scale - 1
        [gnr, gnr + 1].each { |g| @groups[g] = Number::Group.new(self, g, @count, :xross) }
        (0..game_scale - 1).each do |i|
          waku.cells[base0 + (xmax + 1) * i].group_ids << gnr
          waku.cells[base1 + (xmax - 1) * i].group_ids << gnr + 1
        end
        gnr + 2
      end
    end
  end
end
