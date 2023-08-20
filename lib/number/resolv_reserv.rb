# frozen_string_literal: true

require_relative './resolv_reserv'
module Number
  # 解法
  module ResolvReserv
    ###########################################################
    # 予約席
    # あるgroupで 値  v1,v2,,,vn がr入り得るcellがN個だけだったら、
    # それらの cell にはn他の値は入れない ⇒ 削除対象
    # その数字は他のcellには入らない
    def reserv(v_num)
      # group において、可能性ある cell が v_num個以下の数字を探す
      # それらのcellに他の数字の可能性が有ってもよい。
      # それらの v_num個のcombinationのうち、
      # cell数が v_num 個であるものを得る
      # それらの cell ではそれらの値以外ははいらない
      @groups.each do |group|
        candidate_reserved_set(v_num, group)
          .each do |values, reserved_cells, _abl_cmb|
          rm_value = values_to_rm(reserved_cells, values)
          reserved_cells.each do |c|
            msg = "reserve#{v_num} group #{group.g} cells#{reserved_cells} v=#{values}"
            @cells[c].rm_ability(rm_value, msg)
          end
          @count["reserv#{v_num}"] += 1
          prison_done[v_num] << reserved_cells
          return "reserv(#{v_num}): cells:#{reserved_cells}, values:#{values}"
        end
      end
      ''
    end

    # reserve の対象となる cell set の候補
    def candidate_reserved_set(v_num, group)
      group.ability.combination_of_ability_of_rest_is_less_or_equal(v_num) # [[[2,[28,29],7], [2,[28,29],9]]]
           .map do |abl_cmb|
        values, reserved_cells = sum_of_cells_and_values(abl_cmb)
        [values, reserved_cells, abl_cmb]
      end
           .select do |values, reserved_cells, _abl_cmb|
        !prison_done?(v_num, reserved_cells) && values_to_rm(reserved_cells, values).size.positive?
      end
    end

    # abilitys :: [ [grp_ability, grp_abirity], [], , ,]
    #  => [[val1, val2], [[1,2], [3, 4, 5] ]
    def sum_of_cells_and_values(abilitys)
      abilitys.each_with_object([[], []]) do |ac, vc| # ac = [ count,[cells],value]
        vc[0] << ac.v # [2]  # value
        vc[1] |= ac.cell_list # [1]  # cell
      end
    end

    def values_to_rm(reserved_cells, values)
      (reserved_cells.map { |c| @cells[c].ability }.flatten.uniq - values)
    end
  end
end
