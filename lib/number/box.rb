# frozen_string_literal: true

module Number
  # 9x9を複数重ねる構造の場合に、構造作成の補助として 9x9の枠を用意する
  class Box
    attr_accessor :game_scale, :game, :position

    def initialize(game, game_scale, x_pos = nil, y_pos = nil)
      @game = game
      @game_scale = game_scale
      @position = []
      @position = x_pos if x_pos.instance_of?(Array)
      @position = [x_pos, y_pos] unless y_pos.nil?
      # pp [:xmax, xmax]
    end

    def xmax
      game.waku.xmax
    end

    def xmax_one
      game.waku.xmax - 1
    end

    def cells
      game.cells
    end

    def set_group(game_type, game_scale, gnr, group_width, group_hight)
      # pp [:xmax1, xmax]
      gnr = holizontal_group(gnr, game_scale)
      gnr = vertical_group(gnr, game_scale)
      gnr = block_group(gnr, group_width, group_hight) unless game_type == 'KIKA'
      gnr
    end

    def aliable_cells_of_block(group_width, y_pos)
      (x_position..x_position + game_scale - 1).step(group_width).reject do |x|
        game.cells[xmax * y_pos + x].nil?
      end
    end

    def block_group(gnr, group_width, group_hight)
      y_range.step(group_hight).each do |y|
        aliable_cells_of_block(group_width, y).each do |x|
          game.groups[gnr] = Number::Group.new(game, gnr, @count, :block)
          block_group_cell(gnr, x, y, group_hight, group_width)
          gnr += 1
        end
      end
      gnr
    end

    def holizontal_group(gnr, game_scale)
      (y_position..y_position + game_scale - 1).each do |y|
        game.groups[gnr] = Number::Group.new(game, gnr, @count, :holizontal)
        holizontal_group_cell(gnr, y)
        gnr += 1
      end
      gnr
    end

    def vertical_group(gnr, game_scale)
      (x_position..x_position + game_scale - 1).each do |x|
        game.groups[gnr] = Number::Group.new(game, gnr, @count, :vertical)
        vertical_group_cell(gnr, x)
        gnr += 1
      end
      gnr
    end

    def holizontal_group_cell(gnr, y_pos)
      xstart = xmax_one * y_pos
      (xstart...xstart + game_scale).each { |x| cells[x].group_ids << gnr }
    end

    def vertical_group_cell(gnr, x_pos)
      y_range.each do |y|
        cells[xmax_one * y + x_pos].group_ids << gnr
      end
    end

    def block_group_cell(gnr, x_pos, y_pos, group_hight, group_width)
      (y_pos...y_pos + group_hight).each do |yy|
        (x_pos...x_pos + group_width).each { |xx| game.cells[xmax_one * yy + xx].group_ids << gnr }
      end
    end

    def p(x_pos = nil, y_pos = nil)
      @position = x_pos if x_pos.instance_of?(Array)
      @position = [x_pos, y_pos] unless y_pos.nil?
      @position
    end

    def p=(x_pos = nil, y_pos = nil)
      @position = x_pos if x_pos.instance_of?(Array)
      @position = [x_pos, y_pos] unless y_pos.nil?
    end

    def +(x_pos = nil, y_pos = nil)
      @position = [@position[0] + x_pos[0], @position[1] + x_pos[1]] if x_pos.instance_of?(Array)
      @position = [@position[0] + x_pos, @position[1] + y_pos]       unless y_pos.nil?
      @position
    end

    def x_pos=(x_pos)
      position[0] = x_pos
    end

    def x_position
      position[0]
    end

    def y_position
      position[1]
    end

    def x_range
      x_position..x_position + game_scale - 1
    end

    def y_range
      y_position..y_position + game_scale - 1
    end

    def y_x_range
      y_range.map { |y| x_range.map { |x| yield(xmax * y + x) } }
    end
  end
end
