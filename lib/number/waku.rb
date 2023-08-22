# frozen_string_literal: true

module Number
  # ゲーム全体の構成
  class Waku
    attr_accessor :waku, :boxes, :xmax, :ymax, :game, :game_scale

    def initialize(game, boxes, game_scale, count, xy_max)
      @game = game
      @game_scale = game_scale
      @boxes = boxes
      @count = count
      @xmax, @ymax = xy_max
      waku_init(boxes)
    end

    def waku_init(boxes)
      cell_no = 0
      null_cell = Number::NullCell.instance
      @waku =  Array.new(xmax * ymax, null_cell)

      boxes.each do |box|
        (box.y_pos..box.y_pos + game_scale - 1).map do |y|
          (box.x_pos..box.x_pos + game_scale - 1).map do |x|
            game.cells << (@waku[xmax * y + x] = Number::Cell.create(game, cell_no, [], game.count))
            cell_no += 1
          end
        end
      end
    end

    def set_grp(group_width, group_hight)
      gnr = 0
      gnr = vertical_holizontal_group(gnr)
      gnr = block_group(gnr, group_width, group_hight) unless game.game_type == "KIKA"
      # set_optional_group(gnr, group_width, group_hight)
      gnr
    end

    def set_optional_group(gnr, group_width, group_hight); end

    def block_group(gnr, group_width, group_hight)
      boxes.each do |box|
        (box.y_pos..box.y_pos + game_scale - 1).step(group_hight).each do |y|
          aliable_waku_of_block(box, group_width, y).each do |x|
            game.groups[gnr] = Number::Group.new(game, gnr, @count, :block)
            (y..y + group_hight - 1).each do |yy|
              (x..x + group_width - 1).each { |xx| waku[xmax * yy + xx].grp_list << gnr }
            end
            gnr += 1
          end
        end
      end
      gnr
    end

    def aliable_waku_of_block(box, group_width, y_pos)
      (box.x_pos..box.x_pos + game_scale - 1).step(group_width).reject do |x|
        waku[xmax * y_pos + x].nil?
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
      # @groups[gnr] =  Group.new(@cells,gnr,game_scale,:holizontal)
      game.groups[gnr] = Number::Group.new(game, gnr, @count, :holizontal)
      (box.x_pos..box.x_pos + game_scale - 1).each do |x|
        waku[xmax * y_pos + x].grp_list << gnr
      end
    end

    def vertical_group(gnr, box, x_pos)
      game.groups[gnr] = Number::Group.new(game, gnr, @count, :vertical)
      (box.y_pos..box.y_pos + game_scale - 1).each do |y|
        waku[xmax * y + x_pos].grp_list << gnr
      end
    end

    def select
      waku.select
    end

    def [](idx, len = nil)
      len ? waku[idx, len] : waku[idx]
    end

    def size
      waku.size
    end

    def map
      waku.map
    end

    def each
      waku.each
    end
  end
end
