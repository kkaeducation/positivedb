require 'open-uri'
require 'nokogiri'
require 'scraperwiki'

# @page_from = 1
# @page_to = 1
@column_limit = 76 # Starting at 0
@html_fields = nil
@database_fields = nil

def init_page_setting
  unless @page_from
    @page_from = 1
  end

  unless @page_to
    url = "http://www.positive-ryouritsu.jp/positivedb/search_res/page:1/sk:2/wkr_1:0/wkr_2:0/wkr_3:0/wkr_4:0/wkr_5:0/wkr_6:0/wkr_7:0/wkm_4:1/wkm_9:1/wkm_15:1/wkm_21:1/wkm_22:1/wkm_25:1/wkm_28:1/wk_1:1/wk_2:1/wk_3:1/wk_4:1/wk_6:1/wk_7:1/wk_8:1/wk_9:1/wk_10:1/wk_11:1/wk_13:1/wk_14:1/wk_15:1/wk_16:1/wk_17:1/wk_18:1/wk_20:1/wk_21:1/wk_22:1/wk_23:1/wk_24:1/wk_25:1/wk_26:1/wk_27:1/wk_29:1/wk_30:1/wk_31:1/wk_33:1/wk_34:1/wk_35:1/wk_36:1/wk_38:1/wk_39:1/wk_40:1/wk_41:1/wk_43:1/wk_44:1/wk_45:1/wk_46:1/p_1:0/s_1:0/s_2:0/s_3:0/s_4:0/s_5:0/s_6:0/s_7:0/p_2:0/s_8:0/s_9:0/s_10:0/s_11:0/s_12:0/s_13:0/s_14:0/p_3:0/s_15:0/s_16:0/s_17:0/s_18:0/s_19:0/s_20:0/p_4:0/s_21:0/s_22:0/s_23:0/s_24:0/s_25:0/s_26:0/s_27:0/s_28:0/s_29:0/s_30:0/p_5:0/s_31:0/s_32:0/s_33:0/s_34:0/s_35:0/s_36:0/s_37:0/s_38:0/s_39:0/p_6:0/s_40:0/s_41:0/s_42:0/s_43:0/s_44:0/s_45:0/s_46:0/s_47:0"
    doc = parse_doc(url)
    @page_to = get_page_count(doc)
  end
end

def init_field_setting
  field_array = [
  #  [fieldname, html_column_position, database_column_position]
    [:company_number, nil, 1],
    [:company_url, nil, 2],
    [:source_url, nil, 3],
    [:company_name, 1, 4],
    [:general_employer_action_plan, 2, 5],
    [:general_employer_action_plan_only, nil, 6],
    [:company_certification, 3, 7],
    [:company_certification1, 4, 8],
    [:company_certification2, 5, 9],
    [:company_certification3, 6, 10],
    [:company_certification4, 7, 11],
    [:company_certification5, 8, 12],
    [:company_certification6, 9, 13],
    [:industry, 10, 14],
    [:company_size, 11, 15],
    [:prefectures, 12, 16],
    [:female_recruitment_job, 13, 17],
    [:female_recruitment_rate, 14, 18],
    [:female_recruitment_unit, 15, 19],
    [:female_recruitment_note, 16, 20],
    [:competitive_ratio_type, 17, 21],
    [:competitive_ratio_job, 18, 22],
    [:competitive_ratio_male, 19, 23],
    [:competitive_ratio_male_unit, 20, 24],
    [:competitive_ratio_female, 21, 25],
    [:competitive_ratio_female_unit, 22, 26],
    [:competitive_ratio_male_and_female, nil, 27],
    [:competitive_ratio_note, 23, 28],
    [:female_job, 24, 29],
    [:female_ratio, 25, 30],
    [:female_ratio_unit, 26, 31],
    [:female_note, 27, 32],
    [:years_of_service_type, 28, 33],
    [:years_of_service_job, 29, 34],
    [:years_of_service_male, 30, 35],
    [:years_of_service_male_unit, 31, 36],
    [:years_of_service_female, 32, 37],
    [:years_of_service_female_unit, 33, 38],
    [:years_of_service_male_and_female, nil, 39],
    [:years_of_service_male_and_female_unit, nil, 40],
    [:years_of_service_note, 34, 41],
    [:childcare_leave_type, 35, 42],
    [:childcare_leave_job, 36, 43],
    [:childcare_leave_male, 37, 44],
    [:childcare_leave_male_unit, 38, 45],
    [:childcare_leave_female, 39, 46],
    [:childcare_leave_female_unit, 40, 47],
    [:childcare_leave_note, 41, 48],
    [:overtime_job, 42, 49],
    [:overtime, 43, 50],
    [:overtime_unit, 44, 51],
    [:overtime_effort, 45, 52],
    [:overtime_note, 46, 53],
    [:paid_vacation_job, 47, 54],
    [:paid_vacation_utilization_rate, 48, 55],
    [:paid_vacation_utilization_rate_unit, 49, 56],
    [:paid_vacation_note, 50, 57],
    [:cief_ratio, 51, 58],
    [:chief_rate_unit, 52, 59],
    [:chief_note, 53, 60],
    [:manager_ratio, 54, 61],
    [:manager_rate_unit, 55, 62],
    [:manager_note, 56, 63],
    [:officer_ratio, 57, 64],
    [:officer_ratio_unit, 58, 65],
    [:officer_note, 59, 66],
    [:reshuffling_job, 60, 67],
    [:reshuffling_content, 61, 68],
    [:reshuffling_male, 62, 69],
    [:reshuffling_male_unit, 63, 70],
    [:reshuffling_female, 64, 71],
    [:reshuffling_female_unit, 65, 72],
    [:reshuffling_note, 66, 73],
    [:reemployment, 67, 74],
    [:reemployment_male, 68, 75],
    [:reemployment_male_unit, 69, 76],
    [:reemployment_female, 70, 77],
    [:reemployment_female_unit, 71, 78],
    [:reemployment_note, 72, 79],
    [:object_of_data, 73, 80],
    [:object_of_data_note, 74, 81],
    [:updated_at, 75, 82],
    [:updated_at_note, 76, 83],
    [:note, 77, 84]
  ]

  fields = []
  field_array.each do |field|
    fields << {
      fieldname: field[0],
      html_column_position: field[1],
      database_column_position: field[2]
    }
  end

  @html_fields = fields
    .reject   { |field| field[:html_column_position].nil? }
    .sort_by! { |field| field[:html_column_position] }
    .map!     { |field| field[:fieldname] }

  @database_fields = fields
    .sort_by { |field| field[:database_column_position] }
    .map!    { |field| field[:fieldname] }
end

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
    years_of_service_male_and_female_flag = false
    company_url = tr.search(".//td//a[1]").attribute("href").text
    company_number = company_url[/id=(.*)$/, 1].to_i

    row = {}
    @database_fields.each do |field|
      row.store(field, nil)
    end
    row.store(:company_number, company_number)
    row.store(:company_url, company_url)
    row.store(:source_url, source_url)

    tr.search(".//td").each do |td|
      colspan_attribute = td.attribute("colspan")
      colspan = colspan_attribute.nil? ? 1 : colspan_attribute.value.to_i
      colspan = 1 if colspan == 0

      field = @html_fields[column_position]
      value = get_value_from_td(td)

      if column_position == 12 and colspan == 99
        field = :general_employer_action_plan_only
      elsif column_position == 18 and colspan == 4
        field = :competitive_ratio_male_and_female
      elsif column_position == 29 and colspan == 3
        field = :years_of_service_male_and_female
        years_of_service_male_and_female_flag = true
      elsif column_position == 32 and years_of_service_male_and_female_flag
        field = :years_of_service_male_and_female_unit
      end

      row.store(field, value)
      column_position += colspan
    end
    ScraperWiki.save_sqlite([:company_url], row)
  end
end

init_page_setting
init_field_setting

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
