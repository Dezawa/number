# frozen_string_literal: true

module Number
  module GameTypes
    # DIFFのextend
    module GameType
      def game
        'DIFF'
      end

      # module Optional
      def optional_struct(_sep, _game_scale, infile)
        get_arrow(infile)
      end
      # end

      def optional_test
        #################
        puts 'optional'
        # def diff(arrow)
        cell_id = []
        sw = nil
        @arrows.each do |arw|
          (dif, cell_id[0], cell_id[1]) = arw
          abiable_combination_of_valu(dif, cell_id)

          [0, 1].each { |idx| sw ||= fix_or_rm_ability(abiable, cell_id, idx) }
        end
        sw
      end

      def abiable_combination_of_valu(dif, cell_id)
        values = @cells[cell_id[0]].vlist.product(@cells[cell_id[1]].vlist)
                                   .select { |v1, v2| (v1 - v2).abs == dif }
        [values.map(&:first).uniq.sort, values.map(&:last).uniq.sort]
      end

      def fix_or_rm_ability(abiable, cell_id, idx)
        if abiable[idx].size == 1
          @cells[cell_id[idx]].set(abiable[idx][0])
        elsif abiable[idx].size.positive? # 二つ以上だったら、
          # それ以外の数字をそのcellの可能性から消す
          vv = @cells[cell_id[idx]].vlist - abiable[i]
          @cells[cell_id[idx]].rm_ability(vv)
        end
      end
    end
  end
end
