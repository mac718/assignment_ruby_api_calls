require 'httparty'
require 'pp'
require 'pry'
require 'json'

class WeatherForecast
  BASE_URI = "http://api.openweathermap.org/data/2.5/forecast/daily?"

  API_KEY = ENV['API_KEY']

  def initialize(location = 4984247, number_of_days = 5)
    @location = location
    @number_of_days = number_of_days
    @results = {}
  end

  def raw_response
    @results = HTTParty.get("http://api.openweathermap.org/data/2.5/forecast?id=#{@location}&units=imperial&cnt=#{@number_of_days}&APPID=#{API_KEY}")
    save_results(@results)
  end

  def hi_temps
    @results.values[3].map do |day|
      day[:main][:temp_max]
    end
  end

  def lo_temps
  end

  def today
  end

  def tomorrow
  end

   def save_results(response)
    File.open('results.json',"w") do |f|
      f.write(response)
    end
  end
end

WeatherForecast.new.raw_response