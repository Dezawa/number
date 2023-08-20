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

      def optional_struct(_sep, _n, infile)
        # @arrows は、隣同士で一つ違いのcellの組み合わせ
        # $neigh は、初期値は隣同士のcell、このmethodの結果、二つ以上違うcellの組み合わせとなる
        @summax = 20
        @arrows = []
        while infile.gets && ($LAST_READ_LINE =~ /^\s*#/ || $LAST_READ_LINE =~ /^\s*$/); end
        w = []
        $LAST_READ_LINE.split.each { |c| w << c.to_i }
        @arrows << w
        while infile.gets && $LAST_READ_LINE =~ /^\s*\d+\s+\d+/
          w = []
          $LAST_READ_LINE.split.each { |c| w << c.to_i }
          @arrows << w
        end
        $nei = @neigh.dup
        @arrows.each { |arw| @neigh.delete(arw.sort) }
      end
      # end

      def optional_test
        #################
        $optsw = nil
        neigh_test1 && rest_one # 2以上離れているべきは、離れているか
        # arrow.each{|arw| neigh_test2(arw)} && rest_one  # 隣り合っているべきは隣り合っているか
        neigh_test2 && rest_one
        neigh_test3(@cells) && rest_one
        neigh_test4 && rest_one
        # puts "$optsw = #{$optsw}"
        $optsw
      end

      def neigh_test1
        # 2以上離れているべきは、離れているか
        ret = false
        @neigh.each do |neigh|
          c0 = @cells[neigh[0]]
          c1 = @cells[neigh[1]]
          case [!c0.v.nil?, !c1.v.nil?]
          when [true, true] then next # 両方決まり
          when [true, false] then v0 = c0.v
                                  c = c1
                                  neighber = neigh[0]
          when [false, true] then v0 = c1.v
                                  c = c0
                                  neighber = neigh[1]
          else; next
          end
          if false
            if c0.v
              next if c1.v; # $neigh.delete(neigh) ;

              # 両方決まり

              v0 = c0.v
              c = c1
            else
              next unless c1.v

              v0 = c1.v
              c = c0

            end
          end
          # cc0,cc1 について
          c.vlist.each do |v|
            next unless (v0 - v).abs < 2

            if $dbg
              print 'rm_ability by neiber '
              p neigh
            end
            c.rm_ability(v, "rm_ability by neiber test1:cell #{neighber}=#{v0}")
            ret = @gsw = $optsw = true
          end
        end
        ret
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
          if $dbg
            print '## neighber arrow'
            p arrow
          end
          if option[:dbg] && option[:cout] && (1..@cells.size - 1).each do |c|
               printf '%2d %d', c, @cells[c].valurest
               p @cells[c].ability
             end
          end

          # 指定されたcellに残っている値の配列  の配列
          s =  arrow.map { |c| @cells[c].vlist }

          # 大サイズの場合は組み合わせが膨大になってしまうのでパスしておくことにしよう
          next if s.flatten.size > @summax

          # 侯補絞りこみ
          # 残っている値の全組み合わせの中で、ひとつずつ増減しているものを残す
          #    ソートしても同じ並びで、最初と最後の差がサイズで合計が合ってる
          k = s[0].product(*s[1..]).select do |w|
            ww = []
            w.sort.each_with_index { |v, i| ww << v - i }
            ww.uniq.size == 1 &&
              (w.sort == w || w.sort { |a, b| b <=> a } == w)
          end
          # pp groups[11]
          # pp arrow
          # pp s
          # pp k
          w = k[0].zip(*k[1..])

          if $dbg
            print '  neigh '
            p w
          end
          # これで、 w には 可能性のある数字が並んだ
          # w [[],[],[]] cell毎に可能性ある数字の配列
          wk = []
          arw = []
          (0..w.size - 1).each do |c|
            if w[c].size == 1 # 一つに絞られたら、そのcellは決定
              print ' cell.set by neigh @size==1 ' if $dbg

              @cells[arrow[c]].set(w[c][0], "neiber test2 arrow [#{arrow.join ','}]")
              $optsw = true
            elsif w[c].size.positive? # 二つ以上だったら、
              # 次の処理の準備
              wk << w[c]
              arw << arrow[c + 1]

              # それ以外の数字をそのcellの可能性から消す
              vv = @cells[arrow[c]].vlist - w[c]
              if vv.size.positive?
                @cells[arrow[c]].rm_ability(vv, "rm_ability by neiber test2[#{arrow.join(',')}]")
                ret = @gsw = $optsw = true
              end
            end
          end
        end
        ret
      end

      ##############
      def neigh_test3(cells)
        #
        #  2|5  @   このようなときには、＠ には 1、2、3、4、5、6が入らない
        #   @  2|5  という事の評価
        #  この様なとき、とは　
        #      ２x２のcellの対角線にある二つのcellの可能性が 二つの数字の同じ組み合わせ
        #      かつ、これらが互いに「二つ以上違い」の場合
        # 　   可能性が　i,j であったら、＠には i,j, (i,j)±1 は入れない。
        #  可能性が二つしかないcellのうち、同じ可能性の物を探す
        #  そのうち、その二つのcellが同じ隣を持つものをのこす。
        #  その、隣 から可能性を削除する。

        ret = false

        #  可能性が二つしかないcellのうち、同じ可能性の物を探す
        ww = cells.select { |cell| cell.valurest == 2 }
        www = ww.combination(2).select { |cell1, cell2| cell1.ability == cell2.ability }
        # それらのうち、2x2の組み合わせで対角線同士のものを探す。
        # それは、共通な隣が二つあるもの
        www.each do |cell1, cell2|
          c1 = cell1.c
          c2 = cell2.c
          nei1 = $nei.select { |nei|
            nei[0] == c1 || nei[1] == c1
          }.flatten.uniq - [c1] # cell1の隣。通常４つ
          nei2 = $nei.select { |nei|
            nei[0] == c2 || nei[1] == c2
          }.flatten.uniq - [c2] # cell2の隣。通常４つ
          next unless (nei1 & nei2).size == 2

          # うち、「一つ違い」である隣は削除する
          nei = (nei1 & nei2).select { |c| [c, c1].sort & @neigh && [c, c2].sort & @neigh }
          #  その、隣 から可能性を削除する。
          v = cell1.vlist
          v += [v[0] + 1, v[0] - 1, v[1] + 1, v[1] - 1].uniq.select(&:positive?)
          nei.each do |c|
            cells[c].rm_ability(v, "neighber test3 cells #{c1},#{c2}") &&
              ret = $optsw = true
          end
        end

        ret
      end

      def neigh_test4
        # 連続する3つのcellが、「二つ以上違い」であったとき
        # かつ、可能性ありの数字が計３つで
        # 　連続している　なら 真ん中のcellには真ん中の数字は入らない
        #   連続と片割れだったら 片割れをまん中にセット。

        # 1-18のグループから3つづつ46の三つ組について調べる
        # 三つ組の中の二つの隣組のいずれかが一つ違いだったらパス
        # 三つ組の可能性の数が3でなかったらパス
        # 三つの数を各々見て、3連続ならまん中の数をまん中のcellから外す
        # 2連続と片割れ だったら、片割れをまん中にセット。

        ret = false
        # 1-18のグループから7つづつ46の三つ組について調べる
        (0..@groups.size / 3 * 2 - 1).each do |g|
          cells = @groups[g].cell_list
          (0..game_scale - 3).each do |i|
            c0 = cells[i]
            c1 = cells[i + 1]
            c2 = cells[i + 2]
            # 三つ組の中の二つの隣組のいずれかが一つ違いだったらパス
            next if @neigh.index([c0, c1]).nil? || @neigh.index([c1, c2]).nil?

            # 三つ組の可能性の数が3でなかったらパス
            vs = (@cells[c0].vlist + @cells[c1].vlist + @cells[c2].vlist).uniq
            next unless vs.size == 3

            # 三つの数を各々見て、
            # p vs
            if vs[1] - vs[0] == 1
              if vs[2] - vs[1] == 1
                # 3連続ならまん中の数をまん中のcellから外す
                @cells[c1].rm_ability(vs[1], 'neighber test4')
              else
                # 2連続と片割れ だったら、片割れをまん中にセット。
                @cells[c1].set(vs[2])
              end
              ret = $optsw = true
            elsif vs[2] - vs[1] == 1
              # 2連続と片割れ だったら、片割れをまん中にセット。
              @cells[c1].set(vs[0])
              ret = $optsw = true
            end
          end
        end
        ret
      end
    end
  end
end
