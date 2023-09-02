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

      # 所定の cell数だけ、初期データを読む
      while c < @size && (line = gets_skip_comment(infile))
        line.chop.split(sep).each do |v|
          next if /\s/ =~ v

          @cells[c].assign_valu(v)
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
        @arrows << line.split.map { |c| c.to_i - 1 }
        puts "arrow #{line}" if option[:verb]
      end
      @arrows = @arrows.compact if @arrows
    end

    def structure
      make_waku_pform(form_type)
      # if struct_reg =~ form_type # 3x3-4+5
      ban_initialize(@waku, game_scale, @waku.xmax, @waku.ymax)
      # 印刷フォーム設定
      # end
      @form = Number::Form.new([@waku, @waku.xmax, @waku.ymax], game_scale)
    end
  end
end
