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

# railsでアソシエーションみたいな感じでやると早いかも....

class Race
  def self.get_race
    # url = "http://race.netkeiba.com/"
    race_url = "http://race.netkeiba.com/?pid=race_old&id=c201707030601" # 動的にする

    # 各馬のオブジェクトをまとめて入れている配列(レース毎にまとめたい)
    horse_list = []  # 馬データ突っ込む
    horse_detail_urls = [] # 馬の詳細データをまとめたもの

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

      # 各馬の配列
      horse_data = []

      # 馬の詳細URLをまとめておく
      #horse_detail_url = []

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
      # binding.pry
      # 馬の詳細URL 使用する => どのようにして保持させるか....配列でまとめてから or 一回毎に詳細データ取得するか
      puts horse_url
      horse_detail_urls << horse_url

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
      # binding.pry

    end
    race_to_csv(horse_list)
    detail_horse(horse_detail_urls)
    #horse_detail_to_csv(horse_details)


  end

  # CSVにエクスポート
  def self.race_to_csv(horse_list)
    # binding.pry
    puts "race_csv"
    CSV.open("race_info.csv", "wb") do |csv|
      #[[],[],[]]となっている
      horse_list.each do |r|
        csv << r
      end
    end
  end

  def self.get_detail_url_horse(horse_detail_urls)
    horse_detail_urls # 配列
  end

  # ↑と同じような感じなので、まとめられそう
  def self.horse_detail_to_csv(horse_details)

    puts "detail_csv"
    CSV.open("horse_details_info.csv", "wb") do |csv|
      # 馬の情報を入れていく
      # binding.pry
      # horse_detail_data.each { |hoge| csv << hoge }
      horse_details.each do |data|
        csv << data
      end
    end
  end

  def self.detail_horse(horse_detail_urls)
    puts horse_detail_urls
    horses = get_detail_url_horse(horse_detail_urls) # url配列
    horse_details = []

    horses.each do |horse|
      horse_url = horse
      html = open(horse_url) do |f|
        charset = f.charset
        puts "-----------------------"

        f.read # htmlを読み込んでhtmlに渡す
      end
      # htmlをパース（解析）してオブジェクトを生成
      doc = Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')

      # お試し
      title = doc.css("title")
      puts "--------------------"
      puts "詳細詳細詳細詳細詳細詳細詳細詳細詳細詳細"
      puts title # あとで文字列処理する
      # <title>レッドシャーロット | 競走馬データ - netkeiba.com</title>
      # puts doc
      a_detail_info = doc.css("#contents > div.db_main_race.fc > div > table > tbody > tr") # 列は取得

      a_detail_info.each do |detail|
        info = []

        # 日付
        date = detail.elements[0].children[0].children.to_s # "2017/07/16"
        info << date

        # 開催
        place = detail.elements[1].children[0].children.to_s # 中京3
        info << place

        # 天気
        whether = detail.elements[2].children.to_s # 晴れ
        info << whether

        # 何レース目(1~12)
        race = detail.elements[2].children.to_s # 3
        info << race

        # レース名
        race_title = detail.elements[4].children[0].attributes.values[1].value # ２歳未勝利
        info << race_title

        # 頭数
        head_count = detail.elements[6].children.to_s # 11
        info << head_count

        # 枠番
        frame_number = detail.elements[7].children.to_s
        info << frame_number

        # 馬番
        bib_number = detail.elements[8].children.to_s # 2
        info << bib_number

        # オッズ
        odds = detail.elements[9].children.to_s
        info << odds

        # 人気
        ninki = detail.elements[10].children.to_s
        info << ninki

        # 着順
        finish_number = detail.elements[11].children.to_s
        info << finish_number

        # 騎手
        jockey = detail.elements[12].children[1].children.to_s
        info << jockey

        # 斤量
        basis_weight = detail.elements[13].children.to_s
        info << basis_weight

        # 距離
        distance =  detail.elements[14].children.to_s
        info << distance

        # 馬場状態
        field_condition = detail.elements[15].children.to_s
        info << field_condition

        # 馬場指数 → プレミア情報(あとで使ってみたい....)
        # ??

        # 走破タイム
        time = detail.elements[17].children.to_s
        info << time

        # 着差
        margin = detail.elements[18].children.to_s
        info << margin

        # タイム指数 → プレミア
        # ??

        # 通過順位(10-8-7-7)
        passing = detail.elements[20].children.to_s
        info << passing

        # ペース
        pace = detail.elements[21].children.to_s
        info << pace

        # ラスト3ハロン
        last_600 = detail.elements[22].children.to_s
        info << last_600

        # 体重
        weight = detail.elements[23].children.to_s
        info << weight

        # (1位 or 2位の馬)
        opponent = detail.elements[26].children[0].children.to_s
        info << opponent

        # 賞金
        money = detail.elements[27].children
        info << money

        horse_details << info

      end
    end
    horse_detail_to_csv(horse_details)

  end

end

Race.get_race # レース取得


# class Horse
#
#   puts self
#
# end



# Race.get_detail_horse
