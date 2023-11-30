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

  # dir :: 
  def initialize(*dir)
    @directories = dir
  end
  def numples
    @numples = [directories].flatten.map { |directory| Dir.glob("#{directory}/*") }.flatten
  end

  def stat
    statistics = Hash.new{|h,k| h[k] = 0 }
    numples.sort.map do |numple|
      $stderr.print  "#{numple} \r"
      game = Number::Game.create(File.open(numple))
      game.resolve
      game.count.each{|k,v| statistics[k] += v }
    end
    
    puts Number::Game::RESOLVE_PATH.map{|sym, num|
      format(" Stat: %<l>-10s %<v>3d\n",
             l: "#{sym}#{num}", v: statistics["#{sym}#{num}"]) }.join
  end
  
  def analyze
    numples.sort.map do |numple|
      $stderr.print  "#{numple} \r"
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

# pp $ARGV
if /numple_analize.rb$/ =~ $0
  
  NumpleAnalize.new(ARGV).stat
end
