require 'date'
require_relative 'team'
require_relative 'player'
require_relative 'players_game'

class Game < Sequel::Model
  many_to_one :team
  one_to_many :players_games
  many_to_many :players, :join_table => :players_games

  def num_players_going
    players_games.inject(0) do |sum, pg|
      pg.status == "yes" ? sum + 1 : sum
    end
  end

  def num_guys_confirmed
    players_games.inject(0) do |sum, pg|
      pg.status == "yes" && pg.player.gender == "guy" ? sum + 1 : sum
    end
  end

  def num_gals_confirmed
    players_games.inject(0) do |sum, pg|
      pg.status == 'yes' && pg.player.gender == 'gal' ? sum + 1 : sum
    end
  end

  def self.create_test(attrs={})
    game = Game.new(
      :date => Date.today(),
      :description => 'test game',
      :team_id => 1
    )
    game.update(attrs) if attrs
    game.save
    return game
  end
end
