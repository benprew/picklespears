require 'date'
require_relative 'division'
require_relative 'player'
require_relative 'game'

class Team
  include DataMapper::Resource

  belongs_to :division
  has n, :games
  has n, :players_teams
  has n, :players, :through => :players_teams

  property :id, Serial
  property :name, String
  property :division_id, Integer, :required => true

  def upcoming_games
    games.all( :date.gte => Date.today(), :order => [ :date.asc ] )
  end

  def next_game
    games.first( :date.gte => Date.today(), :team_id => self.id, :order => [ :date.asc ] )
  end

  def self.create_test(attrs={})
    team = Team.new(:division_id => 1)
    team.save
    team.update(attrs) if attrs
    team.save
    return team
  end
end

