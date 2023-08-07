require_relative '../number/game'
require_relative '../number/box'
require_relative '../number/cell'
require_relative '../number/form'
require_relative '../number/group'
require_relative '../number/group_ability'
RSpec.describe Number::Game, type: :model do
  let(:data) { "123......\n.........\n.........\n.........\n.........\n.........\n.........\n.........\n.........\n" }
  let(:infile) {  StringIO.new(data, 'r+') }
  context :new do
    let(:game) { Number::Game.new(infile, "9", "") }
      
    it "groupは27" do
      expect(game.groups.size).to eq 3*9
    end
    it "cellは81" do
      expect(game.cells.size).to eq 9*9
    end
    it "cellの値は1,2,3とnil" do
      expect(game.cells.map(&:v)).to eq [1,2,3]+[nil]*78
    end

    context "cell[0]は" do
      it "group 0,9,18 に属する" do
        expect(game.cells[0].grpList).to eq [0,9,18]
      end
      it "abirityは[]" do
        expect(game.cells[0].ability).to eq []
      end
    end
    context "cell[3]は" do
      it "group 0,12,18 に属する" do
        expect(game.cells[3].grpList).to eq [0,12,19]
      end
      it "abirityは123以外" do
        expect(game.cells[3].ability).to eq [4, 5, 6, 7, 8, 9]
      end
    end
  end
end
