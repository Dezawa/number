# frozen_string_literal: true

module Number
  # mail class
  module GameInitiate
    def set_game_type
      required = Number::Game::IROMONO_REG =~ game_type ? "./game_types/#{::Regexp.last_match(0).downcase}" : nil
      return unless required

      require_relative required
      extend Number::GameTypes::GameType
    end

    # data file の残りを読んで、初期値を得る
    #    dataファイルにある、arrow情報も読む
    def data_initialize
      c = 0
      # print "last $_='",$_,"', @gsize=#{@gsize} @size=#{@size}\n" unless $quiet

      # 所定の cell数だけ、初期データを読む
      while c < @size
        gets_skip_comment(infile).chop.split(sep).each do |v|
          case v
          when 'e'
            @cells[c].set_even
          when 'o'
            @cells[c].set_odd
          when /^\d/
            @cells[c].set_cell(v.to_i, 'initialize')
          when /\s/
            next
          end
          c += 1
        end
      end
      # dataファイルの後半にある arrow情報を得る
      # 標準では何もしないmethod
      optional_struct(sep, game_scale, infile)
      # @arrows = @arrows.compact if @arrows
    end

    def get_arrow(infile)
      puts 'GET ARROW' if option[:verb]
      @arrows = []

      while (line = gets_skip_comment(infile))
        puts line if option[:verb]

        @arrows << line.split.map { |c| c.to_i - 1 }
        puts "arrow #{$LAST_READ_LINE}" if option[:verb]
      end
      @arrows = @arrows.compact if @arrows
    end

    def structure
      xmax, ymax = make_waku_pform(form_type)
      # if struct_reg =~ form_type # 3x3-4+5
      ban_initialize(@waku, game_scale, xmax, ymax)
      # 印刷フォーム設定
      # end
      @form = Number::Form.new([@waku, xmax, ymax], game_scale)
    end
  end
end
