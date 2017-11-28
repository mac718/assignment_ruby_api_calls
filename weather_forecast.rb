require 'httparty'
require 'pp'
require 'pry'
require 'json'

class WeatherForecast
  BASE_URI = "http://api.openweathermap.org/"

  API_KEY = ENV['API_KEY']

  attr_reader :location, :number_of_days, :results 

  def initialize(location = 4984247, number_of_days = 5)
    @location = location
    @number_of_days = number_of_days > 5 ? 5 : number_of_days
    @results = {}
  end

  def display_hi_temps
    puts "Daliy high temperatures for the next #{number_of_days} days"
    hi_temps.each_with_index { |temp, index| puts "#{dates[index]}: #{temp}" }
  end

  def display_lo_temps
    puts "Daliy low temperatures for the next #{number_of_days} days"
    lo_temps.each_with_index { |temp, index| puts "#{dates[index]}: #{temp}" }
  end

  def display_todays_forecast
    puts "Today's forecast:"
    puts
    puts "High Temp: #{today[:high_temp]} degrees"
    puts "Low Temp: #{today[:low_temp]} degrees"
    puts "Clouds/Precipitation: #{today[:weather_description]}"
    puts "humidity: #{today[:humidity]}%"
    puts "Wind Speed: #{today[:wind_speed]}"
  end

  def display_tomorrows_forecast
    puts "Today's forecast:"
    puts
    puts "High Temp: #{tomorrow[:high_temp]} degrees"
    puts "Low Temp: #{tomorrow[:low_temp]} degrees"
    puts "Clouds/Precipitation: #{tomorrow[:weather_description]}"
    puts "humidity: #{tomorrow[:humidity]}%"
    puts "Wind Speed: #{tomorrow[:wind_speed]}"
  end

  private

  def raw_response
    #16 day forecast seems to now require a paid account; this is for 5 day / 3 hour, which works free of charge
    @results = HTTParty.get("#{BASE_URI}data/2.5/forecast?id=#{location}&units=imperial&cnt=#{number_of_days}&APPID=#{API_KEY}")
    save_results(results)
  end

  def hi_temps
    parse_results['list'].map do |day|
      day['main']['temp_max']
    end
  end

  def lo_temps
    parse_results['list'].map do |day|
      day['main']['temp_min']
    end
  end

  def dates
    parse_results['list'].map do |day|
      day['dt_txt'].split(' ')[0]
    end
  end

  def weather_descriptions
    parse_results['list'].map do |day|
      day['weather'][0]['description']
    end
  end

  def humidity
    parse_results['list'].map do |day|
      day['main']['humidity']
    end
  end

  def wind_speed
    parse_results['list'].map do |day|
      day['wind']['speed']
    end
  end

  def today
    { high_temp: hi_temps[0], low_temp: lo_temps[0], weather_description: weather_descriptions[0], 
      humidity: humidity[0], wind_speed: wind_speed[0]  }
  end

  def tomorrow
    { high_temp: hi_temps[1], low_temp: lo_temps[1], weather_description: weather_descriptions[1], 
      humidity: humidity[1], wind_speed: wind_speed[1]  }
  end

   def save_results(response)
    File.open('results.json',"w") do |f|
      f.write(response)
    end
  end

  def parse_results
    JSON.parse(File.read('results.json'))
  end
end

w = WeatherForecast.new