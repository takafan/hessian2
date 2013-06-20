require 'active_record'
require 'mysql2'

options = YAML.load_file(File.expand_path('../options.yml', __FILE__))
ActiveRecord::Base.establish_connection(options['mysql'])
ActiveRecord::Base.default_timezone = :local
ActiveRecord::Base.time_zone_aware_attributes = true
