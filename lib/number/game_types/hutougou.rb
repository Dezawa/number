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
          lrm = @cells[l].vlist.select { |v| v >= @cells[h].vlist.last }
          hrm = @cells[h].vlist.select { |v| v <= @cells[l].vlist[0] }
          lrm.size.positive? && @cells[l].rm_ability(lrm, "HUTOUGOU cell[#{l}]<cell[#{h}]")
          hrm.size.positive? && @cells[h].rm_ability(hrm, "HUTOUGOU cell[#{l}]<cell[#{h}]")
        end
      end
    end
  end
end
