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
        pp [:arrows_arw_group, @arrows, arw_group] if option[:verb]

        check || exit(1)
        # pp arw_group if option[:verb]
      end

      def check
        return true unless option[:strct]

        @err = nil
        (1..@size).to_a
        para = @arrows.map(&:dup).flatten

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
      # arw_group = [[[1,2],[1,3]] ,[  ] ]
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
          p [:arrows, @arrows]
        end
        optsw = nil
        delete_arys = []

        # 効率化のため組み合わせの数が大きくならないように制限する数を
        # 少しずつ大きくする。  このとき小さすぎると一つも解決できず、
        # 失敗で終わってしまうので、ある程度までは成功したことにする
        @summax += 5 # ;  @gsw =  true  if @summax<50
        # @arrows.each_with_index
        @arrows.each_with_index do |arrow, arrow_id| # 指定されたcellに残っている値の配列  の配列
          next unless arrow

          valus, newvalus, = aviable_values(arrow, arrow_id)

          # 元の可能性 values と　newvalues に差があれば、それは可能性から削除
          # valus.each_with_index do |vals, i|
          #   vv = vals - newvalus[i]
          #   next unless vv.size.positive?

          #   @cells[arrow[i]].rm_ability(vv, 'arrow')
          #   @gsw = true
          #   if newvalus[i].size == 1 # 結果一つになれば決定
          #     optsw = true
          #     @cells[arrow[i]].set(newvalus[i][0])
          #   end
          # end

          optsw = rm_unaviable_value(arrow, valus, newvalus)

          # 可能性集合が一つしかない場合は、このarrowはもう考慮不要
          # delete_arys << arrow_id if products.size == 1
          # delete_arys << arrow_is_fixed?(arrow)
          @arrows[arrow_id] = nil
          break if optsw

          @summax -= 5 if optsw
          return true if optsw # 一つできたら全体見直しする
        end

        while (i = delete_arys.pop)
          @arrows.delete_at(i)
          arw_group.delete_at(i)
        end
        optsw # @gsw
      end

      # 元の可能性 values と　newvalues に差があれば、それは可能性から削除
      def rm_unaviable_value(arrow, _valus, newvalus, _products)
        arrow.each_with_index do |cell_no, i|
          vals = @cells[cell_no].ability
          vv = vals - newvalus[i]
          next unless vv.size.positive?

          @cells[cell_no].rm_ability(vv, 'arrow')
          @gsw = true
          if newvalus[i].size == 1 # 結果一つになれば決定
            @optsw = true
            @cells[cell_no].set(newvalus[i][0])
          end
        end
        @optsw
      end

      def rm_unaviable_value(arrow, valus, newvalus)
        valus.each_with_index do |vals, i|
          vv = vals - newvalus[i]
          next unless vv.size.positive?

          @cells[arrow[i]].rm_ability(vv, 'arrow')
          @gsw = true
          if newvalus[i].size == 1 # 結果一つになれば決定
            @optsw = true
            @cells[arrow[i]].set(newvalus[i][0])
          end
        end
        @optsw
      end

      # 可能性集合が一つしかない場合は、このarrowはもう考慮不要
      def arrow_is_fixed?(arrow)
        arrow.all? { |cell_no| @cells[cell_no].fill? }
      end

      #  合計を満たす数字の組み合わせを得、
      #  それから、各cellの可能性あり数字の集合を求める
      def aviable_values(arrow, arrow_id)
        # (0..arrow.size-1).each{|c| valus << @cells[arrow[c]].vlist }
        valus = arrow.map { |c| @cells[c].valu ? [@cells[c].valu] : @cells[c].vlist }

        # 大サイズの場合は組み合わせが膨大になってしまうのでパスしておくことにしよう
        return if valus.flatten.size > @summax

        # この残っている値の組み合わせを作り(product)
        # 計算が合っている　かつ            (inject)
        # このうち、同じgroupに属するcellで同じ数字があるものはだめ
        products = candidate_value_combinations(arrow_id)
        pp [:arw_group, arw_group] if option[:test]
        pp [:arrows, @arrows] if option[:test]
        pp [:products, products] if option[:test]
        # 　products = [ [sum,v1,v2,v3],[sum,V1,V2,V3] ]

        [valus, products[0].zip(*products[1..]), products]
      end

      # arrow を構成するcell達の残り数字の配列のproductのなかで
      # 加算結果を満足する組み合わせを返す
      def candidate_value_combinations(arrow_id)
        valus = arrows[arrow_id].map { |c| @cells[c].valu ? [@cells[c].valu] : @cells[c].vlist }

        valus[0].product(*valus[1..]).map do |vary|
          vary if (vary[0] == vary[1..].inject(0) { |s, v| s + v }) &&
                  arw_group[arrow_id].map do |cell_ids| # このarrowの同じgroupに属するcellID
                    true if # 重複があったら(true)
                      cell_ids.map do |id|
                        vary[id] # を値に変換し、
                      end.uniq.size != cell_ids.size
                  end.compact.empty?
          # だめ
        end.compact
      end

      # arrow を構成する cell達が同じgroupに属する場合、
      # それらに同じ数字を入れることはできない。
      # cell達に共通なgroupを抜き出し、その中にcell達の2つ以上が有ったら
      # 同じ数字にならない、というテストを行う。
      # その判断のためのtable。同じgroupに属するcellがarrowの何番目か。
      def arw_group
        return @arw_group if @arw_group

        @arw_group = []
        @arrows.each_with_index do |arrow, i|
          # @arw_group[i]=arrow[1..-1].map{|cell_no|
          groups = arrow[1..].map do |cell_no| # cell の group の集合を求める
            @cells[cell_no].group_ids
          end.flatten.uniq

          cells_same_group = groups.map do |grp_no|
            cells = @groups[grp_no].cell_ids & arrow[1..]
            cells if cells.size > 1
          end.compact.uniq
          @arw_group[i] = cells_same_group.map do |cells|
            # そのcellはallowの何番目の要素か
            cells.map { |c| arrow.index(c) }.sort
          end.uniq
        end
        @arw_group
      end
    end
  end
end
