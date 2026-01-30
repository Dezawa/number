# nampre7.rb
# ナンプレ７のサイトから game(npLNN001〜)をDLし
# gameのデータを取り出す。 空白は ドット、数字が有ったらその値
# ...34....
# .9.......
# .6...72.4
# .2..3.756
# .........
# 675.8..3.
# 7.39...2.
# .......8.
# ....26...
# というgameを
# ...34.....9........6...72.4.2..3.756.........675.8..3.7.39...2........8.....26...
# で表現

require "ferrum"

class Numpre7
  BASE_URL = "https://numpre7.com"

  def initialize(timeout: 30, headless: true)
    @browser = Ferrum::Browser.new(
      timeout: timeout,
      headless: headless
    )
  end

def html(game)
  url = "#{BASE_URL}/#{game}"

  page = @browser.create_page
  status = nil

  # メインドキュメントの HTTP ステータスを捕まえる
  page.on(:response) do |response|
    if response.url == url
      status = response.status
    end
  end

  page.goto(url)

  # 400なら即 false
  return false if status == 400

  # JS描画完了待ち（DOM待ち）
  page.network.wait_for_idle
  #page.at_css("div#c9-9")

  page.body
rescue Ferrum::TimeoutError
  false
ensure
  page&.close
end
  # def html(game)
  #   url = "#{BASE_URL}/#{game}"
  #   pp url
  #   page = @browser.create_page
  #   puts :page
  #   page.goto(url)

  #   # JS描画が落ち着くまで待つ
  #   puts "###"
  #    page.network.wait_for_idle
  #   #page.at_css("div#c9-9")
  #   puts "$$$"
  #   page.body
  # ensure
  #   page&.close
  # end


  # HTML → 盤面文字列
  def bord(html_str)
    cells = html_str
              .split("</div>")
              .select { |line| /eg-obj eg-np x/ =~ line }

    cells = cells.map do |cell|
      v = cell.sub(/.*>/, "")
      v =~ /\d/ ? v : "."
    end

    cells = cells.each_slice(9).to_a.transpose.flatten.join
    cells.size < 9 ? false : cells
  end
  
  def close
    @browser&.quit
  end
end
