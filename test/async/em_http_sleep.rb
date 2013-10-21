require File.expand_path('../../prepare', __FILE__)
require 'eventmachine'
require 'em-synchrony/em-http'

EM.run do
  @number_of.times do |i|
    puts i
    http = EM::HttpRequest.new("http://127.0.0.1:8080/sleep").apost
    http.callback do |r| 
      puts 'callback' 
      @results << r.response
      EM.stop if @results.size >= @number_of
    end

    http.errback do |r|
      puts "errback #{r.error}"
      EM.stop
    end
  end

  puts "results.size #{@results.size}"
end

puts @results.inspect
puts "results.size #{@results.size}"
