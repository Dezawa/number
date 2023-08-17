# frozen_string_literal: true

# module Optional
module Number
  module GameTypes
    # XROSSのextend
    module GameType
      def game
        'XROSS'
      end

      def set_optional_group(gnr, boxes, _group_width, _group_hight, xmax, waku)
        # def add_xross_group(boxes,xmax,n,w,gsize)
        return 0 if boxes.size != 1

        x, y = boxes[0].p
        base0 = y * xmax + x
        base1 = base0 + game_scale - 1
        2.times { |g| @groups[gnr + g] = Number::Group.new(self, gnr + g, @count, :xross) }
        (0..game_scale - 1).each  do |i|
          waku[base0 + (xmax + 1) * i][1] << gnr
          waku[base1 + (xmax - 1) * i][1] << gnr + 1
        end
        gnr + 2
      end
    end
  end
end
