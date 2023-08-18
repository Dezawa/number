# frozen_string_literal: true

module Number
  # Groupに残された可能性
  class GroupAbilities
    attr_accessor :game_scale, :ability

    def initialize(game_scale)
      @game_scale = game_scale
      @ability = [] # Hash.new #{|h,k| h[k] = [game_scale,[],k] }
    end

    def setup_initial(cell_list)
      (1..game_scale).each { |v| @ability[v] = Number::GroupAbility.new(game_scale, cell_list.dup, v) }
      # @ability[0]= GroupAbility.new(0,cell_list.dup,0)
    end

    def rm_cell_ability(values, cell_no, _msg = nil)
      # このgrpの値 v　から指定cellの可能性をなくす
      values.each { |v| @ability[v].rm_cell_ability(cell_no) }
    end

    def fixed_by_rest_one
      @ability[1..].select { |abl| abl.rest == 1 }
    end

    # v_num個の同じ「可能性数字」を持つv_num個のcellの組み合わせを返す
    # [[[2,[28,29],7], [2,[28,29],9]]] <= cell 28,29 には数字7,9のみが入る
    #   [可能性残り数、[cell_id,,,], 値]
    def combination_of_ability_of_rest_is_less_or_equal(v_num)
      @ability[1..].select { |abl| abl.rest > 1 and abl.rest <= v_num }
                   .combination(v_num)
                   .select { |abl_cmb| abl_cmb.inject([]) { |cells, abl| cells | abl.cell_list }.size == v_num }
    end

    def [](idx)
      @ability[idx]
    end

    def []=(idx, val)
      @ability[idx] = val
    end

    def dump
      ability[1..].map(&:dump)
    end

    def dup
      ablty = clone
      ablty.ability[1..].each { |abl| abl.cell_list = abl.cell_list.dup }
      ablty
    end
  end
end

module Number
  # Groupに残された可能性
  # Group毎に game_scale個作成される。数字ｖ毎に一つ。
  class GroupAbility
    # rest :: 数字v が入る可能性が残っている cell の数。初めはgame_scale。
    # cell_list :: このgroupに属する cell の nrの一覧
    attr_accessor :rest, :cell_list, :v

    def initialize(game_scale, arg_cell_list, arg_v)
      @cell_list = arg_cell_list
      @rest = game_scale
      @v = arg_v
    end

    def rm_cell_ability(cell_no, msg = nil)
      return unless cell_list.delete(cell_no)

      @rest -= 1
      puts msg if msg
    end

    def inspect
      "[#{rest},[#{cell_list.join(',')}],#{v}]"
    end

    def dump
      [rest, cell_list, v]
    end
  end
end
