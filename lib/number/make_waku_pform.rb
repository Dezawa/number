# frozen_string_literal: true

###############################
MEMO = <<~EOMEMO

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
     該当する ban[ ] に　cell_no, line,raw,box 番号を入れる。
             line,raw は2つまで入る　groupとしては3〜5
             すでにcell_noが入っていたら　++しない

  waku は
     ban[x,y].eachにて、cell_noが入っているものを出力する
  隣は x+/- 1, y+/-1 のbanを書き出す

  pform　は
  　　。。。

EOMEMO
######################################
# struct = ARGV.shift #"9" #9-3+4-3"
module Number
  # gameのformを設定するextend
  module GamePform
    def make_waku_pform(struct)
      n, mult, sign, m_nr, dan = base_size(struct)
      @game_scale, group_width, group_hight = n
      @val = (1..game_scale).to_a

      @m = Math.sqrt(game_scale).to_i
      boxes, xsize, ysize = base_pos(mult, sign, m_nr, dan) # Boxを作り、各Boxの左上の座標を得る

      xmax = xsize + 1
      ymax = ysize + 1
      @w = Array.new(xmax * ymax, nil)
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
      boxes[0..m_nr].each do |box|
        (box.y_pos..box.y_pos + game_scale - 1).each do |y|
          (box.x_pos..box.x_pos + game_scale - 1).each { |x| @w[xmax * y + x] = 1 }
        end
      end
      # 　有効なcellに頭からの通し番号を振る
      #  STDの場合
      #    boxは一つ
      #    @w  0 1 2 3 4 5 6 7 8  nil
      #            :
      #        72 .....        80 nil
      #        nnnnnnnnnn
      c = 0
      (0..@w.size - 1).each do |x|
        if @w[x]
          @w[x] = [c, []]
          c += 1
        end
      end
      @size = c

      # $cells を作る。空で。 set_grpの準備
      @cells  = []

      # $grps を作る。 空サイズで作った後埋める
      @gsize = set_grp(boxes, group_width, group_hight, xmax, @w, sep)

      # pp $cells
      # pp $grps
      [xmax, ymax]
    end

    def ban_initialize(waku, _game_scale, xmax, ymax)
      waku.each do |ww|
        next unless ww

        ww[0]
        # pp [ww[0],ww[1]]
        # cell=@cells[ww[0]] = Cell.new(@groups,ww[0],game_scale,ww[1]) #(cell_nr,grp_list)
        @cells[ww[0]] = Number::Cell.create(self, ww[0], ww[1], @count, option: option) # (cell_nr,grp_list)
        ww[1].each { |grp_no| @groups[grp_no].addcell_list ww[0] }
      end
      # get neighber
      @neigh = []
      (0..ymax - 1).each do |y|
        base = xmax * y
        (0..xmax - 1).each do |x|
          next unless waku[base + x]

          @neigh << [waku[base + x][0], waku[base + x + 1][0]]    if waku[base + x + 1]
          @neigh << [waku[base + x][0], waku[base + x + xmax][0]] if waku[base + x + xmax]
        end
      end
      initialize_group_ability
    end

    def initialize_group_ability
      @groups.each { |grp| grp.ability.setup_initial(grp.cell_list) }
    end

    def set_grp(boxes, group_width, group_hight, xmax, waku, _sep)
      boxes.size
      gnr = 0
      gnr = set_vertical_holizontal_group(gnr, boxes, xmax, waku)
      gnr = set_block_group(gnr, boxes, group_width, group_hight, xmax, waku)
      set_optional_group(gnr, boxes, group_width, group_hight, xmax, waku)
    end

    def set_optional_group(gnr, boxes, group_width, group_hight, xmax, waku); end

    def set_block_group(gnr, boxes, group_width, group_hight, xmax, waku)
      boxes.each do |box|
        (box.y_pos..box.y_pos + game_scale - 1).step(group_hight).each do |y|
          (box.x_pos..box.x_pos + game_scale - 1).step(group_width).each do |x|
            # next if waku[xmax*y+x].nil?     #or waku[xmax*y+x][1]
            next if waku[xmax * y + x].nil?

            # @groups[gnr] =  Group.new(@cells,gnr,game_scale,:block)
            @groups[gnr] = Number::Group.new(self, gnr, :block, @count)
            (y..y + group_hight - 1).each do |yy|
              (x..x + group_width - 1).each { |xx| waku[xmax * yy + xx][1] << gnr }
            end
            gnr += 1
          end
        end
      end
      gnr
    end

    def set_vertical_holizontal_group(gnr, boxes, xmax, waku)
      boxes.each do |box|
        (box.y_pos..box.y_pos + game_scale - 1).each do |y|
          # @groups[gnr] =  Group.new(@cells,gnr,game_scale,:holizontal)
          @groups[gnr] = Number::Group.new(self, gnr, :holizontal, @count)
          (box.x_pos..box.x_pos + game_scale - 1).each do |x|
            waku[xmax * y + x][1] << gnr
          end
          gnr += 1
        end
        (box.x_pos..box.x_pos + game_scale - 1).each do |x|
          # @groups[gnr] =  Group.new(@cells,gnr,game_scale,:vertical)
          @groups[gnr] = Number::Group.new(self, gnr, :vertical, count)
          (box.y_pos..box.y_pos + game_scale - 1).each { |y| waku[xmax * y + x][1] << gnr }
          gnr += 1
        end
      end
      gnr
    end

    def base_pos(mult, sign, mnr, dans)
      offset = { '-' => 6, '+' => -6 }
      boxes = Array.new(mnr)

      box = Number::Box.new(game_scale, -6, -6)
      wbox = Number::Box.new(game_scale)
      bnr = -1
      xmin = 0
      xmax = 0
      (0..dans - 1).each do |dan|
        box.p = box + [offset[sign[dan]], 6]
        wbox.p = box.p
        xmin = wbox.x_pos if xmin > wbox.x_pos
        (0..mult[dan] - 1).each do |_b|
          bnr += 1
          boxes[bnr] = Number::Box.new(game_scale, wbox.p)
          xmax = wbox.x_pos + game_scale if xmax < wbox.x_pos + game_scale
          wbox.p = wbox + [12, 0]
        end
      end
      if xmin != 0
        boxes.each { |b| b.x = (b.x - xmin) }
        xmax -= xmin
      end

      [boxes, xmax, box.y_pos + game_scale]
    end

    def base_size(struct)
      mult = struct.split(/[-+]/) #
      n = mult.shift # Gameの基本サイズ
      if /\d+x\d+/ =~ n
        group_width, group_hight = n.split('x')
        group_width = group_width.to_i
        group_hight = group_hight.to_i
        n = group_width * group_hight
      else
        n = n.to_i
        group_width = group_hight = (Math.sqrt(n) + 0.2).to_i
      end
      if mult.empty?
        mult = [1]
        mnr = 1
        dan = 1
        sign = ['-']
      else
        mult = mult.map(&:to_i) # 各段のBOX数
        mnr =  mult.inject(0) { |s, i| s + i } # BOX数合計　箱の数　Mnr
        dan = mult.size # 箱の重なり段数  Dan   3 = struct.split(/[-+]/).size
        sign = struct.split(/\d+/)[1..]
      end
      # pp ["struct,n,mult,sign",struct,n,mult,sign]
      # pp ["Mnr,Dan",mnr,dan]
      [[n, group_width, group_hight], mult, sign, mnr, dan]
    end
  end
end

# main(struct)

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
