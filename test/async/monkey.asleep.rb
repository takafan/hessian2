require File.expand_path('../../prepare', __FILE__)
require 'eventmachine'

client = Hessian2::Client.new('http://127.0.0.1:8080/', async: true)

EM.run do
  @number_of.times do |i|
    puts i
    http = client.asleep
    http.callback do |r|
      puts 'callback'
      @results << Hessian2.parse_rpc(r.response)
      EM.stop if @results.size >= @number_of
    end

    http.errback do |r|
      puts "errback #{r.error}"
      @results << nil
      EM.stop
    end
  end

  puts "results.size #{@results.size}"
end

puts @results.inspect
puts "results.size #{@results.size}"
