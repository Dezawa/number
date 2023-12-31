# frozen_string_literal: true

module Number
  # X-wingと言われているらしい
  module ResolvCross
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
    # X-wingと言われているらしい
    def cross_teiin
      ret = ''
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
          if vsw
            @count['X wing'] += 1
            ret = 'x-wing'
          end
          # return true
        end
      end
      # これを g_nums 2,,@m について繰り返し、:holizontal と :vertical を入れ替えて行う
      #
      option[:cross] = nil
      ret # false

      # msg = ''
      # (1..game_scale).each do |v| # (1) 値v　をとり得る
      #   vsw = false
      #   grps1 = groups_remain_2_or_m_cells_of_value_is(:holizontal, :vertical, v)
      #   #  [count , grp,  cells, co_groups]

      #   # (3) それぞれの cell grps1[2,g_nums]から g_numsつづつの組み合わせをつくり cmb_grp
      #   # g_nums
      #   (2..@m).each do |g_nums|
      #     # combination
      #     grps1.select { |count, _grp, _cells, _co_groups| count <= g_nums }
      #          .combination(g_nums).each do |cmb_grp|
      #       # (4) co_groups のuniq がg_numsに等しい組み合わせを残す
      #       # (5) このco_groupsから値vの可能性を削除する。except cells
      #       vsw = select_cmb_grp_and_rm(cmb_grp, g_nums, v)
      #   if vsw
      #     @count['X wing'] += 1
      #     msg = "grp #{g_nums}, val #{v}"
      #   end
      #     end
      #   end
      #   # return true
      # end
      # # end
      # # これを g_nums 2,,@m について繰り返し、:holizontal と :vertical を入れ替えて行う
      # #
      # option[:cross] = nil
      # msg # false
    end

    def select_cmb_grp_and_rm(cmb_grp, g_nums, rm_v)
      # (4) co_groups のuniq がg_numsに等しい組み合わせを残す
      rm_grps = cmb_grp.map { |_count, _grp, _cells, co_groups| co_groups }.flatten.uniq
      return unless rm_grps.size == g_nums

      # (5) このco_groupsから値vの可能性を削除する。except cells
      # pp [v,cmb_grp[3]]
      rm_v_from_co_groups(rm_v, cmb_grp, rm_grps)
    end

    def rm_v_from_co_groups(value, cmb_grp, rm_grps)
      ret = false
      except_cells = cmb_grp.map do |co_grp1|
        co_grp1[2]
      end.flatten.uniq
      rm_grps.each do |g|
        msg = "cross_teiin v=#{value}, grps=#{cmb_grp.map { |cg| cg[1].g }.join(',')}"
        removed = @groups[g].rm_ability(value, except_cells, msg)
        next unless removed

        option[:gsw] = true
        ret = true
      end
      ret
    end

    def groups_remain_2_or_m_cells_of_value_is(h_v, v_h, valu)
      groups_remain = groups_remain_2_or_m_cells(h_v, valu)
      # (2) そのcellを共有する:verticalなgroupを集める。[co_groups]
      co_groups_of(groups_remain, v_h, valu)
    end

    def groups_remain_2_or_m_cells(h_v, valu)
      @groups.select do |grp|
        count = grp.ability[valu].rest
        (grp.type == h_v) && (2..@m).include?(count) # 　　 :holizontal なgroupについて、
        #           (count <= @m) && # 値valu　をとり得るcellの数が2,,@m である
        #           (count > 1) #      grp を集め
      end
    end

    def co_groups_of(groups_remain, v_h, valu)
      groups_remain.map do |grp|
        count = grp.ability[valu].rest
        cells = grp.ability[valu].cell_ids
        co_groups = cells.map { |c| cogroup([c]).select { |g| @groups[g].type == v_h }.flatten }
        [count, grp, cells, co_groups]
      end.compact
    end
  end
end
