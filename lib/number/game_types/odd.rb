# frozen_string_literal: true

module Number
  module GameTypes
    # 偶奇のextend
    module GameType
      def game
        'ODD'
      end

      # module Optional
      def optional_struct(_sep, _game_scale, infile)
        get_arrow(infile)
        # @arrow=Hash[*@arrow.map{|c1,c2| [[c1,c2],[c2,c1]]}.flatten]
      end
      # end

      def optional_test
        @arrows.delete_if { |arrow| arrow[0].nil? }

        return true if partner_is_even_or_odd

        true if even_or_odd_can_fix_if_4cupcells_is_in_group
      end

      ########
      def even_or_odd_can_fix_if_4cupcells_is_in_group
        sw = nil
        groups.each do |group|
          ret = even_or_odd_can_fix_if_4cupcells_is_in_the(group)
          sw ||= ret
        end
      end

      def even_or_odd_can_fix_if_4cupcells_is_in_the(group)
        even = game_scale / 2
        odd = (game_scale + 1) / 2
        arrows = arrows_on_the(group)
        odd  -= arrows.size
        even -= arrows.size
        return cells[cells_not_included_in(arrows, group).first].set_odd if even.zero?

        cells_not_included = cells_not_included_in(arrows, group)
        cellss_not_included = cells_not_included.dup

        sw = nil
        cellss_not_included.each do |cell_nr|
          cell = cells[cell_nr]
          if cell.odd?
            odd -= 1
            cells_not_included.delete(cell_nr)
          elsif cell.even?
            even -= 1
            cells_not_included.delete(cell_nr)
          end
          if even.zero?
            cells_not_included.each do |cell_nr|
              ret = cells[cell_nr].set_odd
              sw ||= ret
            end
            return sw
          end
          next unless odd.zero?

          cells_not_included.each do |cno|
            ret = cells[cno].set_even
            sw ||= ret
          end
          return sw
        end
        nil
      end

      def cells_not_included_in(arrows, group)
        group.cell_list - arrows.inject([]) { |cells, arrow| cells | arrow }
      end

      def cell_odd?(_cell, _group, arrows)
        even = game_scale / 2 - arrows.size
        true if even.zero?
      end

      def arrows_on_the(group)
        @arrows.select { |arrow| (arrow & group.cell_list).size == 2 }
      end

      ###
      def partner_is_even_or_odd
        sw = nil
        puts 'partner_is_even_or_odd' if option[:verb]
        @arrows.each do |arrow|
          next unless arrow[0]

          if set_even_if_partner_odd?(arrow)
            sw = true
            next
          elsif  set_odd_if_partner_is_even(arrow)
            sw = true
            next
          end
        end
        sw
      end

      def set_odd_if_partner_is_even(arrow)
        c1, c2 = arrow
        if @cells[c1].odd?
          @cells[c2].set_even
        elsif @cells[c2].odd?
          @cells[c1].set_even
        else
          return nil
        end
        # pp [ "set_even",arrow, @cells[c1],@cells[c2] ]
        arrow[0..1] = [nil, nil]
        true
      end

      def set_even_if_partner_is_odd(arrow)
        c1, c2 = arrow
        if @cells[c1].even?
          @cells[c2].set_odd
        elsif @cells[c2].even?
          @cells[c1].set_odd
        else
          return nil
        end
        arrow[0..1] = [nil, nil]
        true
      end
    end
  end
end
