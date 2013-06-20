require File.expand_path('../establish_connection',  __FILE__)

ActiveRecord::Base.connection.execute("drop table if exists monkeys")
ActiveRecord::Base.connection.execute("create table monkeys(id integer(11) not null auto_increment, born_at datetime, name varchar(255), price decimal(10, 2), primary key(id)) charset=utf8")
