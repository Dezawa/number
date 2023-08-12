# frozen_string_literal: true

module Number
  class Box
    def initialize(n, x = nil, y = nil)
      @n = n
      @position = []
      @position = x if x.instance_of?(Array)
      @position = [x, y] unless y.nil?
    end

    def p(x = nil, y = nil)
      @position = x if x.instance_of?(Array)
      @position = [x, y] unless y.nil?
      @position
    end

    def p=(x = nil, y = nil)
      @position = x if x.instance_of?(Array)
      @position = [x, y] unless y.nil?
    end

    def +(x = nil, y = nil)
      @position = [@position[0] + x[0], @position[1] + x[1]] if x.instance_of?(Array)
      @position = [@position[0] + x, @position[1] + y]       unless y.nil?
      @position
    end

    def x=(i)
      @position[0] = i
    end

    def x
      @position[0]
    end

    def y
      @position[1]
    end
  end
end
