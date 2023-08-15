# frozen_string_literal: true

require_relative './make_waku_pform'
require_relative './resolver'

module Number
  class Game
    Iromono = %w[ARROW KIKA SUM XROSS COLLOR HUTOUGOU DIFF NEIGHBER ODD CUPCELL].freeze
    IromonoReg = /#{Iromono.join('|')}/.freeze
    include Number::GamePform
    include Number::Resolver
    attr_accessor :groups, :cells, :gsize, :size, :form_type, :form, :arrows, :block, :n, :option
    attr_reader :infile, :form, :sep, :game_type, :count

    def self.create(infile, option: {})
      form_type, game_type = form_and_game_type(infile)
      instance = new(infile, form_type, game_type: game_type, option: option)
      instance.set_game_type
      instance.get_structure
      instance.gout if option[:gout]
      instance.get_initialdata
      instance
    end

    def self.form_and_game_type(infile)
      line = gets_skip_comment(infile)
      game_type = (match = line.match(Number::Game::IromonoReg)) ? match[0] : nil
      form_type = line.match(/(\d[-+x\d]*\d?)|STD/)[0]
      form = '9' if form_type == 'STD'
      [form_type, game_type]
    end

    def self.gets_skip_comment(infile)
      line = infile.gets
      line = infile.gets while line =~ /^\s*#/ || line =~ /^\s*$/
      line
    end

    def optional_test; end

    def initialize(infile, arg_form_type, game_type: nil, option: {})
      @infile = infile
      @form_type = arg_form_type
      @sep = arg_form_type.to_i < 10 ? '' : /\s+/
      @game_type = game_type
      @option = option
      @groups = []
      @cells = []
      @count = Hash.new(0)
    end

    def game
      'NOMAL'
    end

    def set_game_type
      required = IromonoReg =~ game_type ? "./game_types/#{::Regexp.last_match(0).downcase}" : nil
      return unless required

      require_relative required
      extend Number::GameTypes::GameType
    end

    def block
      @block ||= @groups.select(&:is_block?)
    end

    def resolve
      count = 4
      # self.rest_one
      sw = true
      while !fill? && (sw || count.positive?)
        sw = nil
        # @cells.each{|cell| sw |= cell.set_if_valurest_equal_1  }
        sw |= rest_one
        sw |= reserv(2)
        sw |= prison(2)
        print "\n prison(2) #{sw}" if option[:verb]

        next if optional_test

        print "optional  #{sw}" if option[:verb]

        sw |= reserv(3)
        print " reserv(3) #{sw}" if option[:verb]
        sw |= prison(3)
        print " prison(3) #{sw}" if option[:verb]
        sw |= reserv(4)
        print " reserv(4) #{sw}" if option[:verb]
        sw |= prison(4)
        print " prison(4) #{sw}" if option[:verb]
        highClass.each do |method|
          sw |= method.call
          print " method #{sw}" if option[:verb]
        end
        # puts count
        count -= 1
      end
      fill?
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
              @cells[c].rmAbility(vv, 'initialize')
            end
          end
          c += 1
        end
      end
      # dataファイルの後半にある arrow情報を得る
      # 標準では何もしないmethod
      optional_struct(sep, @n, infile)
      # @arrows = @arrows.compact if @arrows
    end

    def optional_struct(a, b, f); end

    def get_arrow(infile)
      puts 'GET ARROW' if option[:verb]
      # $_ =~ /^[#\s]*$/ && while infile.gets =~ /^[#\s]*$/;end
      while infile.gets && ($LAST_READ_LINE =~ /^\s*#/ || $LAST_READ_LINE =~ /^\s*$/); end
      @arrows = []
      a = []
      puts $LAST_READ_LINE if option[:verb]
      raise 'ENOUGH ARROW DATA' unless $LAST_READ_LINE

      $LAST_READ_LINE.split.each { |c| a << c.to_i - 1 }
      @arrows << a.dup

      puts "arrow #{$LAST_READ_LINE}" if option[:verb]
      while infile.gets =~ /\d/
        puts "arrow #{$LAST_READ_LINE}" if option[:verb]
        raise 'ENOUGH ARROW DATA' unless $LAST_READ_LINE

        a = []
        $LAST_READ_LINE.split.each { |c| a << c.to_i - 1 }
        @arrows << a.dup
      end
      @arrows = @arrows.compact if @arrows
      # @arrows = @arrows.sort { |a, b| b.size <=> a.size }
    end

    ### def structure(data,form,sep)
    ###   if /^\s*\d+(x\d+)?([-+]\d+)*\s*$/ =~ form # 3x3-4+5
    ###     xmax,ymax = make_waku_pform_new(data,form,sep)  # 枠を算出
    ###     ban_initialize(@w,@n,xmax,ymax)
    ###     #印刷フォーム設定
    ###     @form=Number::Form.new([@w,xmax,ymax],@n)
    ###   end
    ###   #@block ||= @groups.select{|grp| grp.is_block? }
    ### end
    def get_structure
      xmax, ymax = make_waku_pform(form_type)
      if /^\s*\d+(x\d+)?([-+]\d+)*\s*$/ =~ form_type # 3x3-4+5
        ban_initialize(@w, @n, xmax, ymax)
        # 印刷フォーム設定
      end
      @form = Number::Form.new([@w, xmax, ymax], @n)
      # @block ||= @groups.select{|grp| grp.is_block? }
    end

    ### 出力系 ###
    # 版の出力。決まっていない所は . ピリオド
    def output_form
      form.out cells
    end

    # 使った技の統計
    def output_statistics
      @count.map { |l, v| format(" Stat: %-10s %3d\n", l, v) }.join
    end

    # 未解決の cellがある場合、その残っている可能性をまとめる
    # [ [cell_nr, [ 1, 5,,,] ]
    def cell_ability
      cells.select { |cell| cell.v.nil? }
           .map { |cell| [cell.c, cell.ability] }
    end

    # 未解決の cellがある場合、その残っている可能性を出力する。後方互換
    # 2 : [ 3, 4]
    def cell_out
      cell_ability.map { |c, ability| "#{c} : #{ability}" }.join("\n")
    end

    def output(statistics, _count, cellout)
      cellout && cell_out
      statistics && @count.each { |l, v| printf " Stat: %-10s %3d\n", l, v }
      form.out cells
    end
  end
end
