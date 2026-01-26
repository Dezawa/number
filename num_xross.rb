#module Optional
class Game
  def set_optional_group(gnr,boxes,bx,by,xmax,w,infile,sep)
  #def add_xross_group(boxes,xmax,n,w,gsize) 
    return 0 if boxes.size != 1

    x,y = boxes[0].p
    base0 = y*xmax + x ;    base1 = base0 + @n -1
    (0..1).each{|g| @groups[gnr+g] =  Group.new(self,gnr+g,:xross)}
    (0..@n-1).each{|i|  
      w[base0 +(xmax+1)*i][1] << gnr
      w[base1 +(xmax-1)*i][1] << gnr+1
    }
    gnr+2  
  end
end
