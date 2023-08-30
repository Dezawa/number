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
    def make_waku_pform(form_type)
      @game_scale, group_width, group_hight, mult, sign, m_nr, dan = base_size(form_type)
      @m = Math.sqrt(game_scale).to_i
      boxes, xmax, ymax = base_pos(mult, sign, m_nr, dan) # Boxを作り、各Boxの左上の座標を得る
      @waku = Number::Waku.new(self, boxes, game_scale, @count, [xmax, ymax])

      @size = @waku.cells.reject(&:nil?).size

      # $grps を作る。 空サイズで作った後埋める
      @gsize = @waku.set_grp(group_width, group_hight)
      @gsize = optional_group(@gsize, boxes, xmax, @waku.cells)

      [xmax, ymax]
    end

    def ban_initialize(waku, _game_scale, xmax, ymax)
      waku.cells.each do |cell|
        next if cell.nil?

        # @cells[cell.c] = Number::Cell.create(self, cell.c[0], cell[1], @count, option: option) # (cell_nr,group_ids)
        cell.group_ids.each { |grp_no| @groups[grp_no].addcell_ids cell.c }
      end

      @neigh = neighber(waku.cells, xmax, ymax)
      initialize_group_ability
    end

    def neighber(cells, xmax, ymax)
      (0...(xmax * ymax - xmax)).map { |x| [[cells[x].c, cells[x + 1].c], [cells[x].c, cells[x + xmax].c]] }
                                .flatten(1).select { |c0, c1| c0 && c1 }
    end

    def initialize_group_ability
      @groups.each { |grp| grp.ability.setup_initial(grp.cell_ids) }
    end

    def optional_group(gnr, boxes, xmax, cells); end

    def base_pos(mult, sign, mnr, dans)
      bnr = -1
      boxes, xmin, y_pos = create_boxes_for_all(bnr, mnr, mult, sign, dans)

      reset_xmax(xmin, boxes)
      [boxes, @xmax + 1, y_pos + game_scale + 1]
    end

    def create_boxes_for_all(bnr, mnr, mult, sign, dans)
      xmin = 0
      box = Number::Box.new(game_scale, -6, -6)
      boxes = Array.new(mnr)
      wbox = Number::Box.new(game_scale)
      offset = { '-' => 6, '+' => -6 }
      (0...dans).each do |dan|
        box.p = box + [offset[sign[dan]], 6]
        wbox.p = box.p
        xmin = wbox.x_pos if xmin > wbox.x_pos
        @xmax = create_boxes_for_dan(mult[dan], xmin, bnr, boxes, wbox)
      end
      [boxes, xmin, box.y_pos]
    end

    def create_boxes_for_dan(dan, _xmin, bnr, boxes, wbox)
      @xmax = 0
      (0...dan).each do |_b|
        bnr += 1
        boxes[bnr] = Number::Box.new(game_scale, wbox.p)
        @xmax = wbox.x_pos + game_scale if @xmax < wbox.x_pos + game_scale
        wbox.p = wbox + [12, 0]
      end
      @xmax
    end

    def reset_xmax(xmin, boxes)
      return unless xmin != 0

      boxes.each do |b|
        pp [:pos, b]
        b.x_pos = (b.x_pos - xmin)
      end
      @xmax -= xmin
    end

    def base_size(struct)
      mult = struct.split(/[-+]/)
      n, group_width, group_hight = mult_params(mult)
      mult, mnr, dan, sign = mult_struct(mult)
      [n, group_width, group_hight, mult, sign, mnr, dan]
    end

    def mult_params(mult)
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
      [n, group_width, group_hight]
    end

    def mult_struct(mult)
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
      [mult, mnr, dan, sign]
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
