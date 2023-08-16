# frozen_string_literal: true

module Number
  class GroupAbilities
    attr_accessor :game_scale, :ability

    def initialize(arg_n)
      @game_scale = arg_n
      @ability = [] # Hash.new #{|h,k| h[k] = [game_scale,[],k] }
    end

    def setup_initial(cell_list)
      (1..game_scale).each { |v| @ability[v] = Number::GroupAbility.new(game_scale, cell_list.dup, v) }
      # @ability[0]= GroupAbility.new(0,cell_list.dup,0)
    end

    def rmCellAbility(v0, cell_no, _msg = nil)
      # このgrpの値 v　から指定cellの可能性をなくす
      v0.each { |v| @ability[v].rmCellAbility(cell_no) }
    end

    def fixed_by_rest_one
      @ability[1..].select { |abl| abl.rest == 1 }
    end

    def combination_of_ability_of_rest_is_less_or_equal(v_num)
      @ability[1..].select { |abl| abl.rest > 1 and abl.rest <= v_num }
                   .combination(v_num)
                   .select { |abl_cmb| abl_cmb.inject([]) { |cells, abl| cells | abl.cell_list }.size == v_num }
      # [[[2,[28,29],7], [2,[28,29],9]]]
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
  class GroupAbility
    attr_accessor :rest, :cell_list, :v

    def initialize(arg_n, arg_cell_list, arg_v)
      @cell_list = arg_cell_list
      @rest = arg_n
      @v = arg_v
    end

    def rmCellAbility(cell_no, msg = nil)
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
