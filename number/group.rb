class Number::Group
  attr_accessor  :game,:cells,:n,:g,:ability,:cellList,:atrivute, :count
  def initialize(arg_game,arg_g,atr=[], count)
    @game = arg_game
    @n = @game.n
    @g = arg_g
    @cells=@game.cells
    @ability= Number::GroupAbilities.new(@n)
    @cellList=Array.new
    @atrivute = atr # :holizontal :vertical  :block
    @count = count
  end

  def inspect
    "#<Group:#{object_id} " +
      [:g,:atrivute,:cellList].map{|sym|  "  @#{sym.to_s}=#{send(sym).inspect}"}.join+
      "\n  @ability=[\n"+
      @ability.ability.map{|abl| "         "+abl.inspect}.join("\n")
  end
  def type; @atrivute; end
  def g ; @g ; end
  def addcellList(a) ;    @cellList<< a ;  end
  def cellList;	@cellList ;  end
  def is_block? ; @atrivute == :block     ;end

  def line_groups_join_with
    cellList.inject([]){|g_nrs,c| g_nrs |= @cells[c].grpList } - [g]
  end

  def block_groups_join_with
    cellList.inject([]){|g_nrs,c| g_nrs << @cells[c].grpList[2] }.uniq 
  end
  def rmCellAbility(v0,cell_no,msg=nil)
    return @ability.rmCellAbility(v0,cell_no,msg)
  end
  
  def set_cell_if_some_value_s_ability_is_rest_one
    sw = nil
    ability.fixed_by_rest_one.each{|cellData|
      if @cells[cellData.cellList.first].set(cellData.v,"grp(#{g}).ability #{cellData.cellList}")
        @count[:Group_ability_is_rest_one] += 1
        sw = true
      end
    }
    sw
  end
  # このgroupの値 v 
  def rmAbility(v,except_cells=[],msg="")
    #このgrpに属する各cellの値vの可能性を調べ、残っていたら
    #可能性を削除する
    # ただし、array except_cells  にある cell はいじらない。
    # vが配列の場合は、その中をすべて
    v = [v] unless v.class == Array
    rm_cells = @cellList - except_cells
    ret=nil
    rm_cells.each{|c0|  #(0..@n-1).each{|c| c0=@cellList[c]
      if (@cells[c0].ability & v).size > 0 
        @cells[ c0 ].rmAbility(v,msg)
        ret=true 
      end
    }
    ret
  end
end # of Group
####
