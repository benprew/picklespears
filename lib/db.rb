require 'rubygems'
gem 'dm-core'
require 'dm-core'

DataMapper.setup(:default, 'mysql://rails_user:foo@localhost/rails_development')
