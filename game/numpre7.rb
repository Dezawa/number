# nampre7.rb
# ナンプレ７のサイトから game(npLNN001〜)をDLし得た html を返す
require "ferrum"

class Nampre7
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

  def close
    @browser&.quit
  end
end
