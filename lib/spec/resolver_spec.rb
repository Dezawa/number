# frozen_string_literal: true

require_relative '../number/game'
# require_relative '../number/box'
require_relative '../number/cell'
# require_relative '../number/form'
require_relative '../number/group'
require_relative '../number/group_ability'
# require_relative '../number/game_types'

RSpec.describe Number::Game, type: :model do
  let(:game) { Number::Game.new(nil, '9') }
  let(:group) do
    grp = Number::Group.new(game, 9, [])
    grp.cell_list = (10..18).to_a
    grp
  end
  let(:group_aiblilities) { Number::GroupAbilities.new(9) }

  describe :prison do
    let(:cell_abilities_for_prison) do
      # cell 10,11,12には1,2,3のみが有る。cell 13,14 には4,5のみが有る。
      # これらcellには他の数字はない
      # この数字は他のcellにもある
      [[1, 2, 3], [1, 2], [2, 3], [4, 5], [4, 5]] + # cell 10~14の可能性数字
        [[1, 6, 7, 8], [4, 6, 7, 8, 9], [1, 4, 7, 9], [1, 2, 3, 7, 9]]
    end
    let(:cells) do
      [nil] * 10 +
        cell_abilities_for_prison.map.with_index(10) do |ability, cell_no|
          cell = Number::Cell.new(game, cell_no, group, [])
          cell.ability = ability
          cell
        end
    end

    before do
      game.cells = cells
      group.cell_list = (10..18).to_a
      group.cells = cells
    end

    it '座敷牢2' do
      expect(game.prisonable_cells(group, 2)).to eq [[[13, 14], [4, 5]]]
    end
  end

  describe :reserv do
    let(:abilities_for_reserv) do
      # cell 10,11,12には1,2,3が有る。cell 13,14 には4,5が有る。
      # cell 15,16 には 6,7 がある
      # これらの数字は他のcellにはない
      # 他の数字はこれらのcellにもある
      # 数字１のあるcell、数字2の、数字3の、
      [[10, 11, 12], [11, 12], [10, 12]] +
        [[13, 14], [13, 14]] + # 数字 4, 5のあるcell
        [[15, 16], [15, 16]] + # 数字6, 7のあるcell
        [[13, 17], [10, 13, 18]] # 数字 8, 9のあるcell
    end
    let(:cell_abilities) do
      cell_ability = Hash.new { |h, k| h[k] = [] }
      abilities_for_reserv.map.with_index(1) do |cells, val|
        pp [cells, val]
        cells.each { |cell| cell_ability[cell] << val }
      end
      cell_ability
    end
    let(:cells) do
      # pp [:cell_abilities,cell_abilities]
      [nil] * 10 +
        cell_abilities.map.with_index(10) do |_ability, cell_no|
          cell = Number::Cell.new(game, cell_no, group, [])
          cell.ability = cell_abilities[cell_no]
          cell
        end
    end

    let(:ary_groupability) do
      abilities_for_reserv.map.with_index(1) do |ability, value|
        group_aiblilities.ability[value] =
          Number::GroupAbility.new(ability.size, ability, value)
      end
    end

    let(:combo3) { ary_groupability[0, 3] }
    let(:combo2) { ary_groupability[3, 2] }
    let(:combo2_2) { ary_groupability[5, 2] }

    context :candidate_reserved_set do
      before do
        game.cells = cells
        group.ability = Number::GroupAbilities.new(9)
        group.ability.ability = ary_groupability
        allow(group.ability)
          .to receive(:combination_of_ability_of_rest_is_less_or_equal)
          .and_return([combo2, combo2_2])
        allow(game).to receive(:prison_done?).and_return(false)
      end

      it '' do
        # pp [:less_or_equal,group.ability.combination_of_ability_of_rest_is_less_or_equal(2)]
        expect(game.candidate_reserved_set(2, group))
          .to eq [[[4, 5], [13, 14], combo2]]
      end
    end
    context :sum_of_cells_and_values do
      it 'combo2 の時' do
        ret = game.sum_of_cells_and_values(combo2)
        expect(ret).to eq [[4, 5], [13, 14]]
      end
      it 'combo3 の時' do
        ret = game.sum_of_cells_and_values(combo3)
        expect(ret).to eq [[1, 2, 3], [10, 11, 12]]
      end
    end
  end
end
__END__
  it '3個以下のcombintion。数字4,5がcell13,14にある' do
    abilities = group_aiblilities.combination_of_ability_of_rest_is_less_or_equal(3)
    expect(abilities.map{|ab| ab.map{|ablty| [ablty.cell_list,ablty.v]}}).to match_array [[[[10,11,12],1], [[11,12],2], [[10,12],3]]]
  end
end
end
