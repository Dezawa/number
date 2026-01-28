# frozen_string_literal: true

require_relative '../number/game'
# require_relative '../number/box'
require_relative '../number/cell'
# require_relative '../number/form'
require_relative '../number/group'
require_relative '../number/group_ability'
require_relative '../number/resolv_cross'
require_relative '../number/resolv_reserv'
require_relative '../number/resolv_curb'
require_relative '../number/resolv_prison'

RSpec.describe Number::Game, type: :model do
  let(:game) { Number::Game.new(nil, '9') }
  let(:group) do
    grp = Number::Group.new(game, 9, [])
    grp.cell_ids = (10..18).to_a
    grp
  end
  #  let(:group_aiblilities) { Number::GroupAbilities.new(9) }

  describe :groups_remain_2_or_m_cells_of_value_is do
    subject(:groups_remain) { groups_remain_2_or_m_cells_of_value_is(:holizontal, :vertical, 5) }
  end
end
