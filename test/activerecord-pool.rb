require 'active_record'

options = YAML.load_file(File.expand_path('../../spec/database.yml', __FILE__))
ActiveRecord::Base.establish_connection(options)

threads = []
10.times do |n|
  threads << Thread.new {
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      res = conn.execute('select sleep(1)')
    end
  }
end

threads.each{|t| t.join }

# time ruby activerecord-pool.rb