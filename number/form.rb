class Number::Form < Array
  def initialize(p_form, n)
    @n = n
    if p_form.instance_of?(Array)
      # [ w,xmax,ymax ]
      w, xmax, ymax = p_form
      (0..ymax - 2).each { |i| push(w[i * xmax, xmax].map { |ww| ww ? ww[0] : nil }) }
      @lines = ymax - 1
      # pp self
    elsif p_form.instance_of?(String)
      file = open(p_form)
      while file.gets && ($_ =~ /^\s*#/ || $_ =~ /^\s*$/); end
      @lines = $_.to_i
      # 9 -3 9 -3 9 -3 9
      # 45*3
      #-6 9 -3 9 -3 9
      clm = 0
      line = 0
      while file.gets
        next unless $_ !~ /^\s*#/ && $_ !~ /^\s*$/

        wk = $_.split(/\*/)
        mlt = wk[1] ? wk[1].to_i : 1
        (1..mlt).each do |_k|
          line += 1
          self[line] = []
          wk[0].split.each do |n0|
            nn = n0.to_i
            if nn > 0
              self[line] << [clm + 1, clm + nn]
              clm += nn
            else
              self[line] << [0, -nn]
            end
          end
        end
      end
      file.close
      print "*** error p_form lines miss ***\n" if @lines != line
    end
  end # def initialize

  def out(cells)
    if @n > 9
      sp =  3
      fm1 = '%2d '
      fm2 = ' . '
    else
      sp =  1
      fm1 = '%1d'
      fm2 = '.'
    end

    out = ''
    each  do |l|
      l.each do |c|
        if c
          w = cells[c].v
          out << (w ? fm1 % w : fm2)
        else
          out << ' ' * sp
        end
      end
      out << "\n"
    end
    out
  end

  def outAbility(cells, v)
    print "\n-----\n"
    each  do |l|
      l.each do |c|
        if c
          w = cells[c].ability.include?(v) ? v : nil
          w ? (printf '%2d', w) : (print ' .')
        else
          print ' ' * (@n > 9 ? 3 : 2) # **** [1]*3
        end
      end
      print "\n"
    end
    return

    (1..@lines).each do |l|
      self[l].each  do |se|
        if se[0] == 0
          print ' ' * se[1] * (@n > 9 ? 3 : 2) # **** [1]*3
        else
          (se[0]..se[1]).each do |c|
            w = cells[c].ability[v]
            w ? (printf '%2d', w) : (print ' .')
            print @n > 9 ? ' ' : ''
          end
        end
      end
      print "\n"
    end
  end
end # class Form
