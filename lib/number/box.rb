# frozen_string_literal: true

module Number
  # 9x9を複数重ねる構造の場合に、構造作成の補助として 9x9の枠を用意する
  class Box
    def initialize(_game_scale, x_pos = nil, y_pos = nil)
      @position = []
      @position = x_pos if x_pos.instance_of?(Array)
      @position = [x_pos, y_pos] unless y_pos.nil?
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

    def x_pos=(position)
      @position[0] = position
    end

    def x_pos
      @position[0]
    end

    def y_pos
      @position[1]
    end
  end
end
