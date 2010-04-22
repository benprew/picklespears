require 'rubygems'
require 'dm-core'
require 'yaml'

def make_connect_string(db_config, environment)
  db_info = db_config[environment.to_s]
  return sprintf "%s://%s:%s@localhost/%s", db_info['adapter'], db_info['username'], db_info['password'], db_info['database']
end

db_config = YAML::load File.open(File.dirname(__FILE__) + '/../../config/database.yml')

if test?
  DataMapper.setup(:default, 'sqlite3:///tmp/test_db')
  DataMapper.auto_migrate!
elsif production?
  DataMapper.setup(:default, make_connect_string(db_config, :production))
else
  DataMapper.setup(:default, make_connect_string(db_config, :development))
end
