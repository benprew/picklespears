require 'db'
require 'rubygems'
gem 'activerecord'
require 'activerecord'
require 'team'
require 'player'

class PlayersGame < ActiveRecord::Base
  belongs_to :player
  belongs_to :game
end

class Game < ActiveRecord::Base
  belongs_to :team
  has_many :players_games
  has_many :players, :through => :players_games

  def num_guys_confirmed
    players_games.each.map { |pg| pg.status == 'yes' ? 1 : 0 }.sum
  end

  def num_gals_confirmed
    players_games.each.map { |pg| pg.status == 'yes' ? 1 : 0 }.sum
  end
end

