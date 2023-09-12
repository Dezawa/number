# frozen_string_literal: true

module Number
  # 解法
  module ResolvPrison5
    
  def prison5
    #return # prison(2,3)と等価?
    ret = false
    @groups.each{|grp|
      (1..game_scale).each{|v| cnt=grp.ability[v].rest
        if cnt>1 && cnt < 4 ## -> 1.
          # 値vの可能性をもつcellを得る
          w = grp.ability[v].cell_ids
          s=w.size # 2 or 3
          # これと同じcellを全て含むグループを探す
          cogroup(w).each{|g| grp0=@groups[g]
            # group g0 の w 以外のcellから 値Vの可能性をなくす
            if grp0.rm_ability(v,w,"## prison5:group #{grp.g} V=#{v} cells=#{w.join(",")}")
              @count[:prison_5] += 1
              return true #ret = true
            end
         
          }
        end
      }
    }
    ret
  end
  end
end
  
