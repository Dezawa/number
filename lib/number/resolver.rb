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
    def cogroup(cells)
      return [] if cells.empty?

      cells[1..].inject(@cells[cells[0]].group_ids) { |groups, c| groups & @cells[c].group_ids }
    end

    def cocell(grps)
      return [] if grps.size < 2

      grps[1..].inject(groups[grps[0]].cell_ids) { |cells, group| cells & groups[group].cell_ids }
    end

    def fill?
      @cells.select { |cell| cell.v.nil? }.empty?
    end

    def gout
      pp( # .ability.map { |abl| [grp.g, abl] if (abl[0]).positive? }.compact })
        groups.map do |grp|
          ["Group #{grp.g}:", grp.cell_ids]
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
    ##########################
    ##########################
  end
end
