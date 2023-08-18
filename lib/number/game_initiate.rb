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
    def get_initialdata
      c = 0
      # print "last $_='",$_,"', @gsize=#{@gsize} @size=#{@size}\n" unless $quiet

      # 所定の cell数だけ、初期データを読む
      while infile.gets && c < @size
        # print $_
        $LAST_READ_LINE =~ /^\s*#/ && while infile.gets =~ /^\s*#/; end
        # STDERR.
        # print $_ unless $quiet
        $LAST_READ_LINE.chop.split(sep).each do |v|
          # print "#{c}='#{v}' "
          next if v =~ /\s/

          if v == 'e'
            @cells[c].set_even
          elsif v == 'o'
            @cells[c].set_odd
          elsif (vv = v.to_i).positive?
            # STDERR.        print "#{vv} "
            vlst = v.split('|')
            if vlst.size == 1
              # print "[ C=#{c} vv=#{vv}] ";
              @cells[c].set_cell(vv, 'initialize')
            else
              vv = @val - vlst.map!(&:to_i)
              @cells[c].rm_ability(vv, 'initialize')
            end
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
      # $_ =~ /^[#\s]*$/ && while infile.gets =~ /^[#\s]*$/;end
      #while infile.gets && ($LAST_READ_LINE =~ /^\s*#/ || $LAST_READ_LINE =~ /^\s*$/); end
      @arrows = []

      while line = gets_skip_comment(infile)
        puts line if option[:verb]
        raise 'ENOUGH ARROW DATA' unless line

        @arrows << line.split.map { |c| c.to_i - 1 }
        puts "arrow #{$LAST_READ_LINE}" if option[:verb]
      end
      @arrows = @arrows.compact if @arrows
    end

    def get_structure
      xmax, ymax = make_waku_pform(form_type)
      # if struct_reg =~ form_type # 3x3-4+5
      ban_initialize(@w, game_scale, xmax, ymax)
      # 印刷フォーム設定
      # end
      @form = Number::Form.new([@w, xmax, ymax], game_scale)
    end
  end
end
