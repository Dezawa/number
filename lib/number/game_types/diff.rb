# frozen_string_literal: true

module Number
  module GameTypes
    module GameType
      def game_type
        'DIFF'
      end

      # module Optional
      def optional_struct(_sep, _n, infile)
        get_arrow(infile)
      end
      # end

      def optional_test
        #################
        puts 'optional'
        # def diff(arrow)
        sw = nil
        c = []
        @arrow.each do |arw|
          (dif, c[0], c[1]) = arw
          k = []
          k[0] = []
          k[1] = []
          w = []
          @cells[c[0]].vlist.each do |v1|
            @cells[c[1]].vlist.each  do |v2|
              if (v1 - v2).abs == dif
                k[0] << v1
                k[1] << v2
              end
            end
          end
          w[0] = k[0].uniq.sort
          w[1] = k[1].uniq.sort

          2.times do |i|
            if w[i].size == 1
              ret = @cells[c[i]].set(w[i][0])
              sw ||= ret
            elsif w[i].size.positive? # 二つ以上だったら、
              # それ以外の数字をそのcellの可能性から消す
              vv = @cells[c[i]].vlist - w[i]
              ret = @cells[c[i]].rmAbility(vv)
              sw ||= ret
            end
          end
        end
        sw
      end
    end
  end
end