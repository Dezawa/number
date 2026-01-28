# frozen_string_literal: true

module Number
  # 解法

  ######################
  # 可能性が下のような場合は、+ は可能性落とす。
  # 0609-119
  #  @ 6 1 . 9 . 3 @ 5
  #  5 @ 9 3 6 1 @ 7 2
  #  3 7 2 8 4 5 9 1 6
  #  + 3 * 5 1 . @ 2 9
  #  7 2 * 6 3 9 1 @ 4
  #  9 1 . . 2 8 . . 3
  #  2 * * 9 7 3 5 . 1
  #  . 9 7 . 5 6 . 3 8
  #  . 5 3 . 8 . . 9 7

  # そのための関数
  # :cross_teiin, :curb
  module ResolvCurb
    # こういう関係では A,B は 1,2 が入る。
    # 上中央のblockに注目すると、$$C%% のいずれかに 1,2が入る。
    #   A には 1,2 のいずれかが入るから、C%%に1,2の両方が入ることはできない
    #   よって $$のどちらかに2,1が入ることになる。
    #   $$Aで1,2がはいるから、* には1,2は入らない。
    # 同じように、+ には1,2は入れない。
    # ...|$68|...
    # ++.|C%%|++B
    # .6.|$79|..4
    # -----------
    # .8.|A..|..5
    # .4.|837|..6
    # .3.|695|..7
    # -----------
    # .7.|4..|..9
    # .5.|*...|.8
    # ...|*...|.3
    #
    # == 「こういう関係」
    # 残り可能性が２でかつ同じ値 V1,V2をもつcell A,B が対角線の位置にある
    # その長方形の残りの頂点 C を含む block G に着目
    # G上にあり、AC,BCのライン上にない 4つのcellのいずれもが、V1,V2の
    # 可能性も、決定もしていなければ、
    # 仮抑えのカーブ
    def curb
      # 1. 残り可能性二つのcellを得る
      # 2. それらのcombinationを作り、
      # 3. そのうち 同じ数値の組み合わせのものを残す　cell A,B に v1,v2とする
      # 4. それらを対角線とする長方形の残りの頂点のcell C,Dを得る
      # 5. C,D 各々が属する block上で、AC,BC 上にないcell(4つ)を求め
      # 6. その4つのcellにV1,V2 がありうるか見る）
      cell_combinations_rest_is_2_and_same_value.map do |cell_pair| # 1,2,3 残り可能性二つのcell
        # pp ["curb",cell_pair.map{|cell| cell.c}]
        theother_cells_of_rectangle_which_made_by_diagonal_of(cell_pair) # 4.その対角線のcell [0, 53]
          .each do |c|
          next unless c

          values = cell_pair.first.ability
          next if cells_ability_values?( # 6
            cells_not_on_the_v_or_h_group_of_the_group_of(c), # 5.
            values
          )

          # cell c と cell_nrs の共通group のcellから、v1,v2の可能性を削除する
          rm_values_from_cells_and_group(values, c, cell_pair, cogroup)
        end
      end
      nil
    end

    def cell_combinations_rest_is_2_and_same_value
      @cells.select { |cell| cell.valurest == 2 }
            .combination(2).select do |cell1, cell2|
        # 3. そのうち 同じ数値の組み合わせのものを残す　cell1,2に　v1,v2とする
        # 4. そのうち 共通するgroupが無いものを残す
        #
        cell1.ability == cell2.ability &&
          (cell1.group_ids & cell2.group_ids).empty?
      end
    end

    # 二つのcellを対角線とする長方形の残りのcell
    def theother_cells_of_rectangle_which_made_by_diagonal_of(cells)
      xross_cells = cells[0].group_ids.product(cells[1].group_ids)
                            .map { |grps| cocell(grps) }.flatten
      xross_cells.size == 2 ? xross_cells : []
    end

    def cells_not_on_the_v_or_h_group_of_the_group_of(cell)
      h, v, b = cells[cell].group_ids.sort
      groups[b].cell_ids - groups[h].cell_ids - groups[v].cell_ids
    end

    # cellsのabilityに値v0,v1があるか
    def cells_ability_values?(c_nrs, values)
      (c_nrs.inject([]) { |ablty, c| ablty | cells[c].vlist } & values).size.positive?
    end

    # cell c と cell_nr の共通group のcell　でかつ c のblock上のもの
    def cells_on_the_co_group_and_block(cell0, cell1)
      (groups[cogroup([cell0, cell1]).first].cell_ids &
        groups[cells[cell0].group_ids.max].cell_ids) - [cell0] + [cell1]
    end

    def rm_values_from_cells_and_group(values, c_cell, cell_pair, _cogroup)
      cell_pair.each do |cell|
        groups[cogroup([c_cell, cell.c]).first]
          .rm_ability(values,
                      cells_on_the_co_group_and_block(c_cell, cell.c),
                      curb_msg(c_cell, cell, cell_pair))
      end
    end

    def curb_msg(c_cell, cell, cell_pair)
      "curb: cogroup([#{c_cell},#{cell.c}])=> #{groups[cogroup([c_cell, cell.c]).first].g}" \
      " 対角線[#{cell_pair[0].c},#{cell_pair[1].c}] values=#{values} "
    end
  end
end
