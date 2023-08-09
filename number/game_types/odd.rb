class Number::Game 
  #module Optional
  def optional_struct(sep,n,infile)
    get_arrow(infile)
    #@arrow=Hash[*@arrow.map{|c1,c2| [[c1,c2],[c2,c1]]}.flatten]
  end  
  #end

  def optional_test
    @arrow.delete_if{|arrow| arrow[0].nil?}

    return true if partner_is_even_or_odd
    return true if even_or_odd_can_fix_if_4cupcells_is_in_group
  end

  ########
  def even_or_odd_can_fix_if_4cupcells_is_in_group
    sw = nil
    groups.each{|group| 
      ret = even_or_odd_can_fix_if_4cupcells_is_in_the(group)
        sw ||= ret
    }
  end

  def even_or_odd_can_fix_if_4cupcells_is_in_the(group)
    even,odd = @n/2,(@n+1)/2
    arrows = arrows_on_the(group)
    odd  -= arrows.size
    even -= arrows.size
    return cells[cells_not_included_in(arrows,group).first].set_odd  if even == 0
    cells_not_included = cells_not_included_in(arrows,group)
    cellss_not_included = cells_not_included.dup

    sw = nil
    cellss_not_included.each{|cno| cell = cells[cno]
      if cell.is_odd
        odd  -= 1 
        cells_not_included.delete(cno)
      elsif cell.is_even
        even -= 1 
        cells_not_included.delete(cno)
      end
      if even == 0
        cells_not_included.each{|cno| ret=cells[cno].set_odd;sw ||= ret}
        return sw
      end 
      if odd == 0
        cells_not_included.each{|cno| ret=cells[cno].set_even;sw ||= ret}
        return sw
      end
    }
    return nil
  end
  def  cells_not_included_in( arrows,group )
    group.cellList - arrows.inject([]){|cells,arrow| cells | arrow}
  end
  def cell_is_odd?(cell,group,arrows)
    even= @n/2 -arrows.size
    return true if even == 0
  end
  def arrows_on_the(group)
    @arrow.select{|arrow| (arrow & group.cellList).size == 2}
  end

    ###
    def partner_is_even_or_odd
      sw=nil
      puts "partner_is_even_or_odd" if $verb
      @arrow.each{|arrow|       next unless arrow[0]
        if set_even_if_partner_is_odd(arrow)
          sw = true 
          next
        elsif  set_odd_if_partner_is_even(arrow)
          sw = true 
          next
        end
      }
      sw
    end

    def set_odd_if_partner_is_even(arrow)
      c1, c2 = arrow
      if     @cells[c1].is_odd ; @cells[c2].set_even
      elsif  @cells[c2].is_odd ; @cells[c1].set_even
      else   ;return nil 
      end
      #pp [ "set_even",arrow, @cells[c1],@cells[c2] ]
      arrow[0..1] = [nil,nil]
      return true
    end
    def set_even_if_partner_is_odd(arrow)
      c1, c2 = arrow
      if     @cells[c1].is_even ; @cells[c2].set_odd
      elsif  @cells[c2].is_even ; @cells[c1].set_odd
      else   ;return nil 
      end
      arrow[0..1] = [nil,nil]
      return true
    end
  end
