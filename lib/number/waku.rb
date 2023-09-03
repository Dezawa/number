# frozen_string_literal: true

module Number
  # ゲーム全体の構成
  class Waku
    attr_accessor :cells, :boxes, :xmax, :ymax, :game, :game_scale, :group_width, :group_hight, :m

    def self.create(game, form_type)
      waku = new(game)
      waku.setup(form_type)
      waku
    end

    def initialize(game)
      @game = game
      game.waku = self
    end

    def setup(form_type)
      mult, m_nr, dan, sign = base_size(form_type)
      @m = Math.sqrt(game_scale).to_i
      @xmax, @ymax = base_pos(mult, sign, m_nr, dan) # Boxを作り、各Boxの左上の座標を得る
      @count = game.count
    end

    def base_pos(mult, sign, mnr, dans)
      bnr = -1
      @boxes, @xmin, y_pos = create_boxes_for_all(bnr, mnr, mult, sign, dans)

      reset_xmax(@xmin, boxes)
      [@xmax + 1, y_pos + game_scale + 1]
    end

    def base_size(form_type)
      mult = form_type.split(/[-+]/)
      mult_params(mult) # @game_scale, @group_width, @group_hight 設定
      mult_struct(mult)
    end

    OFFSET = { '-' => 6, '+' => -6 }.freeze
    def create_boxes_for_all(bnr, mnr, mult, sign, dans)
      xmin = 0
      # box = Number::Box.new(game, game_scale, -6, -6)
      boxes = Array.new(mnr)
      wbox = Number::Box.new(game, game_scale, -6, -6)
      (0...dans).each do |dan|
        wbox.p = wbox + [OFFSET[sign[dan]], 6]
        create_boxes_for_dan(mult[dan], bnr, boxes, wbox)
      end
      [boxes, xmin, wbox.y_pos]
    end

    def create_boxes_for_dan(dan, bnr, boxes, wbox)
      @xmax = 0
      (0...dan).each do |_b|
        bnr += 1
        boxes[bnr] = Number::Box.new(game, game_scale, wbox.p)
        @xmax = wbox.x_pos + game_scale if @xmax < wbox.x_pos + game_scale
        wbox.p = wbox + [12, 0]
      end
    end

    def mult_params(mult)
      @game_scale = mult.shift # Gameの基本サイズ
      if /\d+x\d+/ =~ @game_scale
        @group_width, @group_hight = n.split('x').map(&:to_i)
        @game_scale = @group_width * @group_hight
      else
        @game_scale = @game_scale.to_i
        @group_width = @group_hight = (Math.sqrt(@game_scale) + 0.2).to_i
      end
      @m = (Math.sqrt(@game_scale) + 0.2).to_i
    end

    def mult_struct(mult)
      if mult.empty?
        mult = [1]
        mnr = 1
        dan = 1
        sign = ['-']
      else
        mult = mult.map(&:to_i) # 各段のBOX数
        mnr =  mult.inject(0) { |s, i| s + i } # BOX数合計　箱の数　Mnr
        dan = mult.size # 箱の重なり段数  Dan   3 = struct.split(/[-+]/).size
        sign = struct.split(/\d+/)[1..]
      end
      [mult, mnr, dan, sign]
    end

    def reset_xmax(xmin, boxes)
      return unless xmin != 0

      boxes.each do |b|
        b.x_pos = (b.x_pos - xmin)
      end
      @xmax -= xmin
    end

    # ( #boxes)
    def cells_init
      cell_no = 0
      null_cell = Number::NullCell.instance
      @cells =  Array.new(xmax * ymax, null_cell)
      @boxes.each do |box|
        box.y_x_range do |y_x|
          game.cells << (@cells[y_x] = Number::Cell.create(game, cell_no, [], game.count))
          cell_no += 1
        end
      end
    end

    def set_grp
      gnr = 0
      boxes.each do |box|
        gnr = box.set_group(game.game_type, game_scale, gnr, group_width, group_hight)
      end
      gnr
    end
  end
end
