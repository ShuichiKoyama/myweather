
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
#  feels_temp    = weather_data['main']['feels_like']

#  p '@@@@@'
#  p weather_data
#  p weather_data['list'][1]['dt_text']
#  p '#####'
#  p weather_data['list'][0]['main']['temp']
#  p '@@@@@'

  aryW1 = []
  aryW2 = []
  aryW3 = []
  aryW4 = []
  hrows = [
    { cols: [ {value: '日時'},{value: '予想'},[value:'気温'}]
  rows = []  

#  weather_data['list'].each do |num| 
   (1..24).each do |num| 
      aryW1 << weather_data['list'][num]['dt_txt'].slice(8,2)
      aryW1 << "日 "
      aryW2 << weather_data['list'][num]['dt_txt'].slice(11,5)
      aryW2 << "&nbsp"
      aryW3 << weather_data['list'][num]['weather'][0]['description']
      aryW3 << "&nbsp"
      aryW4 << weather_data['list'][num]['main']['temp'] 
      aryW4 << "°C "
  end 
#  aryW1 << aryW2
#  aryW1 << aryW3
#  aryW1 << aryW4
#  tbForecast = aryW1.join
#  p tbForecast

  #小数点２位まで表示させる
  #&deg はhtmlで温度表示の小さい丸
  #
  send_event( 'weather_ndc' , { :tbForecast => "#{tbForecast}",
                          :color => color_temperature(current_temp),
                          :climacon => climacon_class(detailed_info['id'])})

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
