require 'rubygems'
require 'dm-core'
require 'date'
require 'division'
require 'player'
require 'game'

class Team
  include DataMapper::Resource

  belongs_to :division
  has n, :games
  has n, :players_teams
  has n, :players, :through => :players_teams

  property :id, Integer, :serial => true
  property :name, String
  property :division_id, Integer, :nullable => false

  def upcoming_games
    games.all( :date.gte => Date.today(), :order => [ :date.asc ] )
  end

  def next_game
    games.first( :date.gte => Date.today(), :team_id => self.id, :order => [ :date.asc ] )
  end

  def self.create_test(attrs={})
    team = Team.new(:division_id => 1)
    team.update_attributes(attrs) if attrs
    team.save
    return team
  end
end

