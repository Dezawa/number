# frozen_string_literal: true

module Number
  # mail class
  class Waku
    attr_accessor :waku, :boxes, :xmax, :game, :game_scale

    def initialize(game, boxes, game_scale, m_nr, count, xmax, _ymax)
      cell_no = 0
      @waku = []
      @game = game
      @game_scale = game_scale
      @boxes = boxes
      @count = count
      @xmax = xmax

      boxes[0..m_nr].each do |box|
        (box.y_pos..box.y_pos + game_scale - 1).map do |_y|
          (box.x_pos..box.x_pos + game_scale - 1).map do |_x|
            @waku << WakuSub.new(cell_no)
            cell_no += 1
          end
          @waku << WakuSub.new(nil)
        end
        @waku += [WakuSub.new(nil)] * xmax
      end
    end

    def set_grp(group_width, group_hight)
      gnr = 0
      gnr = set_vertical_holizontal_group(gnr)
      gnr = set_block_group(gnr, group_width, group_hight)
      set_optional_group(gnr, group_width, group_hight)
    end

    def set_optional_group(gnr, group_width, group_hight); end

    def set_block_group(gnr, group_width, group_hight)
      boxes.each do |box|
        (box.y_pos..box.y_pos + game_scale - 1).step(group_hight).each do |y|
          (box.x_pos..box.x_pos + game_scale - 1).step(group_width).reject do |x|
            # next if waku[xmax*y+x].nil?     #or waku[xmax*y+x][1]
            waku[xmax * y + x].nil?
          end.each do |x|
            # @groups[gnr] =  Group.new(@cells,gnr,game_scale,:block)
            game.groups[gnr] = Number::Group.new(game, gnr, @count, :block)
            (y..y + group_hight - 1).each do |yy|
              (x..x + group_width - 1).each { |xx| waku[xmax * yy + xx][1] << gnr }
            end
            gnr += 1
          end
        end
      end
      gnr
    end

    def set_vertical_holizontal_group(gnr)
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
        waku[xmax * y_pos + x][1] << gnr
      end
    end

    def vertical_group(gnr, box, x_pos)
      # @groups[gnr] =  Group.new(@cells,gnr,game_scale,:vertical)
      game.groups[gnr] = Number::Group.new(game, gnr, @count, :vertical)
      (box.y_pos..box.y_pos + game_scale - 1).each { |y| waku[xmax * y + x_pos][1] << gnr }
    end

    def select
      waku.select
    end

    def [](idx, len = 1)
      waku[idx, len]
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

  class WakuSub
    attr_accessor :cell_no, :group_list

    def initialize(cell_n)
      @cell_no = cell_n if cell_n
      @group_list = []
    end

    def [](idx)
      case idx
      when 0
        cell_no
      when 1
        group_list
      end
    end

    def nil?
      !cell_no
    end

    def inspect
      return 'NullWaku' unless cell_no

      "[#{cell_no}, #{group_list}]"
    end
  end
end
