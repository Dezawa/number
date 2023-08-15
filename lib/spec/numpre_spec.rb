# frozen_string_literal: true

require_relative '../numple'
RSpec.describe Numple, type: :model do
  let(:std) { "#\n" }
  let(:data) { "123......\n.........\n.........\n.........\n.........\n.........\n.........\n.........\n.........\n" }

  describe 'Game.createの実行' do
    it 'params' do
      infile = StringIO.new("# \n9\n#{data}", 'r+')
      expect(Number::Game).to receive(:create) do |infile|
        expect(infile).to eq(infile)
      end
      numple = Numple.new(infile)
      numple.create_game
    end
  end
end
