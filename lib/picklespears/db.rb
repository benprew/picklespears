require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'yaml'

def make_connect_string(db_config, environment)
  # for Heroku
  return ENV['DATABASE_URL'] if ENV['DATABASE_URL']

  db_info = db_config[environment.to_s]

  if db_info['adapter'] == 'sqlite3'
    return sprintf "%s:%s", db_info['adapter'], db_info['database']
  else
    return sprintf "%s://%s:%s@localhost/%s", db_info['adapter'], db_info['username'], db_info['password'], db_info['database']
  end
end

db_config = YAML::load File.open(File.dirname(__FILE__) + '/../../config/database.yml')

if test?
  DataMapper.setup(:default, make_connect_string(db_config, :test))
elsif production?
  DataMapper.setup(:default, make_connect_string(db_config, :production))
else
  DataMapper.setup(:default, make_connect_string(db_config, :development))
end
