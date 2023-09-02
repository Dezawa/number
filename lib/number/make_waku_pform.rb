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
      @waku = Number::Waku.create(self, form_type)
      @game_scale = @waku.game_scale
      @m = @waku.m
      @waku.cells_init

      @size = @waku.cells.reject(&:nil?).size

      # $grps を作る。 空サイズで作った後埋める
      @gsize = @waku.set_grp
      @gsize = optional_group(@gsize, @waku.boxes, @waku.xmax, @waku.cells)

      # [xmax, ymax]
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
