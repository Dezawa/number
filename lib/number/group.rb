# frozen_string_literal: true

module Number
  class Group
    attr_accessor :game, :cells, :n, :game_scale, :g, :ability, :cell_list, :atrivute, :count

    def initialize(arg_game, arg_g, atr = [], count)
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

    attr_reader :g, :cell_list

    def addcell_list(a)
      @cell_list << a
    end

    def is_block?
      @atrivute == :block
    end

    def line_groups_join_with
      cell_list.inject([]) { |g_nrs, c| g_nrs | @cells[c].grp_list } - [g]
    end

    def block_groups_join_with
      cell_list.inject([]) { |g_nrs, c| g_nrs << @cells[c].grp_list[2] }.uniq
    end

    def rmCellAbility(v0, cell_no, msg = nil)
      @ability.rmCellAbility(v0, cell_no, msg)
    end

    def set_cell_if_some_value_s_ability_is_rest_one
      sw = nil
      ability.fixed_by_rest_one.each do |cellData|
        if @cells[cellData.cell_list.first].set(cellData.v, "grp(#{g}).ability #{cellData.cell_list}")
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
