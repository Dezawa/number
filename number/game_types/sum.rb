module Number::GameTypes::GameType
  def game_type
    'SUM'
  end

  # #NSP SUM
  # 9
  # ここに9x9データ
  # このあと sum cell0 cell..... を並べる
  
##############
require 'pp'
def optional_struct(sep,n,infile)
  get_arrow(infile)
  @arrow.each{|arw| arw[0] += 1}
  @arrow.sort!{|a,b| a.size<=>b.size}
  #pp @arrow
  print_struct if $check
  check || exit(1)
  hamidasi
  
  @summax=25
end

def print_struct
  cell = Array.new(81)
  @arrow.each{|ary|
    v=ary[0]
    ary[1..-1].each{|c| cell[c-1]=v }  
  }
  (0..80).step(9).each{|l|
    (l..l+8).each{|r|  printf "%2d ", cell[r] }
    puts ""
    
  }

end

# block の正方形からはみ出している部分を取り出し、それの合計が
# いくつになるかも arrowに追加する。
# ただしはみ出しが一つのblockに入っていない場合は厄介だから無視。
def hamidasi
  #block毎に
  arrow=@groups.select{|grp| grp.type == :block}.map{|grp| 
    g_cells=grp.cellList
    # @arrowの中にgroup のcellと一致するcellを含むものがあれば抜き出し
    # その groupに属さないcellの一覧を用意する
    sum =0
    cells = []
    @arrow.map{|arw|
      #pp [ arw,arw[1..-1], grp.cellList,(arw[1..-1] & grp.cellList)]
      if (arw[1..-1] & grp.cellList).size > 0 
        sum += arw[0]
        cells += ( arw[1..-1] - grp.cellList) 
        #pp [arw,sum,cells]
      end
    }
    # そのcellが一つのgrpに属していたら登録する
    if cells.size >0
      g_list= @cells[cells[0]].grpList
      cells[1..-1].each{|c| g_list = g_list & @cells[c].grpList }
      if g_list.size>0
        #pp [sum,cells]
        cells.unshift(sum-45)
      else
        nil
      end
    end
  }.compact
  #pp arrow
  #exit
  @arrow += arrow
end

def check
  return true unless $check
  p @arrow
  p @arrow.size
  $err=true
  para=[]
  q=[]; (1..@size).each{|i| q << i }
  @arrow.each{|a|
    b=a.dup; b.shift
    para << b
  }
  para.flatten!
  p=para.sort.uniq; 
  
  qq = (q - para).sort
  if qq.size>0
    STDERR.print "Optional Para is missing   #{qq.join(',')}\n" ;
    #$err=true
  end
  qq =(para - q).sort   
  if qq.size>0
    STDERR.print "Optional Para is tomuch   #{qq.join(',')}\n" ;
    $err=nil
  end
  
  if p.size != para.size
    STDERR.print "Optional Para is duped " ;
    qq=para.sort
    (0..qq.size-2).each{|i| 
      if qq[i]==qq[i+1];STDERR.print " #{qq[i]}";end
    }
    STDERR.print "\n"
    $err=nil
  end
  qq = (para-q).sort
  if qq.size>0
    STDERR.print "Optional Para value is wrong   #{qq.join(',')}\n"
    $err=nil
  end

  $err
end # $check

#end

  # arw = [[sum,c1,c2,c3],
  #        [sum,c1,c2]
  #       ]
  # valus    = [ [v1,v2],[v4,v5,v6] ]  arw １要素毎に作り壊される
  # products = [ [v1,v4],[v2,v6] ]     合計が sumとなる組み合わせ
  # val      = [ [v1,v2],[v4,v6]       残った可能性

  def optional_test
    if $verb;print "sum arrow" ;p @arrow;end
    optsw=nil
    delete_arys=[]
    
    # 効率化のため組み合わせの数が大きくならないように制限する数を
    # 少しずつ大きくする。  このとき小さすぎると一つも解決できず、
    # 失敗で終わってしまうので、ある程度までは成功したことにする
    @summax += 5  ;  $gsw =  true  if @summax<40
    @arrow.each_with_index{|arrow,i|
      #pp ["arrow",arrow,@summax] if $verb
      valus=[] # 指定されたcellに残っている値の配列  の配列
      sum = arrow[0]
      (1..arrow.size-1).each{|c| valus << @cells[arrow[c]].vlist }
      
      # 大サイズの場合は組み合わせが膨大になってしまうのでパスしておくことにしよう
      next if valus.flatten.size > @summax
      
      # 高速化のための枝切りだが、変わらない。 0.1秒。。。
      #  ここが働き出すまでに8秒、残り3秒弱
      #    最初の 一セルfix までに  6秒
      if valus.flatten.size == valus.size
        #pp ["arw.delete_at",i,arrow]
        delete_arys << i # arw.delete_at(i)
        next  # 一つ飛んじゃうな
      end
      #pp [valus.flatten.size ,valus.size,valus]
      # ここに枝切りとして、同じ数字があったらだめ、を入れたいのだが、
      # 違うグループに属するcellの場合は許される？ のでややこしい
      #   だが、大物はこれがないと解けないのでとりあえずこれで入れておく
      #pp valus if $verb
      #pp  product_sum(sum,valus) if $verb
      products_all = valus.size == 1 ? valus : valus[0].product(*valus[1..-1])
      products = products_all.select{|vary|
        #products = product_sum(sum,valus).select{|vary| 
        sm=vary.inject(0){|sm,v| sm += v.to_i}
        sm == sum and  vary.size==vary.uniq.size
      }
      val = products[0].zip(*products[1..-1])
      val = val.map{|v| v.uniq }

      val.each_with_index{|vary,c|
        if vary.size == 1 # 一つに絞られたら、そのcellは決定
          pp ["cell #{arrow[c+1]}  fix",vary[0]]if $verb
          @cells[arrow[c+1]].set(vary[0],"sum") && $gsw = optsw = true
        elsif (vv = valus[c]  - vary).size>0
          pp ["cell #{arrow[c+1]}  delete",vv] if $verb
          @cells[arrow[c+1]].rmAbility(vv,"sum") && $gsw = optsw = true
        end
      }
      while i=delete_arys.pop; @arrow.delete_at(i) ;end
      if optsw
        @summax -= 5
        return true  # 一つできたら全体見直しする
      end
    }
  end # sum_test ##############
end
