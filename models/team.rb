require 'date'
require_relative 'division'
require_relative 'player'
require_relative 'game'

class Team < Sequel::Model
  many_to_one :division
  one_to_many :games
  one_to_many :players_teams
  many_to_many :players, :join_table => :players_teams

  def upcoming_games
    Game.filter(:team_id => self.id).filter{ date >= Date.today()}.order(:date.asc).all
  end

  def next_game
    upcoming_games.first
  end

  def self.create_test(attrs={})
    team = Team.new(:division_id => 1, :name => 'test team')
    team.save
    team.update(attrs) if attrs
    team.save
    return team
  end
end
