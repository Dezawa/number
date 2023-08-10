require_relative './make_waku_pform'
require_relative './resolver'

module Number
  class Game
    Iromono = %w[ARROW SUM KIKA XROSS COLLOR HUTOUGOU DIFF NEIGHBER ODD CUPCELL]
    IromonoReg = %r[#{Iromono.join("|")}]
    include Number::GamePform
    include Number::Resolver
  attr_accessor :groups,:cells,:gsize,:size, :form_size,:form,:arrow,:block,:n
  attr_reader :infile, :form, :sep, :game_type, :count

  def self.create(infile,form_size,sep, game_type: nil)
    instance = new(infile,form_size,sep, game_type: nil)
    instance.set_game_type
    instance.get_structure
    instance.get_initialdata
    instance
  end
  
  def optional_test;end
  
  def initialize(infile,form_size,sep, game_type: nil)
    @infile,@form_size,@sep,@game_type = infile,form_size,sep,game_type
    @groups = Array.new
    @cells = []
    @count =  Hash.new(0)
  end

  def set_game_type
    required = IromonoReg =~ game_type ? "./game_types/#{$&.downcase}" : nil
    return unless required

    require_relative required
    extend Number::GameTypes::GameType
  end
  
  def block
    @block ||= @groups.select{|grp| grp.is_block? }
  end

  def resolve
    count = 4
    #self.rest_one 
    sw = true
    while ! self.fill? && (sw || count >0)
      sw = nil
      #@cells.each{|cell| sw |= cell.set_if_valurest_equal_1  }
      sw |= self.rest_one 
      sw |= self.reserv(2)
      sw |= self.prison(2)
      print "\n prison(2) #{sw}" if $verb

      next if self.optional_test
      print "optional  #{sw}" if $verb

      sw |= self.reserv(3)
      print " reserv(3) #{sw}" if $verb
      sw |= self.prison(3)
      print " prison(3) #{sw}" if $verb
      sw |= self.reserv(4)
      print " reserv(4) #{sw}" if $verb
      sw |= self.prison(4)
      print " prison(4) #{sw}" if $verb
      self.highClass.each{|method| sw |= method.call
        print " method #{sw}" if $verb
      }
      #puts count
      count -= 1
    end
    self.fill? 
  end
  
  # data file の残りを読んで、初期値を得る 
  #    dataファイルにある、arrow情報も読む
  def get_initialdata
    c=0
    # print "last $_='",$_,"', @gsize=#{@gsize} @size=#{@size}\n" unless $quiet

    #所定の cell数だけ、初期データを読む
    while infile.gets && c < @size
      # print $_
      $_ =~ /^\s*#/ && while infile.gets =~ /^\s*#/;end
      #STDERR.
      # print $_ unless $quiet
      $_.chop.split(sep).each{|v|
        # print "#{c}='#{v}' "
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
    raise 'ENOUGH ARROW DATA' unless $_
    $_.split.each{|c| a << c.to_i - 1 }
    @arrow << a.dup
    
    puts "arrow #{$_}"  if $verb
    while infile.gets =~ /\d/ ; 
      puts "arrow #{$_}"    if $verb
      raise 'ENOUGH ARROW DATA' unless $_
      
      a=[]
      $_.split.each{|c| a << c.to_i - 1 }
      @arrow << a.dup
    end
    @arrow = @arrow.compact if @arrow
    @arrow=@arrow.sort{|a,b| b.size<=>a.size  }
  end
  ### def structure(data,form,sep)
  ###   if /^\s*\d+(x\d+)?([-+]\d+)*\s*$/ =~ form # 3x3-4+5
  ###     xmax,ymax = make_waku_pform_new(data,form,sep)  # 枠を算出
  ###     ban_initialize(@w,@n,xmax,ymax)
  ###     #印刷フォーム設定
  ###     @form=Number::Form.new([@w,xmax,ymax],@n)
  ###   end
  ###   #@block ||= @groups.select{|grp| grp.is_block? }
  ### end
  def get_structure
    if /^\s*\d+(x\d+)?([-+]\d+)*\s*$/ =~ form_size # 3x3-4+5
      xmax,ymax = make_waku_pform(form_size)  # 枠を算出
      ban_initialize(@w,@n,xmax,ymax)
      #印刷フォーム設定
      @form=Number::Form.new([@w,xmax,ymax],@n)
    else
      xmax,ymax = make_waku_pform(form_size)  # 枠を算出
      @form=Number::Form.new([@w,xmax,ymax],@n)
    end
    #@block ||= @groups.select{|grp| grp.is_block? }
  end

  ### 出力系 ###
  # 版の出力。決まっていない所は . ピリオド
  def output_form
    form.out cells
  end

  # 使った技の統計
  def output_statistics
    @count.map{|l,v| " Stat: %-10s %3d\n" % [l, v]}.join
  end
  
  # 未解決の cellがある場合、その残っている可能性をまとめる
  # [ [cell_nr, [ 1, 5,,,] ]
  def cell_ability
    cells.select{|cell| cell.v.nil?}
      .map{|cell| [cell.c,cell.ability]}
  end
  
  # 未解決の cellがある場合、その残っている可能性を出力する。後方互換
  # 2 : [ 3, 4]
  def cell_out
    cell_ability.map{|c,ability| "#{c} : #{ability}"}.join("\n")
  end

  def output(statistics, count, cellout)
    cellout && cell_out
    statistics &&  @count.each{|l,v| printf " Stat: %-10s %3d\n",l,v}
    form.out cells
  end
end # Groups
end
