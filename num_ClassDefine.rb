# coding: UTF-8
#
# Define Classed
# Arry, Cell, Group
#
# @ Cell#set_cell --> Cell#rmCellAbilityFromGroupsOfGroupList(@ability)
#                          --> grpList Group#rmCellAbility
#                                --> cellList GroupAbilities#rmCellAbility
#                 --> grpList Group#rmAbility
#                        --> @ Cell#rmAbility
#                                --> #rmCellAbilityFromGroupsOfGroupList(v_remove) 
#                                      #-> Group#rmCellAbility
#                                         --> GroupAbilities#rmCellAbility

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


##################
class Group
  attr_accessor  :game,:cells,:n,:g,:ability,:cellList,:atrivute
  def initialize(arg_game,arg_g,atr=[])
    @game = arg_game
    @n = @game.n
    @g = arg_g
    @cells=@game.cells
    @ability= GroupAbilities.new(@n)
    @cellList=Array.new
    @atrivute = atr # :holizontal :vertical  :block
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
        $count[:Group_ability_is_rest_one] += 1
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

#################################
class Form < Array
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
