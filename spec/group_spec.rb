require_relative '../number/group'
RSpec.describe Number::Group, type: :model do
  let(:data) { "123......\n.........\n.........\n.........\n.........\n.........\n.........\n.........\n.........\n" }

  context :new do
    let(:number) { Number.new("9", "",nil,data) }
      
    it "groupは27" do
      expect(number.game.groups.size).to eq 3*9
    end
    it "cellは81" do
      expect(number.game.cells.size).to eq 9*9
    end
    it "cellの値は1,2,3とnil" do
      expect(number.game.cells.map(&:v)).to eq [1,2,3]+[nil]*78
    end

    context "cell[0]は" do
      it "group 0,9,18 に属する" do
        expect(number.game.cells[0].grpList).to eq [0,9,18]
      end
      it "値は1" do
        expect(number.game.cells[0].v).to eq 1
      end
    end
  end
end
