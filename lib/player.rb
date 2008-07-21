require 'db'
require 'team'
require 'game'

class Player
  include DataMapper::Resource

  has n, :players_teams
  has n, :teams, :through => :players_teams
  has n, :players_games
  has n, :games, :through => :players_games

  property :id, Integer, :serial => true
  property :name, String, :nullable => false
  property :email_address, String, :nullable => false
  property :phone_number, String
  property :is_sub, Boolean
  property :password, String, :nullable => false
  property :birthdate, String
  property :zipcode, String

  def self.login( email_address, password )
    return Player.first(:email_address => email_address, :password => password)
  end
end
