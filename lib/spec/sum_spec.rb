# frozen_string_literal: true

require_relative '../number/game'
require_relative '../number/box'
require_relative '../number/cell'
require_relative '../number/form'
require_relative '../number/group'
require_relative '../number/group_ability'
require_relative '../number/game_types'
require_relative '../number/game_types/sum'

RSpec.describe Number::Game, type: :model do
  let(:game) do
    game = Number::Game.new('', '9', game_type: 'SUM')
    game.extend Number::GameTypes::GameType
  end

  context :list_of_aviable_valu_set do
    cell1 = [1, 2, 3]
    cell2 = [2, 3, 4]
    cell3 = [3, 4, 5]

    before do
      allow(game).to receive(:allowable_dup?).and_return(true)
    end

    context "#{cell1},#{cell2},#{cell3} の組み合わせでは" do
      it 'sum=9のとき7組できる' do
        sum = 9
        products_all = cell1.product(cell2, cell3)
        expect(game.list_of_aviable_valu_set([3, 4, 5, 6], products_all, sum).size)
          .to eq 7
      end
    end
  end

  context :is_allowable_dup do
    #             [sum,c-idx,c-idx,c-idx] c-idx は0から
    let(:arrow1) { [9, 21, 22, 23] } # 横一直線
    let(:arrow2) { [9, 21, 30, 29] } # Lの字 21、29は共通Groupなし
    let(:cell20) { Number::Cell.new(nil, 20, [2, 11, 18], 0) }
    let(:cell21) { Number::Cell.new(nil, 21, [2, 12, 19], 0) }
    let(:cell22) { Number::Cell.new(nil, 22, [2, 13, 19], 0) }
    let(:cell23) { Number::Cell.new(nil, 23, [2, 14, 19], 0) }
    let(:cell30) { Number::Cell.new(nil, 30, [3, 12, 21], 0) }
    let(:cell29) { Number::Cell.new(nil, 29, [3, 11, 22], 0) }

    before do
      # cell20は c-idx20、すなわち21番め
      game.cells = [nil] * 20 + [cell20, cell21, cell22, cell23] + [nil] * 5 + [cell29, cell30, nil]
    end
    it '横一直線のとき同じ数字があるとfalse' do
      sells_value = [1, 2, 1]
      expect(game.allowable_dup?(arrow1, sells_value)).to eq false
    end
    it '横一直線のとき同じ数字がないとtrue' do
      sells_value = [1, 2, 4]
      expect(game.allowable_dup?(arrow1, sells_value)).to eq true
    end
    it 'コの字のとき1,2つ目に同じ数字があるとfalse' do
      sells_value = [1, 1, 3]
      expect(game.allowable_dup?(arrow2, sells_value)).to eq false
    end
    it 'コの字のとき1,3つ目に同じ数字が有ってもtrue' do
      sells_value = [1, 2, 1]
      expect(game.allowable_dup?(arrow2, sells_value)).to eq true
    end
  end
end
