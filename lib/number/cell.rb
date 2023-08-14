# frozen_string_literal: true

module Number
  class Cell
    attr_accessor :game, :groups, :valu, :c, :ability, :grpList, :option

    def self.create(arg_game, cell_no, arg_grpList, count, option: {})
      cell = new(arg_game, cell_no, arg_grpList, count, option: option)
      cell.setup
    end
    def initialize(arg_game, cell_no, arg_grpList, count, option: {})
      @game = arg_game
      @c = cell_no
      @grpList = arg_grpList
      @count = count
      @option = option
      #pp [:option,option]
    end

    def setup
      @n = @game.n
      @ability = (1..@n).map { |v| v }
      @valu = nil
      @val = (1..@n).to_a
      @groups = @game.groups
      self
    end
    
    def inspect
      super +
        %i[c valu grpList ability].map { |sym| "  @#{sym}=#{send(sym).inspect}" }.join
    end

    def related_groups
      related_groups_no.map { |g| @groups[g] }
    end

    def related_groups_no
      holizontal, vertical, block, = grpList
      (@groups[block].line_groups_join_with +
        @groups[holizontal].block_groups_join_with +
        @groups[vertical].block_groups_join_with) - grpList
    end

    attr_reader :ability

    def v
      @valu
    end

    def valurest
      @ability.size
    end

    def vlist
      @valu ? [@valu] : @ability # .select{|a| a>0}
    end

    def is_even
      vlist.select(&:odd?).empty?
    end

    def is_odd
      vlist.select(&:even?).empty?
    end

    def set_even(msg = nil)
      return nil if valu

      puts(msg || "set even cell #{c}") if option[:verb]
      (1..@n).step(2) { |v| rmAbility(v) }
    end

    def set_odd(msg = nil)
      return nil if valu

      puts(msg || "set odd cell #{c}") if option[:verb]
      (2..@n).step(2) { |v| rmAbility(v) }
    end

    def set_if_valurest_equal_1
      return nil unless valurest == 1 && !v

      set(ability[0])
    end

    def set(v, msg = 'rest_one')
      @count['Cell_ability is rest one'] += 1
      set_cell(v, msg)
    end

    def set_cell(v, msg = 'rest one')
      return nil if @valu || v && !@ability.include?(v)

      # $gsw = true

      # if v.nil? and @ability.size == 1 ; v= @ability[0] ; end
      printf "Set cell %2d = %2d. by #{msg} \n", @c, v if option[:verb]

      @valu = v
      msg = "#{msg} : cell #{@c}"
      # このcellから全valueの可能性をなくす
      # self.rmAbility(@val,msg)
      rmCellAbilityFromGroupsOfGroupList(@ability)
      @ability = []

      # この value を grpの他のcellから可能性削除する
      @grpList.each do |grp|
        @groups[grp].rmAbility(v, [@c], msg)
      end
    end

    def rmAbility(v0, msg = '')
      ret = nil
      vv = if v0.instance_of?(Array)
             v0
           else
             [v0]
           end
      v_remove = vv & @ability
      if v_remove.size.positive?
        print " rmAbility cell #{@c} v=[#{v_remove.join(',')}]. by #{msg}\n" if option[:verb]
        ret = $gsw = true
        @ability -= v_remove
        rmCellAbilityFromGroupsOfGroupList(v_remove)
      end
      ret
    end

    def rmCellAbilityFromGroupsOfGroupList(v_remove, msg = nil)
      @grpList.each do |grp|
        @groups[grp].rmCellAbility(v_remove, c, msg)
      end
    end
  end
end
