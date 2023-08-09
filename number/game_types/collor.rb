#module Optional
module Number::GameTypes::GameType
  def game_type
    'COLLOR'
  end
  def set_optional_group(gnr,boxes,bx,by,xmax,w,infile,sep)
      #    puts gnr
      while  infile.gets !~ /^([\d\s]+$)/;end
      while $_ =~ /^([\d\s]+$)/
        if $1 && $_ =~ /\d/
          #        puts $_
          @groups[gnr] = Number::Group.new(self,gnr,:option)
          $_.split.each{|cell|   # これらのcellがそのgrp
            ww = w.assoc(cell.to_i-1)
            ww[1] << gnr
          }
          gnr += 1
        end
        infile.gets
      end
    gnr
  end
end
