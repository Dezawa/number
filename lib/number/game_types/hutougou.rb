# frozen_string_literal: true

require 'English'
module Number
  module GameTypes
    # 不等号のextemd
    module GameType
      def game
        'HUTOUGOU'
      end

      # module Optional
      def optional_struct(_sep, _game_scale, infile)
        while infile.gets && ($LAST_READ_LINE =~ /^\s*#/ || $LAST_READ_LINE =~ /^\s*$/); end
        @arrows = []
        while $LAST_READ_LINE =~ /\d/
          a = []
          $LAST_READ_LINE.split.each { |c| a << c.to_i - 1 }
          @arrows << a.dup
          infile.gets
        end
        @neigh -= @arrows
        # p $neigh
        # p @arrows
      end
      # end

      def optional_test
        @arrows.each do |l, h|
          rm_bility_from_lower_cell(l, h)
          rm_bility_from_higher_cell(l, h)
        end
      end

      def rm_bility_from_lower_cell(low, high)
        lrm = @cells[low].vlist.select { |v| v >= @cells[high].vlist.last }
        lrm.size.positive? && @cells[low].rm_ability(lrm, "HUTOUGOU cell[#{low}]<cell[#{high}]")
      end

      def rm_bility_from_higher_cell(low, high)
        hrm = @cells[high].vlist.select { |v| v <= @cells[low].vlist[0] }
        hrm.size.positive? && @cells[high].rm_ability(hrm, "HUTOUGOU cell[#{low}]<cell[#{high}]")
      end
    end
  end
end
