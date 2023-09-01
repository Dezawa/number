# frozen_string_literal: true

module Number
  # ゲーム全体の構成
  class Waku
    attr_accessor :cells, :boxes, :xmax, :ymax, :game, :game_scale

    def initialize(game, boxes, game_scale, count, xy_max)
      @game = game
      @game_scale = game_scale
      @boxes = boxes
      @count = count
      @xmax, @ymax = xy_max
      cells_init(boxes)
    end

    def cells_init(boxes)
      cell_no = 0
      null_cell = Number::NullCell.instance
      @cells =  Array.new(xmax * ymax, null_cell)

      boxes.each do |box|
        box.y_x_range do |y, x|
          game.cells << (@cells[xmax * y + x] = Number::Cell.create(game, cell_no, [], game.count))
          cell_no += 1
        end
      end
    end

    def set_grp(group_width, group_hight)
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
