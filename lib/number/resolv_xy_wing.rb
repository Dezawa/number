# frozen_string_literal: true

module Number
  # 解法
  module ResolvXyWing
    def xy_wing
      candidate_cells_of_trio.each do |wing_cells|
        target_val = (wing_cells.first.ability & wing_cells.last.ability).first
        co_cells_of_pair_grp_of(wing_cells).each do |co_cells|
          co_cells.each do |cell|
            @count['xy_wing'] += 1 if cell.rm_ability(target_val)
          end
        end
      end
    end

    # 対角にあるpair_cellsの3つのgroup同士が重なる部分のcell
    def co_cells_of_pair_grp_of(pair_cells)
      pair_cells.first.group_ids.product(pair_cells.last.group_ids)
                .map { |grp_id0, grp_id1| groups[grp_id0].co_cell_ids(groups[grp_id1]) }
                .reject(&:empty?)
                .map { |ids| ids.map { |id| cells[id] } }
    end

    # 戻り値は  [ wing, wing ] の arry
    def candidate_cells_of_trio
      trio_cells_of_3_values.select { |trio| not_on_the_same_group(trio) }
                            .map { |trio| join_by_co_group(trio) }
                            .compact
    end

    #  [1, 2], [1, 3], [2, 3]
    def trio_cells_of_3_values
      rest_two_cells.combination(3)
                    .select { |cell3| cell3.map(&:ability).flatten.tally.values == [2, 2, 2] }
    end

    def rest_two_cells
      cells.select { |cell| cell.valurest == 2 }
    end

    # 3つが同じgroupに属していたらそれは xy-wingではなく 座敷牢
    def not_on_the_same_group(trio)
      # pp [trio.map(&:c), trio.map(&:group_ids),trio.map(&:group_ids).inject{|common, grp| common & grp }]
      trio.map(&:group_ids).inject { |common, grp| common & grp }.empty?
    end

    # 2cellづつの組み合わせ3組のうち2組は co groupがある
    # 戻り値はwingのcell
    def join_by_co_group(trio)
      combinations = trio.combination(2).to_a # [[0, 1], [0, 2], [1, 3]] の順
      co_groups = combinations.map { |c0, c1| c0.group_ids & c1.group_ids }
      # co group の数の順にsortして、2つ目が 0 ということは
      # 同じgroupに乗っているのはたかだか1組
      return nil if co_groups.map(&:size).sort[0, 2] == [0, 0]

      # 3組ともco groupがある、ということはないから、2,1,0 1,1,0 のどれか。
      # 0 の組み合わせが wing両端
      idx = co_groups.find_index(&:empty?)
      return nil unless idx

      combinations[idx]
    end
  end
end
