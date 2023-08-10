# module Optional
module Number::GameTypes::GameType
  def game_type
    'COLLOR'
  end

  def set_optional_group(gnr, _boxes, _bx, _by, _xmax, w, infile, _sep)
    #    puts gnr
    while infile.gets !~ /^([\d\s]+$)/; end
    while $_ =~ /^([\d\s]+$)/
      if ::Regexp.last_match(1) && $_ =~ /\d/
        #        puts $_
        @groups[gnr] = Number::Group.new(self, gnr, :option, @count)
        $_.split.each  do |cell| # これらのcellがそのgrp
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
