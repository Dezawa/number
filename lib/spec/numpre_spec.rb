# frozen_string_literal: true

require_relative '../numple'
RSpec.describe Numple, type: :model do
  let(:std) { "#\n" }
  let(:data) { "123......\n#{".........\n" * 8}" }

  describe 'Game.createの実行' do
    it 'params' do
      infile = StringIO.new("# \n9\n#{data}", 'r+')
      expect(Number::Game).to receive(:create) do |file|
        expect(infile).to eq(file)
      end
      numple = Numple.new(infile)
      numple.create_game
    end
  end
end
