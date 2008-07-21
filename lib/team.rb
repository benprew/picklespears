require 'db'
require 'date'
require 'division'
require 'player'
require 'game'

class PlayersTeam
  include DataMapper::Resource
  belongs_to :player
  belongs_to :team

  property :player_id, Integer, :key => true
  property :team_id, Integer, :key => true
end

class Team
  include DataMapper::Resource

  belongs_to :division
  has n, :games
  has n, :players_teams
  has n, :players, :through => :players_teams

  property :id, Integer, :serial => true
  property :name, String
  property :division_id, Integer, :nullable => false

  def next_unreminded_game
    games.first( :date.gte => Date.today(), :reminder_sent => false, :order => [ :date.asc ] )
  end

  def upcoming_games
    games.all( :date.gte => Date.today(), :order => [ :date.asc ] )
  end

  def next_game
    games.first( :date.gte => Date.today(), :order => [ :date.asc ] )
  end
end

