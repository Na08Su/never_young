# URLにアクセスするためのライブラリの読み込み
require 'open-uri'
require 'open_uri_redirections'
require 'nokogiri'
require 'anemone'
require 'mechanize'
require 'pry'

url = "http://race.netkeiba.com/"


#doc = Nokogiri.HTML(open("http://nokogiri.org/"))
doc = Nokogiri.HTML(open(url), nil, 'utf-8')

# ページに含まれるリンクを出力する
doc.css('a').each do |element|
  puts element[:href]
end
# =>
# http://www.homes.co.jp/
# http://www.homes.co.jp/contents/no1/
# http://www.homes.co.jp/contents/abouthomes/
# http://www.homes.co.jp/contents/sitemap/
# http://www.homes.co.jp/callcenter/
# ...


# h2のテキストを出力する
doc2 = Nokogiri.HTML(open(url), nil, 'utf-8')
doc.xpath('//h2').each do |e|
  puts e.text
end





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
