# frozen_string_literal: true

# module Optional
require 'English'
module Number
  module GameTypes
    module GameType
      def game_type
        'COLLOR'
      end

      def set_optional_group(gnr, _boxes, _bx, _by, _xmax, w, infile, _sep)
        #    puts gnr
        while infile.gets !~ /^([\d\s]+$)/; end
        while $LAST_READ_LINE =~ /^([\d\s]+$)/
          if ::Regexp.last_match(1) && $LAST_READ_LINE =~ /\d/
            #        puts $_
            @groups[gnr] = Number::Group.new(self, gnr, :option, @count)
            $LAST_READ_LINE.split.each do |cell| # これらのcellがそのgrp
              ww = w.assoc(cell.to_i - 1)
              ww[1] << gnr
            end
            gnr += 1
          end
          infile.gets
        end
        gnr
      end
    end
  end
end
