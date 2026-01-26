
class Game 
  attr_accessor :groups,:cells,:gsize,:size,:form,:arrow,:block,:n
  def optional_test;end
  
  def initialize(args={})#n,gsize,cells)
    @groups = Array.new
    @cells = []
  end

  def block
    @block ||= @groups.select{|grp| grp.is_block? }
  end

  def resolve
    return true if try
    $level>0 && try_error 
  end
  def try
    count = 4
    #self.rest_one 
    sw = true
    while ! self.fill? && (sw || count >0)
      sw = nil
      #@cells.each{|cell| sw |= cell.set_if_valurest_equal_1  }
      sw |= self.rest_one 
      sw |= self.reserv(2)
      sw |= self.teiin(2)
      print "\n teiin(2) #{sw}" if $verb
      sw |= self.teiin5

      print " teiin5 #{sw}" if $verb
      next if self.optional_test
      print "optional  #{sw}" if $verb

      sw |= self.reserv(3)
      print " reserv(3) #{sw}" if $verb
      sw |= self.teiin(3)
      print " teiin(3) #{sw}" if $verb
      sw |= self.reserv(4)
      print " reserv(4) #{sw}" if $verb
      sw |= self.teiin(4)
      print " teiin(4) #{sw}" if $verb
      self.highClass.each{|method| sw |= method.call
        print " method #{sw}" if $verb
      }
      #puts count
      count -= 1
    end
    self.fill? 
  end

  def try_error
    if true
      (1..1).each{|i| # とりあえず、深さ1まで
        $try = nil

        # 未定cellのうち、可能性数がもっとも少ない cellについて、トライ＆エラー
        ## target t_
        t_cell= self.cells.map{|cell| cell if cell.valurest>0 }.
        compact.sort{|a,b| a.valurest <=> b.valurest}[0]
        t_vlist = t_cell.vlist
        t_c = t_cell.c

        puts "Try & error cell #{t_c}:vlist #{t_cell.vlist.join(' ')}" unless $quiet
        $count["Try & error"] += 1

        t_vlist.each{|v|
          puts "Cell #{t_cell} value=#{v}" unless $quiet
          # 現環境の保存と複製
          $BAN << self
          game  = self.copy
          game.cells[t_c].set(v,"Try & error")
          return  true if game.try#(self) 
          #$self = $BAN.pop
        }
      }
    end
  end

  def copy
    gr = self.dup
    gr.cells.each{|cell| 
      cell.ability = cell.ability.dup
      cell.groups  = gr.groups
    }
    gr.groups.each{|grp|  grp.ability = grp.ability.dup   }
    gr
  end
  
  # data file の残りを読んで、初期値を得る 
  #    dataファイルにある、arrow情報も読む
  def get_initialdata(infile,sep)
    c=0
    print "last $_='",$_,"', @gsize=#{@gsize} @size=#{@size}\n" unless $quiet
    
    #所定の cell数だけ、初期データを読む
    while infile.gets && c < @size
      # print $_
      $_ =~ /^\s*#/ && while infile.gets =~ /^\s*#/;end
      #STDERR.
      print $_ unless $quiet
      $_.chop.split(sep).each{|v|
        #print "#{c}='#{v}' "
        next if v =~ /\s/
        if v=="e"
          @cells[c].set_even
        elsif v=="o"
          @cells[c].set_odd
        elsif (vv=v.to_i) > 0 
          #STDERR.        print "#{vv} "
          vlst = v.split("|")
          if vlst.size==1
            #print "[ C=#{c} vv=#{vv}] ";
            @cells[c].set_cell(vv,"initialize")
          else
            vv= @val - vlst.map!{|i| i.to_i}
            @cells[c].rmAbility(vv,"initialize")
          end
        end
        c += 1
      }
    end 
    
    # dataファイルの後半にある arrow情報を得る
    # 標準では何もしないmethod
    optional_struct(sep,@n,infile)
    #@arrow = @arrow.compact if @arrow
    
  end # of get_initialdata
  def optional_struct(a,b,f);end

  def get_arrow(infile)
    puts "GET ARROW"   if $verb
    #$_ =~ /^[#\s]*$/ && while infile.gets =~ /^[#\s]*$/;end
    while infile.gets && ( $_ =~ /^\s*#/ || $_ =~ /^\s*$/) ; end
    @arrow=[]
    a=[]
    puts $_   if $verb
    $_.split.each{|c| a << c.to_i - 1 }
    @arrow << a.dup
    
    puts "arrow #{$_}"  if $verb
    while infile.gets =~ /\d/ ; 
      puts "arrow #{$_}"    if $verb
      
      a=[]
      $_.split.each{|c| a << c.to_i - 1 }
      @arrow << a.dup
    end
    @arrow = @arrow.compact if @arrow
    @arrow=@arrow.sort{|a,b| b.size<=>a.size  }
  end
  def get_structure(infile,form,sep)
    if /^\s*\d+(x\d+)?([-+]\d+)*\s*$/ =~ form # 3x3-4+5
      xmax,ymax = make_waku_pform(infile,form,sep)  # 枠を算出
      ban_initialize(@w,@n,xmax,ymax)
      #印刷フォーム設定
      @form=Form.new([@w,xmax,ymax],@n)
    else
      w_form = "#{$FileDir}/waku#{form}"
      p_form = "#{$FileDir}/pform#{form}"
      get_structure_file(w_form,sep)
      #印刷フォーム指定ファイルを読む
      ##### get PRINT FORM
      print "###\n" unless $quiet
      @form=Form.new(p_form,@n)
    end
    @block ||= @groups.select{|grp| grp.is_block? }
  end



end # Groups
