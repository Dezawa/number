# frozen_string_literal: true

require_relative './resolv_reserv'
module Number
  # 解法
  module Resolver
    include ResolvReserv
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
      cells = []
      while sw
        sw = false

        # (1) cell Ability
        @cells.each do |cell|
          result = cell.set_if_valurest_equal_1
          cells << cell.c if result
          sw |= result
        end
        # (2) group ability [ 可能性cell数 , [cell_no,cell_no,, ], 値 ]
        @groups.each do |grp|
          fixed_cells = grp.set_cell_if_some_value_s_ability_is_rest_one
          unless fixed_cells.empty?
            sw |= true
            cells += fixed_cells
          end
        end
        ret |= sw
      end

      cells.empty? ? '' : " rest_one cells=#{cells}"
    end

    ########
    # 座敷牢
    # N個のcellには v1,v2,,,vn なるN種の数字しか入らないとき、
    # これらのcellが属するgroupの他のcell には　v1,v2,,,は入らない
    # この数字が N個以外のcellに可能性が有ってもよい。それは削除対象
    ########
    ###########################################################
    def prison(v_num)
      # 残り可能性の数　2,,v_num なcellを拾い上げる
      # 同じ「残り可能性」なcellの組み合わせを探し、v_numあればhit
      ret = []
      @groups.each do |grp|
        ret << prisonable_cells(grp, v_num)
               .reject { |cc, _values| prison_done[v_num].include?(cc) }
               .map do |cc, values|
          @count["prison#{v_num}"] += 1

          # このcellを含むgrpの 他のcellにあるｖの可能性を消す
          cogroup(cc).each do |grp0|
            msg = "prison#{v_num} grp #{grp0} val #{values} cells exept #{cc}"
            @groups[grp0].rm_ability(values, cc, msg)
          end
          prison_done[v_num] << cc
          [cc, values]
        end
      end
      ret = ret.delete_if(&:empty?).flatten(1)
      return '' if ret.empty?

      ret.uniq.map { |cc, values| "cels#{cc},vlues#{values}" }.join('   ')
      "prison(#{v_num}): [cells, values] #{ret}"
    end

    def prison_done
      @prison_done ||= Hash.new { |h, k| h[k] = [] }
    end

    def prison_done?(v_num, cells)
      prison_done[v_num].include? cells
    end

    # prison対象のcellの組み合わせを返す。
    # grp にて、
    # 可能性残り数が v_num個以下のcellの
    # v_num個の組み合わせの中で
    # 可能性数字種類が v_num個の組み合わせを返す。
    # それらの 数字が他のcellに有っても良い。それは可能性削除対象
    # 戻り値 :: [ [cell_list, 数字list], [ ],,, ]
    def prisonable_cells(grp, v_num)
      # 数字残り可能性数 が v_num以下のcell
      able_cells = grp.cell_list_avility_le_than(v_num)

      # それらの v_num個のcombinationのうち、数字種類がv_num個のもの
      # [ [cell_ids, valus], [ ],,]
      able_cells.combination(v_num).map do |cc|
        values = cc.map { |c| cells[c].ability }.flatten.uniq
        [cc, values] if values.size == v_num
      end.compact
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

    def rm_values_from_cells_and_group(values, _cell, cell_pair, _cogroup)
      cell_pair.each do |cell|
        msg = "curb: cogroup([#{c},#{cell.c}])=> #{groups[cogroup([c, cell.c]).first].g}" \
              " 対角線[#{cell_pair[0].c},#{cell_pair[1].c}] values=#{values} "

        ret | groups[cogroup([c, cell.c]).first]
              .rm_ability(values, cells_on_the_co_group_and_block(c, cell.c), msg)
      end
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
              rm_grps = cmb_grp.map { |grp| grp[3] }.flatten.uniq
              next unless rm_grps.size == g_nums

              # (5) このco_groupsから値vの可能性を削除する。except cells
              # pp [v,cmb_grp[3]]
              rm_v_from_co_groups(v, cmb_grp, rm_grps)
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

    def rm_v_from_co_groups(value, cmb_grp, rm_grps)
      except_cells = cmb_grp.map do |co_grp1|
        co_grp1[2]
      end.flatten.uniq
      rm_grps.each do |g|
        msg = "cross_teiin v=#{value}, grps=#{cmb_grp.map { |cg| cg[1].g }.join(',')}"
        removed = @groups[g].rm_ability(value, except_cells, msg)
        next unless removed

        option[:gsw] = true
      end
    end

    def groups_remain_2_or_m_cells_of_value_is(h_v, v_h, valu)
      @groups.map do |grp|
        count = grp.ability[valu].rest
        next unless (grp.type == h_v) && # 　　 :holizontal なgroupについて、
                    (count <= @m) && # 値valu　をとり得るcellの数が2,,@m である
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
    # :cross_teiin, :curb
  end
end
