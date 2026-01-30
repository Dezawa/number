require 'fileutils'
require 'selenium-webdriver'
require 'webdrivers'

class Numpre7
  attr_accessor :game_number

  LEVELS = (1..7).to_a
  GAME_NR_LIST_FILES = LEVELS.map { |lvl| "game_number_level#{lvl}" }

  def url_base
    'https://numpre7.com'
  end

  def game_url
    "#{url_base}/np#{game_number}"
  end

  def output_file(number)
    "np#{number}"
  end

  def game_number_level(lvl)
    "game_number_level#{lvl}"
  end

  #  [[7, 3], [6, 1], [5, 1], [4, 1], [3, 1], [2, 1]]
  def game_levels(level = 7, page = 1)
    game_lvls = (level..1).step(-1).to_a.map { |lvl| [lvl, 1] }
    game_lvls[0][1] = page
    game_lvls
  end

  def get_games(level = 7, page = 1)
    game_levels(level, page)[0, 1].each do |lvl, page|
      pp [lvl, page]
      game_number_file = File.open(game_number_level(lvl))
      (page - 1).times { game_number_file.gets }
      while (line = game_number_file.gets)
        print "\n#{line}    "
        numbers = line.split
        page = numbers.shift
        numbers.sort.each do |number|
          output number
          sleep 5
        end
      end
    end
  end

  def output(number)
    self.game_number = number
    dir = "../sample/#{number[0, 2]}"
    FileUtils.mkdir_p(dir)
    File.open("#{dir}/#{output_file(number)}", 'w') do |f|
      print "#{number} "
      f.puts "## #{output_file(number)} ##\n9"
      f.puts game_data
    end
  end

  def driver
    return @driver if @driver

    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    @driver = Selenium::WebDriver.for(:chrome, options: options)
  end

  def cell_ids
    @cell_ids ||= (1..9).to_a.product((1..9).to_a).map { |r, c| "c#{c}-#{r}" }
  end

  def game_data
    begin
      driver.get(game_url)
    rescue StandardError => e
      puts "ERROR #{e}"
      sleep 5
      retry
    end
    cell_ids.map do |cell_id|
      val = driver.find_element(id: cell_id).text
      val == '' ? '.' : val
    end.join
  end
end
