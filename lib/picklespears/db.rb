require 'rubygems'
require 'dm-core'

# default to a dev connection
DataMapper.setup(:default, 'sqlite3:///tmp/dev_db')

configure :production do
  DataMapper.setup(:default, 'mysql://rails_user:foo@localhost/rails_development')
end

configure :test do
  DataMapper.setup(:default, 'sqlite3:///tmp/test_db')
  DataMapper.auto_migrate!
end

configure :development do
  DataMapper.setup(:default, 'sqlite3:///tmp/dev_db')
end
