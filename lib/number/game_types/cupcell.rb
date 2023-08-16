# frozen_string_literal: true

####
module Number
  class Cell
    def even_only?
      @valu&.even? ||
        !@valu &&  @ability.select(&:odd?).empty?
      # (1..game_scale).step(2).map{|v| @ability[v] if @ability[v]>0 }.compact.size==0
    end

    def odd_only?
      @valu&.odd? ||
        !@valu &&  @ability.select(&:even?).empty?
      # (2..game_scale).step(2).map{|v| @ability[v] if @ability[v]> 0 }.compact.size==0
    end
  end
end

module Number
  module GameTypes
    module GameType
      def game
        'CUPCELL'
      end

      # coding: euc-jp
      # module Optional
      def optional_struct(_sep, _n, infile)
        get_arrow(infile)
      end
      # end

      def ddrest_one
        puts 'rest_one'
        return nil unless super

        puts 'rest_one end'
        optional_test
      end

      # (arrow)
      def optional_test
        # pp arrow
        #################
        # 1. only_test
        #   pairの一つのcellがe/oいずれかしか候補が残っていない場合は
        #   反対のcellはo/eである
        # 2. reserve
        #    pairがともに一つのGroupに属し、かつそのgroupに残るe/oの可能性が
        #    一つしか残されていない場合、そのpair cellはそのe/oに予約される
        ##################
        @arrows.delete_if do |pair|
          # pp [@cells[pair[0]].ability[0],@cells[pair[1]].ability[0]]
          @cells[pair[0]].v && @cells[pair[1]].v
        end

        @arrows.each do |pair|
          only_test(pair) && @arrows.delete(pair)
          reserve(pair) && @arrows.delete(pair)
        end
        $gsw
      end

      def only_test(pair)
        # pp pair
        2.times do |i|
          c = pair[i]
          c1 = pair[1 - i]
          # pp @cells[c].ability
          if @cells[c].even_only?
            @cells[c1].set_odd("#{c1} odd by pair[#{pair.join(',')}]")
            $gsw = true
            return true
          end
          next unless @cells[c].odd_only?

          @cells[c1].set_even("#{c1} even by pair[#{pair.join(',')}]")
          $gsw = true
          return true
        end
        false
      end

      # piar の両方に入る　e/o　が一つしかなくかつ同じものだったら
      # その二つのcellが指定席。　同じグループの他のcellには入らない。
      def reserve(pair)
        # 二つのcellが共に属するgroupを得る。少なくとも一つある
        groups = cogroup(pair)

        # pairの二つのcellにe/oが一種しか入らず、かつ同じであったら
        # このgroupの他のcellにはこの数字は入らない
        # どちらかが確定していたら、対象外

        # 確定していたら対象外
        return false if @cells[pair[0]].v || @cells[pair[1]].v

        # 可能性のpair
        abilitys = pair.map { |c| @cells[c].ability }

        # pp [groups,abilitys]
        # evenについて調べる
        even = abilitys.map { |ab| ab.select { |i| i.positive? && i.even? } }
        # pp [even,(even[0] & even[1])]
        if even[0].size == 1 && even[1].size == 1 && (even[0][0] == even[1][0])
          # このevenの値が予約される
          v = even[0][0]
          # pp "# このevenの値が予約される #{v}"
          groups.each { |grp| @groups[grp].rmAbility(v, pair, "cupcell [#{pair.join(',')}]") }
        end

        # oddについて調べる
        odd = abilitys.map { |ab| ab.select(&:odd?) }
        return unless odd[0].size == 1 && odd[1].size == 1 && (odd[0] & odd[1]).size == 1

        # このevenの値が予約される
        v = (odd[0] & odd[1])[0]
        groups.each { |grp| @groups[grp].rmAbility(v, pair, "cupcell [#{pair.join(',')}]") }
      end
      # class Groups
      #  extend GroupsCupcell
      # end
    end
  end
end
