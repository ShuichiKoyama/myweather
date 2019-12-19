
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
 
  {weather_tko:"Tokyo,jp",weather_osk:"Osaka-shi,jp",weather_ngo:"Nagoya-shi,jp",weather_spk:"Sapporo-shi,jp"}.each do |keys,values|

  http = Net::HTTP.new('api.openweathermap.org')
  response = http.request(Net::HTTP::Get.new("/data/2.5/weather?q=#{values}&units=#{UNITS}&appid=#{API_KEY}"))

  next unless '200'.eql? response.code

  print '============================'
  print response.body
  print '============================'
  
  
  weather_data  = JSON.parse(response.body)
  detailed_info = weather_data['weather'].first
  current_temp  = weather_data['main']['temp']

  print '@@@@@'
  print weather_data['main']['temp']
  print weather_data['name']
  print weather_data['main']['temp_min']
  
  print '@@@@@'

  
  print #{keys}
  siterb = #{keys}
  
  #小数点２位まで表示させる
  #&deg はhtmlで温度表示の小さい丸
  #
  send_event(siterb , { :temp => "#{current_temp}.to_f &deg;#{temperature_units}",
                          :condition => detailed_info['main'],
                          :title => "#{weather_data['name']}",
                          :color => color_temperature(current_temp),
                          :climacon => climacon_class(detailed_info['id'])})


 
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
