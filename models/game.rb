require 'date'
require_relative 'team'
require_relative 'teams_game'

class Game < Sequel::Model
  one_to_many :players_games
  many_to_many :players, join_table: :players_games
  many_to_one :seasons
  many_to_many :teams, join_table: :teams_games, select: Team.columns + [ :name, :is_home_team, :has_coed_bonus_point, :goals_scored ]

  def division
    teams.first.division if teams
  end

  def num_players_going
    players_games.reduce(0) do |sum, pg|
      pg.status == 'yes' ? sum + 1 : sum
    end
  end

  def num_guys_confirmed
    players_games.reduce(0) do |sum, pg|
      pg.status == 'yes' && pg.player.gender == 'guy' ? sum + 1 : sum
    end
  end

  def num_gals_confirmed
    players_games.reduce(0) do |sum, pg|
      pg.status == 'yes' && pg.player.gender == 'gal' ? sum + 1 : sum
    end
  end

  def self.create_test(attrs = {})
    game = Game.new(
      date: Date.today,
      description: 'test game')
    game.save
    game.update(attrs) if attrs
    game.save
  end

  def home_team=(team_to_add)
    add_new_team(team_to_add, true)
  end

  def home_team
    teams.select { |t| t[:is_home_team] }.first
  end

  def away_team=(team_to_add)
    add_new_team(team_to_add, false)
  end

  def away_team
    teams.select { |t| !t[:is_home_team] }.first
  end

  # Since a game has N teams, we want the team the player cares
  # about. This assumes that a player is only on one team in a
  # game
  def team_player_plays_on(player)
    teams.select { |t| player.teams.include?(t) }.first
  end

  private

  # TODO: make add_team private, since you should always call
  # home_team= or away_team=

  def add_new_team(team_to_add, is_home)
    tg = TeamsGame.find(game_id: id, is_home_team: is_home)
    tg && tg.delete
    TeamsGame.create(game_id: id, team_id: team_to_add.id, is_home_team: is_home).save
  end
end
