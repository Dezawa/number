require 'pp'
class Number::Game

def optional_struct(sep,n,infile)
  get_arrow(infile)
  @arrow.sort!{|a,b| a.size<=>b.size}
  #p @arrow if $verb
  
  @summax=20

  # arrow それぞれの中で、同じgroup に属するものの組み合わせを作る
  #     . . . . . . . . .  10 => 11,21,22 の場合
  #     # * . . . . . . .      11,21 group 19, 
  #     . . * * . . . . .      21,22 group 12
  #     . . . . . . . . .
  # 同じgroupに属するcell を集める
  $arw_group=[]
  @arrow.each_with_index{|arrow,i|
     #$arw_group[i]=arrow[1..-1].map{|cellNo|
     groups = arrow[1..-1].map{|cellNo|     # cell の group の集合を求める
          @cells[cellNo].grpList
       }.flatten.uniq
     cellsSameGroup=groups.map{|grpNo|
          cells = @groups[grpNo].cellList & arrow[1..-1]
          cells if cells.size>1
    }.compact
    $arw_group[i]=cellsSameGroup.map{|cells| 
         #そのcellはallowの何番目の要素か
	 cells.map{|c| arrow.index(c) }.sort
    }.uniq
  }
   pp [@arrow,$arw_group] if $verb
  
     check || exit(1) 
  #pp $arw_group if $verb
end

def check
  return true unless $strct
  
  pp @arrow
  p @arrow.size
  $err=nil
  para=[]
  q=[]; (1..@size).each{|i| q << i }
  @arrow.each{|a|
    b=a.dup
    para << b
  }
  para.flatten!
  p=para.sort.uniq; 
  if p.size != para.size;STDERR.print "Optional Para is duped\n"; exit(1);end
  if (p[0]<1 || p[@size-1] > @size ) 
    STDERR.print "Optional Para value is wrong\n" && exit(1)
  end
end

# 矢印の○のcellと矢印のcell のarry、のarry
# @arrow = [[sumCell,c1,c2,c3], [sumCell,c1,c2] ]
#
# arrowのc1,c2,c3,,, が同じgroupに属している場合は同じ数字は入らない。
# それを枝刈りするための情報。arrow毎に同じgroupに属するcellの集合
# $arw_group = [[[1,2],[1,3]] ,[  ] ]
#                 cell Noではなく、そのcellがarrayの何番目なのか、の位置情報
#
#実行時
# arrowの各cellに残されている可能性の集合。arw １要素毎に作り壊される
#   valus    = [[s1,s2,s3], [V1,V2],[v1,v2],[v4,v5,v6] ]        
#                 sumCell     c1       c2       c3
# それらのうち、合計が sumCellの値となる組み合わせ
#   products = [ [V1,v1,v4],[V1,v2,v6],[V2,v1,v6] ]  合計が sumとなる組み合わせ
# val      = [ [V1,V2],[v1,v2],[v4,v6]       残った可能性
def optional_test
  if $verb;print "sum arrow @summax=#{@summax}\n" ;p @arrow;end
  optsw=nil
  delete_arys=[]
  
  # 効率化のため組み合わせの数が大きくならないように制限する数を
  # 少しずつ大きくする。  このとき小さすぎると一つも解決できず、
  # 失敗で終わってしまうので、ある程度までは成功したことにする
  @summax += 5  #;  $gsw =  true  if @summax<50

  delete_array = []
  @arrow.each_with_index{|arrow,i|
    valus=[] # 指定されたcellに残っている値の配列  の配列
    #(0..arrow.size-1).each{|c| valus << @cells[arrow[c]].vlist }
    valus = arrow.map{|c| @cells[c].valu ? [@cells[c].valu] :  @cells[c].vlist}
    pp ["arrow",arrow, $arw_group[i],valus] if $verb

    # 大サイズの場合は組み合わせが膨大になってしまうのでパスしておくことにしよう
    next if valus.flatten.size > @summax
    
    # この残っている値の組み合わせを作り(product)
    # 計算が合っている　かつ            (inject)
    # このうち、同じgroupに属するcellで同じ数字があるものはだめ
    products = valus[0].product(*valus[1..-1]).map{|vary| 
      vary if vary[0] == vary[1..-1].inject(0){|s,v| s += v} and
              $arw_group[i].map{|cellIDs|     # このarrowの同じgroupに属するcellID 
                true if cellIDs.map{|id| vary[id] # を値に変換し、
                        }.uniq.size != cellIDs.size  # 重複があったら(true)
              }.compact.size == 0 
                # だめ
    }.compact 
pp $arw_group if $test
pp @arrow  if $test
pp products if $test
    #　products = [ [sum,v1,v2,v3],[sum,V1,V2,V3] ]
    #     合計を満たす値の組み合わせ
    #  これから、各cellの値の集合を求める
    newvalus = products[0].zip(*products[1..-1])

    # 元の可能性 values と　newvalues に差があれば、それは可能性から削除
    valus.each_with_index{|vals,i|
        vv = vals - newvalus[i]
        if vv.size > 0
          @cells[ arrow[i] ].rmAbility(vv,msg="arrow") 
          $gsw = true
          if newvalus[i].size == 1 # 結果一つになれば決定
            optsw = true
            @cells[arrow[i]].set(newvalus[i][0])
          end
        end
    }
    # 可能性集合が一つしかない場合は、このarrowはもう考慮不要
    if products.size == 1
      delete_arys << i
    end
  
    break if optsw
    @summax -= 5 if optsw
    return true if optsw # 一つできたら全体見直しする
    
  } # @arrow.each_with_index
 
  while i=delete_arys.pop; @arrow.delete_at(i) ;$arw_group.delete_at(i); end
  return optsw # $gsw
end
   
end
