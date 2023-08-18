# frozen_string_literal: true

# require_relative '../number/game'
# require_relative '../number/box'
# require_relative '../number/cell'
# require_relative '../number/form'
# require_relative '../number/group'
require_relative '../number/group_ability'
# require_relative '../number/game_types'

RSpec.describe Number::GroupAbilities, type: :model do
  let(:group_aiblilities) { Number::GroupAbilities.new(9) }
  let(:abilities) do
    # cell 10,11,12には1,2,3が有る。cell 13,14 には4,5が有る。
    # これらの数字は他のcellにはない
    # 他の数字はこれらのcellにもある
    [[10, 11, 12], [11, 12], [10, 12]] +
      [[13, 14], [13, 14]] +
      [[10, 13, 15, 16, 17, 18]] * 4
  end
  context :combination_of_ability_of_rest_is_less_or_equal do
    before do
      abilities.each.with_index(1) do |ability, value|
        group_aiblilities.ability[value] =
          Number::GroupAbility.new(ability.size, ability, value)
      end
    end
    it '2個以下のcombintion。数字4,5がcell13,14にある' do
      abilities = group_aiblilities.combination_of_ability_of_rest_is_less_or_equal(2)
      expect(abilities.map do |ab|
               ab.map do |ablty|
                 [ablty.cell_list, ablty.v]
               end
             end).to match_array([[[[13, 14], 4], [[13, 14], 5]]])
    end
    it '3個以下のcombintion。数字4,5がcell13,14にある' do
      abilities = group_aiblilities.combination_of_ability_of_rest_is_less_or_equal(3)
      expect(abilities.map do |ab|
               ab.map do |ablty|
                 [ablty.cell_list, ablty.v]
               end
             end).to match_array [[[[10, 11, 12], 1], [[11, 12], 2], [[10, 12], 3]]]
    end
  end
end
