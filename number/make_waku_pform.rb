# coding: UTF-8
###############################
MEMO =<<EOMEMO

type="9-3-2-3" から　waku9-3-2-3, pform9-2-3 相当を作る
箱の数　	Mnr   8 = 3+2+3 = 8
箱の重なり段数  Dan   3 = type.split(/[-+]/).size
箱の重なり横数  Retsu 5  アルゴリズム考えよう
重なり総行数	Lines 21 = Dan * 6 + 3
重なり総欄数	Raws  33 = Retsu * 6 + 3
重複BOXの数　	Dnr   8   適切なアルゴリズムがないなぁ
  line数	Lnr  72   Mnr * 9
  raw数		Rnr  72   Mnr * 9
  box数		Bnr  64	  Mnr*9 - Dnr
Group数		Gnr 108   Lnr + Cnr + Gnr
Cell数		Cnr 576	  Mnr * 81 - Dnr * 9 = 8*81 - 8*9 = 8*72

最初の箱の左上X座標を　0 とする。
一段目の右端の箱の右上X座標は 0+ 3*9 + (3-1)*3 -1 = 32

二段目の左端,右端 X座標(X1L X1R)    X1L= 0 +/- 6, X1R=X1L+9*2+(2-1)*3-1
        :::

という考えで、8個の箱の左上端座標を得る box[0..7]=[0,0],,,
一番左の箱のX座標が　0　となるようにする。

面全体の座標は ban[ Dan , Retsu ]
箱一つづつ9x9のcellの座標を求め( box[*]+[l,r])
   該当する ban[ ] に　cellNo, line,raw,box 番号を入れる。
           line,raw は2つまで入る　groupとしては3〜5
           すでにcellNoが入っていたら　++しない

waku は
   ban[x,y].eachにて、cellNoが入っているものを出力する
隣は x+/- 1, y+/-1 のbanを書き出す

pform　は
　　。。。

EOMEMO
######################################
require 'pp'
#struct = ARGV.shift #"9" #9-3+4-3"
module Number
  module GamePform
  def make_waku_pform(infile,struct,sep)
    n,mult,sign,m_nr,dan = get_baseSize(struct)
    @n,bx,by = n
    @val = (1..@n).to_a

    @m =  Math.sqrt(@n).to_i
    boxes,xsize,ysize = setBasePos(mult,sign,m_nr,dan) # Boxを作り、各Boxの左上の座標を得る

    xmax = xsize + 1;
    ymax = ysize + 1
    @w = Array.new(xmax * ymax , nil)
    # 最終的には、有効なcellでは以下の構造の情報となる
    #   [ cell_Nr, [grp_Nr0,grp_Nr1,,,] ]

    # 有効なcellに１を入れる
    #  STDの場合
    #    boxは一つ
    #    @w  111111111n
    #        111111111n
    #           ....
    #        111111111n
    #        111111111n
    #        nnnnnnnnnn
    boxes[0..m_nr].each{|box|
      (box.y .. box.y+@n-1).each{|y| 
        (box.x .. box.x+@n-1).each{|x| @w[xmax*y + x] = 1 }
      }}
    #　有効なcellに頭からの通し番号を振る
    #  STDの場合
    #    boxは一つ
    #    @w  0 1 2 3 4 5 6 7 8  nil
    #            :
    #        72 .....        80 nil
    #        nnnnnnnnnn 
    c = 0
    (0..@w.size-1).each{|x| 
      if @w[x] ;@w[x]=[c,[]];  c += 1; end
    }
    @size = c

    # $cells を作る。空で。 set_grpの準備
    @cells  = Array.new

    # $grps を作る。 空サイズで作った後埋める
    @gsize = set_grp(infile,boxes,bx,by,xmax,@w,sep)
    
    #pp $cells
    #pp $grps
    [xmax,ymax]
  end

  def ban_initialize(w,n,xmax,ymax)
    w.each{|ww|
      next unless ww
      j=ww[0]
      #pp [ww[0],ww[1]]
      #cell=@cells[ww[0]] = Cell.new(@groups,ww[0],@n,ww[1]) #(cell_nr,grp_list)
      cell=@cells[ww[0]] = Number::Cell.new(self,ww[0],ww[1], @count) #(cell_nr,grp_list)
      ww[1].each{|grp_no| @groups[grp_no].addcellList ww[0] }
    }
    # get neighber
    @neigh=[]
    (0..ymax-1).each{|y|      base=xmax*y
      (0..xmax-1).each{|x|
        next unless w[base+x]
        @neigh << [w[base+x][0],w[base+x+1][0]]    if w[base+x+1]
        @neigh << [w[base+x][0],w[base+x+xmax][0]] if w[base+x+xmax]
      }}
    initialize_group_ability
  end 

  def  initialize_group_ability
    @groups.each{|grp| grp.ability.setup_initial(grp.cellList) }    
  end

  def waku_out(w,n,gnr,cnr,xmax,ymax)
    # size
    $stderr.printf "%d %d %d\n", n,cnr,gnr

    # cell-group
    w.each{|ww|
      $stderr.puts ww.flatten.join(" ") if ww 
    }

    #neigber
    (0..ymax-1).each{|y|      base=xmax*y
      (0..xmax-1).each{|x|
        next unless w[base+x]
        $stderr.puts "#{w[base+x][0]} #{w[base+x+1][0]}"    if w[base+x+1]
        $stderr.puts "#{w[base+x][0]} #{w[base+x+xmax][0]}" if w[base+x+xmax]
      }}
  end


  def set_grp(infile,boxes,bx,by,xmax,w,sep)
    maxgnr = boxes.size*@n*2
    gnr = 0
    gnr = set_vertical_holizontal_group(gnr,boxes,xmax,w)
    gnr = set_block_group(gnr,boxes,bx,by,xmax,w,infile,sep)
    gnr = set_optional_group(gnr,boxes,bx,by,xmax,w,infile,sep)
    gnr
  end
  
  def set_optional_group(gnr,boxes,bx,by,xmax,w,infile,sep)
  end

  def set_block_group(gnr,boxes,bx,by,xmax,w,infile,sep)
    boxes.each{|box|  
      (box.y .. box.y+@n-1).step(by).each{|y| 
        (box.x .. box.x + @n-1).step(bx).each{|x|
          #next if w[xmax*y+x].nil?     #or w[xmax*y+x][1]
          unless  w[xmax*y+x].nil? 
            #@groups[gnr] =  Group.new(@cells,gnr,@n,:block)
            @groups[gnr] =  Number::Group.new(self,gnr,:block)
            (y .. y+by-1).each{|yy| 
              (x .. x+bx-1).each{|xx| w[xmax*yy+xx][1]<< gnr }
            }
            gnr += 1
          end
        }
      }
    }
    gnr
  end

  def set_vertical_holizontal_group(gnr,boxes,xmax,w)
    boxes.each{|box|
      (box.y .. box.y+@n-1).each{|y|
        #@groups[gnr] =  Group.new(@cells,gnr,@n,:holizontal)
        @groups[gnr] =  Number::Group.new(self,gnr,:holizontal)
        (box.x .. box.x + @n-1).each{|x|
          w[xmax*y+x][1] << gnr 
        }
        gnr += 1
      }
      (box.x .. box.x+@n-1).each{|x|
        #@groups[gnr] =  Group.new(@cells,gnr,@n,:vertical)
        @groups[gnr] =  Number::Group.new(self,gnr,:vertical)
        (box.y .. box.y + @n-1).each{|y| w[xmax*y+x][1] << gnr }
        gnr += 1 
      }
    }
    gnr
  end
  def setBasePos(mult,sign,mnr,dan)
    offset = {'-' => 6, '+' => -6 }
    boxes =   Array.new(mnr)

    box = Number::Box.new(@n,-6,-6)
    wbox=Number::Box.new(@n)
    bnr = -1
    xmin = 0
    xmax = 0
    y = -6
    (0..dan-1).each{|dan|
      box.p = box + [offset[sign[dan]],6]
      wbox.p = box.p
      xmin = wbox.x if ( xmin > wbox.x )
      (0..mult[dan]-1).each{|b|
        bnr += 1
        boxes[bnr] = Number::Box.new(@n,wbox.p)
        xmax = wbox.x+@n if  xmax < wbox.x+@n
        wbox.p = wbox+ [12,0]
      }

    }
    if xmin != 0
      boxes.each{|b| b.x = (b.x - xmin) }
      xmax -= xmin
    end

    [boxes,xmax,box.y+@n]
  end

  def get_baseSize(struct)
    mult = struct.split(/[-+]/)         #
    n = mult.shift                    # Gameの基本サイズ
    if /\d+x\d+/ =~ n
      bx,by = n.split("x")
      bx=bx.to_i; by=by.to_i;n=bx*by
    else
      n=n.to_i ;   bx = by = (Math.sqrt(n)+0.2).to_i
    end
    if mult.size == 0
      mult =[1]
      mnr = 1
      dan = 1
      sign = ['-']
    else
      mult = mult.map{|c| c.to_i}       # 各段のBOX数
      mnr =  mult.inject(0){|s,i| s+i}   # BOX数合計　箱の数　Mnr
      dan = mult.size      	    # 箱の重なり段数  Dan   3 = struct.split(/[-+]/).size
      sign = struct.split(/\d+/)[1..-1]
    end
    # pp ["struct,n,mult,sign",struct,n,mult,sign]
    # pp ["Mnr,Dan",mnr,dan]
    [[n,bx,by],mult,sign,mnr,dan ]
  end
end
end


#main(struct)

__END__
箱の重なり横数  Retsu 5  アルゴリズム考えよう
重なり総行数    Lines 21 = Dan * 6 + 3
重なり総欄数    Raws  33 = Retsu * 6 + 3
重複BOXの数　   Dnr   8   適切なアルゴリズムがないなぁ
  line数        Lnr  72   Mnr * 9
  raw数         Rnr  72   Mnr * 9
  box数         Bnr  64   Mnr*9 - Dnr
Group数         Gnr 108   Lnr + Cnr + Gnr
Cell数          Cnr 576   Mnr * 81 - Dnr * 9 = 8*81 - 8*9 = 8*72
0....5....1....5....2....5....3....5....4....5....5
      123456789...123456789...123456789......
0....56.......4...
......111111111.............111111111........
......111111111.............111111111........
......111111111.............111111111........
......111111111.............111111111........
......111111111.............111111111........

......111111111.............111111111.............1
......111111111.............111111111.............1
......111111111.............111111111.............1
......111111111.............111111111.............1
......111111111.............111111111.............1
......111111111.............111111111.............1
......111111111.............111111111.............1
......111111111.............111111111..............
......111111111....................................
