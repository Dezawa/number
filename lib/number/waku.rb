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
    end

    def setup(form_type)
      mult, sign, m_nr, dan = base_size(form_type)
      @m = Math.sqrt(game_scale).to_i
      @xmax, @ymax = base_pos(mult, sign, m_nr, dan) # Boxを作り、各Boxの左上の座標を得る
      @count = game.count
      # cells_init # (@boxes)
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

      mult, mnr, dan, sign = mult_struct(mult)
      [mult, sign, mnr, dan]
    end

    def create_boxes_for_all(bnr, mnr, mult, sign, dans)
      xmin = 0
      box = Number::Box.new(game_scale, -6, -6)
      boxes = Array.new(mnr)
      wbox = Number::Box.new(game_scale)
      offset = { '-' => 6, '+' => -6 }
      (0...dans).each do |dan|
        box.p = box + [offset[sign[dan]], 6]
        wbox.p = box.p
        xmin = wbox.x_pos if xmin > wbox.x_pos
        @xmax = create_boxes_for_dan(mult[dan], xmin, bnr, boxes, wbox)
      end
      [boxes, xmin, box.y_pos]
    end

    def create_boxes_for_dan(dan, _xmin, bnr, boxes, wbox)
      @xmax = 0
      (0...dan).each do |_b|
        bnr += 1
        boxes[bnr] = Number::Box.new(game_scale, wbox.p)
        @xmax = wbox.x_pos + game_scale if @xmax < wbox.x_pos + game_scale
        wbox.p = wbox + [12, 0]
      end
      @xmax
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
        box.y_x_range do |y, x|
          game.cells << (@cells[xmax * y + x] = Number::Cell.create(game, cell_no, [], game.count))
          cell_no += 1
        end
      end
    end

    def set_grp
      gnr = 0
      gnr = vertical_holizontal_group(gnr)
      gnr = block_group(gnr, group_width, group_hight) unless game.game_type == 'KIKA'
      gnr
    end

    def block_group(gnr, group_width, group_hight)
      boxes.each do |box|
        box.y_range.step(group_hight).each do |y|
          aliable_cells_of_block(box, group_width, y).each do |x|
            new_group(gnr, [x, y], group_hight, group_width)
            gnr += 1
          end
        end
      end
      gnr
    end

    def new_group(gnr, x_y, group_hight, group_width)
      x, y = x_y
      game.groups[gnr] = Number::Group.new(game, gnr, @count, :block)
      (y..y + group_hight - 1).each do |yy|
        (x..x + group_width - 1).each { |xx| cells[xmax * yy + xx].group_ids << gnr }
      end
    end

    def aliable_cells_of_block(box, group_width, y_pos)
      (box.x_pos..box.x_pos + game_scale - 1).step(group_width).reject do |x|
        cells[xmax * y_pos + x].nil?
      end
    end

    def vertical_holizontal_group(gnr)
      boxes.each do |box|
        (box.y_pos..box.y_pos + game_scale - 1).each do |y|
          holizontal_group(gnr, box, y)
          gnr += 1
        end
        (box.x_pos..box.x_pos + game_scale - 1).each do |x|
          vertical_group(gnr, box, x)
          gnr += 1
        end
      end
      gnr
    end

    def holizontal_group(gnr, box, y_pos)
      game.groups[gnr] = Number::Group.new(game, gnr, @count, :holizontal)
      (box.x_pos..box.x_pos + game_scale - 1).each do |x|
        cells[xmax * y_pos + x].group_ids << gnr
      end
    end

    def vertical_group(gnr, box, x_pos)
      game.groups[gnr] = Number::Group.new(game, gnr, @count, :vertical)
      (box.y_pos..box.y_pos + game_scale - 1).each do |y|
        cells[xmax * y + x_pos].group_ids << gnr
      end
    end
  end
end
