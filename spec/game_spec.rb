# frozen_string_literal: true

require_relative '../number/game'
require_relative '../number/box'
require_relative '../number/cell'
require_relative '../number/form'
require_relative '../number/group'
require_relative '../number/group_ability'
require_relative '../number/game_types'

RSpec.describe Number::Game, type: :model do
  let(:data) { String.new("123......\n.........\n.........\n.........\n.........\n.........\n.........\n.........\n.........\n") }
  let(:infile) { StringIO.new(data, 'r+') }
  context :new do
    let(:game) { Number::Game.create(infile, '9', '') }

    it 'groupは27' do
      expect(game.groups.size).to eq 3 * 9
    end
    it 'cellは81' do
      expect(game.cells.size).to eq 9 * 9
    end
    it 'cellの値は1,2,3とnil' do
      expect(game.cells.map(&:v)).to eq [1, 2, 3] + [nil] * 78
    end

    context 'cell[0]は' do
      it 'group 0,9,18 に属する' do
        expect(game.cells[0].grpList).to eq [0, 9, 18]
      end
      it 'abirityは[]' do
        expect(game.cells[0].ability).to eq []
      end
    end
    context 'cell[3]は' do
      it 'group 0,12,18 に属する' do
        expect(game.cells[3].grpList).to eq [0, 12, 19]
      end
      it 'abirityは123以外' do
        expect(game.cells[3].ability).to eq [4, 5, 6, 7, 8, 9]
      end
    end
  end

  describe '色物拡張' do
    Number::Game::Iromono.each do |game_type|
      it "#{game_type}がextendされる" do
        game = Number::Game.new(infile, '9', '', game_type: "# NSP #{game_type}")
        game.set_game_type
        expect(game.game_type).to eq game_type
      end
    end
  end

  let(:sult) do
    "876159423
321487965
945326187
452978631
638241759
719635842
594762318
267813594
183594276".gsub(/\s/, '').split('').map(&:to_i)
  end
  describe '解' do
    let(:game) { Number::Game.create(infile, '9', '') }
    let(:infile) { open('./sample/np101001') }
    before do
      infile.gets
      infile.gets
    end

    it '解は' do
      game.resolve
      expect(game.cells.map(&:v)).to eq sult
    end
  end
end
