require 'rest-client'
require 'date'

# Simple widget that will parse and display task weather info from opnw.
# copy from smhi
# Setup, change longitude, latitude, city and temp_format. 
# https://github.com/DidrikLindqvist/Dashing.io-widgets

class WhetherHandler

  def initialize()

    # Sets the longitude and latitude for where to fetch the wheather info from.
    # Lat and long can be found here http://www.latlong.net/
    @longitude = "20.290890"  #Change this
    @latitude = "63.821342"   #Change this
    @city = "Tokyo,jp"        #Change this
    @temp_format = " °C"

    @whether_info = []
    @whether_info.push(whether_station: @city)
    @curr_day = 0
    
     UNITS   = 'metric'  # options: metric / imperial

# API_KEY = ENV['YOUR-AUTHOLIZED-KEY']
  API_KEY = 'd1185e03748c9212756c163633c2c2ce'  # create free account on open weather map to get API key

  end

  def parseWhether()

    @whetherInfo = parseWhetherInfo()
    raw_whetherData = @whetherInfo['timeSeries']

    raw_whetherData.map do |whetherData|
    
      succ = addWheterDataOnTime(whetherData, "00:00")
      succ = addWheterDataOnTime(whetherData, "03:00")
      succ = addWheterDataOnTime(whetherData, "06:00")
      succ = addWheterDataOnTime(whetherData, "09:00")
      succ = addWheterDataOnTime(whetherData, "12:00")
      succ = addWheterDataOnTime(whetherData, "15:00")
      succ = addWheterDataOnTime(whetherData, "18:00")
      succ = addWheterDataOnTime(whetherData, "21:00")
      if(succ)
        @curr_day += 1
      end      
    end

  end
 
  def addWheterDataOnTime(whetherData, time)
    
    if whetherData['validTime'].to_s.include? time and whetherData['validTime'].to_s.include? (Date.today + @curr_day).to_s
      temp = retriveTempatures(whetherData)
      @whether_info.push(date: (Date.today + @curr_day), time: time, temp: temp[0].to_s + @temp_format, icon: temp[1].to_s )
      return true
    end
    return false

  end

  def parseWhetherInfo()

#    url = "http://opendata-download-metfcst.smhi.se/api/category/pmp2g/version/2/geotype/point/lon/" + @longitude + "/lat/" + @latitude + "/data.json"
#    @whetherInfo = JSON.parse(RestClient.get(url))

  {weather_tko:"Tokyo,jp"}.each do |keys,values|
  http = Net::HTTP.new('api.openweathermap.org')
  @whetherInfo = http.request(Net::HTTP::Get.new("/data/2.5/forecast?q=#{values}&units=#{UNITS}&appid=#{API_KEY}&lang=ja"))
  end

  end

  def retriveTempatures(whetherData)
    
    whetherData['parameters'].each do |k|
      next if k['name'].to_s != "t"

      return [k['values'][0], k['level'] ]
    end
  end

  def getWheterInfo()
    return @whether_info , @city
  end

end


SCHEDULER.every '10m', :first_in => 0 do |job|

  wHandler = WhetherHandler.new
  wHandler.parseWhether()
  whether_info, city = wHandler.getWheterInfo()
  send_event('opnw', city: city , days: whether_info)

end
