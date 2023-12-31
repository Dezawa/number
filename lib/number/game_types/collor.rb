# frozen_string_literal: true

# module Optional
require 'English'
module Number
  module GameTypes
    # COLLORのextend
    module GameType
      def game
        'COLLOR'
      end

      def optional_group(gnr, _boxes, _xmax, cells)
        #    puts gnr
        while infile.gets !~ /^([\d\s]+$)/; end
        while $LAST_READ_LINE =~ /^([\d\s]+$)/
          if ::Regexp.last_match(1) && $LAST_READ_LINE =~ /\d/
            #        puts $_
            @groups[gnr] = Number::Group.new(self, gnr, @count, :option)
            $LAST_READ_LINE.split.each do |cell| # これらのcellがそのgrp
              ww = cells.assoc(cell.to_i - 1)
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
