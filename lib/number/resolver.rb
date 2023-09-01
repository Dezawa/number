# frozen_string_literal: true

require_relative './resolv_reserv'
require_relative './resolv_curb'
require_relative './resolv_prison'
require_relative './resolv_cross'
module Number
  # 解法
  module Resolver
    include ResolvReserv
    include ResolvCurb
    include ResolvPrison
    include ResolvCross
    # Cell達に共通なGroup
    # cell_ids :: Cell#c
    # 戻り値 :: [group_id, group_id, , ,] まあ有っても最大4つ。
    def cogroup(cell_ids)
      return [] if cell_ids.empty?

      cell_ids[1..].inject(@cells[cell_ids[0]].group_ids) { |groups, c| groups & @cells[c].group_ids }
    end

    # Group達に共通なCell
    # group_ids :: Group#g
    # 戻り値 :: [cell_id, cell_id, , ]
    def cocell(group_ids)
      return [] if group_ids.size < 2

      group_ids[1..].inject(groups[group_ids[0]].cell_ids) { |cells, group_id| cells & groups[group_id].cell_ids }
    end

    # 全て埋まったら true
    def fill?
      @cells.select { |cell| cell.v.nil? }.empty?
    end

    # option -g のときに Groupの状態を印刷
    def gout
      pp( # .ability.map { |abl| [grp.g, abl] if (abl[0]).positive? }.compact })
        groups.map do |grp|
          ["Group #{grp.g}:", grp.cell_ids]
        end
      )
    end

    # option -c のときに 埋まっていないCellの残ってる可能性を印刷
    def cout
      @cells.each { |cell| puts "#{cell.c} : #{cell.ability}" unless cell.v }
    end

    ##### 解への技 #########
    # (1) 可能な値が一つだけになった　cell　を確定する
    #   ⇒ ここには 1しか入らない
    # (2) ある値の可能性あるcellが一つになったら、そのcellを確定する
    #   ⇒ 1 はここにしか入らない
    def rest_one
      sw = true
      cells = []
      while sw
        sw = false

        # (1) cell Ability
        @cells.each do |cell|
          result = cell.set_if_valurest_equal_one
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

    def prison_done
      @prison_done ||= Hash.new { |h, k| h[k] = [] }
    end

    def prison_done?(v_num, cells)
      prison_done[v_num].include? cells
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
    # cross_teiin(X-wing)、 座敷牢、予約席、curb はくくりだしてある
    # curb はひねり出したが使われていない感
    # xy-wing は実装していないが、これもなくても行けてる
    ##########################
    ##########################
  end
end
