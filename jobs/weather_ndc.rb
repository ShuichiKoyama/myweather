
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
  detailed_info = weather_data['list'][0]['weather'][0]['icon']
  current_temp  = weather_data['list'][0]['main']['temp']

#  p '@@@@@'
#  p weather_data
#  p weather_data['list'][1]['dt_text']
#  p '#####'
#  p weather_data['list'][0]['main']['temp']
#  p '@@@@@'
#### json形式のデータから、配列に 
  aryW1 = []
  aryW2 = []
  aryW3 = []
  aryW4 = []
  aryW5 = []

  #  weather_data['list'].each do |num| 
   (1..24).each do |num| 
# 日付
      aryW1 << weather_data['list'][num]['dt_txt'].slice(8,2)
# 時間帯
      aryW2 << weather_data['list'][num]['dt_txt'].slice(11,5)
# 天気予報
      aryW3 << weather_data['list'][num]['weather'][0]['description']
# 気温
      aryW4 << weather_data['list'][num]['main']['temp'] 
      aryW4 << "°C "
# 体感気温
      aryW5 << weather_data['list'][num]['main']['feels_like'] 
      aryW5 << "°C "
end 
#  aryW1 << aryW2
#  aryW1 << aryW3
#  aryW1 << aryW4
#  tbForecast = aryW1.join
#  p tbForecast

### テーブル出力レイアウトへ編集

hrows = [
  { cols: [ {value: '日付'}, {value: '時間'}, {value: '天気'}, {value: '気温'}, {value: '体感'} ]

rows = [
    { cols: [ {value: 'cell11'}, {value: 'cell12'}, {value: 'cell13'}, {value: 'cell14'}, {value: 'cell15'} ]},
    { cols: [ {value: 'cell21'}, {value: 'cell22'}, {value: 'cell23'}, {value: 'cell24'}, {value: 'cell25'} ]},
    { cols: [ {value: 'cell31'}, {value: 'cell32'}, {value: 'cell33'}, {value: 'cell34'}, {value: 'cell35'} ]},
    { cols: [ {value: 'cell41'}, {value: 'cell42'}, {value: 'cell43'}, {value: 'cell44'}, {value: 'cell45'} ]}
]

  send_event( 'my_table' , { hrows: hrows , rows: rows })

  
 #小数点２位まで表示させる
 #&deg はhtmlで温度表示の小さい丸
 #
 # send_event( 'weather_ndc' , { :tbForecast => "#{tbForecast}",
 #                           :color => color_temperature(current_temp),
 #                         :climacon => climacon_class(detailed_info['id'])})

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
