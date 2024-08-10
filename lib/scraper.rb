require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'date'

get '/' do
  @today = Date.today
  @weekends = fetch_weekends(@today)

  days_of_week = ["日", "月", "火", "水", "木", "金", "土"]
  @grouped_results = {}

  @weekends.each do |date|
    formatted_date = date.strftime("%Y-%m-%d") + " (#{days_of_week[date.wday]})"
    @grouped_results[formatted_date] = fetch_reservation_data(date)
  end

  erb :index
end

def fetch_weekends(today)
  weekends = []

  # 今週の土日を追加
  if today.wday <= 5
    saturday = today + (6 - today.wday)
    sunday = saturday + 1
    weekends.push(saturday, sunday)
  elsif today.wday == 6
    weekends.push(today, today + 1)
  elsif today.wday == 0
    weekends.push(today - 1, today)
  end

  # 次の4週間分の土日を追加
  next_saturday = today + ((6 - today.wday) % 7)
  (0..3).each do |i|
    saturday = next_saturday + (i * 7)
    sunday = saturday + 1
    weekends.push(saturday, sunday)
  end

  weekends
end

def fetch_reservation_data(date)
  url = "https://www.spm-cloud.com/user/seika/uruma/reserves/search-result?date=#{date}&area_id=25&sport_id=67"
  result = {}

  begin
    html = URI.open(url).read
    doc = Nokogiri::HTML(html)

    doc.css('section.rsv__field h3.rsv__result__item').each do |h3|
      em_text = h3.css('em').text.strip

      if em_text == "半面AB" || em_text == "半面CD"
        result[em_text] ||= []

        h3.parent.css('.js_reserved.reserved.rsv__result__click.rsv--result--yes').each do |reserved_element|
          start_time = reserved_element['data-start-time']
          end_time = reserved_element['data-end-time']
          time_slot = "#{start_time} - #{end_time}"

          result[em_text] << time_slot unless result[em_text].include?(time_slot)
        end
      end
    end
  rescue OpenURI::HTTPError => e
    result = { error: "Failed to fetch data: #{e.message}" }
  rescue StandardError => e
    result = { error: "An error occurred: #{e.message}" }
  end

  result
end
