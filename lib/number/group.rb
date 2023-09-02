# frozen_string_literal: true

module Number
  # 行、列、ブロックを総称
  class Group
    attr_accessor :game, :n, :game_scale, :g, :ability, :cell_ids, :atrivute, :count

    def initialize(arg_game, arg_gnr, count, atr = [])
      @game = arg_game
      game_scale = @game.game_scale
      @g = arg_gnr
      # @cells = @game.cells
      @ability = Number::GroupAbilities.new(game_scale)
      @cell_ids = []
      @atrivute = atr # :holizontal :vertical  :block
      @count = count
    end

    def inspect
      g_atrivute_cell_ids = %i[g atrivute cell_ids].map { |sym| "  @#{sym}=#{send(sym).inspect}" }.join
      ability = @ability.ability.map { |abl| "         #{abl.inspect}" }.join("\n")
      "#<Group:#{object_id} #{g_atrivute_cell_ids}\n  @ability=[\n#{ability}"
    end

    def holizontal?
      atrivute == :holizontal
    end

    def vertical?
      atrivute == :vertical
    end

    def block?
      atrivute == :block
    end

    def cells
      cell_ids.map { |c_no| game.cells[c_no] }
    end

    # 数字残り可能性数 が v_num以下のcell
    def cell_ids_avility_le_than(v_num)
      cell_ids.select { |c_no| (1..v_num).include?(game.cells[c_no].valurest) }
    end

    def type
      @atrivute
    end

    def addcell_ids(cell_id)
      # puts "group:#{g}, add cell #{cell_id}   "
      @cell_ids << cell_id
    end

    def line_groups_join_with
      cell_ids.inject([]) { |g_nrs, c| g_nrs | @game.cells[c].group_ids } - [g]
    end

    def block_groups_join_with
      cell_ids.inject([]) { |g_nrs, c| g_nrs << @game.cells[c].group_ids[2] }.uniq
    end

    def rm_cell_ability(values, cell_no, msg = nil)
      @ability.rm_cell_ability(values, cell_no, msg)
    end

    def set_cell_if_some_value_s_ability_is_rest_one
      sw = nil
      cells = []
      ability.fixed_by_rest_one.each do |group_ability|
        # next unless group_ability.cell_ids.first
        next unless @game.cells[group_ability.cell_ids.first].set(group_ability.v,
                                                                  "grp(#{g}).ability #{group_ability.cell_ids}")

        game.count[:Group_ability_is_rest_one] += 1
        cells += group_ability.cell_ids
        sw = true
      end
      cells
    end

    # このgroupの値 v
    def rm_ability(rm_value, except_cells = [], msg = '')
      # このgrpに属する各cellの値vの可能性を調べ、残っていたら
      # 可能性を削除する
      # ただし、array except_cells  にある cell はいじらない。
      # vが配列の場合は、その中をすべて
      rm_value = [rm_value].flatten
      rm_cells = @cell_ids - except_cells
      ret = nil
      rm_cells.each do |c0| # (0..game_scale-1).each{|c| c0=@cell_ids[c]
        if (@game.cells[c0].ability & rm_value).size.positive?
          @game.cells[c0].rm_ability(rm_value, msg)
          ret = true
        end
      end
      ret
    end
  end
end
####
