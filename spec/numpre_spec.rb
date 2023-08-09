require_relative '../numple'
RSpec.describe Numple, type: :model do
  let(:std) { "#NSP\n" }
  let(:data) { "123......\n.........\n.........\n.........\n.........\n.........\n.........\n.........\n.........\n" }

  describe '#analyze_data' do
    Number::Game::Iromono.each do |game_type|
      it '戻り値' do
        infile = StringIO.new("#NSP #{game_type}\n9\n" + data, 'r+')
        numple = Numple.new(infile)
        expect(numple.analyze_data).to eq ['9', '', game_type]
      end
    end

    it 'infile の残りはdata' do
      infile = StringIO.new("#NSP \n9\n" + data, 'r+')
      numple = Numple.new(infile)
      numple.analyze_data
      expect(infile.read).to eq data
    end 
  end
  
  describe 'Game.createの実行' do
    it 'params' do
      infile = StringIO.new("#NSP \n9\n" + data, 'r+')
      expect(Number::Game).to receive(:create) do |infile, form, sep, game_type|
        expect(infile).to eq(infile) and
          expect(form).to eq '9' and
          expect(sep).to eq '' and
          expect(game_type).to eq ({game_type: nil})
      end
      numple = Numple.new(infile)
      game = numple.create_game
    end
  end
end
