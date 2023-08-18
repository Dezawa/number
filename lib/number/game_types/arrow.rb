# frozen_string_literal: true

# 構造、初期データのあと、Arrow定義の行をつける
# ○のcell番号 arrowのcell番号達
module Number
  module GameTypes
    # ARROWのextend
    module GameType
      def game
        'ARROW'
      end

      def optional_struct(_sep, _game_scale, infile)
        get_arrow(infile)
        @arrows.sort! { |a, b| a.size <=> b.size }
        # p @arrows if optoin[:verb]

        @summax = 20

        # arrow それぞれの中で、同じgroup に属するものの組み合わせを作る
        #     . . . . . . . . .  10 => 11,21,22 の場合
        #     # * . . . . . . .      11,21 group 19,
        #     . . * * . . . . .      21,22 group 12
        #     . . . . . . . . .
        # 同じgroupに属するcell を集める
        @arw_group = []
        @arrows.each_with_index do |arrow, i|
          # @arw_group[i]=arrow[1..-1].map{|cell_no|
          groups = arrow[1..].map do |cell_no| # cell の group の集合を求める
            @cells[cell_no].grp_list
          end.flatten.uniq
          cells_same_group = groups.map do |grp_no|
            cells = @groups[grp_no].cell_list & arrow[1..]
            cells if cells.size > 1
          end.compact
          @arw_group[i] = cells_same_group.map do |cells|
            # そのcellはallowの何番目の要素か
            cells.map { |c| arrow.index(c) }.sort
          end.uniq
        end
        pp [@arrows, @arw_group] if option[:verb]

        check || exit(1)
        # pp @arw_group if option[:verb]
      end

      def check
        return true unless option[:strct]

        @err = nil
        q = (1..@size).to_a
        para = @arrows.map { |a| a.dup }.flatten

        p = para.sort.uniq
        $stderr.print "Optional Para is duped\n" && exit(1) if p.size != para.size
        return unless p[0] < 1 || p[@size - 1] > @size

        $stderr.print "Optional Para value is wrong\n" && exit(1)
      end

      # 矢印の○のcellと矢印のcell のarry、のarry
      # @arrows = [[sumCell,c1,c2,c3], [sumCell,c1,c2] ]
      #
      # arrowのc1,c2,c3,,, が同じgroupに属している場合は同じ数字は入らない。
      # それを枝刈りするための情報。arrow毎に同じgroupに属するcellの集合
      # @arw_group = [[[1,2],[1,3]] ,[  ] ]
      #                 cell Noではなく、そのcellがarrayの何番目なのか、の位置情報
      #
      # 実行時
      # arrowの各cellに残されている可能性の集合。arw １要素毎に作り壊される
      #   valus    = [[s1,s2,s3], [V1,V2],[v1,v2],[v4,v5,v6] ]
      #                 sumCell     c1       c2       c3
      # それらのうち、合計が sumCellの値となる組み合わせ
      #   products = [ [V1,v1,v4],[V1,v2,v6],[V2,v1,v6] ]  合計が sumとなる組み合わせ
      # val      = [ [V1,V2],[v1,v2],[v4,v6]       残った可能性
      def optional_test
        if option[:verb]
          print "sum arrow @summax=#{@summax}\n"
          p @arrows
        end
        optsw = nil
        delete_arys = []

        # 効率化のため組み合わせの数が大きくならないように制限する数を
        # 少しずつ大きくする。  このとき小さすぎると一つも解決できず、
        # 失敗で終わってしまうので、ある程度までは成功したことにする
        @summax += 5 # ;  @gsw =  true  if @summax<50
        # @arrows.each_with_index
        @arrows.each_with_index do |arrow, i| # 指定されたcellに残っている値の配列  の配列
          # (0..arrow.size-1).each{|c| valus << @cells[arrow[c]].vlist }
          valus = arrow.map { |c| @cells[c].valu ? [@cells[c].valu] : @cells[c].vlist }
          pp ['arrow', arrow, @arw_group[i], valus] if option[:verb]

          # 大サイズの場合は組み合わせが膨大になってしまうのでパスしておくことにしよう
          next if valus.flatten.size > @summax

          # この残っている値の組み合わせを作り(product)
          # 計算が合っている　かつ            (inject)
          # このうち、同じgroupに属するcellで同じ数字があるものはだめ
          products = valus[0].product(*valus[1..]).map do |vary|
            vary if (vary[0] == vary[1..].inject(0) { |s, v| s + v }) &&
                    @arw_group[i].map do |cellIDs| # このarrowの同じgroupに属するcellID
                      true if # 重複があったら(true)
    cellIDs.map do |id|
      vary[id] # を値に変換し、
    end.uniq.size != cellIDs.size
                    end.compact.empty?
            # だめ
          end.compact
          pp @arw_group if option[:test]
          pp @arrows if option[:test]
          pp products if option[:test]
          # 　products = [ [sum,v1,v2,v3],[sum,V1,V2,V3] ]
          #     合計を満たす値の組み合わせ
          #  これから、各cellの値の集合を求める
          newvalus = products[0].zip(*products[1..])

          # 元の可能性 values と　newvalues に差があれば、それは可能性から削除
          valus.each_with_index do |vals, i|
            vv = vals - newvalus[i]
            next unless vv.size.positive?

            @cells[arrow[i]].rm_ability(vv, 'arrow')
            @gsw = true
            if newvalus[i].size == 1 # 結果一つになれば決定
              optsw = true
              @cells[arrow[i]].set(newvalus[i][0])
            end
          end
          # 可能性集合が一つしかない場合は、このarrowはもう考慮不要
          delete_arys << i if products.size == 1

          break if optsw

          @summax -= 5 if optsw
          return true if optsw # 一つできたら全体見直しする
        end

        while (i = delete_arys.pop)
          @arrows.delete_at(i)
          @arw_group.delete_at(i)
        end
        optsw # @gsw
      end
    end
  end
end
