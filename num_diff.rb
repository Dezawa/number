class Game
#module Optional
def optional_struct(sep,n,infile)
     get_arrow(infile)
end   
#end

def optional_test
  #################
puts "optional"
 # def diff(arrow)
  sw = nil
    c=[]
    @arrow.each{|arw|
      (dif , c[0], c[1]) = arw
      k=[]; k[0]=[] ; k[1]=[]; w=[]
      @cells[c[0]].vlist.each{|v1|  
	@cells[c[1]].vlist.each{|v2| 
          if (v1-v2).abs==dif ; k[0] << v1 ; k[1] << v2 ;end
        }
      }
      w[0]=k[0].uniq.sort
      w[1]=k[1].uniq.sort

      (0..1).each{|i|
        if w[i].size==1 
          ret = @cells[c[i]].set(w[i][0])
          sw ||= ret
        elsif w[i].size >0 # 二つ以上だったら、
          # それ以外の数字をそのcellの可能性から消す
          vv=@cells[c[i]].vlist - w[i]
          ret = @cells[c[i]].rmAbility(vv)
          sw ||= ret
        end
      }
   }
  sw
end # $diff
end
