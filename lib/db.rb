require 'rubygems'
gem 'activerecord'
require 'activerecord'
require 'mysql'

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql",
  :host     => "localhost",
  :username => "rails_user",
  :password => "foo",                                        
  :database => "rails_development"
)
