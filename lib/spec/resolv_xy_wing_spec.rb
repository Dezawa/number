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
require_relative '../number/resolv_xy_wing'

# rubocop: disable Metrics/BlockLength
RSpec.describe Number::Game, type: :model do
  let(:game) { Number::Game.new(nil, '9') }
  # 1  .  3|4..|...
  # 10 11 .|...|...
  # .  .  .|...|...
  # 28 29
  #          @c  group_ids   abblity
  { cell1: [0,  [0, 9, 18], [2, 3]],
    cell3: [2,  [0, 11, 18], [1, 2]],
    cell4: [3,  [0, 12, 19], [1, 2]],
    cell10: [9,  [1, 9, 18], [1, 3]],
    cell11: [10, [1, 10, 18], [1, 3]],
    cell28: [27, [3, 9, 21], [1, 3]],
    cell29: [28, [3, 10, 21], [1, 3]] }
    .each do |cell, (c, grp, abl)|
    let(cell) do
      cell = Number::Cell.new(game, c, grp, [])
      cell.ability = abl
      cell
    end
  end

  let(:hash_cells) do
    { 1 => cell1, 3 => cell3, 4 => cell4, 10 => cell10,
      11 => cell11, 28 => cell28, 29 => cell29 }
  end

  before { game.cells = hash_cells.values }

  describe 'candidate_cells_of_trio' do
    it ' [[4,10], 4,11], [4,28]]' do
      # cells = cell_ids.map{|id| hash_cells[id]}
      expect(game.candidate_cells_of_trio.map { |cells| cells.map { |cell| cell.c + 1 } })
        .to eq [[3, 28], [4, 10], [4, 11], [4, 28]]
    end
  end

  # 1  .  3|4..|...  1, 3, 4 nil
  # 10 11 .|...|...  1, 10,4 [4, 10]
  # .  .  .|...|...  1, 11,4 nil
  # 28 29            1, 28,4 [4,28],   1, 29, 4 nil
  describe 'join_by_co_group' do
    [[[1, 4, 3], nil],
     [[1, 4, 10], [4, 10]],
     [[1, 4, 11], [4, 11]],
     [[1, 4, 28], [4, 28]],
     [[1, 4, 29], nil],
     [[1, 3, 10], nil],
     [[1, 3, 11], nil],
     [[1, 3, 28], [3, 28]],
     [[1, 3, 29], nil]]
      .each do |cell_ids, result|
      it "cells#{cell_ids}は#{result}" do
        cells = cell_ids.map { |id| hash_cells[id] }
        ret = game.join_by_co_group(cells)
        ret = ret.map { |cell| cell.c + 1 } if ret
        expect(ret).to eq result
      end
    end
  end

  # end
  # __END__
  describe 'rest_two_cells' do
    it '' do
      expect(game.rest_two_cells.map(&:c)).to eq([0, 2, 3, 9, 10, 27, 28])
    end
  end

  describe 'trio_of_3_values' do
    it '' do
      expect(game.trio_cells_of_3_values.map { |cells| cells.map(&:c) })
        .to eq [[0, 2, 9], [0, 2, 10], [0, 2, 27], [0, 2, 28],
                [0, 3, 9], [0, 3, 10], [0, 3, 27], [0, 3, 28]]
    end
  end

  # 1  .  3|4..|...  1, 3, 4 NG
  # 10 11 .|...|...  1, 10,4 OK
  # .  .  .|...|...  1, 11,4 OK
  # 28 29            1, 28,4 OK,   1, 29, 4 OK
  describe 'not_on_same_group' do
    [[[1, 4, 3], false],
     [[1, 4, 10], true],
     [[1, 4, 11], true],
     [[1, 4, 28], true],
     [[1, 4, 29], true]]
      .each do |cell_ids, result|
      it "cells#{cell_ids}は#{result}" do
        cells = cell_ids.map { |id| hash_cells[id] }
        expect(game.not_on_the_same_group(cells)).to eq result
      end
    end

    it 'cell 1, 4, 10 はtrue' do
      expect(game.not_on_the_same_group([cell1, cell4, cell10])).to eq true
    end
    it 'cell 1, 3, 10 はfale' do
      expect(game.not_on_the_same_group([cell1, cell3, cell4])).to eq false
    end
  end
end
# rubocop: enable Metrics/BlockLength
