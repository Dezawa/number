# frozen_string_literal: true

require 'singleton'

module Number
  class NullCell
    include Singleton
    def nil?
      true
    end
  end

  # 9x9の枠内の 枡
  class Cell
    attr_accessor :game, :groups, :valu, :c, :ability, :group_ids, :option, :game_scale

    def nil?
      false
    end

    def self.create(arg_game, cell_no, arg_group_ids, count, option: {})
      cell = new(arg_game, cell_no, arg_group_ids, count, option: option)
      cell.setup
    end

    def initialize(arg_game, cell_no, arg_group_ids, count, option: {})
      @game = arg_game
      @c = cell_no
      @group_ids = arg_group_ids
      @count = count
      @option = option
    end

    def setup
      @game_scale = @game.game_scale
      @ability = (1..game_scale).map { |v| v }
      @valu = nil
      @val = (1..game_scale).to_a
      @groups = @game.groups
      self
    end

    def inspect
      super +
        %i[c valu group_ids ability].map { |sym| "  @#{sym}=#{send(sym).inspect}" }.join
    end

    def v
      @valu
    end

    def fill?
      !!valu
    end

    def valurest
      @ability.size
    end

    def vlist
      @valu ? [@valu] : @ability # .select{|a| a>0}
    end

    def even?
      vlist.select(&:odd?).empty?
    end

    def odd?
      vlist.select(&:even?).empty?
    end

    def set_even(msg = nil)
      return nil if valu

      puts(msg || "set even cell #{c}") if option[:verb]
      (1..game_scale).step(2) { |v| rm_ability(v) }
    end

    def set_odd(msg = nil)
      return nil if valu

      puts(msg || "set odd cell #{c}") if option[:verb]
      (2..game_scale).step(2) { |v| rm_ability(v) }
    end

    def set_if_valurest_equal_one
      return nil unless valurest == 1 && !v

      set(ability[0])
    end

    def set(val, msg = 'rest_one')
      @count['Cell_ability is rest one'] += 1
      set_cell(val, msg)
    end

    def set_cell(val, msg = 'rest one')
      return nil if @valu || val && !@ability.include?(val)

      # if v.nil? and @ability.size == 1 ; v= @ability[0] ; end
      printf "Set cell %2d = %2d. by #{msg} \n", @c, val if option[:verb]

      @valu = val
      msg = "#{msg} : cell #{@c}"
      # このcellから全valueの可能性をなくす
      # self.rm_ability(@val,msg)
      rm_cell_ability_from_groups_of_group_list(@ability)
      @ability = []

      # この value を grpの他のcellから可能性削除する
      @group_ids.each do |grp|
        @groups[grp].rm_ability(val, [@c], msg)
      end
    end

    def rm_ability(rm_value, msg = '')
      ret = nil
      vv = [rm_value].flatten(1)
      v_remove = vv & @ability
      if v_remove.size.positive?
        print " rm_ability cell #{@c} v=[#{v_remove.join(',')}]. by #{msg}\n" if option[:verb]
        ret = @gsw = true
        @ability -= v_remove
        rm_cell_ability_from_groups_of_group_list(v_remove)
      end
      ret
    end

    def rm_cell_ability_from_groups_of_group_list(v_remove, msg = nil)
      @group_ids.each do |grp|
        @groups[grp].rm_cell_ability(v_remove, c, msg)
      end
    end
  end
end
