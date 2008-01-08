require 'db'
require 'rubygems'
gem 'activerecord'
require 'activerecord'
require 'team'

class Game < ActiveRecord::Base
  belongs_to :team
end

