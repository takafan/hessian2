require File.expand_path('../establish_connection',  __FILE__)
require File.expand_path('../monkey',  __FILE__)

ActiveRecord::Base.connection.execute("truncate table #{Monkey.table_name}")

now = Time.new
1.upto(1000).each do |i|
  Monkey.create(
    id: i, 
    name: "#{i}号猴",
    price: 0.25 * i, 
    born_at: now - 3600 * (1000 - i)
  )
end
