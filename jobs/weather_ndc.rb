
require 'net/http'

# you can find CITY_ID here http://bulk.openweathermap.org/sample/city.list.json.gz
# CITY_ID = 2172517
# CITY_ID = 2345889

# options: metric / imperial
  UNITS   = 'metric'

# create free account on open weather map to get API key

# API_KEY = ENV['YOUR-AUTHOLIZED-KEY']
  API_KEY = 'd1185e03748c9212756c163633c2c2ce'

SCHEDULER.every '600s', :first_in => 0 do |job|

# shu1 start 
 
#  {weather_tko:"Tokyo,jp",weather_osk:"Osaka-shi,jp",weather_ngo:"Nagoya-shi,jp",weather_spk:"Sapporo-shi,jp"}.each do |keys,values|
  {weather_tko:"Tokyo,jp"}.each do |keys,values|

  http = Net::HTTP.new('api.openweathermap.org')
  response = http.request(Net::HTTP::Get.new("/data/2.5/forecast?q=#{values}&units=#{UNITS}&appid=#{API_KEY}&lang=ja"))

  next unless '200'.eql? response.code

 # print '===json形式=================='
 # print response.body
 # print '============================'

  
  weather_data  = JSON.parse(response.body)
#  detailed_info = weather_data['weather'].first
#  current_temp  = weather_data['main']['temp']
#  feels_temp    = weather_data['main']['feels_like']

#  p '@@@@@'
#  p weather_data['list'][1]['dt_text']
#  p '#####'
#  p weather_data['list'][0]['main']['temp']
#  p '@@@@@'

  aryW1 = []
  table_data = "<table><tr><th>日時</th><th>天気予想</th><th>気温</th></tr>"
  aryW1 << table_data
  weather_data.each do |n| 
      aryW1 << "<td>"
      aryW1 << weather_data['list'][0]['dt_text']
      aryW1 << "</td><td>"
      aryW1 << weather_data['list'][0]['weather'][0]['description']
      aryW1 << "</td><td>"
      aryW1 << weather_data['list'][0]['main']['temp']
      aryW1 << "</td>"
  end 
  aryW1 << "</tr></table>"
  tbForecast = aryW1.join

  p tbForecast

# "<% weather_data.each do |lists| %>"&
# "<td><% weather_data['list'][0]['dt_text'] %></td>"&
# "<td><% weather_data['list'][0]['weather']['description'] %></td>"&
#  "</tr><% end %></table>"

  #小数点２位まで表示させる
  #&deg はhtmlで温度表示の小さい丸
  #
  send_event( 'weather_ndc' , { :tbForecast => "#{tbForecast}"})

  #send_event(siterb , { :temp => "#{current_temp}.to_f &deg;#{temperature_units}",
  #                        :condition => detailed_info['main'],
  #                        :title => "#{weather_data['name']}",
  #                        :color => color_temperature(current_temp),
  #                        :climacon => climacon_class(detailed_info['id'])})
 
  end
end


def temperature_units
  'metric'.eql?(UNITS) ? 'C' : 'K'
end

def color_temperature(temp_celsius)
  case temp_celsius.to_i
  when 30..100
    '#FF3300'
  when 25..29
    '#FF6000'
  when 19..24
    '#FF9D00'
  when 13..18
    '#18A9FF'
  when 5..12
    '#0052CC'
  else
    '#0065FF'
  end
end

# fun times ;) legend: http://openweathermap.org/weather-conditions
def climacon_class(weather_code)
  case weather_code.to_s
  when /800/
    'sun'
  when /80./
    'cloud'
  when /2.*/
    'lightning'
  when /3.*/
    'drizzle'
  when /5.*/
    'rain'
  when /6.*/
    'snow'
  else
    'sun'
  end
end
