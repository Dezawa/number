class GroupAbilities
  attr_accessor :n, :ability
  def initialize(arg_n)
    @n = arg_n
    @ability = [] #Hash.new #{|h,k| h[k] = [@n,[],k] }
  end

  def setup_initial(cellList)
    (1..@n).each{|v| @ability[v]= GroupAbility.new(@n,cellList.dup,v)}
    #@ability[0]= GroupAbility.new(0,cellList.dup,0)
  end
  def rmCellAbility(v0,cell_no,msg=nil)
    #このgrpの値 v　から指定cellの可能性をなくす
      v0.each{|v|  @ability[v].rmCellAbility(cell_no)  }
  end
  def fixed_by_rest_one
    @ability[1..-1].select{|abl| abl.rest==1}
  end

  def combination_of_ability_of_rest_is_less_or_equal(v_num)
    a= @ability[1..-1].select{|abl| abl.rest>1 and abl.rest<=v_num}.
      combination(v_num).
      select{|abl_cmb| abl_cmb.inject([]){|cells,abl| cells |= abl.cellList }.size == v_num}
    # [[[2,[28,29],7], [2,[28,29],9]]]
  end

  def [](idx) ;@ability[idx] ; end
  def []=(idx,val) ;@ability[idx]=val ; end
  def dump  ;    ability[1..-1].map{|abl| abl.dump}      ;  end
  def dup
    ablty = self.clone
    ablty.ability[1..-1].each{|abl| abl.cellList=abl.cellList.dup}
    ablty
  end
end

class GroupAbility
  attr_accessor :rest,:cellList ,:v
  def initialize(arg_n,arg_cellList,arg_v)
    @cellList = arg_cellList
    @rest      = arg_n
    @v = arg_v
  end
  def rmCellAbility(cell_no,msg=nil)
    if cellList.delete(cell_no) 
      @rest -= 1  
      puts msg if msg
    end
  end
  def inspect
    "[#{rest},[#{cellList.join(',')}],#{v}]"
  end

  def dump 
    [rest,cellList,v]
  end
end
