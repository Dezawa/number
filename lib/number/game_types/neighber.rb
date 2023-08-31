# frozen_string_literal: true

# module Optional
require 'English'
module Number
  module GameTypes
    # NEIGHBERのextend
    module GameType
      def game
        'NEIGHBER'
      end

      def optional_struct(_sep, _game_scale, infile)
        # @arrows は、隣同士で一つ違いのcellの組み合わせ
        # $neigh は、初期値は隣同士のcell、このmethodの結果、二つ以上違うcellの組み合わせとなる
        @summax = 20
        @arrows = []
        while (line = gets_skip_comment(infile))
          @arrows << line.split.map(&:to_i)
        end
        @nei = @neigh.dup
        @arrows.each { |arw| @neigh.delete(arw.sort) }
      end

      def optional_test
        #################
        @optsw = nil
        neigh_test2 && rest_one
        @optsw
      end

      ##############
      # arrow 1つ1つについて調べる
      def neigh_test2
        ret = false

        # 効率化のため組み合わせの数が大きくならないように制限する数を
        # 少しずつ大きくする。  このとき小さすぎると一つも解決できず、
        # 失敗で終わってしまうので、ある程度までは成功したことにする
        @summax += 5

        @arrows.each do |arrow|
          dbgout arrow

          # 指定されたcellに残っている値の配列  の配列
          vlist_list = arrow.map { |c| @cells[c].vlist }

          # 大サイズの場合は組み合わせが膨大になってしまうのでパスしておくことにしよう
          next if vlist_list.flatten.size > @summax

          # 侯補絞りこみ
          candidates = candidate_list(vlist_list)
          candidates.each_with_index do |candidate, c|
            if candidate.size == 1
              print ' cell.set by neigh @size==1 ' if option[:dbg]

              @cells[arrow[c]].set(candidate[0], "neiber test2 arrow [#{arrow.join ','}]")
              @optsw = true
            elsif candidate.size > 1
              ret |= rm_ability_exept_candidates(@cells[arrow[c]], candidate, arrow)
            end
          end
        end
        ret
      end

      # 残っている値の全組み合わせの中で、ひとつずつ増減しているものを残す
      #    ソートしても同じ並びで、最初と最後の差がサイズで合計が合ってる
      def candidate_list(vlist_list)
        candidate = vlist_list[0].product(*vlist_list[1..]).select do |w|
          # ww = []
          # ww = w.sort.map.with_index { |v, i| v - i }
          # ww.uniq.size == 1 &&
          #  (w.sort == w || w.sort { |a, b| b <=> a } == w)
          w.size == (w.max - w.min + 1)
        end

        candidates = candidate[0].zip(*candidate[1..])
        dbgout_neigh(candidates)
        candidates
      end

      def rm_ability_exept_candidates(cell, candidate, arrow)
        vv = cell.vlist - candidate
        if vv.size.positive?
          cell.rm_ability(vv, "rm_ability by neiber test2[#{arrow.join(',')}]")
          ret = @gsw = @optsw = true
        end
        ret
      end

      def dbgout(arrow)
        if option[:dbg]
          print '## neighber arrow'
          p arrow
        end
        return unless option[:dbg] && option[:cout]

        (1..@cells.size - 1).each do |c|
          printf '%<cell_id>2d %<rest>d', cell_id: c, rest: @cells[c].valurest
          p @cells[c].ability
        end
      end

      def dbgout_neigh(candidates)
        return unless option[:dbg]

        candidate_cell_values = candidates[0].zip(*candidates[1..])
        print '  neigh '
        p candidate_cell_values
      end
    end
  end
end
