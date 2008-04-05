require 'db'
require 'rubygems'
gem 'activerecord'
require 'activerecord'
require 'game'
require 'division'
require 'player'

class Team < ActiveRecord::Base
  has_many :games
  belongs_to :division
  has_and_belongs_to_many :players
end
