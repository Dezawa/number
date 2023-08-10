module Number::GameTypes::GameType
  def game_type
    'HUTOUGOU'
  end

  # module Optional
  def optional_struct(_sep, _n, infile)
    while infile.gets && ($_ =~ /^\s*#/ || $_ =~ /^\s*$/); end
    @arrow = []
    while $_ =~ /\d/
      a = []
      $_.split.each { |c| a << c.to_i }
      @arrow << a.dup
      infile.gets
    end
    @neigh -= @arrow
    # p $neigh
    # p @arrow
  end
  # end

  def optional_test
    @arrow.each do |arw|
      l = arw[0]
      h = arw[1]
      llist = @cells[l].vlist
      hlist = @cells[h].vlist
      lrm = @cells[l].vlist.select { |v| v >= hlist.last }
      hrm = @cells[h].vlist.select { |v| v <= llist[0] }
      lrm.size > 0 && @cells[l].rmAbility(lrm, "HUTOUGOU cell[#{l}]<cell[#{h}]")
      hrm.size > 0 && @cells[h].rmAbility(hrm, "HUTOUGOU cell[#{l}]<cell[#{h}]")
    end
  end # hutougou
end
