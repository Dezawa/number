#!/usr/bin/env ruby
# frozen_string_literal: true
# == dir内のgameを全部解いて
# default :: 解けなかった問題をlist up
# -S      :: 解けたか否かに関わらず、使った技の統計を出す
# frozen_string_literal: true

require_relative 'lib/number/game'

# == dir内のgameを全部解いて
# default :: 解けなかった問題をlist up
# -S      :: 解けたか否かに関わらず、使った技の統計を出す
class NumpleAnalize
  attr_accessor :directories

  def numples
    @numples = [directories].flatten.map { |directory| Dir.glob("#{directory}/*") }.flatten
  end

  def analyze
    numples.sort.map do |numple|
      print  "#{numple} \r"
      game = Number::Game.create(File.open(numple))
      unless game.resolve
        puts "#{numple}:error"
        numple
      end
    end.compact
  end

  def output
    pp analyze
  end
end
