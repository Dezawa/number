# frozen_string_literal: true

module Number
  module GameTypes
    # SUMのextend
    module GameType
      def game
        'SUM'
      end

      # # SUM
      # 9
      # ここに9x9データ
      # このあと sum cell0 cell..... を並べる

      ##############
      def optional_struct(_sep, _game_scle, infile)
        get_arrow(infile)
        @arrows.each { |arw| arw[0] += 1 }
        # @arrows.sort! { |a, b| a.size <=> b.size }
        # pp @arrows
        print_struct if @check
        check || exit(1)
        # hamidasi
        cell_fix_for_single_cell_arrow

        @summax = 25
      end

      def print_struct
        cell = Array.new(81)
        @arrows.each do |ary|
          v = ary[0]
          ary[1..].each { |c| cell[c - 1] = v }
        end
        (0..80).step(9).each do |l|
          (l..l + 8).each { |r| printf '%2d ', cell[r] }
          puts ''
        end
      end

      def cell_fix_for_single_cell_arrow
        @arrows.select { |arrow| arrow.size == 2 }
               .each { |arrow| @cells[arrow[1]].set(arrow[0], 'sum') }
        @work_arrow = @arrows.select { |arrow| arrow.size > 2 }
      end

      def check
        return true unless @check

        p @arrows
        p @arrows.size
        @err = true
        para = []
        q = []
        (1..@size).each { |i| q << i }
        @arrows.each do |a|
          b = a.dup
          b.shift
          para << b
        end
        para.flatten!
        p = para.sort.uniq

        qq = (q - para).sort
        if qq.size.positive?
          $stderr.print "Optional Para is missing   #{qq.join(',')}\n"
          # @err=true
        end
        qq = (para - q).sort
        if qq.size.positive?
          $stderr.print "Optional Para is tomuch   #{qq.join(',')}\n"
          @err = nil
        end

        if p.size != para.size
          $stderr.print 'Optional Para is duped '
          qq = para.sort
          (0..qq.size - 2).each do |i|
            $stderr.print " #{qq[i]}" if qq[i] == qq[i + 1]
          end
          $stderr.print "\n"
          @err = nil
        end
        qq = (para - q).sort
        if qq.size.positive?
          $stderr.print "Optional Para value is wrong   #{qq.join(',')}\n"
          @err = nil
        end

        @err
      end

      # end

      # arw = [[sum,c1,c2,c3],
      #        [sum,c1,c2]
      #       ]
      # valus    = [ [v1,v2],[v4,v5,v6] ]  arw １要素毎に作り壊される
      # products = [ [v1,v4],[v2,v6] ]     合計が sumとなる組み合わせ
      # val      = [ [v1,v2],[v4,v6]       残った可能性

      def optional_test
        if option[:verb]
          print 'sum arrow'
          p @workarrow
        end
        optsw = nil

        # 効率化のため組み合わせの数が大きくならないように制限する数を
        # 少しずつ大きくする。  このとき小さすぎると一つも解決できず、
        # 失敗で終わってしまうので、ある程度までは成功したことにする
        @summax += 5
        @gsw = true if @summax < 40
        @work_arrow.each_with_index do |arrow, arrow_idx|
          next unless arrow

          if arrow.size == 2
            @cells[arrow[1]].set(arrow[0], 'sum') && @gsw = optsw = true
            arrow = nil
            next
          end
          # pp ["arrow",arrow,@summax] if option[:verb]
          valus = [] # 指定されたcellに残っている値の配列  の配列
          sum = arrow[0]
          arrow[1..].each { |cell_id| valus << @cells[cell_id].vlist }

          # 大サイズの場合は組み合わせが膨大になってしまうのでパスしておくことにしよう
          next if valus.flatten.size > @summax

          products_all = valus.size == 1 ? valus : valus[0].product(*valus[1..])

          valu_set_ary = list_of_aviable_valu_set(arrow, products_all, sum)

          if valu_set_ary.size == 1
            # fix!
            valu_set_ary.first.each_with_index do |val, idx|
              @cells[arrow[idx + 1]].set(val, 'sum') && @gsw = optsw = true
            end
            @work_arrow[arrow_idx] = nil
          else
            # 可能性を削っていく
            rm_ability(arrow_idx, valu_set_ary)
          end
          # while (i = delete_arys.pop); @arrows.delete_at(i); end
          if optsw
            @summax -= 5
            return true # 一つできたら全体見直しする
          end
        end
      end

      # arrayを構成する各cellの [残された可能性ある値]の組み合わせの中で
      # 合計が sum になるものの組み合わせを返す。ただし、同じ値が有る場合は除く
      # products_all :: [残された可能性ある値] のproduct
      def list_of_aviable_valu_set(arrow, products_all, sum)
        products_all
          .select { |cells_value| cells_value.flatten.sum == sum }
          .select do |cells_value|
          cells_value.uniq.size == cells_value.size ||
            allowable_dup?(arrow, cells_value)
        end
      end

      def valus_each_cells
        products.inject { |sum, ary| sum.zip(ary) }.map { |a| a.flatten.uniq }
      end

      # sumを満たす値の組み合わせで同じ数字を使うものが有った場合、
      # それらが同じ groupに属しているか否かで判定する
      def allowable_dup?(arrow, sells_value)
        return false if arrow.size == 3

        duped_value = sells_value.tally.select { |_v, c| c > 1 }.first&.first
        return true unless duped_value

        duped_index = sells_value.map.with_index { |v, idx| v == duped_value ? idx : nil }.compact

        duped_cells = duped_index.map { |idx| @cells[arrow[idx + 1]] }
        duped_cells.map(&:group_ids).flatten.tally.all? { |_v, c| c == 1 }
      end

      # cell毎の残された可能性に基づき、cellのabilityを調整する
      # valu_set_ary :: sum になる組み合わせのary
      def rm_ability(arrow_idx, valu_set_ary)
        values_of_each_cell = valu_set_ary.transpose
        values_of_each_cell.each_with_index do |values, idx_on_arry|
          cell_idx = @work_arrow[arrow_idx][idx_on_arry + 1]
          if values.size == 1 # このcellはfix
            @cells[cell_idx].set(values.first, 'sum') && @gsw = true
          elsif values.size > 1
            # @cells[cell_idx]の可能性を調整する
            # 新たな可能性は values。既に消えている可能性もある
            if (vv = values - @cells[cell_idx].ability).size.positive?
              @cells[cell_idx].rm_ability(vv, 'sum') && @gsw = true
            end
          end
        end
      end
    end
  end
end
