require 'db'
require 'rubygems'
gem 'activerecord'
require 'activerecord'
require 'game'
require 'division'

class Team < ActiveRecord::Base
  has_many :games
  belongs_to :division
end
