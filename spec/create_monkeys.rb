require File.expand_path('../spec_helper',  __FILE__)

ActiveRecord::Base.connection.execute("drop table if exists monkeys")
ActiveRecord::Base.connection.execute("create table monkeys(id integer(11) not null auto_increment, born_at datetime, name varchar(255), price decimal(10, 2), primary key(id)) charset=utf8")

born_at = Time.new(1989, 5, 8)
1000.times.each do |i|
  Monkey.create(
    id: i + 1, 
    name: "#{i}号猴",
    price: 0.25 * i, 
    born_at: born_at + 86400 * i
  )
end
