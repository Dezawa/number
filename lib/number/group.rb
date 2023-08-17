# frozen_string_literal: true

module Number
  # 行、列、ブロックを総称
  class Group
    attr_accessor :game, :cells, :n, :game_scale, :g, :ability, :cell_list, :atrivute, :count

    def initialize(arg_game, arg_g, count, atr = [])
      @game = arg_game
      game_scale = @game.game_scale
      @g = arg_g
      @cells = @game.cells
      @ability = Number::GroupAbilities.new(game_scale)
      @cell_list = []
      @atrivute = atr # :holizontal :vertical  :block
      @count = count
    end

    def inspect
      "#<Group:#{object_id} " +
        %i[g atrivute cell_list].map { |sym| "  @#{sym}=#{send(sym).inspect}" }.join +
        "\n  @ability=[\n" +
        @ability.ability.map { |abl| "         #{abl.inspect}" }.join("\n")
    end

    def type
      @atrivute
    end

    def addcell_list(cell)
      @cell_list << cell
    end

    def line_groups_join_with
      cell_list.inject([]) { |g_nrs, c| g_nrs | @cells[c].grp_list } - [g]
    end

    def block_groups_join_with
      cell_list.inject([]) { |g_nrs, c| g_nrs << @cells[c].grp_list[2] }.uniq
    end

    def rm_cell_ability(values, cell_no, msg = nil)
      @ability.rm_cell_ability(values, cell_no, msg)
    end

    def set_cell_if_some_value_s_ability_is_rest_one
      sw = nil
      ability.fixed_by_rest_one.each do |cell_data|
        if @cells[cell_data.cell_list.first].set(cell_data.v, "grp(#{g}).ability #{cell_data.cell_list}")
          @count[:Group_ability_is_rest_one] += 1
          sw = true
        end
      end
      sw
    end

    # このgroupの値 v
    def rm_ability(rm_value, except_cells = [], msg = '')
      # このgrpに属する各cellの値vの可能性を調べ、残っていたら
      # 可能性を削除する
      # ただし、array except_cells  にある cell はいじらない。
      # vが配列の場合は、その中をすべて
      v = [rm_value] unless v.instance_of?(Array)
      rm_cells = @cell_list - except_cells
      ret = nil
      rm_cells.each do |c0| # (0..game_scale-1).each{|c| c0=@cell_list[c]
        if (@cells[c0].ability & v).size.positive?
          @cells[c0].rm_ability(v, msg)
          ret = true
        end
      end
      ret
    end
  end
end
####
