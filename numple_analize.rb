#!/usr/bin/env ruby
# frozen_string_literal: true
# == dir内のgameを全部解いて
# default :: 解けなかった問題をlist up
# -S      :: 解けたか否かに関わらず、使った技の統計を出す
# frozen_string_literal: true

require_relative 'lib/number/game'
require_relative 'lib/numple'

# == dir内のgameを全部解いて
# default :: 解けなかった問題をlist up
# -S      :: 解けたか否かに関わらず、使った技の統計を出す
class NumpleAnalize
  attr_accessor :directory, :directories, :gcount, :call_count

  def initialize(directory)
    @directory = directory
  end
  
  def numples(dir)
    @numples =Dir.glob("#{dir}/np*") #[0,100]
  end

  def analyze
    #pp numples
    @gcount = Hash.new(0)
    @call_count = Hash.new(0)
    # directories.each do |dir|
    #  pp dir
      # pp numples(dir)
      counts =
        numples(directory).sort.map do |filename|
          # puts File.basename(filename)
          numple = Numple.new(filename, option: {nine: true})
          unless numple.resolve
            # game = Number::Game.create(File.open(numple), option: {nine: true})
            # unless game.resolve
            $stderr.puts "#{File.basename filename}:error"
            $stderr.puts numple.output_form
            nil
          else
            #puts numple.output_form
            sum_count(numple.game.count)
            sum_call_count(numple.game.call_count)
            #puts "#{File.basename filename}:\n#{numple.game.output_statistics}"
          end
      end.compact
    # end
  end

  def sum_count(count)
    count.each{|k,v| @gcount[k] += v}
  end
  def sum_call_count(count)
    count.each{|k,v| @call_count[k] += v}
  end

  def print_count(count)
   ret =  Number::Resolver::RESOLVE_KEY.map do |key|
     "%7d," % count[key].to_s
     #key
   end.to_a.join
   ret
  end
  def print_call_count(count)
   ret =  Number::Resolver::RESOLVE_KEY.map do |key|
     "%7d," % count[key].to_s
     #key
   end.to_a.join
   ret
  end
  
  def output
    pp analyze
  end
end

if $0 ==  __FILE__
  # pp ARGV
  #puts Number::Resolver::RESOLVE_KEY.join(" ")
  keys = Number::Resolver::RESOLVE_KEY + ["reserv4", "prison4"]
  #puts "    "+keys.map{|key| "#{key}    "[0,7]}.join(' ')
  puts "    "+Number::Resolver::RESOLVE_KEY.map{|key| "#{key}    "[0,7]}.join(' ')
 # exit
  ARGV.each do |dir|
    analize = NumpleAnalize.new dir
    analize.analyze
    # pp analize.gcount
    puts "#{File.basename dir}:#{analize.print_count(analize.gcount)}"
    puts "   :#{analize.print_call_count(analize.call_count)}"
    #running_count(count)
  end
end
