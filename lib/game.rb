require 'date'
require 'team'
require 'player'
require 'players_game'

class Game
  include DataMapper::Resource
  belongs_to :team
  has n, :players_games
  has n, :players, :through => :players_games

  property :id, Serial
  property :date, Date, :nullable => false
  property :description, String, :nullable => false
  property :team_id, Integer, :nullable => false
  property :reminder_sent, Boolean, :nullable => false, :default => false

  def num_guys_confirmed
    players_games.all.inject(0) do |sum, pg|
      pg.status == "yes" && pg.player.gender == "guy" ? sum + 1 : sum
    end
  end

  def num_gals_confirmed
    players_games.all.inject(0) do |sum, pg|
      pg.status == 'yes' && pg.player.gender == 'gal' ? sum + 1 : sum
    end
  end

  def self.create_test(attrs={})
    game = Game.new(
      :date => Date.today(),
      :description => 'test game',
      :team_id => 1
    )
    game.save
    game.update(attrs) if attrs
    game.save
    return game
  end
end

