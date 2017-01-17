# 女性の活躍推進企業データベース | トップ
# http://www.positive-ryouritsu.jp/positivedb/
# 項目定義
# 取得元URL,企業URL,企業番号,一般事業主行動計画のみ公表,競争倍率_男女,勤続年数_男女,勤続年数_男女_単位,企業名,一般事業主行動計画,企業認定等,企業認定等1,企業認定等2,企業認定等3,企業認定等4,企業認定等5,企業認定等6,業種,企業規模,都道府県,女性採用_職種,女性採用_割合,女性採用_単位,女性採用_注,競争倍率_区分,競争倍率_職種,競争倍率_男性,競争倍率_男性_単位,競争倍率_女性,競争倍率_女性_単位,競争倍率_注,女性_職種,女性_割合,女性_割合_単位,女性_注,勤続年数_区分,勤続年数_職種,勤続年数_男性,勤続年数_男性_単位,勤続年数_女性,勤続年数_女性_単位,勤続年数_注,育児休業_区分,育児休業_職種,育児休業_男性,育児休業_男性_単位,育児休業_女性,育児休業_女性_単位,育児休業_注,残業_職種,残業_平均残業時間,残業_平均残業時間_単位,残業_取組有無,残業_注,有給休暇_職種,有給休暇_取得率,有給休暇_取得率_単位,有給休暇_注,係長_割合,係長_割合_単位,係長_注,管理職_割合,管理職_割合_単位,管理職_注,役員_割合,役員_割合_単位,役員_注,転換_職種,転換_内容,転換_男性,転換_男性_単位,転換_女性,転換_女性_単位,転換_注,再雇用_再雇用／中途採用,再雇用_男性,再雇用_男性_単位,再雇用_女性,再雇用_女性_単位,再雇用_注,データの対象_対象,データの対象_注,データ更新時点_時点,データ更新時点_注,備考

require 'open-uri'
require 'nokogiri'
require 'scraperwiki'

# @page_from = 1
# @page_to = 1
@column_limit = 76 # Starting at 0

def parse_doc(url)
  charset = nil
  html = open(url) do |f|
    charset = f.charset
    f.read
  end

  Nokogiri::HTML.parse(html, nil, charset)
end

def get_page_count(doc)
  pagination_last_a = doc.xpath("//*[@id='table']/table[last()]//span[last()]//a").first
  last_url = pagination_last_a.attribute("href").text
  last_url[/page:(.*)\//, 1].to_i
end

def get_value_from_td(td)
  value = td.text

  img_alt_delimiter = ''
  td.search(".//img").each do |img|
    value += img_alt_delimiter + img.attribute("alt").text
    img_alt_delimiter = ', '
  end

  value.gsub!(/(?:\s|\xe3\x80\x80)+/, ' ') # Shrink spaces (\xe3... == full-width space)
  value.gsub!(/\s?$/, '')                  # Chop off trailing space
  value.gsub!(/\u00a0/, '')                # Shrink spaces (\u00a0 == &nbsp;)
  value.strip!
  value = nil if value.empty?
  value
end

def scrape_page(doc, source_url)
  doc.xpath("//*[@id='table']/table//tr[position() >= 4]").each do |tr|
    column_position = 0
    kinzokunensu_danjo = false
    url = tr.search(".//td//a[1]").attribute("href").text
    id = url[/id=(.*)$/, 1].to_i
    row = {
      source_url: source_url,
      url: url,
      id: id,
      ippan_jigyonushi_keikaku: nil,
      kyoso_bairitsu_danjo: nil,
      kinzokunensu_danjo: nil,
      kinzokunensu_danjo_tanni: nil
    }

    tr.search(".//td").each do |td|
      colspan_attribute = td.attribute("colspan")
      colspan = colspan_attribute.nil? ? 1 : colspan_attribute.value.to_i
      colspan = 1 if colspan == 0

      field = ('field' + column_position.to_s).to_sym
      value = get_value_from_td(td)

      if column_position == 12 and colspan == 99
        field = :ippan_jigyonushi_keikaku
      elsif column_position == 18 and colspan == 4
        field = :kyoso_bairitsu_danjo
      elsif column_position == 29 and colspan == 3
        field = :kinzokunensu_danjo
        kinzokunensu_danjo = true
      elsif column_position == 32 and kinzokunensu_danjo
        field = :kinzokunensu_danjo_tanni
      end

      row.store(field, value)
      column_position += colspan
    end
    ScraperWiki.save_sqlite([:url], row)
  end
end

unless @page_from
  @page_from = 1
end

unless @page_to
  url = "http://www.positive-ryouritsu.jp/positivedb/search_res/page:1/sk:2/wkr_1:0/wkr_2:0/wkr_3:0/wkr_4:0/wkr_5:0/wkr_6:0/wkr_7:0/wkm_4:1/wkm_9:1/wkm_15:1/wkm_21:1/wkm_22:1/wkm_25:1/wkm_28:1/wk_1:1/wk_2:1/wk_3:1/wk_4:1/wk_6:1/wk_7:1/wk_8:1/wk_9:1/wk_10:1/wk_11:1/wk_13:1/wk_14:1/wk_15:1/wk_16:1/wk_17:1/wk_18:1/wk_20:1/wk_21:1/wk_22:1/wk_23:1/wk_24:1/wk_25:1/wk_26:1/wk_27:1/wk_29:1/wk_30:1/wk_31:1/wk_33:1/wk_34:1/wk_35:1/wk_36:1/wk_38:1/wk_39:1/wk_40:1/wk_41:1/wk_43:1/wk_44:1/wk_45:1/wk_46:1/p_1:0/s_1:0/s_2:0/s_3:0/s_4:0/s_5:0/s_6:0/s_7:0/p_2:0/s_8:0/s_9:0/s_10:0/s_11:0/s_12:0/s_13:0/s_14:0/p_3:0/s_15:0/s_16:0/s_17:0/s_18:0/s_19:0/s_20:0/p_4:0/s_21:0/s_22:0/s_23:0/s_24:0/s_25:0/s_26:0/s_27:0/s_28:0/s_29:0/s_30:0/p_5:0/s_31:0/s_32:0/s_33:0/s_34:0/s_35:0/s_36:0/s_37:0/s_38:0/s_39:0/p_6:0/s_40:0/s_41:0/s_42:0/s_43:0/s_44:0/s_45:0/s_46:0/s_47:0"
  doc = parse_doc(url)
  @page_to = get_page_count(doc)
end

puts 'Start: ' + Time.now.to_s
puts 'Page from ' + @page_from.to_s + ' to ' + @page_to.to_s

Range.new(@page_from, @page_to).each do |i|
  url = "http://www.positive-ryouritsu.jp/positivedb/search_res/page:#{i}/sk:2/wkr_1:0/wkr_2:0/wkr_3:0/wkr_4:0/wkr_5:0/wkr_6:0/wkr_7:0/wkm_4:1/wkm_9:1/wkm_15:1/wkm_21:1/wkm_22:1/wkm_25:1/wkm_28:1/wk_1:1/wk_2:1/wk_3:1/wk_4:1/wk_6:1/wk_7:1/wk_8:1/wk_9:1/wk_10:1/wk_11:1/wk_13:1/wk_14:1/wk_15:1/wk_16:1/wk_17:1/wk_18:1/wk_20:1/wk_21:1/wk_22:1/wk_23:1/wk_24:1/wk_25:1/wk_26:1/wk_27:1/wk_29:1/wk_30:1/wk_31:1/wk_33:1/wk_34:1/wk_35:1/wk_36:1/wk_38:1/wk_39:1/wk_40:1/wk_41:1/wk_43:1/wk_44:1/wk_45:1/wk_46:1/p_1:0/s_1:0/s_2:0/s_3:0/s_4:0/s_5:0/s_6:0/s_7:0/p_2:0/s_8:0/s_9:0/s_10:0/s_11:0/s_12:0/s_13:0/s_14:0/p_3:0/s_15:0/s_16:0/s_17:0/s_18:0/s_19:0/s_20:0/p_4:0/s_21:0/s_22:0/s_23:0/s_24:0/s_25:0/s_26:0/s_27:0/s_28:0/s_29:0/s_30:0/p_5:0/s_31:0/s_32:0/s_33:0/s_34:0/s_35:0/s_36:0/s_37:0/s_38:0/s_39:0/p_6:0/s_40:0/s_41:0/s_42:0/s_43:0/s_44:0/s_45:0/s_46:0/s_47:0"
  puts 'Fetching page: ' + i.to_s
  doc = parse_doc(url)
  scrape_page(doc, url)

  sleep 2
end

puts 'End: ' + Time.now.to_s
