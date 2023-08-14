# frozen_string_literal: true

require 'English'
module Number
  module GameTypes
    module GameType
      def game_type
        'HUTOUGOU'
      end

      # module Optional
      def optional_struct(_sep, _n, infile)
        while infile.gets && ($LAST_READ_LINE =~ /^\s*#/ || $LAST_READ_LINE =~ /^\s*$/); end
        @arrows = []
        while $LAST_READ_LINE =~ /\d/
          a = []
          $LAST_READ_LINE.split.each { |c| a << c.to_i }
          @arrows << a.dup
          infile.gets
        end
        @neigh -= @arrows
        # p $neigh
        # p @arrows
      end
      # end

      def optional_test
        @arrows.each do |arw|
          l = arw[0]
          h = arw[1]
          llist = @cells[l].vlist
          hlist = @cells[h].vlist
          lrm = @cells[l].vlist.select { |v| v >= hlist.last }
          hrm = @cells[h].vlist.select { |v| v <= llist[0] }
          lrm.size.positive? && @cells[l].rmAbility(lrm, "HUTOUGOU cell[#{l}]<cell[#{h}]")
          hrm.size.positive? && @cells[h].rmAbility(hrm, "HUTOUGOU cell[#{l}]<cell[#{h}]")
        end
      end
    end
  end
end
