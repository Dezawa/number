# frozen_string_literal: true

# module Optional
module Number
  module GameTypes
    module GameType
      def game_type
        'XROSS'
      end

      def set_optional_group(gnr, boxes, _bx, _by, xmax, w)
        # def add_xross_group(boxes,xmax,n,w,gsize)
        return 0 if boxes.size != 1

        x, y = boxes[0].p
        base0 = y * xmax + x
        base1 = base0 + @n - 1
        2.times { |g| @groups[gnr + g] = Number::Group.new(self, gnr + g, :xross, @count) }
        (0..@n - 1).each  do |i|
          w[base0 + (xmax + 1) * i][1] << gnr
          w[base1 + (xmax - 1) * i][1] << gnr + 1
        end
        gnr + 2
      end
    end
  end
end
