# URLにアクセスするためのライブラリの読み込み
require 'open-uri'
require 'open_uri_redirections'
require 'nokogiri'
require 'anemone'
require 'mechanize'
require 'pry'
require 'kconv'
require 'csv'
# jsはcapybaraかseleniumの予定

# -----------------------------------------------
# 第一階層
## 全レース(24~36レースを取得)


# 第二階層
## 各レースの情報(枠番、ジョッキー、調教師、オッズ 、 斤量 ...)


#第三階層
## 各レースのそれぞれの馬の情報(基本ここのデータでロジックを組む)

# -----------------------------------------------


class Race

  # url = "http://race.netkeiba.com/"
  race_url = "http://race.netkeiba.com/?pid=race_old&id=c201707030601" # 動的にする

  horse_list = []  # 馬データ突っ込む

  charset = nil
  # ページの中のhtml
  html = open(race_url) do |f|
    charset = f.charset
    puts "-----------------------"
    puts "charsettttttttttttttttttttttttt"
    puts charset

    f.read # htmlを読み込んでhtmlに渡す
  end
  # htmlをパース（解析）してオブジェクトを生成
  doc = Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')

  # puts doc
  race_title = doc.css("title")
  puts race_title
  # 2017/07/16 中京 1R 未勝利 / 出馬表｜レース情報(JRA) - netkeiba.com





  # １レースの馬の情報 (第二階層)

  horse_info = doc.css("tr.bml1") #=>  各馬の情報がとりあえず取れる
  puts horse_info

  uma_count =0
  horse_info.each do |info|
    uma_count +=1
    # binding.pry
    horse_data = []



    # 枠
    puts "枠"
    waku = info.elements[0].children[0].text
    puts waku
    horse_data << waku
    puts "===================="
    puts "馬番: #{uma_count}"
    umaban = uma_count
    horse_data << umaban


    horse_url = info.elements[4].children[1].children[1].attributes["href"].value
    # 馬の詳細URL
    puts horse_url
    horse_data << horse_url

    # 馬名
    horse_name = info.elements[4].children[1].children[1].attributes["title"].value
    horse_data << horse_name
    puts horse_name


    # 年齢
    old = info.elements[5].children.text
    horse_data << old
    puts old

    # 斤量
    basis_weight = info.elements[6].children.text
    puts basis_weight
    horse_data << basis_weight

    # ジョッキー
    jockey = info.elements[7].children.text
    puts jockey # 松若
    horse_data << jockey

    # ジョッキーのURL
    jockey_url = info.elements[7].children[0].attributes["href"].value
    puts jockey_url
    horse_data << jockey_url

    # 調教師name
    trainer = info.elements[8].children[0].attributes["title"].value

    puts trainer
    horse_data << trainer

    # 調教師 URL
    trainer_url = info.elements[8].children[0].attributes["href"].value
    horse_data << trainer_url
    puts info.elements[8].children[0].attributes["href"].value

    # 馬体重
    horse_weight = info.elements[9].children[0].text
    puts horse_weight
    horse_data << horse_weight


    # 単勝オッズ
    puts "単勝オッズ"
    odds = info.elements[10].children[0].text
    puts odds
    horse_data << odds

    # 人気
    puts "単勝人気"
    ninki = info.elements[11].children[0].text
    puts ninki
    horse_data << ninki

    horse_list << horse_data
  end

  # raise
  # CSVにエクスポート
  CSV.open("race_info.csv", "wb") do |csv|
    horse_list.each do |r|
      csv << r
    end
  end
end

# puts horse_info
# <td class="txt_l horsename">
# <div>
# <a href="http://db.netkeiba.com/horse/2015101921/" target="_blank" title="ノーボーダー">ノーボーダー</a>
# </div>
# </td>
# <td class="txt_l"><a href="http://db.netkeiba.com/jockey/01014/" target="_blank" title="福永">福永</a></td>
# <td class="txt_l"><a href="http://db.netkeiba.com/trainer/01110/" target="_blank" title="清水久">清水久</a></td>
# <td class="txt_l">472(-6)</td>
# <td class="txt_l">
#  ..
# ......

# est_venture_100_list = []
#
#   # スクレイピング先のURL
#   url = "http://best100.v-tsushin.jp/"
#   charset = nil
#   html = open(url) do |f|
#     charset = f.charset # 文字種別を取得
#     f.read # htmlを読み込んで変数htmlに渡す
#   end
#
#   # htmlをパース(解析)してオブジェクトを生成
#   doc = Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')
#   # id=companyListのulを取得
#   companies = doc.css("ul#companyList")
#   # id=companyListのul以下のliを配列で取得
#   company_list = companies.css("li")
#   # 配列内のliを一つ一つeachでfetchする
#   company_list.each do |company|
#     # dataを保存するArrayを作成
#     data = []
#     count += 1
#     # liの子要素であるimgのtitle情報を取得
#     name = company.css("img")[0][:title]
#     # liの子要素であるaのhrehパラメータを取得
#     url = company.css("a")[0][:href]
#     # liの子要素であるimgのsrcパラメータを取得
#     logo = company.css("img")[0][:src]
#
#     # 各要素を確認
#     p count, name, url, logo
#
#     # data配列に取得した情報を格納
#     data.push(count)
#     data.push(name.tosjis)
#     data.push(url.tosjis)
#     data.push(logo.tosjis)
#


#html = open(url, "r:cp932").read.encode('utf-8')


# About anemone
# Anemone.crawl("http://race.netkeiba.com/", :delay => 3,:depth_limit => 0, 'CP932') do |anemone|
#   puts "hoge"
#   anemone.on_every_page do |page|
#     puts "aaa"
#     puts page.url
#     puts page.doc.
#     puts page.links
#     # -------------------ここまでオK
#     # page.doc.xpath("//h2").each do |title| # ここで落ちる
#     #   puts "jjjjjjj"
#     #   puts title.text
#     # end
#   end
# end
# http://www.homes.co.jp/
# http://race.netkeiba.com/
# http://race.netkeiba.com/?pid=race_old&id=c201707030601

# class Crawler
#   def self.enter_in_form
#     agent = Mechanize.new
#     page = agent.get('http://db.netkeiba.com/?pid=race_search_detail')
#     form = page.forms[1]
#     form.fields[4].value = 2000 # start_year
#     form.fields[5].value = 1    # start_mon
#     form.fields[6].value = 2017 # end_year
#     form.fields[7].value = 6    # end_mon
#     form.checkboxes[10].click   # 競馬場
#
#     agent.submit(form)
#   end
#
#   def self.crawl(page)
#     search_links  = "//div[@id='page']/div[@id='contents_liquid']/table/tr/td/a"
#     search_result = "//div[@id='page']/div[@class='race_result fc']/div[@id='contents_liquid']/table[@class='race_table_01 nk_tb_common']/tr"
#     hrefs = page.search(search_links)
#     links = []
#     ar = []
#
#     hrefs.each do |href|
#       if href.attributes['href'].value =~ /\/race\/[0-9]+\//
#         links.push(page.link_with(href: href.attributes['href'].value))
#       end
#     end
#
#     links.each_with_index do |link, i|
#       puts i
#       page = link.click
#       ar << results_scraping(page, search_result)
#       sleep(3)
#     end
#   end
#
#   def self.results_scraping(page, search_text)
#     results     = page.search(search_text)
#     results_ar  = []
#
#     results.each do |result|
#       result = result.text.tr("\n", 'a').gsub(/a+/, ',').split(',')
#       result.shift
#       results_ar << result
#     end
#     results_ar
#   end
# end
#
# page = Crawler.enter_in_form
# puts Crawler.crawl(page)
