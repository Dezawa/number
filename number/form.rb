class Number::Form < Array
  def initialize(p_form,n)
    @n = n
    if p_form.class == Array
      # [ w,xmax,ymax ]
      w,xmax,ymax = p_form
      (0..ymax-2).each{|i| self.push(w[i * xmax,xmax].map{|ww| ww ? ww[0] : nil})}
      @lines=ymax-1
      #pp self
    elsif p_form.class == String
      file=open(p_form)
      while file.gets && ( $_ =~ /^\s*#/ || $_ =~ /^\s*$/) ; end
      @lines = $_.to_i
      #9 -3 9 -3 9 -3 9
      #45*3 
      #-6 9 -3 9 -3 9 
      clm=0 ; line=0
      while file.gets
        if $_ !~ /^\s*#/ && $_ !~ /^\s*$/
	  wk= $_.split(/\*/)
          mlt = wk[1]? wk[1].to_i : 1
          (1..mlt).each{|k|  line += 1 ;
            self[line]=[]
            wk[0].split.each{|n0| 
              nn = n0.to_i
              if nn>0 ; self[line]<< [clm+1,clm+nn] ; clm += nn
              else    ; self[line]<< [0,-nn] 
              end
            }
 	  }
        end
      end
      file.close
      if @lines != line ; print "*** error p_form lines miss ***\n" ; end
    end

  end # def initialize
  
  def out(cells,of=$of)
    of.print "\n-----\n"
    if @n > 9 
      sp =  3 ; fm1 = "%2d " ;fm2 = " . "
    else
      sp =  1 ; fm1 = "%1d"  ;fm2 = "."
    end

    self.each{|l|
      l.each{|c| 
        if c
          w=cells[c].v
          if w ;of.printf fm1,w ;else ;of.print fm2;end 
        else
          of.print " "*sp
        end
      }
      of.print "\n"
    }
    
  end
  
  def outAbility(cells,v)  
    print "\n-----\n"
    self.each{|l|
      l.each{|c| 
        if c
          w = cells[c].ability.include?(v) ? v : nil
          if w ;printf "%2d",w ;else ;print " .";end
        else
          print " "*( @n>9?3:2)  #**** [1]*3
        end
      }
      print "\n"
    }
    return
    
    (1..@lines).each{|l|
      self[l].each{|se|
        if se[0] == 0
          print " "*se[1]*( @n>9?3:2)  #**** [1]*3
        else
          (se[0]..se[1]).each{|c|
            w=cells[c].ability[v]
            if w ;printf "%2d",w ;else ;print " .";end 
            print @n>9 ? " ":""
          }
        end
      }
      print "\n"
    }
  end
end # class Form 
