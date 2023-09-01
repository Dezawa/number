# frozen_string_literal: true

require_relative '../number/game'
require_relative '../number/box'
require_relative '../number/cell'
require_relative '../number/form'
require_relative '../number/group'
require_relative '../number/group_ability'
require_relative '../number/game_types'

RSpec.describe Number::Game, type: :model do
  let(:cells) do
    (0..80).step(9).map do |c0|
      (c0..c0 + 8).map { |c| Number::Cell.new(nil, c, [], nil) } << Number::NullCell.instance
    end.flatten(1) + [Number::NullCell.instance] * 10
  end
  let(:game) { Number::Game.new }

  it { pp cells.size }
  it 'neighberは144個' do
    expect(game.neighber(cells, 10, 10).size).to eq (8 + 9) * 8 + 8
  end
  it 'cell 0のneighberは' do
    expect(game.neighber(cells, 10, 10).select { |c0, _c1| c0.zero? }).to eq [[0, 1], [0, 9]]
  end
  it 'cell 8のneighberは' do
    expect(game.neighber(cells, 10, 10).select { |c0, _c1| c0 == 8 }).to eq [[8, 17]]
  end
  it 'cell 80のneighberは' do
    expect(game.neighber(cells, 10, 10).select { |c0, _c1| c0 == 80 }).to eq []
  end
end
