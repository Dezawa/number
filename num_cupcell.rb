####
class Cell
  def even_only?
    @valu && @valu.even? || 
      !@valu &&  @ability.select{|a| a.odd? }.size==0
    #(1..@n).step(2).map{|v| @ability[v] if @ability[v]>0 }.compact.size==0
  end
  def odd_only?
     @valu && @valu.odd? || 
      !@valu &&  @ability.select{|a| a.even? }.size==0
    #(2..@n).step(2).map{|v| @ability[v] if @ability[v]> 0 }.compact.size==0
  end

end
class Game #sub < Groups #Cupcell 
# coding: euc-jp
#module Optional
def optional_struct(sep,n,infile)
     get_arrow(infile)
end   
#end

def ddrest_one
puts "rest_one"
  return nil unless super
puts "rest_one end"
  optional_test  
end

def optional_test#(arrow)
#pp arrow
  #################
  # 1. only_test
  #   pairの一つのcellがe/oいずれかしか候補が残っていない場合は
  #   反対のcellはo/eである
  # 2. reserve
  #    pairがともに一つのGroupに属し、かつそのgroupに残るe/oの可能性が
  #    一つしか残されていない場合、そのpair cellはそのe/oに予約される
  ##################
  @arrow.delete_if{|pair| 
    #pp [@cells[pair[0]].ability[0],@cells[pair[1]].ability[0]]
    @cells[pair[0]].v && @cells[pair[1]].v
  }

  @arrow.each{|pair| only_test(pair) && @arrow.delete(pair)}
  @arrow.each{|pair| reserve(pair)   && @arrow.delete(pair)}
  return $gsw
end

def only_test(pair)
#pp pair
  (0..1).each{|i| c = pair[i];c1=pair[1-i]#;pp @cells[c].ability
    if @cells[c].even_only?
      @cells[c1].set_odd("#{c1} odd by pair[#{pair.join(',')}]")
      $gsw = true;return true
    end
    if @cells[c].odd_only? 
      @cells[c1].set_even("#{c1} even by pair[#{pair.join(',')}]")
      $gsw = true;return true
    end
  }
  false
end

# piar の両方に入る　e/o　が一つしかなくかつ同じものだったら
# その二つのcellが指定席。　同じグループの他のcellには入らない。
def reserve(pair)
  # 二つのcellが共に属するgroupを得る。少なくとも一つある
  groups = cogroup(pair)

  # pairの二つのcellにe/oが一種しか入らず、かつ同じであったら
  # このgroupの他のcellにはこの数字は入らない
  # どちらかが確定していたら、対象外

  # 確定していたら対象外
  return false if @cells[pair[0]].v ||  @cells[pair[1]].v
  
  # 可能性のpair
  abilitys = pair.map{|c|  @cells[c].ability }

  #pp [groups,abilitys]
  # evenについて調べる
  even = abilitys.map{|ab|  ab.select{|i| i>0 && i%2 == 0}}
#pp [even,(even[0] & even[1])]
  if even[0].size==1 && even[1].size==1 && (even[0][0] == even[1][0])
    # このevenの値が予約される
    v = even[0][0]
    #pp "# このevenの値が予約される #{v}"
    groups.each{|grp|  @groups[grp].rmAbility(v,pair,"cupcell [#{pair.join(',')}]")}
  end

  # oddについて調べる
  odd = abilitys.map{|ab|  ab.select{|i| i%2 == 1}}
  if odd[0].size==1 && odd[1].size==1 && (odd[0] & odd[1]).size==1
    # このevenの値が予約される
    v = (odd[0] & odd[1])[0]
    groups.each{|grp|  @groups[grp].rmAbility(v,pair,"cupcell [#{pair.join(',')}]")}
  end
end
#class Groups
#  extend GroupsCupcell
#end
end
