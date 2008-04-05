require 'db'
require 'rubygems'
gem 'activerecord'
require 'activerecord'
require 'team'

class Player < ActiveRecord::Base
  has_and_belongs_to_many :players
end
