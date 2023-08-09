module Number
  class Cell
  attr_accessor  :game,:groups,:valu,:c,:ability,:grpList
  def initialize(arg_game,cell_no,arg_grpList)
    @game = arg_game
    @n = @game.n
    @c=cell_no
    @ability= (1..@n).map{ |v| v}
    @valu       = nil
    @grpList=arg_grpList
    @groups = @game.groups
    @val = (1..@n).to_a
  end
  def inspect
    super +
      [:c,:valu,:grpList,:ability].map{|sym|  "  @#{sym.to_s}=#{send(sym).inspect}"}.join
   end
  def related_groups
    related_groups_no.map{|g| @groups[g]}
  end
  def related_groups_no
    holizontal,vertical,block,ather = grpList
    (@groups[block].line_groups_join_with +
      @groups[holizontal]. block_groups_join_with +
      @groups[vertical]. block_groups_join_with) - grpList

  end

  def ability ;    @ability ;   end
  def v ; @valu ; end
  def valurest ; @ability.size ;end

  def vlist
    @valu ? [@valu] : @ability  #.select{|a| a>0}
  end
  
  def is_even
    vlist.select{|v| v.odd?}.size == 0
  end
  def is_odd
    vlist.select{|v| v.even?}.size == 0
  end
  def set_even(msg=nil)
    return nil if valu
    puts (msg || "set even cell #{c}") if $verb
    (1..@n).step(2){|v| rmAbility(v) }
  end
  def set_odd(msg=nil)
    return nil if valu
    puts (msg || "set odd cell #{c}") if $verb
    (2..@n).step(2){|v| rmAbility(v) }
  end
  
  def set_if_valurest_equal_1
    return nil unless valurest == 1 && !v
    set(ability[0])
  end
  def set(v,msg="rest_one")
    $count["Cell_ability is rest one"] += 1
    set_cell(v,msg)
  end

  def set_cell(v,msg="rest one")      
    return nil if @valu || v && !@ability.include?(v)
    #$gsw = true

    #if v.nil? and @ability.size == 1 ; v= @ability[0] ; end
    if $verb ; printf "Set cell %2d = %2d. by #{msg} \n",@c,v ; end

    @valu  = v
    msg = "#{msg} : cell #{@c}"
    # このcellから全valueの可能性をなくす
    #self.rmAbility(@val,msg)
    rmCellAbilityFromGroupsOfGroupList(@ability)
    @ability=[]
    
    # この value を grpの他のcellから可能性削除する
    @grpList.each{|grp|
      @groups[grp].rmAbility(v,[@c],msg) 
    }
  end
  
  def rmAbility(v0,msg="")
    ret=nil
    if v0.class == Array
      vv=v0
    else
      vv=[v0]
    end
    v_remove = vv & @ability
    if v_remove.size > 0
      print " rmAbility cell #{@c} v=[#{v_remove.join(',')}]. by #{msg}\n" if $Verb
      ret = $gsw = true
      @ability -= v_remove
      rmCellAbilityFromGroupsOfGroupList(v_remove)
    end
    ret
  end

  def rmCellAbilityFromGroupsOfGroupList(v_remove,msg=nil)
      @grpList.each{|grp| 
          @groups[grp].rmCellAbility(v_remove,c,msg)
      }
  end
end  # class Cell
end
