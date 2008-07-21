require 'db'
require 'team'
require 'player'

class PlayersGame
  include DataMapper::Resource
  belongs_to :player
  belongs_to :game

  property :player_id, Integer, :key => true
  property :game_id, Integer, :key => true
  property :status, String
end

class Game
  include DataMapper::Resource
  belongs_to :team
  has n, :players_games
  has n, :players, :through => :players_games

  property :id, Integer, :serial => true
  property :date, Date, :nullable => false
  property :description, String, :nullable => false
  property :team_id, Integer, :nullable => false
  property :reminder_sent, Boolean, :nullable => false, :default => false

  def num_guys_confirmed
    players_games.all.reduce { |sum, pg| pg.status == 'yes' ? sum + 1 : sum } || 0
  end

  def num_gals_confirmed
    players_games.all.reduce { |sum, pg| pg.status == 'yes' ? sum + 1 : sum } || 0
  end
end

