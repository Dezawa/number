# frozen_string_literal: true

require 'English'
module Number
  # ややこしい出力のためのhelper
  class Form < Array
    attr_accessor :game_scale

    def initialize(p_form, game_scale)
      @game_scale = game_scale

      # [ w,xmax,ymax ]
      w, xmax, ymax = p_form
      (0..ymax - 2).each { |i|
        push(w[i * xmax, xmax].map { |ww| ww.nil? ? nil : ww[0] }) }
      @lines = ymax - 1
      # pp self
    end

    def out(cells)
      space, fm1, fm2 = define_fmt
      outstr = String.new
      each do |l|
        l.each do |cell_no|
          cell = cell_no ? cells[cell_no] : nil
          outstr << out_cell(cell, space, fm1, fm2)
        end
        outstr << "\n"
      end
      outstr
    end

    def out_cell(cell, space, fm1, fm2)
      if cell
        w = cell.v
        w ? fm1 % w : fm2
      else
        space
      end
    end

    def define_fmt
      if game_scale > 9
        space = '   '
        fm1 = '%2d '
        fm2 = ' . '
      else
        space = ' '
        fm1 = '%1d'
        fm2 = '.'
      end
      [space, fm1, fm2]
    end
    # def outAbility(cells, v)
    #   print "\n-----\n"
    #   each  do |l|
    #     l.each do |c|
    #       if c
    #         w = cells[c].ability.include?(v) ? v : nil
    #         w ? (printf '%2d', w) : (print ' .')
    #       else
    #         print ' ' * (game_scale > 9 ? 3 : 2) # **** [1]*3
    #       end
    #     end
    #     print "\n"
    #   end
    #   return

    #   (1..@lines).each do |l|
    #     self[l].each do |se|
    #       if (se[0]).zero?
    #         print ' ' * se[1] * (game_scale > 9 ? 3 : 2) # **** [1]*3
    #       else
    #         (se[0]..se[1]).each do |c|
    #           w = cells[c].ability[v]
    #           w ? (printf '%2d', w) : (print ' .')
    #           print game_scale > 9 ? ' ' : ''
    #         end
    #       end
    #     end
    #     print "\n"
    #   end
    # end
  end
end
