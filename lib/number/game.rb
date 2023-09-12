# frozen_string_literal: true

require_relative './game_initiate'
require_relative './waku'
require_relative './form'
require_relative './box'
require_relative './make_waku_pform'
require_relative './cell'
require_relative './group'
require_relative './group_ability'
require_relative './resolver'

module Number
  # mail class
  class Game
    IROMONO = %w[ARROW KIKA SUM XROSS COLLOR HUTOUGOU DIFF NEIGHBER CUPCELL].freeze
    IROMONO_REG = /#{IROMONO.join('|')}/.freeze
    include Number::GamePform
    include Number::Resolver
    include Number::GameInitiate
    attr_accessor :groups, :cells, :gsize, :size, :form_type, :form, :arrows, :n, :game_scale, :option, :waku
    attr_reader :infile, :sep, :game_type, :count

    def self.create(infile, option: {})
      form_type, game_type = form_and_game_type(infile)
      instance = new(infile, form_type, game_type: game_type, option: option)
      instance.set_game_type
      # @waku、formを作成。groupを作成し、optional_groupも作成
      # ban_initializeにてcell作成
      instance.structure
      instance.gout if option[:gout]
      instance.data_initialize
      puts instance.cell_out if option[:cout]
      instance
    end

    def self.form_and_game_type(infile)
      line = gets_skip_comment(infile)
      game_type = (match = line.match(Number::Game::IROMONO_REG)) ? match[0] : nil
      form_type = line.match(/(\d[-+x\d]*\d?)|STD/)[0]
      form_type = '9' if form_type == 'STD'
      [form_type, game_type]
    end

    def self.gets_skip_comment(infile)
      line = infile.gets
      line = infile.gets while line =~ /^\s*#/ || line =~ /^\s*$/
      line
    end

    def gets_skip_comment(infile)
      line = infile.gets
      line = infile.gets while line =~ /^\s*#/ || line =~ /^\s*$/
      line
    end

    def optional_test; end

    def initialize(infile = nil, arg_form_type = '9', game_type: nil, option: {})
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

    def high_class
      [[:cross_teiin], [:curb]]
    end

    def resolve
      @try_count = 400
      # self.rest_one
      sw = true
      while !fill? && (sw || @try_count.positive?)
        sw = nil
        RESOLVE_PATH.each do |method, arg|
          msg = arg ? send(method, arg) : send(method)
          next if msg.to_s.empty?

          print " #{method}(#{arg}):#{msg}\n" if option[:verb]
          # アクションが有ったら、優しい解法に戻る
          break
        end

        # puts count
        @try_count -= 1
      end
      fill?
    end

    def optional_struct(sep, game_scale, infile); end

    def struct_reg
      /^\s*\d+(x\d+|(x\d)?([-+]\d+)+)\s*$/
    end

    ### 出力系 ###
    # 版の出力。決まっていない所は . ピリオド
    def output_form
      form.out cells
    end

    # 使った技の統計
    def output_statistics
      @count.map { |l, v| format(" Stat: %<l>-10s %<v>3d\n", l: l, v: v) }.join
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
      statistics && @count.each { |l, v| printf " Stat: %<l>-10s %<v>3d\n", l: l, v: v }
      form.out cells
    end
  end
end
