require 'db'
require 'rubygems'
gem 'activerecord'
require 'activerecord'
require 'team'
require 'game'

class Player < ActiveRecord::Base
  has_and_belongs_to_many :teams
  has_many :players_games
  has_many :games, :through => :players_games

  def self.login( email_address, password )
    return Player.find(:first, :conditions => [ "email_address = ? AND password = ? ", email_address, password ])
  end
end
