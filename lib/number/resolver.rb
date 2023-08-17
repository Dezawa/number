# frozen_string_literal: true

# < Array
module Number
  # 解法
  module Resolver
    def cogroup(cells)
      return [] if cells.empty?

      cells[1..].inject(@cells[cells[0]].grp_list) { |groups, c| groups & @cells[c].grp_list }
    end

    def cocell(grps)
      return [] if grps.size < 2

      grps[1..].inject(groups[grps[0]].cell_list) { |cells, group| cells & groups[group].cell_list }
    end

    def fill?
      @cells.select { |cell| cell.v.nil? }.empty?
    end

    def gout
      pp( # .ability.map { |abl| [grp.g, abl] if (abl[0]).positive? }.compact })
        groups.map do |grp|
          ["Group #{grp.g}:", grp.cell_list]
        end
      )
    end

    def cout
      @cells.each { |cell| puts "#{cell.c} : #{cell.ability}" unless cell.v }
    end

    ##############
    def rest_one
      # (1) 可能な値が一つだけになった　cell　を確定する
      # (2) ある値の可能性あるcellが一つになったら、そのcellを確定する

      sw = true
      ret = false
      while sw
        sw = false

        # (1) cell Ability
        @cells.each { |cell| sw |= cell.set_if_valurest_equal_1 }

        # (2) group ability [ 可能性cell数 , [cell_no,cell_no,, ], 値 ]
        @groups.each { |grp| sw |= grp.set_cell_if_some_value_s_ability_is_rest_one }
        ret |= sw
      end
      ret
    end

    ########
    # 定員
    # N個のcellには v1,v2,,,vn なるN種の値しか入らないとき、
    # これらのcellが属するgroupの他のcell には　v1,v2,,,は入らない
    ########
    ###########################################################
    def prison(v_num)
      # 残り可能性の数　2,,v_num なcellを拾い上げる
      # 同じ「残り可能性」なcellの組み合わせを探し、v_numあればhit
      @groups.each do |grp|
        cells = grp.cell_list.select { |c| @cells[c].valurest > 1 && @cells[c].valurest <= v_num }
        cells.combination(v_num) do |cc|
          next if prison_done[v_num].include? cc

          valus = cc.map { |c| @cells[c].ability }.inject([]) { |val, abl| val | abl }
          if valus.size == v_num #  このgrpでこれらのcellは vals が定員
            @count["prison#{v_num}"] += 1
            # このcellを含むgrpの 他のcellにあるｖの可能性を消す
            cogroup(cc).each do |grp0|
              msg = "prison#{v_num} grp #{grp.g} val #{valus} cell #{cc}"
              @groups[grp0].rm_ability(valus, cc, msg)
            end
            prison_done[v_num] << cc
            return true
          end
        end
      end
      nil
    end

    def prison_done
      @prison_done ||= Hash.new { |h, k| h[k] = [] }
    end

    ###########################################################
    # 予約席
    # あるgroupで 値  v1,v2,,,vn がr入り得るcellがN個だけだったら、
    # それらの cell にはn他の値は入れない
    #
    def reserv(v_num)
      # group において、可能性ある cell が v_num個以下の値を探す
      # それらの v_num個のcombinationのうち、
      # cell数が v_num 個であるものを得る
      # それらの cell ではそれらの値以外ははいらない
      @groups.each do |group|
        group.ability.combination_of_ability_of_rest_is_less_or_equal(v_num) # [[[2,[28,29],7], [2,[28,29],9]]]
             .each do |abl_cmb|
          values, rm_cells = sum_of_cells_and_values(abl_cmb)
          next if prison_done[v_num].include? rm_cells # value_cell[1]

          rm_value = @val - values
          next unless (rm_cells.map { |c| @cells[c].ability }.flatten - values).size.positive?

          rm_cells.each do |c|
            msg = "reserve#{v_num} group #{group.g} cells#{rm_cells} v=#{values}"
            @cells[c].rm_ability(rm_value, msg)
          end
          @count["reserv#{v_num}"] += 1
          prison_done[v_num] << rm_cells
          return true
        end
      end
      nil
    end

    def sum_of_cells_and_values(abilitys)
      abilitys.each_with_object([[], []]) do |ac, vc| # ac = [ count,[cells],value]
        vc[0] << ac.v # [2]  # value
        vc[1] |= ac.cell_list # [1]  # cell
      end
    end

    def not_fill
      ret = nil
      (1..@cells.size - 1).each { |c| @cells[c].ability[0].zero? && ret = true }
      ret
    end

    def fail
      @cells[1..].inject([]) { |values, cell| values | cell.ability }.size.positive?
    end

    ########################### 上級モード Level-1
    ##########################
    # こういう関係では @ には 1,2 が入る。
    # 上中央のblockに注目すると、$$&%% のいずれかに 1,2が入る。
    #   @ には 1,2 のいずれかが入るから、&%%に1,2の両方が入ることはできない
    #   よって $$のどちらかに2,1が入ることになる。
    #   $$@で1,2がはいるから、| には1,2は入らない。
    # 同じように、+ には1,2は入れない。
    # ...$68...
    # ++.&%%++@
    # .6.$79..4
    # .8.@....5
    # .4.837..6
    # .3.695..7
    # .7.4....9
    # .5.|....8
    # ...|....3
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
      ret = nil
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
          cell_pair.each do |cell|
            msg = "curb: cogroup([#{c},#{cell.c}])=> #{groups[cogroup([c, cell.c]).first].g}" \
                  " 対角線[#{cell_pair[0].c},#{cell_pair[1].c}] values=#{values} "

            ret |= groups[cogroup([c, cell.c]).first]
                   .rm_ability(values, cells_on_the_co_group_and_block(c, cell.c), msg)
          end
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
          (cell1.grp_list & cell2.grp_list).empty?
      end
    end

    # 二つのcellを対角線とする長方形の残りのcell
    def theother_cells_of_rectangle_which_made_by_diagonal_of(cells)
      xross_cells = cells[0].grp_list.product(cells[1].grp_list)
                            .map { |grps| cocell(grps) }.flatten
      xross_cells.size == 2 ? xross_cells : []
    end

    def cells_not_on_the_v_or_h_group_of_the_group_of(cell)
      h, v, b = cells[cell].grp_list.sort
      groups[b].cell_list - groups[h].cell_list - groups[v].cell_list
    end

    # cellsのabilityに値v0,v1があるか
    def cells_ability_values?(c_nrs, values)
      (c_nrs.inject([]) { |ablty, c| ablty | cells[c].vlist } & values).size.positive?
    end

    # cell c と cell_nr の共通group のcell　でかつ c のblock上のもの
    def cells_on_the_co_group_and_block(cell0, cell1)
      (groups[cogroup([cell0, cell1]).first].cell_list &
        groups[cells[cell0].grp_list.max].cell_list) - [cell0] + [cell1]
    end

    ##########################
    # こういう関係で１があるとき、＊の位置に１があったらそれは削除
    # *.1..1..1
    # .........
    # .........
    # ..1.*1..1
    # .........
    # .........
    # ..1..1*.1
    # .........
    # .........
    #
    # (1) :holizontal なgroupについて、値v　をとり得るcellの数が2,,@m であるグループを集める grps1
    #      grps1 = [ count, group ,[cells], [co_groups] ]  count <- cell数、co_?groups <- (2)
    # (2) そのcellを共有する:verticalなgroupを集める。[co_groups]
    # (3) それぞれの grps1から g_nums(2..@m)個づつの組み合わせをつくり cmb_grp
    # (4) co_groups のuniq がg_numsに等しい組み合わせを残す
    # 　　　複数のBOXな場合要吟味。重なる:block上に対象となるcellがあるという特殊な場合以外は行けるかも
    #
    # (5) このco_groupsから値vの可能性を削除する。except cells
    #
    # これを g_nums 2,,@m について繰り返し、:holizontal と :vertical を入れ替えて行う
    #

    def cross_teiin
      ret = false
      h_v_table = %i[holizontal vertical]
      # h_v
      h_v_table.each_with_index  do |h_v, idx|
        v_h = h_v_table[1 - idx] # 　holizontal と :vertical について
        # value
        (1..game_scale).each do |v| # (1) 値v　をとり得る
          vsw = false
          grps1 = groups_remain_2_or_m_cells_of_value_is(h_v, v_h, v)
          #  [count , grp,  cells, co_groups]

          # (3) それぞれの cell grps1[2,g_nums]から g_numsつづつの組み合わせをつくり cmb_grp
          # g_nums
          (2..@m).each do |g_nums|
            # combination
            grps1.select { |grp| grp[0] <= g_nums }
                 .combination(g_nums).each do |cmb_grp|
              # (4) co_groups のuniq がg_numsに等しい組み合わせを残す
              next unless (rm_grps = cmb_grp.map do |grp|
                             grp[3]
                           end.flatten.uniq).size == g_nums

              # (5) このco_groupsから値vの可能性を削除する。except cells
              # pp [v,cmb_grp[3]]
              except_cells = cmb_grp.map do |co_grp1|
                co_grp1[2]
              end.flatten.uniq
              rm_grps.each do |g|
                msg = "cross_teiin v=#{v}, grps=#{cmb_grp.map { |cg| cg[1].g }.join(',')}"
                removed = @groups[g].rm_ability(v, except_cells, msg)
                next unless removed

                vsw = ret = option[:gsw] = true
              end
            end
          end
          @count['X wing'] += 1 if vsw
          # return true
        end
      end
      # これを g_nums 2,,@m について繰り返し、:holizontal と :vertical を入れ替えて行う
      #
      option[:cross] = nil
      ret # false
    end

    def groups_remain_2_or_m_cells_of_value_is(h_v, v_h, valu)
      @groups.map do |grp|
        next unless (grp.type == h_v) && # 　　 :holizontal なgroupについて、
                    ((count = grp.ability[valu].rest) <= @m) && # 値valu　をとり得るcellの数が2,,@m である
                    (count > 1) #      grp を集め

        # (2) そのcellを共有する:verticalなgroupを集める。[co_groups]
        cells = grp.ability[valu].cell_list
        co_groups = cells.map { |c| cogroup([c]).select { |g| @groups[g].type == v_h }.flatten }
        [count, grp, cells, co_groups]
      end.compact
    end

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

    def high_class
      [method(:cross_teiin), method(:curb)]
    end
  end
end
