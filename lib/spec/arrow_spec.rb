# frozen_string_literal: true

require_relative '../number/game'
# require_relative '../number/box'
require_relative '../number/cell'
# require_relative '../number/form'
require_relative '../number/group'
require_relative '../number/group_ability'
require_relative '../number/game_types'
require_relative '../number/game_types/arrow'

# rubocop: disable Metrics/BlockLength
RSpec.describe Number::Game, type: :model do
  let(:game) do
    game = Number::Game.new('', '9', game_type: 'ARROW')
    game.extend Number::GameTypes::GameType
    game.arrows = [arrow]
    groups = [nil] * 27
    groups[1] = Number::Group.new(game, 1, nil)
    groups[2] = Number::Group.new(game, 2, nil)
    groups[9] = Number::Group.new(game, 9, nil)
    groups[18] = Number::Group.new(game, 18, nil)
    groups[1].cell_ids = (9..17).to_a
    groups[2].cell_ids = (18..26).to_a
    groups[9].cell_ids = (0..73).step(9).to_a
    groups[18].cell_ids = [0, 1, 2, 9, 10, 11, 18, 19, 20]
    game.groups = groups
    game
  end

  let(:cell0) do
    cell = Number::Cell.new(game, 0, [0, 9, 18], nil)
    cell.ability = [7, 8, 9]
    cell
  end
  let(:cell9) do
    cell = Number::Cell.new(game, 9, [1, 9, 18], nil)
    cell.ability = [3, 4, 5]
    cell
  end
  let(:cell18) do
    cell = Number::Cell.new(game, 18, [2, 9, 18], nil)
    cell.ability = [2, 3, 4]
    cell
  end

  let(:arrow) { [0, 9, 18] }
  let(:values) { [cell0.ability, cell9.ability, cell18.ability] }

  before do
    cells = [nil] * 81
    cells[0] = cell0
    cells[9] = cell9
    cells[18] = cell18
    game.cells = cells
  end
  describe :arw_group do
    it '' do
      expect(game.arw_group).to eq [[[1, 2]]]
    end
  end

  describe :candidate_value_combinations do
    it '' do
      expect(game.candidate_value_combinations(0))
        .to eq [[7, 3, 4], [7, 4, 3], [7, 5, 2], [8, 5, 3], [9, 5, 4]]
    end
  end
end
# rubocop:enable Metrics/BlockLength
